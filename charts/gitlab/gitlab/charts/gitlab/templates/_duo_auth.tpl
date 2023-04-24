
{{- define "gitlab.appConfig.duo.secretKey.key" -}}
{{ with $.Values.global.appConfig }}
{{- if .duoAuth.secretKey }}
{{- default "secretKey" $.Values.global.appConfig.duoAuth.secretKey.key -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "gitlab.duo.secretKey.path" -}}
{{ with $.Values.global.appConfig }}
{{- if .duoAuth.secretKey }}
  {{- printf "/etc/gitlab/duo/%s/%s" .duoAuth.secretKey.secret ( include "gitlab.appConfig.duo.secretKey.key" $) -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "gitlab.appConfig.duo.configuration" -}}
{{ with $.Values.global.appConfig }}
duo_auth:
  enabled: {{ eq .duoAuth.enabled true }}
  hostname: {{ .duoAuth.hostname }}
  integration_key: {{ .duoAuth.integrationKey }}
  secret_key: {{ .duoAuth.enabled | ternary (printf "<%= File.read('%s').strip.to_json() %>" (include "gitlab.duo.secretKey.path" $)) "" }}
{{- end -}}
{{- end -}}

{{- define "gitlab.appConfig.duo.mountSecrets" -}}
{{- with $.Values.global.appConfig -}}
{{- if .duoAuth.secretKey }}
- secret:
    name: {{ .duoAuth.secretKey.secret }}
    items:
      - key: {{ include "gitlab.appConfig.duo.secretKey.key" $ }}
        path: {{ printf "duo/%s/%s" .duoAuth.secretKey.secret (include "gitlab.appConfig.duo.secretKey.key" $) }}
{{- end -}}
{{- end -}}
{{- end -}}
