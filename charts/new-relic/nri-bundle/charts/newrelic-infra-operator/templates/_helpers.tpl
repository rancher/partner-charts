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
Returns configmap data
*/}}
{{- define "newrelic-infra-operator.configmap.data" -}}
{{ toYaml (merge (include "newrelic-infra-operator.fargate-config" . | fromYaml) .Values.config) }}
{{- end }}
