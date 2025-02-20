{{/* vim: set filetype=mustache: */}}

{{- /* Allow to change pod defaults dynamically based if we are running in privileged mode or not */ -}}
{{- define "newrelic-k8s-metrics-adapter.securityContext.pod" -}}
{{- if include "newrelic.common.securityContext.pod" . -}}
{{- include "newrelic.common.securityContext.pod" . -}}
{{- else -}}
fsGroup: 1001
runAsUser: 1001
runAsGroup: 1001
{{- end -}}
{{- end -}}



{{/*
Select a value for the region
When this value is empty the New Relic client region will be the default 'US'
*/}}
{{- define "newrelic-k8s-metrics-adapter.region" -}}
{{- if .Values.config.region -}}
  {{- .Values.config.region | upper -}}
{{- else if (include "newrelic.common.nrStaging" .)  -}}
Staging
{{- else if hasPrefix "eu" (include "newrelic.common.license._licenseKey" .) -}}
EU
{{- end -}}
{{- end -}}



{{- /*
Naming helpers
*/ -}}
{{- define "newrelic-k8s-metrics-adapter.name.apiservice" -}}
{{ include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "apiservice") }}
{{- end -}}

{{- define "newrelic-k8s-metrics-adapter.name.apiservice.serviceAccount" -}}
{{- if include "newrelic.common.serviceAccount.create" . -}}
  {{- include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "apiservice") -}}
{{- else -}}
  {{- include "newrelic.common.serviceAccount.name" . -}}
{{- end -}}
{{- end -}}

{{- define "newrelic-k8s-metrics-adapter.name.apiservice-create" -}}
{{ include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "apiservice-create") }}
{{- end -}}

{{- define "newrelic-k8s-metrics-adapter.name.apiservice-patch" -}}
{{ include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "apiservice-patch") }}
{{- end -}}

{{- define "newrelic-k8s-metrics-adapter.name.hpa-controller" -}}
{{ include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "hpa-controller") }}
{{- end -}}
