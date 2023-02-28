{{/* ######### Redis related templates for Rails consumption */}}

{{/*
Render a Redis `resque` format configuration for Rails.
Input: dict "context" $ "name" string
*/}}
{{- define "gitlab.rails.redis.yaml" -}}
{{- if $cluster := include "gitlab.redis.cluster" .context -}}
{{ .name }}.yml.erb: |
  production:
    {{- include "gitlab.redis.cluster.user" .context | nindent 4 }}
    {{- include "gitlab.redis.cluster.password" .context | nindent 4 }}
    {{- $cluster | nindent 4 }}
    id:
{{- else -}}
{{ .name }}.yml.erb: |
  production:
    url: {{ template "gitlab.redis.url" .context }}
    {{- include "gitlab.redis.sentinels" .context | nindent 4 }}
    id:
    {{- if eq .name "cable" }}
    adapter: redis
    {{-   if index .context.Values.global.redis "actioncable" }}
    channel_prefix: {{ .context.Values.global.redis.actioncable.channelPrefix }}
    {{-   end }}
    {{- end }}
{{- end -}}
{{- $_ := set .context "redisConfigName" "" }}
{{- end -}}

{{- define "gitlab.rails.redis.resque" -}}
{{- $_ := set $ "redisConfigName" "" }}
{{- include "gitlab.rails.redis.yaml" (dict "context" $ "name" "resque") -}}
{{- end -}}

{{- define "gitlab.rails.redis.cache" -}}
{{- if .Values.global.redis.cache -}}
{{- $_ := set $ "redisConfigName" "cache" }}
{{- include "gitlab.rails.redis.yaml" (dict "context" $ "name" "redis.cache") -}}
{{- end -}}
{{- end -}}

{{- define "gitlab.rails.redis.clusterCache" -}}
{{- if .Values.global.redis.clusterCache -}}
{{-   $_ := set $ "redisConfigName" "clusterCache" }}
{{-   include "gitlab.rails.redis.yaml" (dict "context" $ "name" "redis.cluster_cache") -}}
{{- end -}}
{{- end -}}

{{- define "gitlab.rails.redis.sharedState" -}}
{{- if .Values.global.redis.sharedState -}}
{{- $_ := set $ "redisConfigName" "sharedState" }}
{{- include "gitlab.rails.redis.yaml" (dict "context" $ "name" "redis.shared_state") -}}
{{- end -}}
{{- end -}}

{{- define "gitlab.rails.redis.traceChunks" -}}
{{- if .Values.global.redis.traceChunks -}}
{{- $_ := set $ "redisConfigName" "traceChunks" }}
{{- include "gitlab.rails.redis.yaml" (dict "context" $ "name" "redis.trace_chunks") -}}
{{- end -}}
{{- end -}}

{{- define "gitlab.rails.redis.queues" -}}
{{- if .Values.global.redis.queues -}}
{{- $_ := set $ "redisConfigName" "queues" }}
{{- include "gitlab.rails.redis.yaml" (dict "context" $ "name" "redis.queues") -}}
{{- end -}}
{{- end -}}

{{- define "gitlab.rails.redis.rateLimiting" -}}
{{- if .Values.global.redis.rateLimiting -}}
{{- $_ := set $ "redisConfigName" "rateLimiting" }}
{{- include "gitlab.rails.redis.yaml" (dict "context" $ "name" "redis.rate_limiting") -}}
{{- end -}}
{{- end -}}

{{- define "gitlab.rails.redis.clusterRateLimiting" -}}
{{- if .Values.global.redis.clusterRateLimiting -}}
{{-   $_ := set $ "redisConfigName" "clusterRateLimiting" }}
{{-   include "gitlab.rails.redis.yaml" (dict "context" $ "name" "redis.cluster_rate_limiting") -}}
{{- end -}}
{{- end -}}

{{- define "gitlab.rails.redis.sessions" -}}
{{- if .Values.global.redis.sessions -}}
{{- $_ := set $ "redisConfigName" "sessions" }}
{{- include "gitlab.rails.redis.yaml" (dict "context" $ "name" "redis.sessions") -}}
{{- end -}}
{{- end -}}

{{- define "gitlab.rails.redis.repositoryCache" -}}
{{- if .Values.global.redis.repositoryCache -}}
{{-   $_ := set $ "redisConfigName" "repositoryCache" }}
{{-   include "gitlab.rails.redis.yaml" (dict "context" $ "name" "redis.repository_cache") -}}
{{- end -}}
{{- end -}}

{{/*
cable.yml configuration
If no `global.redis.actioncable`, use `global.redis`
*/}}
{{- define "gitlab.rails.redis.cable" -}}
{{- if .Values.global.redis.actioncable -}}
{{-   $_ := set $ "redisConfigName" "actioncable" }}
{{- end -}}
{{- include "gitlab.rails.redis.yaml" (dict "context" $ "name" "cable") -}}
{{- end -}}

{{- define "gitlab.rails.redisYmlOverride" -}}
{{- if .Values.global.redis.redisYmlOverride -}}
redis.yml.erb: |
  production: {{ toYaml .Values.global.redis.redisYmlOverride | nindent 4 }}
{{- end -}}
{{- end -}}

{{- define "gitlab.rails.redis.all" -}}
{{ include "gitlab.rails.redis.resque" . }}
{{ include "gitlab.rails.redis.cache" . }}
{{ include "gitlab.rails.redis.clusterCache" . }}
{{ include "gitlab.rails.redis.sharedState" . }}
{{ include "gitlab.rails.redis.queues" . }}
{{ include "gitlab.rails.redis.cable" . }}
{{ include "gitlab.rails.redis.traceChunks" . }}
{{ include "gitlab.rails.redis.rateLimiting" . }}
{{ include "gitlab.rails.redis.clusterRateLimiting" . }}
{{ include "gitlab.rails.redis.sessions" . }}
{{ include "gitlab.rails.redis.repositoryCache" . }}
{{ include "gitlab.rails.redisYmlOverride" . }}
{{- end -}}
