{{- define "alchemi-keycloak.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "alchemi-keycloak.fullname" -}}
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

{{- define "alchemi-keycloak.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "alchemi-keycloak.labels" -}}
helm.sh/chart: {{ include "alchemi-keycloak.chart" . }}
{{ include "alchemi-keycloak.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: identity
{{- end }}

{{- define "alchemi-keycloak.selectorLabels" -}}
app.kubernetes.io/name: {{ include "alchemi-keycloak.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
ALCHEMISTUDIO PATCH 7 (umbrella 1.1.0): Keycloak is the "auth" tier. namespace wins when
set; otherwise global.namespaceMode=split puts it in "<global.namespacePrefix>-auth"
(the umbrella creates that namespace); single (default) = the release namespace.
*/}}
{{- define "alchemi-keycloak.namespace" -}}
{{- if .Values.namespace -}}{{ .Values.namespace }}
{{- else if eq ((.Values.global).namespaceMode | default "single") "split" -}}{{ printf "%s-auth" ((.Values.global).namespacePrefix | default "alchemistudio") }}
{{- else -}}{{ .Release.Namespace }}{{- end -}}
{{- end -}}
