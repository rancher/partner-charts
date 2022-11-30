{{/*
server name
*/}}
{{- define "asserts.serverName" -}}
{{- if .Values.server.nameOverride -}}
{{- .Values.server.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{ include "asserts.name" . }}-server
{{- end -}}
{{- end -}}

{{/*
server fullname
*/}}
{{- define "asserts.serverFullname" -}}
{{- if .Values.server.fullnameOverride -}}
{{- .Values.server.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{ include "asserts.fullname" . }}-server
{{- end -}}
{{- end -}}

{{/*
server common labels
*/}}
{{- define "asserts.serverLabels" -}}
{{ include "asserts.labels" . }}
app.kubernetes.io/component: server
{{- end }}

{{/*
server selector labels
*/}}
{{- define "asserts.serverSelectorLabels" -}}
{{ include "asserts.selectorLabels" . }}
app.kubernetes.io/component: server
{{- end }}

{{/*
redisgraph sentinel hosts
*/}}
{{- define "asserts.graphSentinelHosts" -}}
"{{.Values.redisgraph.fullnameOverride}}-node-0.{{.Values.redisgraph.fullnameOverride}}-headless.{{include "domain" .}}:26379,{{.Values.redisgraph.fullnameOverride}}-node-1.{{.Values.redisgraph.fullnameOverride}}-headless.{{include "domain" .}}:26379,{{.Values.redisgraph.fullnameOverride}}-node-2.{{.Values.redisgraph.fullnameOverride}}-headless.{{include "domain" .}}:26379"
{{- end }}

{{/*
redisearch sentinel hosts
*/}}
{{- define "asserts.searchSentinelHosts" -}}
"{{.Values.redisearch.fullnameOverride}}-node-0.{{.Values.redisearch.fullnameOverride}}-headless.{{include "domain" .}}:26379,{{.Values.redisearch.fullnameOverride}}-node-1.{{.Values.redisearch.fullnameOverride}}-headless.{{include "domain" .}}:26379,{{.Values.redisearch.fullnameOverride}}-node-2.{{.Values.redisearch.fullnameOverride}}-headless.{{include "domain" .}}:26379"
{{- end }}