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
app.kubernetes.io/topology-enabled: "true"
{{- else }}
app.kubernetes.io/management-plane: "PrismElement"
{{- if eq .Values.ntnxInitConfigMap.usePETopology true }}
app.kubernetes.io/topology-enabled: "true"
{{- else }}
app.kubernetes.io/topology-enabled: "false"
{{- end }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "nutanix-csi-storage.selectorLabels" -}}
app.kubernetes.io/name: {{ include "nutanix-csi-storage.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
CSI Token Directory - Internal value, not user configurable
*/}}
{{- define "nutanix-csi-storage.csiTokenDir" -}}
/var/run/ntnx-token-dir
{{- end -}}

{{/*
CSI Token File - Internal value, not user configurable
*/}}
{{- define "nutanix-csi-storage.csiTokenFile" -}}
ntnx-jwt-secret
{{- end -}}

{{/*
PE Secrets Directory - Directory where PE secrets will be mounted inside CSI pods
*/}}
{{- define "nutanix-csi-storage.peSecretDir" -}}
/var/run/ntnx-pe-secret-dir
{{- end -}}


{{/*
Checks if topology aware provisioning is enabled in PE mode
*/}}
{{- define "isPETopologyEnabled" -}}
{{- if hasKey .Values.ntnxInitConfigMap "usePETopology" -}}
{{- if eq .Values.ntnxInitConfigMap.usePETopology true -}}
true
{{- else -}}
false
{{- end }}
{{- else -}}
false
{{- end -}}
{{- end}}

{{/*
Checks if the Helm chart is rendered in a live cluster rather than locally using helm template
*/}}
{{- define "nutanix-csi-storage.isChartRenderedInCluster" -}}
{{- $kubeSystemNs := (lookup "v1" "Namespace" "" "kube-system") -}}
{{- if $kubeSystemNs -}}
    {{- print "true" -}}
{{- else -}}
    {{- print "false" -}}
{{- end -}}
{{- end -}}