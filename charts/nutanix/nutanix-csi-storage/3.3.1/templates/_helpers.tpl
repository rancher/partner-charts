{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "nutanix-csi-storage.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "nutanix-csi-storage.fullname" -}}
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

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "nutanix-csi-storage.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create CSI driver name.
*/}}
{{- define "nutanix-csi-storage.drivername" -}}
{{- if .Values.legacy -}}
com.nutanix.csi
{{- else -}}
csi.nutanix.com
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "nutanix-csi-storage.labels" -}}
helm.sh/chart: {{ include "nutanix-csi-storage.chart" . }}
{{ include "nutanix-csi-storage.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if eq .Values.ntnxInitConfigMap.usePC true }}
app.kubernetes.io/management-plane: "PrismCentral"
{{- else }}
app.kubernetes.io/management-plane: "PrismElement"
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "nutanix-csi-storage.selectorLabels" -}}
app.kubernetes.io/name: {{ include "nutanix-csi-storage.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

