{{/*
Expand the name of the chart.
*/}}
{{- define "ballast.name" -}}
    {{- printf "%s-%s" (include "cf-runtime.name" .) "ballast" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ballast.fullname" -}}
    {{- printf "%s-%s" .Values.name "ballast" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ballast.labels" -}}
{{ include "cf-runtime.labels" . }}
codefresh.io/application: ballast
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ballast.selectorLabels" -}}
{{ include "cf-runtime.selectorLabels" . }}
codefresh.io/application: ballast
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "ballast.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "ballast.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
