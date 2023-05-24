{{/*
Generates sidekiq (client) configuration.

Usage:
{{ include "gitlab.appConfig.sidekiq.configuration" $ }}
*/}}
{{- define "gitlab.appConfig.sidekiq.configuration" -}}
{{- with $.Values.global.appConfig.sidekiq }}
sidekiq:
{{- $loggingFormat := default "json" (pluck "format" (default (dict) $.Values.logging) | first) }}
  log_format: {{ $loggingFormat }}
{{- if kindIs "slice" .routingRules }}
  {{- if gt (len .routingRules) 0 }}
  routing_rules:
    {{- range $rule := .routingRules }}
    - {{ toJson $rule }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}
{{- end -}}{{/* "gitlab.appConfig.sidekiq.configuration" */}}
