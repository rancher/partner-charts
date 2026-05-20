{{/* vim: set filetype=mustache: */}}

{{/*
Renders a value that contains template.
Usage:
{{ include "tplvalues.render" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "tplvalues.render" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{- /*
Naming helpers
*/ -}}
{{- define "newrelic-infra-operator.name.admission" -}}
{{ include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.name" .) "suffix" "admission") }}
{{- end -}}

{{- define "newrelic-infra-operator.fullname.admission" -}}
{{ include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "admission") }}
{{- end -}}

{{- define "newrelic-infra-operator.fullname.admission.serviceAccount" -}}
{{- if include "newrelic.common.serviceAccount.create" . -}}
  {{- include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "admission") -}}
{{- else -}}
  {{- include "newrelic.common.serviceAccount.name" . -}}
{{- end -}}
{{- end -}}

{{- define "newrelic-infra-operator.name.admission-create" -}}
{{ include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.name" .) "suffix" "admission-create") }}
{{- end -}}

{{- define "newrelic-infra-operator.fullname.admission-create" -}}
{{ include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "admission-create") }}
{{- end -}}

{{- define "newrelic-infra-operator.name.admission-patch" -}}
{{ include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.name" .) "suffix" "admission-patch") }}
{{- end -}}

{{- define "newrelic-infra-operator.fullname.admission-patch" -}}
{{ include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "admission-patch") }}
{{- end -}}

{{- define "newrelic-infra-operator.fullname.self-signed-issuer" -}}
{{ include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "self-signed-issuer") }}
{{- end -}}

{{- define "newrelic-infra-operator.fullname.root-cert" -}}
{{ include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "root-cert") }}
{{- end -}}

{{- define "newrelic-infra-operator.fullname.root-issuer" -}}
{{ include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "root-issuer") }}
{{- end -}}

{{- define "newrelic-infra-operator.fullname.webhook-cert" -}}
{{ include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "webhook-cert") }}
{{- end -}}

{{- define "newrelic-infra-operator.fullname.infra-agent" -}}
{{ include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "infra-agent") }}
{{- end -}}

{{- define "newrelic-infra-operator.fullname.config" -}}
{{ include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "config") }}
{{- end -}}

{{/*
Returns Infra-agent rules
*/}}
{{- define "newrelic-infra-operator.infra-agent-monitoring-rules" -}}
- apiGroups: [""]
  resources:
    - "nodes"
    - "nodes/metrics"
    - "nodes/stats"
    - "nodes/proxy"
    - "pods"
    - "services"
    - "namespaces"
  verbs: ["get", "list"]
- nonResourceURLs: ["/metrics"]
  verbs: ["get"]
{{- end -}}

{{/*
Returns fargate
*/}}
{{- define "newrelic-infra-operator.fargate" -}}
{{- if .Values.global }}
  {{- if .Values.global.fargate }}
    {{- .Values.global.fargate -}}
  {{- end -}}
{{- else if .Values.fargate }}
  {{- .Values.fargate -}}
{{- end -}}
{{- end -}}

{{/*
Returns fargate configuration for configmap data
*/}}
{{- define "newrelic-infra-operator.fargate-config" -}}
infraAgentInjection:
  resourcePrefix: {{ include "newrelic.common.naming.fullname" . }}
{{- if include "newrelic-infra-operator.fargate" . }}
{{- if not .Values.config.infraAgentInjection.policies }}
  policies:
    - podSelector:
        matchExpressions:
          - key: "eks.amazonaws.com/fargate-profile"
            operator: Exists
{{- end }}
  agentConfig:
{{- if not .Values.config.infraAgentInjection.agentConfig.customAttributes }}
    customAttributes:
      - name: computeType
        defaultValue: serverless
      - name: fargateProfile
        fromLabel: eks.amazonaws.com/fargate-profile
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Returns the sidecar image repository, respecting global.images.registry
*/}}
{{- define "newrelic-infra-operator.sidecar.image" -}}
{{- $imageRepository := .Values.config.infraAgentInjection.agentConfig.image.repository -}}
{{- $globalRegistry := "" -}}
{{- if and .Values.global .Values.global.images }}
  {{- $globalRegistry = .Values.global.images.registry | default "" -}}
{{- end -}}
{{- $chartRegistry := .Values.config.infraAgentInjection.agentConfig.image.registry | default "" -}}
{{- if $chartRegistry -}}
  {{- printf "%s/%s" $chartRegistry $imageRepository -}}
{{- else if $globalRegistry -}}
  {{- printf "%s/%s" $globalRegistry $imageRepository -}}
{{- else -}}
  {{- $imageRepository -}}
{{- end -}}
{{- end -}}

{{/*
Returns configmap data
*/}}
{{- define "newrelic-infra-operator.configmap.data" -}}
{{- $config := (merge (include "newrelic-infra-operator.fargate-config" . | fromYaml) (deepCopy .Values.config)) -}}
{{- $sidecarImage := include "newrelic-infra-operator.sidecar.image" . -}}
{{- $_ := set $config.infraAgentInjection.agentConfig.image "repository" $sidecarImage -}}
{{- $sidecarPullPolicy := include "newrelic-infra-operator.sidecar.imagePullPolicy" . -}}
{{- $_ := set $config.infraAgentInjection.agentConfig.image "pullPolicy" $sidecarPullPolicy -}}
{{- $_ := unset $config.infraAgentInjection.agentConfig.image "registry" -}}
{{ toYaml $config }}
{{- end }}

{{/*
Returns the pull policy for sidecar image, respecting global.images.pullPolicy
*/}}
{{- define "newrelic-infra-operator.sidecar.imagePullPolicy" -}}
{{- $globalPullPolicy := "" -}}
{{- if and .Values.global .Values.global.images }}
  {{- $globalPullPolicy = .Values.global.images.pullPolicy | default "" -}}
{{- end -}}
{{- $chartPullPolicy := .Values.config.infraAgentInjection.agentConfig.image.pullPolicy | default "" -}}
{{- if $chartPullPolicy -}}
  {{- $chartPullPolicy -}}
{{- else if $globalPullPolicy -}}
  {{- $globalPullPolicy -}}
{{- else -}}
  IfNotPresent
{{- end -}}
{{- end -}}

{{/*
Returns the pull policy for operator image, respecting global.images.pullPolicy
*/}}
{{- define "newrelic-infra-operator.imagePullPolicy" -}}
{{- $globalPullPolicy := "" -}}
{{- if and .Values.global .Values.global.images }}
  {{- $globalPullPolicy = .Values.global.images.pullPolicy | default "" -}}
{{- end -}}
{{- $chartPullPolicy := .Values.image.pullPolicy | default "" -}}
{{- if $chartPullPolicy -}}
  {{- $chartPullPolicy -}}
{{- else if $globalPullPolicy -}}
  {{- $globalPullPolicy -}}
{{- else -}}
  IfNotPresent
{{- end -}}
{{- end -}}

{{/*
Returns the pull policy for admission webhooks patch job image, respecting global.images.pullPolicy
*/}}
{{- define "newrelic-infra-operator.admissionWebhooksPatchJob.imagePullPolicy" -}}
{{- $globalPullPolicy := "" -}}
{{- if and .Values.global .Values.global.images }}
  {{- $globalPullPolicy = .Values.global.images.pullPolicy | default "" -}}
{{- end -}}
{{- $chartPullPolicy := .Values.admissionWebhooksPatchJob.image.pullPolicy | default "" -}}
{{- if $chartPullPolicy -}}
  {{- $chartPullPolicy -}}
{{- else if $globalPullPolicy -}}
  {{- $globalPullPolicy -}}
{{- else -}}
  IfNotPresent
{{- end -}}
{{- end -}}
