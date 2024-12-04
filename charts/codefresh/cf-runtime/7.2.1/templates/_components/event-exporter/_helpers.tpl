{{/*
Expand the name of the chart.
*/}}
{{- define "event-exporter.name" -}}
    {{- printf "%s-%s" (include "cf-runtime.name" .) "event-exporter" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "event-exporter.fullname" -}}
    {{- printf "%s-%s" (include "cf-runtime.fullname" .) "event-exporter" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "event-exporter.labels" -}}
{{ include "cf-runtime.labels" . }}
app: event-exporter
{{- end }}

{{/*
Selector labels
*/}}
{{- define "event-exporter.selectorLabels" -}}
{{ include "cf-runtime.selectorLabels" . }}
app: event-exporter
{{- end }}


{{/*
Create the name of the service account to use
*/}}
{{- define "event-exporter.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "event-exporter.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
