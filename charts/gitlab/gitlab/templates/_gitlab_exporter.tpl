{{/*
Return the GitLab Exporter TLS secret name
*/}}
{{- define "gitlab.gitlab-exporter.tls.secret" -}}
{{-   default (printf "%s-gitlab-exporter-tls" .Release.Name) .Values.tls.secretName | quote -}}
{{- end -}}
