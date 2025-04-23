{{/*
Expand the name of the chart.
*/}}
{{- define "instana-agent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "instana-agent.fullname" -}}
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
{{- define "instana-agent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "instana-agent.labels" -}}
helm.sh/chart: {{ include "instana-agent.chart" . }}
app.kubernetes.io/name: instana-agent-operator
{{ include "instana-agent.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "instana-agent.selectorLabels" -}}
app.kubernetes.io/name: instana-agent-operator
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "instana-agent.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "instana-agent.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Composes a container image from a dict containing a "name" field (required), "tag" and "digest" (both optional, if both provided, "digest" has priority)
*/}}
{{- define "image" }}
{{- $name := .name }}
{{- $tag := .tag }}
{{- $digest := .digest }}
{{- if $digest }}
{{- printf "%s@sha256:%s" $name $digest }}
{{- else if $tag }}
{{- printf "%s:%s" $name $tag }}
{{- else }}
{{- print $name }}
{{- end }}
{{- end }}
