{{/* ######### Spamcheck related templates */}}
{{/*
Return the Spamcheck service name
*/}}
{{- define "gitlab.spamcheck.serviceName" -}}
{{- include "gitlab.other.fullname" (dict "context" . "chartName" "spamcheck") -}}
{{- end -}}
