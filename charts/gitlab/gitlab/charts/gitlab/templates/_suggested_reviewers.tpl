{{/* ######### Suggested Reviewers related templates */}}

{{- define "gitlab.suggestedReviewers.mountSecrets" -}}
# mount secret for suggested reviewers
- secret:
    name: {{ template "gitlab.suggested-reviewers.secret" . }}
    items:
      - key: {{ template "gitlab.suggested-reviewers.key" . }}
        path: suggested_reviewers/.gitlab_suggested_reviewers_secret
{{- end -}}{{/* "gitlab.suggestedReviewers.mountSecrets" */}}
