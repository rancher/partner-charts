{{/* ######### KAS related templates */}}

{{- define "gitlab.kas.mountSecrets" -}}
{{- if (or .Values.global.kas.enabled .Values.global.appConfig.gitlab_kas.enabled) -}}
# mount secret for kas
- secret:
    name: {{ template "gitlab.kas.secret" . }}
    items:
      - key: {{ template "gitlab.kas.key" . }}
        path: kas/.gitlab_kas_secret
{{- end -}}
{{- end -}}{{/* "gitlab.kas.mountSecrets" */}}

{{/*
Returns the KAS external hostname (for agentk connections)
If the hostname is set in `global.hosts.kas.name`, that will be returned,
otherwise the hostname will be assembed using `kas` as the prefix, and the `gitlab.assembleHost` function.
*/}}
{{- define "gitlab.kas.hostname" -}}
{{- coalesce $.Values.global.hosts.kas.name (include "gitlab.assembleHost"  (dict "name" "kas" "context" . )) -}}
{{- end -}}

{{/*
Returns the KAS external URL (for external agentk connections)
*/}}
{{- define "gitlab.appConfig.kas.externalUrl" -}}
{{-   if .Values.global.appConfig.gitlab_kas.externalUrl -}}
{{-     .Values.global.appConfig.gitlab_kas.externalUrl -}}
{{-   else -}}
{{-     $hostname := include "gitlab.kas.hostname" . -}}
{{-     if or .Values.global.hosts.https .Values.global.hosts.kas.https -}}
{{-       printf "wss://%s" $hostname -}}
{{-     else -}}
{{-       printf "ws://%s" $hostname -}}
{{-     end -}}
{{-   end -}}
{{- end -}}

{{- define "gitlab.kas.internal.scheme" -}}
{{- $tlsEnabled := "" -}}
{{- if eq .Chart.Name "kas" -}}
{{-    $tlsEnabled = .Values.privateApi.tls.enabled -}}
{{-    printf "%s" (ternary "grpcs" "grpc" (or (eq $tlsEnabled true) (eq $.Values.global.kas.tls.enabled true))) -}}
{{- else -}}
{{-    printf "%s" (ternary "grpcs" "grpc" (eq $.Values.global.kas.tls.enabled true)) -}}
{{- end -}}
{{- end -}}

{{/*
Returns the KAS internal URL (for GitLab backend connections)
*/}}
{{- define "gitlab.appConfig.kas.internalUrl" -}}
{{-   if .Values.global.appConfig.gitlab_kas.internalUrl -}}
{{-     .Values.global.appConfig.gitlab_kas.internalUrl -}}
{{-   else -}}
{{-     $serviceHost := include "gitlab.kas.serviceHost" . -}}
{{-     $scheme := include "gitlab.kas.internal.scheme" . -}}
{{-     $port := .Values.global.kas.service.apiExternalPort -}}
{{-     printf "%s://%s:%s" $scheme $serviceHost (toString $port) -}}
{{-   end -}}
{{- end -}}

{{/*
Return the KAS service host
*/}}
{{- define "gitlab.kas.serviceHost" -}}
{{-     $serviceName := include "gitlab.kas.serviceName" . -}}
{{-     printf "%s.%s.svc" $serviceName $.Release.Namespace -}}
{{- end -}}

{{/*
Return the KAS service name
*/}}
{{- define "gitlab.kas.serviceName" -}}
{{- include "gitlab.other.fullname" (dict "context" . "chartName" "kas") -}}
{{- end -}}


