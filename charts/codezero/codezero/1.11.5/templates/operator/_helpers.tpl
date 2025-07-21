{{- if ne .Release.Namespace "codezero" }}
{{- fail "Codezero has to be installed in codezero namespace" }}
{{- end }}

{{- define "operator.name" -}}
operator
{{- end }}

{{/*
Common labels
*/}}
{{- define "operator.labels" -}}
{{ include "codezero.labels" . }}
{{ include "operator.selectorLabels" . }}
{{- with .Values.operator.labels }}
{{ . | toYaml }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "operator.selectorLabels" -}}
app.kubernetes.io/name: {{ include "operator.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Pod labels
*/}}
{{- define "operator.podLabels" -}}
{{ include "codezero.podLabels" . }}
{{ include "operator.selectorLabels" . }}
{{- with .Values.operator.podLabels }}
{{ . | toYaml }}
{{- end }}
{{- end }}

{{/*
Pod annotations
*/}}
{{- define "operator.podAnnotations" -}}
{{ include "codezero.podAnnotations" . }}
{{- with .Values.operator.podAnnotations }}
{{ . | toYaml }}
{{- end }}
{{- end }}
