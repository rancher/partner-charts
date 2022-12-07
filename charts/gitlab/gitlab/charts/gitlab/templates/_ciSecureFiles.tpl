{{/*
Generates a templated config for ci_secure_files key in gitlab.yml.

Usage:
{{ include "gitlab.appConfig.ciSecureFiles.configuration" ( \
     dict                                                    \
         "config" .Values.path.to.ci_secure_files.config      \
         "context" $                                         \
     ) }}
*/}}
{{- define "gitlab.appConfig.ciSecureFiles.configuration" -}}
ci_secure_files:
  enabled: {{ if kindIs "bool" .config.enabled }}{{ eq .config.enabled true }}{{ end }}
  {{- if not .context.Values.global.appConfig.object_store.enabled }}
  {{-   include "gitlab.appConfig.objectStorage.configuration" (dict "name" "ci_secure_files" "config" .config "context" .context) | nindent 2 }}
  {{- end }}
{{- end -}}{{/* "gitlab.appConfig.ciSecureFiles.configuration" */}}
