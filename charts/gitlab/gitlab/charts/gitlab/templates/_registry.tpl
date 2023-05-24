{{/* ######### Registry related templates */}}

{{/*
Returns the Registry hostname.
If the hostname is set in `global.hosts.registry.name`, that will be returned,
otherwise the hostname will be assembed using `registry` as the prefix, and the `gitlab.assembleHost` function.
*/}}
{{- define "gitlab.registry.hostname" -}}
{{-   $registryHost := pluck "host" (default (dict) .Values.registry) .Values.global.registry | first -}}
{{-   coalesce $registryHost .Values.global.hosts.registry.name (include "gitlab.assembleHost"  (dict "name" "registry" "context" . )) -}}
{{- end -}}

{{/*
Return the registry api hostname
If the registry api host is provided, it will use that, otherwise it will fallback
to the service name
*/}}
{{- define "gitlab.registry.api.host" -}}
{{-   $localRegistry := default (dict) .Values.registry -}}
{{-   $localRegistryApi :=  dig "api" (dict) $localRegistry -}}
{{-   $globalRegistryApi := dig "registry" "api" (dict) .Values.global -}}
{{-   if or $localRegistryApi.host $globalRegistryApi.host -}}
{{-     coalesce $localRegistryApi.host $globalRegistryApi.host -}}
{{-   else -}}
{{-     $name := coalesce $localRegistryApi.serviceName $globalRegistryApi.serviceName .Values.global.hosts.registry.serviceName -}}
{{-     $name = printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{-     printf "%s.%s.svc" $name .Release.Namespace -}}
{{-   end -}}
{{- end -}}

{{/*
Return the registry api port
If the registry api port is provided, it will use that, otherwise it will fallback
to the service default
*/}}
{{- define "gitlab.registry.api.port" -}}
{{-   $localRegistry := default (dict) .Values.registry -}}
{{-   $localRegistryApi :=  dig "api" (dict) $localRegistry -}}
{{-   $globalRegistryApi := dig "registry" "api" (dict) .Values.global -}}
{{-   coalesce .Values.global.hosts.registry.servicePort $localRegistryApi.port $globalRegistryApi.port "5000" -}}
{{- end -}}

{{/*
Return the registry api protocol
If the registry api protocol is provided, it will use that, otherwise it will fallback
to the service default
*/}}
{{- define "gitlab.registry.api.protocol" -}}
{{-   $localRegistry := default (dict) .Values.registry -}}
{{-   $localRegistryApi :=  dig "api" (dict) $localRegistry -}}
{{-   $globalRegistryApi := dig "registry" "api" (dict) .Values.global -}}
{{-   coalesce .Values.global.hosts.registry.protocol $localRegistryApi.protocol $globalRegistryApi.protocol "http" -}}
{{- end -}}


{{/*
Return the registry api url
*/}}
{{- define "gitlab.registry.api.url" -}}
{{-   $scheme := include "gitlab.registry.api.protocol" . -}}
{{-   $host   := include "gitlab.registry.api.host" . -}}
{{-   $port   := include "gitlab.registry.api.port" . -}}
{{    printf "%s://%s:%s" $scheme $host $port }}
{{- end -}}

{{- define "gitlab.appConfig.registry.configuration" -}}
{{-   $registryPort := pluck "port" (default (dict) .Values.registry) .Values.global.registry | first -}}
{{-   $localRegistry := default (dict) .Values.registry -}}
{{-   $localRegistryEnabled :=  dig "enabled" false $localRegistry -}}
{{-   $globalRegistryEnabled := dig "registry" "enabled" false .Values.global -}}
{{-   $registryTokenIssuer := pluck "tokenIssuer" (default (dict) .Values.registry) .Values.global.registry | first -}}
registry:
  enabled: {{ or (not (kindIs "bool" $localRegistryEnabled )) (not (kindIs "bool" $globalRegistryEnabled )) $localRegistryEnabled $globalRegistryEnabled }}
  host: {{ template "gitlab.registry.hostname" . }}
  {{- if $registryPort }}
  port: {{ $registryPort }}
  {{- end }}
  api_url: {{ template "gitlab.registry.api.url" . }}
  key: /etc/gitlab/registry/gitlab-registry.key
  issuer: {{ default "gitlab-issuer" $registryTokenIssuer }}
  notification_secret: <%= YAML.load_file("/etc/gitlab/registry/notificationSecret").flatten.first %>
{{- end -}}{{/* "gitlab.appConfig.registry.configuration" */}}
