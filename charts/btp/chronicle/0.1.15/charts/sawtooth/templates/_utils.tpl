

{{/* */}}
{{- define "utils.hostaliases" -}}
{{- if .Values.hostAliases -}}
{{ toYaml .Values.hostAliases }}
{{- end -}}
{{- end -}}
