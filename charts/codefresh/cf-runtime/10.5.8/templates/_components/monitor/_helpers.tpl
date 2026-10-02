{{/*
Expand the name of the chart.
*/}}
{{- define "monitor.name" -}}
    {{- printf "%s-%s" (include "cf-runtime.name" .) "monitor" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "monitor.fullname" -}}
    {{- printf "%s-%s" (include "cf-runtime.fullname" .) "monitor" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "monitor.labels" -}}
{{ include "cf-runtime.labels" . }}
codefresh.io/application: monitor
{{- end }}

{{/*
Selector labels
*/}}
{{- define "monitor.selectorLabels" -}}
{{ include "cf-runtime.selectorLabels" . }}
codefresh.io/application: monitor
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "monitor.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "monitor.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}