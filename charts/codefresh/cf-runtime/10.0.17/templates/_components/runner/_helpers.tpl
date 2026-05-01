{{/*
Expand the name of the chart.
*/}}
{{- define "runner.name" -}}
  {{- printf "%s-%s" (include "cf-runtime.name" .) "runner" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "runner.fullname" -}}
  {{- coalesce .Values.name (printf "%s-%s" (include "cf-runtime.fullname" .) "runner" | trunc 63 | trimSuffix "-") }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "runner.labels" -}}
{{ include "cf-runtime.labels" . }}
codefresh.io/application: runner
{{- end }}

{{/*
Selector labels
*/}}
{{- define "runner.selectorLabels" -}}
{{ include "cf-runtime.selectorLabels" . }}
codefresh.io/application: runner
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "runner.serviceAccountName" -}}
  {{- if .Values.serviceAccount.create }}
    {{- default (include "runner.fullname" .) .Values.serviceAccount.name }}
  {{- else }}
    {{- default "default" .Values.serviceAccount.name }}
  {{- end }}
{{- end }}
