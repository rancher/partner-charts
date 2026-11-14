{{/* vim: set filetype=mustache: */}}

{{- define "kyverno-notation-aws.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "kyverno-notation-aws.fullname" -}}
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

{{- define "kyverno-notation-aws.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "kyverno-notation-aws.chartVersion" -}}
{{- .Chart.Version | replace "+" "_" -}}
{{- end -}}

{{- define "kyverno-notation-aws.namespace" -}}
{{ default .Release.Namespace .Values.namespaceOverride }}
{{- end -}}

{{- define "kyverno-notation-aws.clusterRoleName" -}}
{{ include "kyverno-notation-aws.fullname" . }}-clusterrole
{{- end -}}

{{- define "kyverno-notation-aws.roleName" -}}
{{ include "kyverno-notation-aws.fullname" . }}-role
{{- end -}}

{{- define "kyverno-notation-aws.serviceAccountName" -}}
{{ default (include "kyverno-notation-aws.name" .) .Values.serviceAccount.name }}
{{- end -}}

{{- define "kyverno-notation-aws.serviceName" -}}
{{- printf "%s-svc" (include "kyverno-notation-aws.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "kyverno-notation-aws.configMap" -}}
{{ default (include "kyverno-notation-aws.name" .) .Values.configMap.name }}
{{- end -}}
