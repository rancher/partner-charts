{{/*
Expand the name of the chart.
*/}}
{{- define "cf-venona.name" -}}
    {{- printf "%s-%s" (include "cf-runtime.name" .) "venona" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cf-venona.fullname" -}}
    {{- printf "%s-%s" (include "cf-runtime.fullname" .) "venona" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cf-venona.labels" -}}
{{ include "cf-runtime.labels" . }}
codefresh.io/application: venona
{{- end }}

{{/*
Selector labels
*/}}
{{- define "cf-venona.selectorLabels" -}}
{{ include "cf-runtime.selectorLabels" . }}
codefresh.io/application: venona
{{- end }}

{{- define "cf-venona.docker-image" -}}
{{- .Values.venona.image }}
{{- end }}
