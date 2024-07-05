{{/*
Expand the name of the chart.
*/}}
{{- define "triggermesh-core.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "triggermesh-core.fullname" -}}
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
{{- define "triggermesh-core.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "triggermesh-core.labels" -}}
helm.sh/chart: {{ include "triggermesh-core.chart" . }}
{{ include "triggermesh-core.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: triggermesh
{{- end }}

{{/*
Selector labels
*/}}
{{- define "triggermesh-core.selectorLabels" -}}
app.kubernetes.io/name: {{ include "triggermesh-core.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "triggermesh-core.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "triggermesh-core.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Controller Service Account Name
*/}}
{{- define "triggermesh-core.controller.serviceAccountName" -}}
{{- $name := include "triggermesh-core.serviceAccountName" . }}
{{- printf "%s-%s" $name "controller" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Controller FQDN
*/}}
{{- define "triggermesh-core.controller.fullname" -}}
{{- $name := include "triggermesh-core.fullname" . }}
{{- printf "%s-%s" $name "controller" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Controller labels
*/}}
{{- define "triggermesh-core.controller.labels" -}}
{{ include "triggermesh-core.labels" . }}
app: triggermesh-core
{{- end }}

{{/*
Controller Selector labels
*/}}
{{- define "triggermesh-core.controller.selectorLabels" -}}
{{ include "triggermesh-core.selectorLabels" . }}
app: triggermesh-core
{{- end }}
