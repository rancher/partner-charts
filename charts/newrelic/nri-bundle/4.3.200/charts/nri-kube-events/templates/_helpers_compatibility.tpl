{{/*
Returns a dictionary with legacy runAsUser config.
We know that it only has "one line" but it is separated from the rest of the helpers because it is a temporary things
that we should EOL. The EOL time of this will be marked when we GA the deprecation of Helm v2.
*/}}
{{- define "newrelic.compatibility.securityContext.pod" -}}
{{- if  .Values.runAsUser -}}
runAsUser: {{ .Values.runAsUser }}
{{- end -}}
{{- end -}}
