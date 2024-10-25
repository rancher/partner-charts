{{/*
Create a default fully qualified name for operator components.
*/}}
{{- define "airlock-microgateway.operator.fullname" -}}
{{ include "airlock-microgateway.fullname" . }}-operator
{{- end }}


{{/*
Common operator labels
*/}}
{{- define "airlock-microgateway.operator.labels" -}}
{{ include "airlock-microgateway.sharedLabels" . }}
{{ include "airlock-microgateway.operator.selectorLabels" . }}
{{- end }}

{{/*
Operator Selector labels
*/}}
{{- define "airlock-microgateway.operator.selectorLabels" -}}
{{ include "airlock-microgateway.sharedSelectorLabels" . }}
app.kubernetes.io/name: {{ include "airlock-microgateway.name" . }}-operator
app.kubernetes.io/component: controller
{{- end }}

{{/*
Create the name of the service account to use for the operator
*/}}
{{- define "airlock-microgateway.operator.serviceAccountName" -}}
{{- if .Values.operator.serviceAccount.create }}
{{- default (include "airlock-microgateway.operator.fullname" .) .Values.operator.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.operator.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
ServiceMonitor metrics regex pattern for leader only metrics
*/}}
{{- define "airlock-microgateway.operator.metricsLeaderOnlyRegexPattern" -}}
^(microgateway_license|microgateway_sidecars).*$
{{- end }}
