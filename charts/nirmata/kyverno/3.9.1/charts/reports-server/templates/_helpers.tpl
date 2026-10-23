{{/*
Expand the name of the chart.
*/}}
{{- define "reports-server.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "reports-server.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "reports-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "reports-server.labels" -}}
helm.sh/chart: {{ include "reports-server.chart" . }}
{{- if .Values.commonLabels }}
{{ include "reports-server.commonLabels" . }}
{{- end }}
{{ include "reports-server.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "reports-server.selectorLabels" -}}
app.kubernetes.io/name: {{ include "reports-server.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "reports-server.commonLabels" -}}
{{- with .Values.commonLabels }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "reports-server.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "reports-server.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Database config is injected into the environment and passed to the command line from there, if secretName is set, the values will be read from there .
*/}}
{{- define "reports-server.dbHost" -}}
{{- if .Values.config.db.secretName -}}
valueFrom:
  secretKeyRef:
    key: {{ .Values.config.db.hostSecretKeyName }}
    name: {{ .Values.config.db.secretName }}
{{- else -}}
value: {{ default (printf "%s-postgresql.%s" $.Release.Name $.Release.Namespace ) .Values.config.db.host | quote }}
{{- end }}
{{- end }}

{{/*
Quote a value for use as a YAML scalar, rendering a nil value as an empty string.

A bare `value: {{ .Values.x | quote }}` renders as `value:` (YAML null) when
`.Values.x` is nil, because sprig's `quote` skips nil arguments. GitOps tools
that apply with server-side apply (GKE Config Sync, Argo CD with ServerSideApply)
turn every null in the rendered manifest into `{}`, which the API server then
rejects, so no rendered field may be null (nirmata/enterprise-kyverno#1090).

Only nil is coerced. Every non-nil value, including falsy ones such as `0`,
`false` and `""`, is rendered exactly as `{{ . | quote }}` would, so this helper
changes nothing for any value that was already set. (`default "" .` would not
be safe here: `default` also replaces `0` and `false`, silently turning
`password: 0` into `""`.)

Usage: `value: {{ include "reports-server.quoteOrEmpty" .Values.config.db.port }}`
*/}}
{{- define "reports-server.quoteOrEmpty" -}}
{{- if kindIs "invalid" . -}}
""
{{- else -}}
{{ . | quote }}
{{- end -}}
{{- end }}

{{- define "reports-server.dbReadReplicaHosts" -}}
{{- if .Values.config.db.secretName -}}
valueFrom:
  secretKeyRef:
    key: {{ .Values.config.db.readReplicaHostsSecretKeyName }}
    name: {{ .Values.config.db.secretName }}
{{- else -}}
value: {{ include "reports-server.quoteOrEmpty" .Values.config.db.readReplicaHosts }}
{{- end }}
{{- end }}

{{- define "reports-server.dbPort" -}}
{{- if .Values.config.db.secretName -}}
valueFrom:
  secretKeyRef:
    key: {{ .Values.config.db.portSecretKeyName }}
    name: {{ .Values.config.db.secretName }}
{{- else -}}
value: {{ include "reports-server.quoteOrEmpty" .Values.config.db.port }}
{{- end }}
{{- end }}

{{- define "reports-server.dbName" -}}
{{- if .Values.config.db.secretName -}}
valueFrom:
  secretKeyRef:
    key: {{ .Values.config.db.dbNameSecretKeyName }}
    name: {{ .Values.config.db.secretName }}
{{- else -}}
value: {{ include "reports-server.quoteOrEmpty" .Values.config.db.name }}
{{- end }}
{{- end }}

{{- define "reports-server.dbUser" -}}
{{- if .Values.config.db.secretName -}}
valueFrom:
  secretKeyRef:
    key: {{ .Values.config.db.userSecretKeyName }}
    name: {{ .Values.config.db.secretName }}
{{- else -}}
value: {{ include "reports-server.quoteOrEmpty" .Values.config.db.user }}
{{- end }}
{{- end }}

{{- define "reports-server.dbPassword" -}}
{{- if .Values.config.db.secretName -}}
valueFrom:
  secretKeyRef:
    key: {{ .Values.config.db.passwordSecretKeyName }}
    name: {{ .Values.config.db.secretName }}
{{- else -}}
value: {{ include "reports-server.quoteOrEmpty" .Values.config.db.password }}
{{- end }}
{{- end }}

