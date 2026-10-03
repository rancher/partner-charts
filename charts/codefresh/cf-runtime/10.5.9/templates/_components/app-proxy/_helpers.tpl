{{/*
Expand the name of the chart.
*/}}
{{- define "app-proxy.name" -}}
    {{- printf "%s-%s" (include "cf-runtime.name" .) "app-proxy" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "app-proxy.fullname" -}}
    {{- printf "%s-%s" (include "cf-runtime.fullname" .) "app-proxy" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "app-proxy.labels" -}}
{{ include "cf-runtime.labels" . }}
codefresh.io/application: app-proxy
{{- end }}

{{/*
Selector labels
*/}}
{{- define "app-proxy.selectorLabels" -}}
{{ include "cf-runtime.selectorLabels" . }}
codefresh.io/application: app-proxy
{{- end }}


{{/*
Create the name of the service account to use
*/}}
{{- define "app-proxy.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "app-proxy.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
