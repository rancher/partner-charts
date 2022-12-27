{{/* ######### gitlab-suggested-reviewers related templates */}}

{{/*
Return the gitlab-suggested-reviewers secret
*/}}

{{- define "gitlab.suggested-reviewers.secret" -}}
{{- default (printf "%s-gitlab-suggested-reviewers" .Release.Name) .Values.global.appConfig.suggested_reviewers.secret | quote -}}
{{- end -}}

{{- define "gitlab.suggested-reviewers.key" -}}
{{- default "suggested_reviewers_secret" .Values.global.appConfig.suggested_reviewers.key | quote -}}
{{- end -}}

