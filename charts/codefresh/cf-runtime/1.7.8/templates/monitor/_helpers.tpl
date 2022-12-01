{{/*
Expand the name of the chart.
*/}}
{{- define "cf-monitor.name" -}}
    {{- printf "%s-%s" (include "cf-runtime.name" .) "monitor" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cf-monitor.fullname" -}}
    {{- printf "%s-%s" (include "cf-runtime.fullname" .) "monitor" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "cf-monitor.rollbackFullname" -}}
    {{- printf "%s-%s" (include "cf-runtime.fullname" .) "monitor-rollback" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cf-monitor.labels" -}}
{{ include "cf-runtime.labels" . }}
codefresh.io/application: monitor
{{- end }}

{{/*
Selector labels
*/}}
{{- define "cf-monitor.selectorLabels" -}}
{{ include "cf-runtime.selectorLabels" . }}
codefresh.io/application: monitor
{{- end }}

{{- define "cf-monitor.docker-image" -}}
{{- if ne .Values.dockerRegistry ""}}
{{- .Values.dockerRegistry }}/{{ .Values.monitor.image }}
{{- else }}
{{- .Values.monitor.image }}
{{- end }}
{{- end }}

{{/*
Get the token secret.
*/}}
{{- define "cf-monitor.secretTokenName" -}}
    {{- if .Values.monitor.existingMonitorToken -}}
        {{- printf "%s" (tpl .Values.monitor.existingMonitorToken $) -}}
    {{- else -}}
        {{- printf "%s" (include "cf-monitor.fullname" .) -}}
    {{- end -}}
{{- end -}}