

{{/* */}}
{{- define "utils.hostaliases" -}}
{{- if .Values.hostAliases -}}
{{ toYaml .Values.hostAliases }}
{{- end -}}
{{- end -}}

{{- define "utils.is_eks" -}}
{{- if and .Values.serviceAccount.annotations (index .Values.serviceAccount.annotations "eks.amazonaws.com/role-arn") -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}
