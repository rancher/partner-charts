{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "keycloak-link.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "keycloak-link.fullname" -}}
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
{{- define "keycloak-link.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
    Common labels
*/}}
{{- define "keycloak-link.labels" -}}
app: {{ .Release.Name }}-{{ include "keycloak-link.name" . }}
helm.sh/chart: {{ include "keycloak-link.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Create user custom defined  envs
*/}}
{{- define "keycloak-link.usr-envs"}}
{{- range $key, $val := .Values.usrEnvs.normal }}
- name: {{ $key }}
  value: {{ $val | quote }}
{{- end }}
{{- end }}

{{/*
Create user custom defined secret envs
*/}}
{{- define "keycloak-link.usr-secret-envs"}}
{{- range $key, $val := .Values.usrEnvs.secret }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Release.Name }}-{{ $.Chart.Name }}-user-custom-envs
      key: {{ $key | quote }}
{{- end }}
{{- end }}

{{/*
Create JAVA_OPTIONS ENV for passing custom work and detailed logs
*/}}
{{- define "keycloak-link.customJavaOptions"}}
{{ $custom := "" }}
{{- $cnCustomJavaOptions := index .Values.global "keycloak-link" "cnCustomJavaOptions" }}
{{- $custom := printf "%s" $cnCustomJavaOptions }}
{{ $memory := .Values.resources.limits.memory | replace "Mi" "" | int -}}
{{- $maxDirectMemory := printf "-XX:MaxDirectMemorySize=%dm" ( mul (mulf $memory 0.41) 1 ) -}}
{{- $xmx := printf "-Xmx%dm" (sub $memory (mulf $memory 0.49)) -}}
{{- $customJavaOptions := printf "%s %s %s" $custom $maxDirectMemory $xmx -}}
{{ $customJavaOptions | trim | quote }}
{{- end }}

{{/*
Create topologySpreadConstraints lists
*/}}
{{- define "keycloak-link.topology-spread-constraints"}}
{{- range $key, $val := .Values.topologySpreadConstraints }}
- maxSkew: {{ $val.maxSkew }}
  {{- if $val.minDomains }}
  minDomains: {{ $val.minDomains }} # optional; beta since v1.25
  {{- end}}
  {{- if $val.topologyKey }}
  topologyKey: {{ $val.topologyKey }}
  {{- end}}
  {{- if $val.whenUnsatisfiable }}
  whenUnsatisfiable: {{ $val.whenUnsatisfiable }}
  {{- end}}
  labelSelector:
    matchLabels:
      app: {{ $.Release.Name }}-{{ include "keycloak-link.name" $ }}
  {{- if $val.matchLabelKeys }}
  matchLabelKeys: {{ $val.matchLabelKeys }} # optional; alpha since v1.25
  {{- end}}
  {{- if $val.nodeAffinityPolicy }}
  nodeAffinityPolicy: {{ $val.nodeAffinityPolicy }} # optional; alpha since v1.25
  {{- end}}
  {{- if $val.nodeTaintsPolicy }}
  nodeTaintsPolicy: {{ $val.nodeTaintsPolicy }} # optional; alpha since v1.25
  {{- end}}
{{- end }}
{{- end }}
