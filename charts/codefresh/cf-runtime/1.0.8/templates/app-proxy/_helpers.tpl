{{/*
Expand the name of the chart.
*/}}
{{- define "cf-app-proxy.name" -}}
    {{- printf "%s-%s" (include "cf-runtime.name" .) "app-proxy" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cf-app-proxy.fullname" -}}
    {{- printf "%s-%s" (include "cf-runtime.fullname" .) "app-proxy" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cf-app-proxy.labels" -}}
{{ include "cf-runtime.labels" . }}
codefresh.io/application: app-proxy
{{- end }}

{{/*
Selector labels
*/}}
{{- define "cf-app-proxy.selectorLabels" -}}
{{ include "cf-runtime.selectorLabels" . }}
codefresh.io/application: app-proxy
{{- end }}

{{- define "cf-app-proxy.docker-image" -}}
{{- if ne .Values.dockerRegistry ""}}
{{- .Values.dockerRegistry }}/{{ .Values.appProxy.image }}
{{- else }}
{{- .Values.appProxy.image }}
{{- end }}
{{- end }}
