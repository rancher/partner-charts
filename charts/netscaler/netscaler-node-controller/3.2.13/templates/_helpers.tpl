{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "netscaler-k8s-node-controller.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "netscaler-k8s-node-controller.fullname" -}}
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
{{- define "netscaler-k8s-node-controller.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Common labels
*/}}
{{- define "netscaler-k8s-node-controller.labels" -}}
helm.sh/chart: {{ include "netscaler-k8s-node-controller.chart" . }}
{{ include "netscaler-k8s-node-controller.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}


{{/*
Add Helm metadata to selector labels specifically for deployments/daemonsets/statefulsets.
*/}}
{{- define "netscaler-k8s-node-controller.selectorLabels" -}}
{{- if .Values.templating -}}
app.kubernetes.io/name: {{ include "netscaler-k8s-node-controller.name" . }}
{{- else -}}
app.kubernetes.io/name: {{ include "netscaler-k8s-node-controller.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "netscaler-k8s-node-controller.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "netscaler-k8s-node-controller.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}


{{/*
Create the name of the RBAC/ServiceAccount/ConfigMap/Prefix for router pods
*/}}
{{- define "netscaler-k8s-node-controller.nsncRouterName" -}}
{{- if .Values.nsncRouterName -}}
    {{ .Values.nsncRouterName | trunc 63 }}
{{- else -}}
    {{- printf "%s-%s" .Release.Name "kube-nsnc-router" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the ConfigMap that helm deploys and NSNC listens to add/delete configurations 
*/}}
{{- define "netscaler-k8s-node-controller.nsncConfigMap" -}}
{{- if .Values.nsncConfigMap.name -}}
    {{ .Values.nsncConfigMap.name | trunc 63 }}
{{- else -}}
    {{ include "netscaler-k8s-node-controller.fullname" . }}
{{- end -}}
{{- end -}}
