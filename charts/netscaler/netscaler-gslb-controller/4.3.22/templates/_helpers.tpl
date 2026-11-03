{{/* vim: set filetype=mustache: */}}
{{/*
fetching sitedata and creating a dict of sites 
*/}}
{{- define "netscaler-gslb-controller.sites" -}}
{{- $sitesWithEnv := dict "sites" (list) -}}
{{- range $site := .Values.sitedata -}}
{{- $var := .siteName | append $sitesWithEnv.sites | set $sitesWithEnv "sites" -}}
{{- end -}}
{{ join "," $sitesWithEnv.sites }}
{{- end -}}

{{/*
Create keyname for siteip. Prefixed with sitename and postfixed with "_ip"
*/}}
{{- define "netscaler-gslb-controller.siteip" -}}
{{ printf "%s_%s" .siteName "ip"}}
{{- end -}}

{{/*
Create keyname for siteusername. Prefixed with sitename and postfixed with "_username"
*/}}
{{- define "netscaler-gslb-controller.siteusername" -}}
{{ printf "%s_%s" .siteName "username"}}
{{- end -}}

{{/*
Create keyname for sitepassword. Prefixed with sitename and postfixed with "_password"
*/}}
{{- define "netscaler-gslb-controller.sitepassword" -}}
{{ printf "%s_%s" .siteName "password"}}
{{- end -}}

{{/*
Create keyname for sitesyncpassword. Prefixed with sitename and postfixed with "_mep_password"
*/}}
{{- define "netscaler-gslb-controller.sitesyncpassword" -}}
{{ printf "%s_%s" .siteName "mep_password"}}
{{- end -}}

{{/*
Create keyname for siteregion. Prefixed with sitename and postfixed with "_region"
*/}}
{{- define "netscaler-gslb-controller.siteregion" -}}
{{ printf "%s_%s" .siteName "region"}}
{{- end -}}

{{/*
Create keyname for sitePublicip. Prefixed with sitename and postfixed with "_publicip"
*/}}
{{- define "netscaler-gslb-controller.sitePublicip" -}}
{{ printf "%s_%s" .siteName "publicip"}}
{{- end -}}

{{/*
Create keyname for siteMask. Prefixed with sitename and postfixed with "_mask"
*/}}
{{- define "netscaler-gslb-controller.siteMask" -}}
{{ printf "%s_%s" .siteName "mask"}}
{{- end -}}

{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "netscaler-gslb-controller.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" | lower -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "netscaler-gslb-controller.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride | lower -}}
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
{{- define "netscaler-gslb-controller.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" | lower -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "netscaler-gslb-controller.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "netscaler-gslb-controller.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create name of the configmap
*/}}
{{- define "gslbconfigmap.fullname" -}}
{{- $name := default .Chart.Name "gslb-configmap" .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
