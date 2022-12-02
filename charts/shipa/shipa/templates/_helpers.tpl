{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "shipa.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "shipa.fullname" -}}
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
{{- define "shipa.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "shipa.labels" -}}
helm.sh/chart: {{ include "shipa.chart" . }}
{{ include "shipa.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
release: {{ .Release.Name }}
app: {{ include "shipa.name" . }}
shipa.io/is-shipa: "true"
{{- end -}}

{{/*
Uninstall labels
*/}}
{{- define "shipa.uninstall-labels" -}}
helm.sh/chart: {{ include "shipa.chart" . }}
{{ include "shipa.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
release: {{ .Release.Name }}
app: {{ include "shipa.name" . }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "shipa.selectorLabels" -}}
app.kubernetes.io/name: {{ include "shipa.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
 If target CNAMEs are set by user in values.yaml, then use the first CNAME from
the list as main target since Shipa host can be only one in the shipa.conf
*/}}
{{- define "shipa.GetMainTarget" -}}
{{- if not (empty (splitList "," (trimPrefix "\n" (include "shipa.cnames" .)))) }}
{{- index (splitList "," (trimPrefix "\n" (include "shipa.cnames" .))) 0 | quote -}}
{{- else -}}
{{- printf " " | quote -}}
{{- end -}}
{{- end -}}

{{/*
 CNAMES is all defined cnames from values.yaml, with addition of api.<.Values.shipaCluster.ip>.shipa.cloud
 it should be used instead of shipaApi.cnames, as we always want to have this default address
*/}}
{{- define "shipa.cnames" -}}
{{- if has (printf "api.%s.shipa.cloud" .Values.shipaCluster.ingress.ip) .Values.shipaApi.cnames }}
{{ join "," .Values.shipaApi.cnames }}
{{- else }}
{{- if .Values.shipaCluster.ingress.ip }}
{{ join "," (append .Values.shipaApi.cnames (printf "api.%s.shipa.cloud" .Values.shipaCluster.ingress.ip)) }}
{{- else }}
{{ join "," .Values.shipaApi.cnames }}
{{- end }}
{{- end }}
{{- end }}

{{/*
 for shipa managed nginx we use shipa-nginx-ingress as classname
 for user managed nginx default is nginx, but user can modify it through values.yaml
*/}}
{{- define "shipa.defaultNginxClassName" }}
{{ if and (eq .Values.shipaCluster.ingress.type "nginx") (not .Values.shipaCluster.ingress.ip)}}
shipa-nginx-ingress
{{- else }}
nginx
{{- end }}
{{- end }}
