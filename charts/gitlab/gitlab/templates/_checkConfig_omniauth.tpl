{{/*
Ensure the provided global.appConfig.omniauth.providerFormat value in expected format */}}
{{- define "gitlab.checkConfig.omniauth.providerFormat" -}}
{{- range $index, $provider := .Values.global.appConfig.omniauth.providers }}
{{-   $badKeys := omit $provider "secret" "key" }}
{{-     if $badKeys }}
omniauth.providers: each provider should only contain 'secret', and optionally 'key'
        A current value of global.appConfig.omniauth.providers[{{ $index }}] must be updated.
        Please see https://docs.gitlab.com/charts/charts/globals.html#providers
{{-     end }}
{{-   end }}
{{- end }}
{{/* END gitlab.checkConfig.omniauth.providerFormat */}}