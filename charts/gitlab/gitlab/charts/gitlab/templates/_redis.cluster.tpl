{{/* ######### Redis Cluster related templates */}}

{{/*
Return redis cluster user
*/}}
{{- define "gitlab.redis.cluster.user" -}}
{{- include "gitlab.redis.clusterConfig" . -}}
{{- if .redisClusterConfig.user -}}
username: {{ .redisClusterConfig.user }}
{{- end -}}
{{- end -}}

{{/*
Return redis cluster password
*/}}
{{- define "gitlab.redis.cluster.password" -}}
{{- include "gitlab.redis.clusterConfig" . -}}
{{- if .redisClusterConfig.password -}}
{{-   if .redisClusterConfig.password.enabled -}}
password: <%= File.read("/etc/gitlab/redis/{{ printf "%s-password" (default "redis" .redisConfigName) }}").strip.to_json %>
{{-   end -}}
{{- end -}}
{{- end -}}

{{/*
Build the structure describing redis cluster
*/}}
{{- define "gitlab.redis.cluster" -}}
{{- include "gitlab.redis.clusterConfig" . -}}
{{- if .redisClusterConfig.cluster -}}
cluster:
{{-   range $i, $entry := .redisClusterConfig.cluster }}
  - host: {{ $entry.host }}
    port: {{ default 6379 $entry.port }}
{{-   end }}
{{- end -}}
{{- end -}}

{{/*
Set redisClusterConfig, we do _not_ support inheriting from global config if the `cluster` key is set.
*/}}
{{- define "gitlab.redis.clusterConfig" -}}
{{- if .redisConfigName }}
{{-   $_ := set . "redisClusterConfig" ( index .Values.global.redis .redisConfigName | default (dict) ) -}}
{{- else -}}
{{-   $_ := set . "redisClusterConfig" (dict) -}}
{{- end -}}
{{- end -}}
