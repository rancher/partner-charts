{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "geo-logcursor.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "geo-logcursor.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Shorthand check for is this chart is enabled
*/}}
{{- define "geo-logcursor.enabled" -}}
{{- if eq true .Values.enabled -}}
{{-   if include "gitlab.geo.secondary" $ -}}
true
{{-   end -}}
{{- end -}}
{{- end -}}
