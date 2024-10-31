{{/*
Namespace for all resources to be installed into
If not defined in values file then the helm release namespace is used
By default this is not set so the helm release namespace will be used
*/}}

{{- define "custom.namespace" -}}
	{{ .Values.namespace | default .Release.Namespace }}
{{- end -}}