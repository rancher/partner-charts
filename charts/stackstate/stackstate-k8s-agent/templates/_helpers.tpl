{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "stackstate-k8s-agent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "stackstate-k8s-agent.fullname" -}}
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
{{- define "stackstate-k8s-agent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "stackstate-k8s-agent.labels" -}}
app.kubernetes.io/name: {{ include "stackstate-k8s-agent.name" . }}
helm.sh/chart: {{ include "stackstate-k8s-agent.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Cluster agent checksum annotations
*/}}
{{- define "stackstate-k8s-agent.checksum-configs" }}
checksum/secret: {{ include (print $.Template.BasePath "/secret.yaml") . | sha256sum }}
{{- end }}

{{/*
StackState URL function
*/}}
{{- define "stackstate-k8s-agent.stackstate.url" -}}
{{ tpl .Values.stackstate.url . | quote }}
{{- end }}

{{- define "stackstate-k8s-agent.configmap.override.checksum" -}}
{{- if .Values.clusterAgent.config.override }}
checksum/override-configmap: {{ include (print $.Template.BasePath "/cluster-agent-configmap.yaml") . | sha256sum }}
{{- end }}
{{- end }}

{{- define "stackstate-k8s-agent.nodeAgent.configmap.override.checksum" -}}
{{- if .Values.nodeAgent.config.override }}
checksum/override-configmap: {{ include (print $.Template.BasePath "/node-agent-configmap.yaml") . | sha256sum }}
{{- end }}
{{- end }}

{{- define "stackstate-k8s-agent.logsAgent.configmap.override.checksum" -}}
checksum/override-configmap: {{ include (print $.Template.BasePath "/logs-agent-configmap.yaml") . | sha256sum }}
{{- end }}

{{- define "stackstate-k8s-agent.checksAgent.configmap.override.checksum" -}}
{{- if .Values.checksAgent.config.override }}
checksum/override-configmap: {{ include (print $.Template.BasePath "/checks-agent-configmap.yaml") . | sha256sum }}
{{- end }}
{{- end }}


{{/*
Return the image registry
*/}}
{{- define "stackstate-k8s-agent.imageRegistry" -}}
  {{- if .Values.global }}
    {{- .Values.global.imageRegistry | default .Values.all.image.registry -}}
  {{- else -}}
    {{- .Values.all.image.registry -}}
  {{- end -}}
{{- end -}}

{{/*
Renders a value that contains a template.
Usage:
{{ include "stackstate-k8s-agent.tplvalue.render" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "stackstate-k8s-agent.tplvalue.render" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{- define "stackstate-k8s-agent.pull-secret.name" -}}
{{ include "stackstate-k8s-agent.fullname" . }}-pull-secret
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names evaluating values as templates
{{ include "stackstate-k8s-agent.image.pullSecrets" ( dict "images" (list .Values.path.to.the.image1, .Values.path.to.the.image2) "context" $) }}
*/}}
{{- define "stackstate-k8s-agent.image.pullSecrets" -}}
  {{- $pullSecrets := list }}
  {{- $context := .context }}
  {{- if $context.Values.global }}
    {{- range $context.Values.global.imagePullSecrets -}}
      {{/* Is plain array of strings, compatible with all bitnami charts */}}
      {{- $pullSecrets = append $pullSecrets (include "stackstate-k8s-agent.tplvalue.render" (dict "value" . "context" $context)) -}}
    {{- end -}}
  {{- end -}}
  {{- range $context.Values.imagePullSecrets -}}
    {{- $pullSecrets = append $pullSecrets (include "stackstate-k8s-agent.tplvalue.render" (dict "value" .name "context" $context)) -}}
  {{- end -}}
  {{- range .images -}}
    {{- if .pullSecretName -}}
      {{- $pullSecrets = append $pullSecrets (include "stackstate-k8s-agent.tplvalue.render" (dict "value" .pullSecretName "context" $context)) -}}
    {{- end -}}
  {{- end -}}
  {{- $pullSecrets = append $pullSecrets (include "stackstate-k8s-agent.pull-secret.name" $context)  -}}
  {{- if (not (empty $pullSecrets)) -}}
imagePullSecrets:
    {{- range $pullSecrets | uniq }}
  - name: {{ . }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
Check whether the kubernetes-state-metrics configuration is overridden. If so, return 'true' else return nothing (which is false).
{{ include "stackstate-k8s-agent.kube-state-metrics.overridden" $ }}
*/}}
{{- define "stackstate-k8s-agent.kube-state-metrics.overridden" -}}
{{- if .Values.clusterAgent.config.override }}
  {{- range $i, $val := .Values.clusterAgent.config.override }}
    {{- if and (eq $val.name "conf.yaml") (eq $val.path "/etc/stackstate-agent/conf.d/kubernetes_state.d") }}
true
    {{- end }}
  {{- end }}
{{- end }}
{{- end -}}

{{- define "stackstate-k8s-agent.nodeAgent.kube-state-metrics.overridden" -}}
{{- if .Values.nodeAgent.config.override }}
  {{- range $i, $val := .Values.nodeAgent.config.override }}
    {{- if and (eq $val.name "auto_conf.yaml") (eq $val.path "/etc/stackstate-agent/conf.d/kubernetes_state.d") }}
true
    {{- end }}
  {{- end }}
{{- end }}
{{- end -}}

{{/*
Return the appropriate os label
*/}}
{{- define "label.os" -}}
{{- if semverCompare "^1.14-0" .Capabilities.KubeVersion.GitVersion -}}
kubernetes.io/os
{{- else -}}
beta.kubernetes.io/os
{{- end -}}
{{- end -}}

{{/*
Returns a YAML with extra annotations
*/}}
{{- define "stackstate-k8s-agent.global.extraAnnotations" -}}
{{- with .Values.global.extraAnnotations }}
{{- toYaml . }}
{{- end }}
{{- end -}}

{{/*
Returns a YAML with extra labels
*/}}
{{- define "stackstate-k8s-agent.global.extraLabels" -}}
{{- with .Values.global.extraLabels }}
{{- toYaml . }}
{{- end }}
{{- end -}}

{{- define "stackstate-k8s-agent.apiKeyEnv" -}}
- name: STS_API_KEY
  valueFrom:
    secretKeyRef:
{{- if not .Values.stackstate.manageOwnSecrets }}
      name: {{ include "stackstate-k8s-agent.fullname" . }}
      key: sts-api-key
{{- else }}
      name: {{ .Values.stackstate.customSecretName | quote }}
      key: {{ .Values.stackstate.customApiKeySecretKey | quote }}
{{- end }}
{{- end -}}

{{- define "stackstate-k8s-agent.clusterAgentAuthTokenEnv" -}}
- name: STS_CLUSTER_AGENT_AUTH_TOKEN
  valueFrom:
    secretKeyRef:
{{- if not .Values.stackstate.manageOwnSecrets }}
      name: {{ include "stackstate-k8s-agent.fullname" . }}
      key: sts-cluster-auth-token
{{- else }}
      name: {{ .Values.stackstate.customSecretName | quote }}
      key: {{ .Values.stackstate.customClusterAuthTokenSecretKey | quote }}
{{- end }}
{{- end -}}
