{{/*
Expand the name of the chart.
*/}}
{{- define "triggermesh.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "triggermesh.fullname" -}}
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
{{- define "triggermesh.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "triggermesh.labels" -}}
helm.sh/chart: {{ include "triggermesh.chart" . }}
{{ include "triggermesh.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: triggermesh
{{- end }}

{{/*
Selector labels
*/}}
{{- define "triggermesh.selectorLabels" -}}
app.kubernetes.io/name: {{ include "triggermesh.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "triggermesh.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "triggermesh.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Controller Service Account Name
*/}}
{{- define "triggermesh.controller.serviceAccountName" -}}
{{- $name := include "triggermesh.serviceAccountName" . }}
{{- printf "%s-%s" $name "controller" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Controller FQDN
*/}}
{{- define "triggermesh.controller.fullname" -}}
{{- $name := include "triggermesh.fullname" . }}
{{- printf "%s-%s" $name "controller" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Controller labels
*/}}
{{- define "triggermesh.controller.labels" -}}
{{ include "triggermesh.labels" . }}
app: triggermesh-controller
{{- end }}

{{/*
Controller Selector labels
*/}}
{{- define "triggermesh.controller.selectorLabels" -}}
{{ include "triggermesh.selectorLabels" . }}
app: triggermesh-controller
{{- end }}

{{/*
Webhook Service Account Name
*/}}
{{- define "triggermesh.webhook.serviceAccountName" -}}
{{- $name := include "triggermesh.serviceAccountName" . }}
{{- printf "%s-%s" $name "webhook" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Webhook FQDN
*/}}
{{- define "triggermesh.webhook.fullname" -}}
{{- $name := include "triggermesh.fullname" . }}
{{- printf "%s-%s" $name "webhook" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Webhook labels
*/}}
{{- define "triggermesh.webhook.labels" -}}
{{ include "triggermesh.labels" . }}
app: triggermesh-webhook
{{- end }}

{{/*
Webhook Selector labels
*/}}
{{- define "triggermesh.webhook.selectorLabels" -}}
{{ include "triggermesh.selectorLabels" . }}
app: triggermesh-webhook
{{- end }}

