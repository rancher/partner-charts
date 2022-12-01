{{/* vim: set filetype=mustache: */}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "labels" -}}
{{ include "selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/version: {{ .Chart.Version }}
helm.sh/chart: {{ include "chart" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "selectorLabels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
