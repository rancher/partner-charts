
{{- define "gitlab.duoAuth.checkConfig" -}}
{{ with $.Values.global.appConfig }}
{{- if .duoAuth.enabled }}
{{-   if (not .duoAuth.hostname) }}
duoAuth: Enabling Duo Auth requires hostname to be present
  Duo Auth requires value of hostname acquired from Duo admin panel, which is provided here as string.
  Please see https://docs.gitlab.com/charts/charts/globals.html#duoauth
{{-   end -}}
{{-   if (not .duoAuth.integrationKey) }}
duoAuth: Enabling Duo Auth requires integrationKey to be present
  Duo Auth requires an integrationKey acquired from Duo admin panel, which is provided here as a string.
  Please see https://docs.gitlab.com/charts/charts/globals.html#duoauth
{{-   end -}}
{{-   if (not .duoAuth.secretKey) }}
duoAuth:  Enabling Duo Auth requires secretKey.secret to be present
  Duo Auth requires a secretKey acquired from Duo admin panel, which is provided here via Kubernete Secret.
  Please see https://docs.gitlab.com/charts/charts/globals.html#duoauth
{{-   end -}}
{{- end -}}
{{- end -}}
{{- end -}}