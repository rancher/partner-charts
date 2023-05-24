{{/* ######### Redis related templates */}}

{{/*
Build a dict of redis configuration

- inherit from global.redis, all but sentinels and cluster
- use values within children, if they exist, even if "empty"
*/}}
{{- define "gitlab.redis.configMerge" -}}
{{-   $_ := set $ "redisConfigName" (default "" $.redisConfigName) -}}
{{-   $_ := unset $ "redisMergedConfig" -}}
{{-   $_ := set $ "redisMergedConfig" (dict "redisConfigName" $.redisConfigName) -}}
{{-   range $want := list "host" "port" "scheme" "user" -}}
{{-     $_ := set $.redisMergedConfig $want (pluck $want (index $.Values.global.redis $.redisConfigName) $.Values.global.redis | first) -}}
{{-   end -}}
{{-   if kindIs "map" (get (index $.Values.global.redis $.redisConfigName) "password")  -}}
{{-     $_ := set $.redisMergedConfig "password" (get (index $.Values.global.redis $.redisConfigName) "password") -}}
{{-   else if (kindIs "map" (get $.Values.global.redis "password")) -}}
{{-     $_ := set $.redisMergedConfig "password" (get $.Values.global.redis "password") -}}
{{-   else -}}
{{-     $_ := set $.redisMergedConfig "password" $.Values.global.redis.auth -}}
{{-   end -}}
{{-   range $key := keys $.Values.global.redis.auth -}}
{{-     if not (hasKey $.redisMergedConfig.password $key) -}}
{{-       $_ := set $.redisMergedConfig.password $key (index $.Values.global.redis.auth $key) -}}
{{-     end -}}
{{-   end -}}
{{- end -}}

{{/*
Return the redis password secret name
*/}}
{{- define "gitlab.redis.password.secret" -}}
{{- include "gitlab.redis.configMerge" . -}}
{{- default (printf "%s-redis-secret" .Release.Name) .redisMergedConfig.password.secret | quote -}}
{{- end -}}

{{/*
Return the redis password secret key
*/}}
{{- define "gitlab.redis.password.key" -}}
{{- include "gitlab.redis.configMerge" . -}}
{{- default "secret" .redisMergedConfig.password.key | quote -}}
{{- end -}}

{{/*
Return a merged setting between global.redis.password.enabled,
global.redis.[subkey/"redisConfigName"].password.enabled, or
global.redis.auth.enabled
*/}}
{{- define "gitlab.redis.password.enabled" -}}
{{- include "gitlab.redis.configMerge" . -}}
{{- .redisMergedConfig.password.enabled -}}
{{- end -}}