{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "alertmanager.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "alertmanager.fullname" -}}
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
{{- define "alertmanager.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "alertmanager.labels" -}}
helm.sh/chart: {{ include "alertmanager.chart" . }}
{{ include "alertmanager.selectorLabels" . }}
{{- with .Chart.AppVersion }}
app.kubernetes.io/version: {{ . | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/name: {{ include "alertmanager.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Selector labels

K10 NOTE:

  The selector labels here (`app` and `component`) are divergent from the
  selector labels set by the upstream chart. This is intentional since a
  Deployment's `spec.selector` is immutable and K10 has already been shipped
  with these values. However, we have always shipped with alertmanager disabled.

  If a customer had explicitly enabled alertmanager, a change to these selector
  labels will mean that all customers must manually delete the Deployment before
  upgrading, which is a situation we don't want for our customers.

  Instead, the `app.kubernetes.io/name` and `app.kubernetes.io/instance` labels
  are included in the `alertmanager.labels` block above.

*/}}
{{- define "alertmanager.selectorLabels" -}}
{{/*app.kubernetes.io/name: {{ include "alertmanager.name" . }}*/}}
{{/*app.kubernetes.io/instance: {{ .Release.Name }}*/}}
app: prometheus
component: alertmanager
release: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "alertmanager.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "alertmanager.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Define Ingress apiVersion
*/}}
{{- define "alertmanager.ingress.apiVersion" -}}
{{- printf "networking.k8s.io/v1" }}
{{- end }}

{{/*
Define Pdb apiVersion
*/}}
{{- define "alertmanager.pdb.apiVersion" -}}
{{- if $.Capabilities.APIVersions.Has "policy/v1/PodDisruptionBudget" }}
{{- printf "policy/v1" }}
{{- else }}
{{- printf "policy/v1beta1" }}
{{- end }}
{{- end }}

{{/*
Allow overriding alertmanager namespace
*/}}
{{- define "alertmanager.namespace" -}}
{{- if .Values.namespaceOverride -}}
{{- .Values.namespaceOverride -}}
{{- else -}}
{{- .Release.Namespace -}}
{{- end -}}
{{- end -}}
