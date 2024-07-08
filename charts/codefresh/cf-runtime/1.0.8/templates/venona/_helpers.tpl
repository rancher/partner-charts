{{/*
Expand the name of the chart.
*/}}
{{- define "cf-runner.name" -}}
    {{- printf "%s-%s" (include "cf-runtime.name" .) "runner" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cf-runner.fullname" -}}
    {{- printf "%s-%s" (include "cf-runtime.fullname" .) "runner" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cf-runner.labels" -}}
{{ include "cf-runtime.labels" . }}
codefresh.io/application: runner
{{- end }}

{{/*
Selector labels
*/}}
{{- define "cf-runner.selectorLabels" -}}
{{ include "cf-runtime.selectorLabels" . }}
codefresh.io/application: runner
{{- end }}

{{- define "cf-runner.docker-image" -}}
{{- if ne .Values.dockerRegistry ""}}
{{- .Values.dockerRegistry }}/{{ .Values.runner.image }}
{{- else }}
{{- .Values.runner.image }}
{{- end}}
{{- end }}

{{/*
Get the token secret.
*/}}
{{- define "cf-runner.secretTokenName" -}}
    {{- if .Values.global.existingAgentToken -}}
        {{- printf "%s" (tpl .Values.global.existingAgentToken $) -}}
    {{- else -}}
        {{- printf "%s" (include "cf-runner.fullname" .) -}}
    {{- end -}}
{{- end -}}