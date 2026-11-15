{{/*
Expand the name of the chart.
*/}}
{{- define "storage-metrics-server.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Fully qualified app name.
*/}}
{{- define "storage-metrics-server.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "storage-metrics-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "storage-metrics-server.labels" -}}
helm.sh/chart: {{ include "storage-metrics-server.chart" . }}
{{ include "storage-metrics-server.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "storage-metrics-server.selectorLabels" -}}
app.kubernetes.io/name: {{ include "storage-metrics-server.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "storage-metrics-server.serviceAccountName" -}}
{{ include "storage-metrics-server.fullname" . }}
{{- end -}}

{{/*
Returns the registry used for the storage-metrics-server docker image.
*/}}
{{- define "storage-metrics-server.image.registry" -}}
{{- list .Values.registryFQDN .Values.image.registry | compact | join "/" }}
{{- end -}}

{{/*
Returns whether the OpenShift distribution is used
*/}}
{{- define "storage-metrics-server.distro.openshift" -}}
{{- or (.Capabilities.APIVersions.Has "project.openshift.io/v1/Project") .Values.distro.openshift -}}
{{- end -}}

{{/*
Returns if ubi images are to be used
*/}}
{{- define "storage-metrics-server.image.ubi" -}}
{{ ternary "-ubi" "" (list "operator" "all" | has .Values.distro.ubi) }}
{{- end -}}
