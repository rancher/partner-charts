{{/*
Expand the name of the chart.
*/}}
{{- define "perf-advisor-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "perf-advisor-chart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "perf-advisor-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "perf-advisor-chart.labels" -}}
helm.sh/chart: {{ include "perf-advisor-chart.chart" . }}
{{ include "perf-advisor-chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "perf-advisor-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "perf-advisor-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common labels template - applies user-defined common labels to all resources
*/}}
{{- define "perf-advisor-chart.commonLabels" -}}
{{- $commonLabels := .Values.commonLabels | default dict -}}
{{- if $commonLabels -}}
{{- toYaml $commonLabels -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "perf-advisor-chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "perf-advisor-chart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Get the full image name for perf-advisor with registry override support.

The preference is to use image.commonRegistry first if it is set.
Otherwise the image.perfAdvisor.registry is used if set.
If neither is set, falls back to perfAdvisor.image from values.

The image name defaults to perfAdvisor.image if image.perfAdvisor.name is not set.
The tag defaults to perfAdvisor.version if image.perfAdvisor.tag is not set.
*/}}
{{- define "perf-advisor-chart.perfAdvisorImage" -}}
  {{- $registry := "" -}}
  {{- $imageName := .Values.perfAdvisor.image -}}
  {{- $tag := .Values.perfAdvisor.version -}}
  
  {{- /* Determine registry: commonRegistry > perfAdvisor.registry */ -}}
  {{- if not (empty .Values.image.commonRegistry) -}}
    {{- $registry = .Values.image.commonRegistry -}}
    {{- /* If registry override is set, extract image name without existing registry */ -}}
    {{- $parts := splitList "/" $imageName -}}
    {{- if gt (len $parts) 1 -}}
      {{- $imageName = join "/" (rest $parts) -}}
    {{- end -}}
  {{- else if not (empty .Values.image.perfAdvisor.registry) -}}
    {{- $registry = .Values.image.perfAdvisor.registry -}}
    {{- /* If registry override is set, extract image name without existing registry */ -}}
    {{- $parts := splitList "/" $imageName -}}
    {{- if gt (len $parts) 1 -}}
      {{- $imageName = join "/" (rest $parts) -}}
    {{- end -}}
  {{- end -}}
  
  {{- /* Override image name if specified */ -}}
  {{- if not (empty .Values.image.perfAdvisor.name) -}}
    {{- $imageName = .Values.image.perfAdvisor.name -}}
  {{- end -}}
  
  {{- /* Override tag if specified */ -}}
  {{- if not (empty .Values.image.perfAdvisor.tag) -}}
    {{- $tag = .Values.image.perfAdvisor.tag -}}
  {{- end -}}
  
  {{- /* Construct full image reference */ -}}
  {{- if not (empty $registry) -}}
    {{- printf "%s/%s:%s" $registry $imageName $tag -}}
  {{- else -}}
    {{- printf "%s:%s" $imageName $tag -}}
  {{- end -}}
{{- end -}}

{{/*
Get the full image name for postgres with registry override support.

The preference is to use image.commonRegistry first if it is set.
Otherwise the image.postgres.registry is used if set.
If neither is set, falls back to postgres.image from values.
*/}}
{{- define "perf-advisor-chart.postgresImage" -}}
  {{- $registry := "" -}}
  {{- $parts := splitList ":" .Values.postgres.image -}}
  {{- $imageName := first $parts -}}
  {{- $tag := "" -}}
  {{- if eq (len $parts) 2 -}}
    {{- $tag = last $parts -}}
  {{- end -}}
  
  {{- /* Determine registry: commonRegistry > postgres.registry */ -}}
  {{- if not (empty .Values.image.commonRegistry) -}}
    {{- $registry = .Values.image.commonRegistry -}}
  {{- else if not (empty .Values.image.postgres.registry) -}}
    {{- $registry = .Values.image.postgres.registry -}}
  {{- end -}}
  
  {{- /* Override image name if specified */ -}}
  {{- if not (empty .Values.image.postgres.name) -}}
    {{- $imageName = .Values.image.postgres.name -}}
  {{- end -}}
  
  {{- /* Override tag if specified */ -}}
  {{- if not (empty .Values.image.postgres.tag) -}}
    {{- $tag = .Values.image.postgres.tag -}}
  {{- end -}}
  
  {{- /* Construct full image reference */ -}}
  {{- if not (empty $registry) -}}
    {{- if not (empty $tag) -}}
      {{- printf "%s/%s:%s" $registry $imageName $tag -}}
    {{- else -}}
      {{- printf "%s/%s" $registry $imageName -}}
    {{- end -}}
  {{- else -}}
    {{- if not (empty $tag) -}}
      {{- printf "%s:%s" $imageName $tag -}}
    {{- else -}}
      {{- printf "%s" $imageName -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Get the full image name for prometheus with registry override support.

The preference is to use image.commonRegistry first if it is set.
Otherwise the image.prometheus.registry is used if set.
If neither is set, falls back to prometheus.image from values.
*/}}
{{- define "perf-advisor-chart.prometheusImage" -}}
  {{- $registry := "" -}}
  {{- $parts := splitList ":" .Values.prometheus.image -}}
  {{- $imageName := first $parts -}}
  {{- $tag := "" -}}
  {{- if eq (len $parts) 2 -}}
    {{- $tag = last $parts -}}
  {{- end -}}
  
  {{- /* Determine registry: commonRegistry > prometheus.registry */ -}}
  {{- if not (empty .Values.image.commonRegistry) -}}
    {{- $registry = .Values.image.commonRegistry -}}
  {{- else if not (empty .Values.image.prometheus.registry) -}}
    {{- $registry = .Values.image.prometheus.registry -}}
  {{- end -}}
  
  {{- /* Override image name if specified */ -}}
  {{- if not (empty .Values.image.prometheus.name) -}}
    {{- $imageName = .Values.image.prometheus.name -}}
  {{- end -}}
  
  {{- /* Override tag if specified */ -}}
  {{- if not (empty .Values.image.prometheus.tag) -}}
    {{- $tag = .Values.image.prometheus.tag -}}
  {{- end -}}
  
  {{- /* Construct full image reference */ -}}
  {{- if not (empty $registry) -}}
    {{- if not (empty $tag) -}}
      {{- printf "%s/%s:%s" $registry $imageName $tag -}}
    {{- else -}}
      {{- printf "%s/%s" $registry $imageName -}}
    {{- end -}}
  {{- else -}}
    {{- if not (empty $tag) -}}
      {{- printf "%s:%s" $imageName $tag -}}
    {{- else -}}
      {{- printf "%s" $imageName -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Make comma separated list of allowed CORS origins
*/}}
{{- define "allowedCorsOrigins" -}}
{{- if .Values.tls.enabled -}}
https://{{ .Values.tls.perfAdvisor.hostname }}{{- if .Values.perfAdvisor.cors.origin -}},{{ .Values.perfAdvisor.cors.origin }}{{- end -}}
{{- else -}}
http://{{ .Values.tls.perfAdvisor.hostname }}{{- if .Values.perfAdvisor.cors.origin -}},{{ .Values.perfAdvisor.cors.origin }}{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Get or generate server key and certs in pem format
*/}}
{{- define "getOrCreateServerPem" -}}
{{- $root := .Root -}}
{{- if and $root.Values.tls.perfAdvisor.certificate $root.Values.tls.perfAdvisor.key -}}
  {{- if $root.Values.tls.perfAdvisor.ca_certificate -}}
    {{- $decodedCert := $root.Values.tls.perfAdvisor.certificate | b64dec -}}
    {{- $decodedCaCert := $root.Values.tls.perfAdvisor.ca_certificate | b64dec -}}
    {{- $tlsCrtTemp := ( printf "%s\n%s" $decodedCert $decodedCaCert ) -}}
    {{- $tlsCrt := $tlsCrtTemp | b64enc -}}
tls.crt: {{ $tlsCrt }}
tls.key: {{ $root.Values.tls.perfAdvisor.key }}
  {{- else -}}
tls.crt: {{ $root.Values.tls.perfAdvisor.certificate }}
tls.key: {{ $root.Values.tls.perfAdvisor.key }}
  {{- end -}}
{{- else -}}
  {{- $result := (lookup "v1" "Secret" .Namespace .Name).data -}}
  {{- if and $result (index $result "tls.crt") (index $result "tls.key") -}}
    {{- $tlsCrt := ( index $result "tls.crt" ) -}}
    {{- $tlsKey := ( index $result "tls.key" ) -}}
tls.crt: {{ $tlsCrt }}
tls.key: {{ $tlsKey }}
  {{- else -}}
    {{- $caCert := genCA $root.Values.tls.perfAdvisor.hostname 3650 -}}
    {{- $cert := genSignedCert $root.Values.tls.perfAdvisor.hostname nil nil 3650 $caCert -}}
    {{- $tlsCrt := ( printf "%s\n%s" $cert.Cert $caCert.Cert ) | b64enc -}}
    {{- $tlsKey := ( printf "%s" $cert.Key ) | b64enc -}}
tls.crt: {{ $tlsCrt }}
tls.key: {{ $tlsKey }}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Get or generate prometheus key and certs in pem format
*/}}
{{- define "getOrCreatePromServerPem" -}}
{{- $root := .Root -}}
{{- if and $root.Values.tls.prometheus.certificate $root.Values.tls.prometheus.key -}}
  {{- if $root.Values.tls.prometheus.ca_certificate -}}
    {{- $decodedCert := $root.Values.tls.prometheus.certificate | b64dec -}}
    {{- $decodedCaCert := $root.Values.tls.prometheus.ca_certificate | b64dec -}}
    {{- $tlsCrtTemp := ( printf "%s\n%s" $decodedCert $decodedCaCert ) -}}
    {{- $tlsCrt := $tlsCrtTemp | b64enc -}}
tls.crt: {{ $tlsCrt }}
tls.key: {{ $root.Values.tls.prometheus.key }}
  {{- else -}}
tls.crt: {{ $root.Values.tls.prometheus.certificate }}
tls.key: {{ $root.Values.tls.prometheus.key }}
  {{- end -}}
{{- else -}}
  {{- $result := (lookup "v1" "Secret" .Namespace .Name).data -}}
  {{- if and $result (index $result "tls.crt") (index $result "tls.key") -}}
    {{- $tlsCrt := ( index $result "tls.crt" ) -}}
    {{- $tlsKey := ( index $result "tls.key" ) -}}
tls.crt: {{ $tlsCrt }}
tls.key: {{ $tlsKey }}
  {{- else -}}
    {{- $caCert := genCA $root.Values.tls.prometheus.hostname 3650 -}}
    {{- $cert := genSignedCert $root.Values.tls.prometheus.hostname nil nil 3650 $caCert -}}
    {{- $tlsCrt := ( printf "%s\n%s" $cert.Cert $caCert.Cert ) | b64enc -}}
    {{- $tlsKey := ( printf "%s" $cert.Key ) | b64enc -}}
tls.crt: {{ $tlsCrt }}
tls.key: {{ $tlsKey }}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Calculate effective PA service port
*/}}
{{- define "getServicePort" -}}
{{- if .Values.perfAdvisor.port -}}{{ .Values.perfAdvisor.port }}{{- else -}}{{- if include "perf-advisor-chart.cloudEnabled" . -}}8080{{- else -}}{{- if .Values.tls.enabled -}}443{{- else -}}80{{- end -}}{{- end -}}{{- end -}}
{{- end -}}

{{/*
Namespace to deploy resources into. When running as a sub-chart of yugaware all
resources go into the release namespace, otherwise the configured namespace is used.
*/}}
{{- define "perf-advisor-chart.namespace" -}}
{{- if .Values.yugaware.enabled -}}
{{- .Release.Namespace -}}
{{- else -}}
{{- .Values.namespace -}}
{{- end -}}
{{- end -}}

{{/*
Effective spring profiles. When running as a sub-chart of yugaware only the
"api,task-runner,collector" profiles are used.
*/}}
{{- define "perf-advisor-chart.springProfiles" -}}
{{- if .Values.yugaware.enabled -}}
api,task-runner,collector
{{- else -}}
{{- .Values.perfAdvisor.profiles -}}
{{- end -}}
{{- end -}}

{{/*
Whether this deployment includes the collector profile. Rendered as the literal "true"/"" so
callers can just use `if`. Note that "collector deployment" and "needs a durable data volume"
are no longer the same question - see perf-advisor-chart.persistDataVolume for the volume
backing decision.
*/}}
{{- define "perf-advisor-chart.hasCollector" -}}
{{- if contains "collector" (include "perf-advisor-chart.springProfiles" .) -}}true{{- end -}}
{{- end -}}

{{/*
Whether this deployment includes the api profile - i.e. whether a Collection API server is
listening inside this pod. Collector and task-runner writes go to that API, so when it is absent
the deployment must be told where to find one.
*/}}
{{- define "perf-advisor-chart.hasApi" -}}
{{- if contains "api" (include "perf-advisor-chart.springProfiles" .) -}}true{{- end -}}
{{- end -}}

{{/*
Whether this deployment includes the task-runner profile.
*/}}
{{- define "perf-advisor-chart.hasTaskRunner" -}}
{{- if contains "task-runner" (include "perf-advisor-chart.springProfiles" .) -}}true{{- end -}}
{{- end -}}

{{/*
Resolved pa.api.url, and the place where a split topology that forgot to set one is rejected.

An explicit perfAdvisor.api.url always wins. Otherwise an empty value is only safe when this pod
also runs the api profile, because the backend then falls back to localhost:server.port and finds
its own listener. A collector-only or task-runner-only install has no such listener, so rather
than render a value that 404s on every collection cycle we fail the render with a message naming
the knob. CollectionApiTargetValidator enforces the same rule at JVM startup for non-chart
deployments.
*/}}
{{- define "perf-advisor-chart.apiUrl" -}}
{{- if .Values.perfAdvisor.api.url -}}
{{- .Values.perfAdvisor.api.url -}}
{{- else if .Values.yugaware.enabled -}}
{{- .Values.tls.enabled | ternary "https" "http" -}}://localhost:8080
{{- else if include "perf-advisor-chart.hasApi" . -}}
{{- else if or (include "perf-advisor-chart.hasCollector" .) (include "perf-advisor-chart.hasTaskRunner" .) -}}
{{- fail (printf "perfAdvisor.api.url must be set: profiles %q include collector and/or task-runner but not api, so this deployment has no local Collection API server to write to. Point perfAdvisor.api.url at the API release's service, e.g. http://<api-release>-perf-advisor-service:8080." (include "perf-advisor-chart.springProfiles" .)) -}}
{{- end -}}
{{- end -}}

{{/*
Normalised boolean check for perfAdvisor.cloud.enabled. Necessary because Helm's `if` treats
any non-empty string as truthy - so `if .Values.perfAdvisor.cloud.enabled` incorrectly matches
when the value is passed as the string "false" (e.g. via `--set-string`), which is easy to hit
because Helm silently coerces to string in a few paths (--set on nested keys with dots,
values-yaml quoted booleans, downstream tools like argocd/kustomize/terraform-helm). Compare
against the literal "true" instead. Rendered as "true"/"" so callers can just use `if`.
*/}}
{{- define "perf-advisor-chart.cloudEnabled" -}}
{{- if eq (toString .Values.perfAdvisor.cloud.enabled) "true" -}}true{{- end -}}
{{- end -}}

{{/*
Whether the perf-advisor-data volume (backs pa.data.path) should be a PVC instead of an
emptyDir. True only when the collector profile is active AND we are NOT running in cloud mode.

Rationale:
  - Non-collector deployments (api/task-runner/anomaly-detector) only need scratch space for
    snappy-java's native lib and can lose it on restart, so emptyDir suffices and keeps the
    Deployment horizontally scalable (no ReadWriteOnce constraint).
  - Cloud collector deployments (perfAdvisor.cloud.enabled=true) forward all metrics via
    remote-write / OTLP and have the JSONL file exporter disabled at the service level (see
    backend/src/main/resources/cloud-defaults.properties), so nothing on pa.data.path needs to
    survive a pod restart there either - support-bundle scratch is transient and gets uploaded
    to the platform. Running on emptyDir also sidesteps StorageClass availability issues in
    YBA/karpenter environments where the default class ("yb-standard") is not provisioned.
  - Only self-hosted collector deployments (yb.cloud.enabled=false) still need the PVC so
    collected JSONL metric files and pending support bundles survive rollouts.

Used by deployment.yaml (volume selection) and perf-advisor-pvc.yaml (PVC creation guard).
Rendered as literal "true"/"" so callers can use `if`.
*/}}
{{- define "perf-advisor-chart.persistDataVolume" -}}
{{- if and (include "perf-advisor-chart.hasCollector" .) (not (include "perf-advisor-chart.cloudEnabled" .)) -}}true{{- end -}}
{{- end -}}

{{/*
Effective postgres connection settings. An explicitly configured external postgres
takes precedence. In yugaware sub-chart mode we default to the postgres deployed by
yugaware, otherwise to the postgres deployed by this chart.
*/}}
{{- define "perf-advisor-chart.postgresHost" -}}
{{- if .Values.postgres.external.host -}}
{{- .Values.postgres.external.host -}}
{{- else if .Values.yugaware.enabled -}}
{{- .Release.Name -}}-postgres
{{- else -}}
{{- .Release.Name }}-postgres.{{ .Values.namespace }}.svc.cluster.local
{{- end -}}
{{- end -}}

{{- define "perf-advisor-chart.postgresPort" -}}
{{- if .Values.postgres.external.host -}}
{{- .Values.postgres.external.port -}}
{{- else -}}
5432
{{- end -}}
{{- end -}}

{{- define "perf-advisor-chart.postgresUser" -}}
{{- if or .Values.postgres.external.host .Values.yugaware.enabled -}}
{{- .Values.postgres.external.user -}}
{{- else -}}
postgres
{{- end -}}
{{- end -}}

{{- define "perf-advisor-chart.postgresDbName" -}}
{{- if or .Values.postgres.external.host .Values.yugaware.enabled -}}
{{- .Values.postgres.external.dbname -}}
{{- else -}}
ts
{{- end -}}
{{- end -}}

{{/*
Name/key of the kubernetes secret holding the postgres password. An explicitly
configured existing secret takes precedence. In yugaware sub-chart mode we default to
the global config secret created by yugaware, otherwise to the secret created by this
chart (see postgres-secret.yaml).
*/}}
{{- define "perf-advisor-chart.postgresSecretName" -}}
{{- if .Values.postgres.external.secret.name -}}
{{- .Values.postgres.external.secret.name -}}
{{- else if .Values.yugaware.enabled -}}
{{- .Release.Name -}}-yugaware-global-config
{{- else -}}
{{- .Release.Name -}}-postgres-password
{{- end -}}
{{- end -}}

{{- define "perf-advisor-chart.postgresSecretKey" -}}
{{- if .Values.postgres.external.secret.name -}}
{{- .Values.postgres.external.secret.key | default "POSTGRES_PASSWORD" -}}
{{- else if .Values.yugaware.enabled -}}
postgres_password
{{- else -}}
POSTGRES_PASSWORD
{{- end -}}
{{- end -}}

{{/*
Effective prometheus URL. An explicitly configured external prometheus takes
precedence. In yugaware sub-chart mode we default to the prometheus deployed by
yugaware, otherwise to the prometheus deployed by this chart.
*/}}
{{- define "perf-advisor-chart.prometheusUrl" -}}
{{- if .Values.prometheus.external.url -}}
{{- .Values.prometheus.external.url -}}
{{- else if .Values.yugaware.enabled -}}
http://{{ .Release.Name }}-yugaware-ui:9090
{{- else if .Values.tls.enabled -}}
https://{{ .Release.Name }}-prometheus.{{ .Values.namespace }}.svc.cluster.local:{{ .Values.prometheus.port }}
{{- else -}}
http://{{ .Release.Name }}-prometheus.{{ .Values.namespace }}.svc.cluster.local:{{ .Values.prometheus.port }}
{{- end -}}
{{- end -}}

{{/*
Return the base64 encoded user-provided value if set, otherwise reuse the value from
the existing secret (preserved across helm upgrades), otherwise generate a random one.
Expects a dict of .Namespace .Name .Key .UserValue and .Length (optional)
*/}}
{{- define "perf-advisor-chart.getOrGeneratePassword" -}}
{{- if .UserValue -}}
{{- .UserValue | b64enc -}}
{{- else -}}
{{- $obj := (lookup "v1" "Secret" .Namespace .Name).data -}}
{{- if and $obj (index $obj .Key) -}}
{{- index $obj .Key -}}
{{- else -}}
{{- randAlphaNum ((.Length | default 64) | int) | b64enc -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{/*
Pod placement - nodeSelector, tolerations and zone affinity.

The values are deliberately the same shape as the yugaware chart's top-level nodeSelector,
tolerations and zoneAffinity, so that in sub-chart mode an operator mirrors that chart's placement
onto Perf Advisor by copying it across rather than translating it. zoneAffinity in particular is a
plain list of zone names, not a nodeAffinity structure: this expands it into one, matching each
name against both the deprecated failure-domain.beta.kubernetes.io/zone label and the current
topology.kubernetes.io/zone, exactly as the yugaware chart does.

Takes a dict: "root" is the chart context, and "override" is an optional map of pod-spec fields
that will be written after this block - perfAdvisor.spec, for the one workload that has it. Any of
the three fields the override already names is skipped here rather than emitted twice, so an
operator who was placing the pod through perfAdvisor.spec before these values existed keeps that
placement and gets no duplicate key.

Emitted at zero indentation; callers set the real one with nindent. Every workload the chart
deploys includes it, so a placed release keeps Perf Advisor and any bundled postgres and
prometheus together rather than scattering the ones that were not named.
*/}}
{{- define "perf-advisor-chart.podPlacement" -}}
{{- $root := .root -}}
{{- $override := .override | default dict -}}
{{- if and $root.Values.nodeSelector (not $override.nodeSelector) }}
nodeSelector:
{{- toYaml $root.Values.nodeSelector | nindent 2 }}
{{- end }}
{{- if and $root.Values.tolerations (not $override.tolerations) }}
tolerations:
{{- toYaml $root.Values.tolerations | nindent 2 }}
{{- end }}
{{- if and $root.Values.zoneAffinity (not $override.affinity) }}
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: failure-domain.beta.kubernetes.io/zone
          operator: In
          values:
{{- toYaml $root.Values.zoneAffinity | nindent 12 }}
      - matchExpressions:
        - key: topology.kubernetes.io/zone
          operator: In
          values:
{{- toYaml $root.Values.zoneAffinity | nindent 12 }}
{{- end }}
{{- end }}
