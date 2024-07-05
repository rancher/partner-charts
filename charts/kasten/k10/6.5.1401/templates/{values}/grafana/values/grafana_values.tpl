{{/*
  With some of K10's features being provided by external Helm charts, those Helm
  charts need to be configured to work with K10.

  Unfortunately, some of the values needed to configure the subcharts aren't
  accessible to the subcharts (only global.* and chart_name.* are accessible).

  This means the values need to be duplicated, making the configuration of K10
  quite cumbersome for users (the same setting has to be provided in multiple
  places, making it easy to misconfigure one thing or another).

  Alternatively, the subchart's templates could be customized to read global.*
  values instead. However, this means upgrading the subchart is quite burdensome
  since the customizations have to be re-applied to the upgraded chart. This is
  even less tenable with the frequency with which chart updates are needed.

  With this in mind, this template was specially crafted to be able to read K10
  values and update the values that will be passed to the subchart.

  ---

  To accomplish this, Helm's template parsing and rendering order is exploited.

  Helm allows parent charts to override templates in subcharts. This is done by
  parsing templates with lower precedence first (templates that are more deeply
  nested than others). This allows templates with higher precedence to redefine
  templates with lower precedence.

  Helm also renders templates in this same order. This template exploits this
  ordering in order to set subchart values before the subchart's templates are
  rendered, having the same effect as the user setting the values.

  WARNING: The name and directory structure of this template was carefully
  selected to ensure that it is rendered before other templates!
*/}}

{{- if .Values.grafana.enabled }}
{{- $grafana_prefix := printf "%s/grafana/" (include "k10.prefixPath" $) -}}
{{- $grafana_scoped_values := (dict "Chart" (dict "Name" "grafana") "Release" .Release "Values" .Values.grafana) -}}

{{- /*** GRAFANA LABELS ***/ -}}
{{- $_ := mergeOverwrite .Values.grafana
  (dict
    "extraLabels" (dict
      "app.kubernetes.io/name" (include "grafana.name" $grafana_scoped_values)
      "app.kubernetes.io/instance" .Release.Name
      "component" "grafana"
    )
    "podLabels" (dict
      "component" "grafana"
    )
  )
-}}

{{- /*** GRAFANA SERVER CONFIGURATION ***/ -}}
{{- $_ := mergeOverwrite (index .Values.grafana "grafana.ini")
    (dict
      "auth" (dict
        "disable_login_form" true
        "disable_signout_menu" true
      )
      "auth.basic" (dict
        "enabled" false
      )
      "auth.anonymous" (dict
        "enabled" true
      )
      "server" (dict
        "root_url" $grafana_prefix
      )
    )
-}}
{{- $authAnonymous := index .Values.grafana "grafana.ini" "auth.anonymous" -}}
{{- $_ := set $authAnonymous "org_name" ($authAnonymous.org_name | default "Main Org.") -}}
{{- $_ := set $authAnonymous "org_role" ($authAnonymous.org_role | default "Admin") -}}

{{- /*** GRAFANA DEPLOYMENT STRATEGY ***/ -}}
{{- $_ := set .Values.grafana.deploymentStrategy "type" "Recreate" -}}

{{- /*** GRAFANA NETWORKING POLICY ***/ -}}
{{- $_ := set .Values.grafana.networkPolicy "enabled" true -}}

{{- /*** GRAFANA TEST FRAMEWORK ***/ -}}
{{- $_ := set .Values.grafana.testFramework "enabled" false -}}

{{- /*** GRAFANA RBAC ***/ -}}
{{- $_ := set .Values.grafana.rbac "namespaced" true -}}

{{- /*** K10 PROMETHEUS DATASOURCE ***/ -}}
{{- $_ := set .Values.grafana.datasources
  "datasources.yaml" (dict
    "apiVersion" 1
    "datasources" (list
      (dict
        "access" "proxy"
        "editable" false
        "isDefault" true
        "name" "Prometheus"
        "type" "prometheus"
        "url" (printf "http://%s-exp%s" (include "k10.prometheus.service.name" $) .Values.prometheus.server.baseURL)
        "jsonData" (dict
          "timeInterval" "1m"
        )
      )
    )
  )
-}}

{{- /*** K10 DASHBOARD ***/ -}}
{{- $_ := set .Values.grafana.dashboards
  "default" (dict
    "default" (dict
      "json" (.Files.Get "grafana/dashboards/default/default.json")
    )
  )
-}}

{{- $_ := mergeOverwrite (index .Values.grafana "grafana.ini")
    (dict
      "dashboards" (dict
        "default_home_dashboard_path" "/var/lib/grafana/dashboards/default/default.json"
      )
    )
-}}

{{- $_ := set .Values.grafana.dashboardProviders
  "dashboardproviders.yaml" (dict
    "apiVersion" 1
    "providers" (list
      (dict
        "name" "default"
        "orgId" 1
        "folder" ""
        "type" "file"
        "disableDeletion" true
        "editable" false
        "options" (dict
          "path" "/var/lib/grafana/dashboards"
        )
      )
    )
  )
-}}

{{- /*** K10 PERSISTENCE ***
    - global.persistence.enabled
    - global.persistence.accessMode
    - global.persistence.storageClass
    - global.persistence.grafana.size
    - global.persistence.size
*/ -}}
{{- if .Values.global.persistence.enabled -}}
  {{ $grafana_storage_class := dict }}
  {{- if eq .Values.global.persistence.storageClass "-" -}}
    {{ $grafana_storage_class = (dict "storageClassName" "") }}
  {{- else if .Values.global.persistence.storageClass -}}
    {{ $grafana_storage_class = (dict "storageClassName" .Values.global.persistence.storageClass) }}
  {{- end -}}

  {{- $_ := mergeOverwrite .Values.grafana.persistence
    $grafana_storage_class
    (dict
      "enabled" true
      "accessModes" (list .Values.global.persistence.accessMode)
      "size" (.Values.global.persistence.grafana.size | default .Values.global.persistence.size)
    )
  -}}
{{- end -}}

{{- /*** K10 IMAGE PULL SECRETS ***
    - secrets.dockerConfig
    - secrets.dockerConfigPath
    - global.imagePullSecret
*/ -}}
{{- $image_pull_secrets := list -}}
{{- if .Values.global.imagePullSecret -}}
  {{- $image_pull_secrets = append $image_pull_secrets .Values.global.imagePullSecret -}}
{{- end -}}
{{- if (or .Values.secrets.dockerConfig .Values.secrets.dockerConfigPath) -}}
  {{ $image_pull_secrets = append $image_pull_secrets "k10-ecr" -}}
{{- end -}}
{{- $image_pull_secrets = $image_pull_secrets | compact | uniq -}}

{{- if $image_pull_secrets -}}
  {{- $image_pull_secrets = concat (.Values.grafana.image.pullSecrets | default list) $image_pull_secrets -}}
  {{- $_ := set .Values.grafana.image "pullSecrets" $image_pull_secrets -}}
{{- end -}}

{{- /*** K10 GRAFANA IMAGE ***
    - global.airgapped.repository
    - global.image.registry
    - global.image.tag
    - global.images.grafana
*/ -}}
{{- $grafana_image := (dict
    "registry" (.Values.global.airgapped.repository | default .Values.global.image.registry)
    "repository" "grafana"
    "tag" (include "get.k10ImageTag" $)
) -}}
{{- if .Values.global.images.grafana -}}
  {{- $grafana_image_args := (dict "image" .Values.global.images.grafana "path" "global.images.grafana") -}}
  {{- $grafana_image = (include "k10.splitImage" $grafana_image_args) | fromJson -}}
{{- end -}}

{{- if .Values.global.azMarketPlace -}}
  {{- $grafana_image = ( dict
            "registry" .Values.global.azure.images.grafana.registry
            "repository" .Values.global.azure.images.grafana.image
            "tag" .Values.global.azure.images.grafana.tag
      ) 
  -}}
{{- end -}}

{{- $_ := set .Values.grafana.image "registry" $grafana_image.registry -}}
{{- $_ := set .Values.grafana.image "repository" $grafana_image.repository -}}
{{- $_ := set .Values.grafana.image "tag" $grafana_image.tag -}}
{{- $_ := set .Values.grafana.image "sha" $grafana_image.sha -}}

{{- /*** K10 INIT IMAGE ***
    - global.airgapped.repository
    - global.image.registry
    - global.image.tag
    - global.images.init
*/ -}}
{{- $init_image := (dict
  "registry" (.Values.global.airgapped.repository | default .Values.global.image.registry)
  "repository" "init"
  "tag" (include "get.k10ImageTag" $)
) -}}

{{- if .Values.global.images.init -}}
  {{- $init_image_args := (dict "image" .Values.global.images.init "path" "global.images.init") -}}
  {{- $init_image = (include "k10.splitImage" $init_image_args) | fromJson -}}
{{- end -}}

{{- if .Values.global.azMarketPlace -}}
  {{- $init_image = ( dict
            "registry" .Values.global.azure.images.init.registry
            "repository" .Values.global.azure.images.init.image
            "tag" .Values.global.azure.images.init.tag
      ) 
  -}}
{{- end -}}

{{- $_ := set .Values.grafana.downloadDashboardsImage "registry" $init_image.registry -}}
{{- $_ := set .Values.grafana.downloadDashboardsImage "repository" $init_image.repository -}}
{{- $_ := set .Values.grafana.downloadDashboardsImage "tag" $init_image.tag -}}
{{- $_ := set .Values.grafana.downloadDashboardsImage "sha" $init_image.sha -}}

{{- $_ := set .Values.grafana.initChownData.image "registry" $init_image.registry -}}
{{- $_ := set .Values.grafana.initChownData.image "repository" $init_image.repository -}}
{{- $_ := set .Values.grafana.initChownData.image "tag" $init_image.tag -}}
{{- $_ := set .Values.grafana.initChownData.image "sha" $init_image.sha -}}

{{- /*** K10 SERVICE ***/ -}}
{{- $_ := set .Values.grafana.service.annotations
  "getambassador.io/config" (dict
    "apiVersion" "getambassador.io/v3alpha1"
    "kind" "Mapping"
    "name" "grafana-server-mapping"
    "prefix" $grafana_prefix
    "rewrite" "/"
    "service" (printf "%s-grafana:%0.f" .Release.Name .Values.grafana.service.port)
    "timeout_ms" 15000
    "hostname" "*"
    "ambassador_id" (list
      (include "k10.ambassadorId" nil | replace "\"" "")
    )
  | toYaml)
-}}
{{- end }}
