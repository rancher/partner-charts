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

{{- if .Values.prometheus.server.enabled }}
{{- $prometheus_scoped_values := (dict "Chart" (dict "Name" "prometheus") "Release" .Release "Values" .Values.prometheus) -}}

{{- $prometheus_name := (include "prometheus.name" $prometheus_scoped_values) -}}
{{- $prometheus_prefix := "/k10/prometheus/" -}}
{{- $release_name := .Release.Name -}}

{{- /*** PROMETHEUS LABELS ***/ -}}
{{- $_ := mergeOverwrite .Values.prometheus
  (dict
    "commonMetaLabels" (dict
      "app.kubernetes.io/name" $prometheus_name
      "app.kubernetes.io/instance" $release_name
    )
  )
-}}

{{- /*** PROMETHEUS SERVER OVERRIDES ***/ -}}
{{- $fullnameOverride := .Values.prometheus.server.fullnameOverride | default "prometheus-server" -}}
{{- $clusterRoleNameOverride := .Values.prometheus.server.clusterRoleNameOverride | default (printf "%s-%s" .Release.Name $fullnameOverride) -}}
{{- $_ := mergeOverwrite .Values.prometheus.server
  (dict
    "baseURL" (.Values.prometheus.server.baseURL | default $prometheus_prefix)
    "prefixURL" (.Values.prometheus.server.prefixURL | default $prometheus_prefix | trimSuffix "/")

    "clusterRoleNameOverride" $clusterRoleNameOverride
    "configMapOverrideName" "k10-prometheus-config"
    "fullnameOverride" $fullnameOverride
  )
-}}

{{- /*** K10 PROMETHEUS CONFIGMAP-RELOAD IMAGE ***
    - global.airgapped.repository
    - global.image.registry
    - global.image.tag
    - global.images.configmap-reload
*/ -}}
{{- $prometheus_configmap_reload_image := (dict
    "registry" (.Values.global.airgapped.repository | default .Values.global.image.registry)
    "repository" "configmap-reload"
    "tag" (include "get.k10ImageTag" $)
) -}}

{{- if (index .Values.global.images "configmap-reload") -}}
  {{- $prometheus_configmap_reload_image = (
        include "k10.splitImage" (dict
          "image" (index .Values.global.images "configmap-reload")
          "path" "global.images.configmap-reload"
        )
      ) | fromJson
  -}}
{{- end -}}

{{- if .Values.global.azMarketPlace -}}
  {{- $prometheus_configmap_reload_image = (dict
      "registry" .Values.global.azure.images.configmapreload.registry
      "repository" .Values.global.azure.images.configmapreload.image
      "tag" .Values.global.azure.images.configmapreload.tag
      ) 
  -}}
{{- end -}}

{{- $_ := mergeOverwrite .Values.prometheus.configmapReload.prometheus.image
  (dict
    "repository" (list $prometheus_configmap_reload_image.registry $prometheus_configmap_reload_image.repository | compact | join "/")
    "tag" $prometheus_configmap_reload_image.tag
    "digest" $prometheus_configmap_reload_image.digest
  )
-}}

{{- /*** K10 PROMETHEUS SERVER IMAGE ***
    - global.airgapped.repository
    - global.image.registry
    - global.image.tag
    - global.images.prometheus
*/ -}}
{{- $prometheus_server_image := (dict
    "registry" (.Values.global.airgapped.repository | default .Values.global.image.registry)
    "repository" "prometheus"
    "tag" (include "get.k10ImageTag" $)
) -}}
{{- if .Values.global.images.prometheus -}}
  {{- $prometheus_server_image = (
        include "k10.splitImage" (dict
          "image" .Values.global.images.prometheus
          "path" "global.images.prometheus"
        )
      ) | fromJson
  -}}
{{- end -}}

{{- if .Values.global.azMarketPlace -}}
  {{- $prometheus_server_image = ( dict
            "registry" .Values.global.azure.images.prometheus.registry
            "repository" .Values.global.azure.images.prometheus.image
            "tag" .Values.global.azure.images.prometheus.tag
      ) 
  -}}
{{- end -}}

{{- $_ := mergeOverwrite .Values.prometheus.server.image
  (dict
    "repository" (list $prometheus_server_image.registry $prometheus_server_image.repository | compact | join "/")
    "tag" $prometheus_server_image.tag
    "digest" $prometheus_server_image.digest
  )
-}}

{{- /*** K10 IMAGE PULL SECRETS ***
    - secrets.dockerConfig
    - secrets.dockerConfigPath
    - global.imagePullSecret
*/ -}}
{{- $image_pull_secret_names := list -}}
{{- if .Values.global.imagePullSecret -}}
  {{- $image_pull_secret_names = append $image_pull_secret_names .Values.global.imagePullSecret -}}
{{- end -}}
{{- if (or .Values.secrets.dockerConfig .Values.secrets.dockerConfigPath) -}}
  {{ $image_pull_secret_names = append $image_pull_secret_names "k10-ecr" -}}
{{- end -}}
{{- $image_pull_secret_names = $image_pull_secret_names | compact | uniq -}}

{{- if $image_pull_secret_names -}}
  {{- $image_pull_secrets := .Values.prometheus.imagePullSecrets | default list -}}
  {{- range $name := $image_pull_secret_names -}}
    {{- $image_pull_secrets = append $image_pull_secrets (dict "name" $name) -}}
  {{- end -}}
  {{- $_ := set .Values.prometheus "imagePullSecrets" $image_pull_secrets -}}
{{- end -}}

{{- /*** K10 PERSISTENCE ***
    - global.persistence.storageClass
*/ -}}
{{- $_ := mergeOverwrite .Values.prometheus.server.persistentVolume
  (dict
    "storageClass" (.Values.prometheus.server.persistentVolume.storageClass | default .Values.global.persistence.storageClass)
  )
-}}
{{- end }}
