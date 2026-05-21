{{/*
Reports Server helpers
*/}}

{{/*
Check if reports-server is enabled
*/}}
{{- define "kyverno.reportsServer.enabled" -}}
{{- if .Values.reportsServer.enabled -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Reports Server service dependency annotation
*/}}
{{- define "kyverno.reportsServer.dependsOnAnnotation" -}}
{{- if .Values.reportsServer.enabled }}
"helm.sh/hook-depends-on": "Service/reports-server"
{{- end -}}
{{- end -}}