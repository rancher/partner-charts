{{- define "spaceagent.name" -}}
spaceagent
{{- end }}

{{/*
Common labels
*/}}
{{- define "spaceagent.labels" -}}
{{ include "codezero.labels" . }}
{{ include "spaceagent.selectorLabels" . }}
{{- with .Values.spaceagent.labels }}
{{ . | toYaml }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "spaceagent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "spaceagent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Pod labels
*/}}
{{- define "spaceagent.podLabels" -}}
{{ include "codezero.podLabels" . }}
{{ include "spaceagent.selectorLabels" . }}
{{- with .Values.spaceagent.podLabels }}
{{ . | toYaml }}
{{- end }}
{{- end }}

{{/*
Pod annotations
*/}}
{{- define "spaceagent.podAnnotations" -}}
{{ include "codezero.podAnnotations" . }}
{{- with .Values.spaceagent.podAnnotations }}
{{ . | toYaml }}
{{- end }}
{{- end }}
