{{/*
Ensure workhorse monitoring exporter's TLS config is valid
*/}}
{{- define "gitlab.checkConfig.workhorse.exporter.tls.enabled" -}}
{{-   $workhorseTlsEnabled := $.Values.global.workhorse.tls.enabled -}}
{{-   $monitoringTlsOverride := pluck "enabled" $.Values.gitlab.webservice.workhorse.monitoring.exporter.tls (dict "enabled" false) | first -}}
{{-   if and (eq $monitoringTlsOverride true) (not $workhorseTlsEnabled) }}
webservice.workhorse:
  The monitoring exporter TLS depends on the main workhorse listener using TLS.
  Use `global.workhorse.tls.enabled` to enable TLS for the main listener or `gitlab.webservice.workhorse.monitoring.exporter.tls.enabled`
  to disable TLS for the monitoring exporter.
{{-   end -}}
{{- end -}}
