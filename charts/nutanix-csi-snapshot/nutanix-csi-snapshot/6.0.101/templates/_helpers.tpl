{{/*
Expand the name of the chart.
*/}}
{{- define "nutanix-csi-snapshot.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "nutanix-csi-snapshot.fullname" -}}
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
{{- define "nutanix-csi-snapshot.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "nutanix-csi-snapshot.labels" -}}
helm.sh/chart: {{ include "nutanix-csi-snapshot.chart" . }}
{{ include "nutanix-csi-snapshot.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "nutanix-csi-snapshot.selectorLabels" -}}
app.kubernetes.io/name: {{ include "nutanix-csi-snapshot.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "nutanix-csi-snapshot.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "nutanix-csi-snapshot.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Select the tag release based on the k8s version
*/}}
{{- define "nutanix-csi-snapshot.release" -}}
{{- if semverCompare ">=1.20-0"  .Capabilities.KubeVersion.Version }}
{{- .Values.tag.rel60 }}
{{- else }}
{{- .Values.tag.rel3 }}
{{- end }}
{{- end }}