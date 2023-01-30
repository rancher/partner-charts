{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "oxshibboleth.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "oxshibboleth.fullname" -}}
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
{{- define "oxshibboleth.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
     Common labels
*/}}
{{- define "oxshibboleth.labels" -}}
app: {{ .Release.Name }}-{{ include "oxshibboleth.name" . }}
helm.sh/chart: {{ include "oxshibboleth.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Create user custom defined  envs
*/}}
{{- define "oxshibboleth.usr-envs"}}
{{- range $key, $val := .Values.usrEnvs.normal }}
- name: {{ $key }}
  value: {{ $val | quote }}
{{- end }}
{{- end }}

{{/*
Create user custom defined secret envs
*/}}
{{- define "oxshibboleth.usr-secret-envs"}}
{{- range $key, $val := .Values.usrEnvs.secret }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Release.Name }}-{{ $.Chart.Name }}-user-custom-envs
      key: {{ $key | quote }}
{{- end }}
{{- end }}

{{/*
Create GLUU_JAVA_OPTIONS ENV for passing detailed logs
*/}}
{{- define "oxshibboleth.detailedLogs"}}
{{ $ldap := "" }}
{{ $messages := "" }}
{{ $encryption := "" }}
{{ $opensaml := "" }}
{{ $props := "" }}
{{ $httpclient := "" }}
{{ $spring := "" }}
{{ $container := "" }}
{{ $xmlsec := "" }}

{{- if .Values.global.oxshibboleth.appLoggers.ldapLogLevel }}
{{ $ldap = printf "-Didp.loglevel.ldap=%s " .Values.global.oxshibboleth.appLoggers.ldapLogLevel }}
{{- end}}
{{- if .Values.global.oxshibboleth.appLoggers.messagesLogLevel }}
{{ $messages = printf "-Didp.loglevel.messages=%s " .Values.global.oxshibboleth.appLoggers.messagesLogLevel }}
{{- end}}
{{- if .Values.global.oxshibboleth.appLoggers.encryptionLogLevel }}
{{ $encryption = printf "-Didp.loglevel.encryption=%s " .Values.global.oxshibboleth.appLoggers.encryptionLogLevel }}
{{- end}}
{{- if .Values.global.oxshibboleth.appLoggers.opensamlLogLevel }}
{{ $opensaml = printf "-Didp.loglevel.opensaml=%s " .Values.global.oxshibboleth.appLoggers.opensamlLogLevel }}
{{- end}}
{{- if .Values.global.oxshibboleth.appLoggers.propsLogLevel }}
{{ $props = printf "-Didp.loglevel.props=%s " .Values.global.oxshibboleth.appLoggers.propsLogLevel }}
{{- end}}
{{- if .Values.global.oxshibboleth.appLoggers.httpclientLogLevel }}
{{ $httpclient = printf "-Didp.loglevel.httpclient=%s " .Values.global.oxshibboleth.appLoggers.httpclientLogLevel }}
{{- end}}
{{- if .Values.global.oxshibboleth.appLoggers.springLogLevel }}
{{ $spring = printf "-Didp.loglevel.spring=%s " .Values.global.oxshibboleth.appLoggers.springLogLevel }}
{{- end}}
{{- if .Values.global.oxshibboleth.appLoggers.containerLogLevel }}
{{ $container = printf "-Didp.loglevel.container=%s " .Values.global.oxshibboleth.appLoggers.containerLogLevel }}
{{- end}}
{{- if .Values.global.oxshibboleth.appLoggers.xmlsecLogLevel }}
{{ $xmlsec = printf "-Didp.loglevel.xmlsec=%s " .Values.global.oxshibboleth.appLoggers.xmlsecLogLevel }}
{{- end}}

{{ $detailLogs := printf "%s%s%s%s%s%s%s%s%s" $ldap $messages $encryption $opensaml $props $httpclient $spring $container $xmlsec }}
{{ $detailLogs | trimSuffix " " | quote }}
{{- end }}

{{/*
Create topologySpreadConstraints lists
*/}}
{{- define "oxshibboleth.topology-spread-constraints"}}
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
      app: {{ $.Release.Name }}-{{ include "oxshibboleth.name" $ }}
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