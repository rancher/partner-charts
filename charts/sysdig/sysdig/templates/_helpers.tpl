{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "sysdig.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sysdig.fullname" -}}
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
{{- define "sysdig.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "sysdig.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "sysdig.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the node analyzer specific service account to use
*/}}
{{- define "sysdig.nodeAnalyzer.serviceAccountName" -}}
{{- if .Values.nodeAnalyzer.serviceAccount.create -}}
    {{ default (include "sysdig.fullname" .) .Values.nodeAnalyzer.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.nodeAnalyzer.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Define the proper imageRegistry to use for agent and kmodule image
*/}}
{{- define "sysdig.imageRegistry" -}}
{{- if and .Values.global (hasKey (default .Values.global dict) "imageRegistry") -}}
    {{- .Values.global.imageRegistry -}}
{{- else -}}
    {{- .Values.image.registry -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper Sysdig Agent image name
*/}}
{{- define "sysdig.repositoryName" -}}
{{- if .Values.slim.enabled -}}
    {{- .Values.slim.image.repository -}}
{{- else -}}
    {{- .Values.image.repository -}}
{{- end -}}
{{- end -}}

{{- define "sysdig.image" -}}
{{- if .Values.image.overrideValue }}
    {{- printf .Values.image.overrideValue -}}
{{- else -}}
    {{- include "sysdig.imageRegistry" . -}} / {{- include "sysdig.repositoryName" . -}} {{- if .Values.image.digest -}} @ {{- .Values.image.digest -}} {{- else -}} : {{- .Values.image.tag -}} {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Sysdig Agent resources
*/}}
{{- define "sysdig.resources" -}}
{{/* we have same values for both requests and limits */}}
{{- $smallCpu := "1000m" -}}
{{- $smallMemory := "1024Mi" -}}
{{- $mediumCpu := "3000m" -}}
{{- $mediumMemory := "3072Mi" -}}
{{- $largeCpu := "5000m" -}}
{{- $largeMemory := "6144Mi" -}}
{{- if eq .Values.resourceProfile "small" -}}
{{- printf "requests:\n  cpu: %s\n  memory: %s\nlimits:\n  cpu: %s\n  memory: %s" $smallCpu $smallMemory $smallCpu $smallMemory -}}
{{- else if eq .Values.resourceProfile "medium" -}}
{{- printf "requests:\n  cpu: %s\n  memory: %s\nlimits:\n  cpu: %s\n  memory: %s" $mediumCpu $mediumMemory $mediumCpu $mediumMemory -}}
{{- else if eq .Values.resourceProfile "large" -}}
{{- printf "requests:\n  cpu: %s\n  memory: %s\nlimits:\n  cpu: %s\n  memory: %s" $largeCpu $largeMemory $largeCpu $largeMemory -}}
{{- else -}}{{/* "custom" or anything else falls here */}}
{{- toYaml .Values.resources -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper Sysdig Agent image name for module building
*/}}
{{- define "sysdig.image.kmodule" -}}
    {{- include "sysdig.imageRegistry" . -}} / {{- .Values.slim.kmoduleImage.repository -}} {{- if .Values.slim.kmoduleImage.digest -}} @ {{- .Values.slim.kmoduleImage.digest -}} {{- else -}} : {{- .Values.image.tag -}} {{- end -}}
{{- end -}}

{{/*
Return the proper Sysdig Agent image name for the Runtime Scanner
*/}}
{{- define "sysdig.image.runtimeScanner" -}}
    {{- include "sysdig.imageRegistry" . -}} / {{- .Values.nodeAnalyzer.runtimeScanner.image.repository -}} {{- if .Values.nodeAnalyzer.runtimeScanner.image.digest -}} @ {{- .Values.nodeAnalyzer.runtimeScanner.image.digest -}} {{- else -}} : {{- .Values.nodeAnalyzer.runtimeScanner.image.tag -}} {{- end -}}
{{- end -}}

{{/*
Return the proper Sysdig Agent image name for the Eve Connector
*/}}
{{- define "sysdig.image.eveConnector" -}}
    {{- include "sysdig.imageRegistry" . -}} / {{- .Values.nodeAnalyzer.runtimeScanner.eveConnector.image.repository -}} {{- if .Values.nodeAnalyzer.runtimeScanner.eveConnector.image.digest -}} @ {{- .Values.nodeAnalyzer.runtimeScanner.eveConnector.image.digest -}} {{- else -}} : {{- .Values.nodeAnalyzer.runtimeScanner.eveConnector.image.tag -}} {{- end -}}
{{- end -}}

{{/*
Return the proper Sysdig Agent image name for the Node Image Analyzer
*/}}
{{- define "sysdig.image.nodeImageAnalyzer" -}}
    {{- include "sysdig.imageRegistry" . -}} / {{- .Values.nodeImageAnalyzer.image.repository -}} {{- if .Values.nodeImageAnalyzer.image.digest -}} @ {{- .Values.nodeImageAnalyzer.image.digest -}} {{- else -}} : {{- .Values.nodeImageAnalyzer.image.tag -}} {{- end -}}
{{- end -}}

{{/*
Return the proper image name for the Image Analyzer
*/}}
{{- define "sysdig.image.imageAnalyzer" -}}
    {{- include "sysdig.imageRegistry" . -}} / {{- .Values.nodeAnalyzer.imageAnalyzer.image.repository -}} {{- if .Values.nodeAnalyzer.imageAnalyzer.image.digest -}} @ {{- .Values.nodeAnalyzer.imageAnalyzer.image.digest -}} {{- else -}} : {{- .Values.nodeAnalyzer.imageAnalyzer.image.tag -}} {{- end -}}
{{- end -}}

{{/*
Return the proper image name for the Host Analyzer
*/}}
{{- define "sysdig.image.hostAnalyzer" -}}
    {{- include "sysdig.imageRegistry" . -}} / {{- .Values.nodeAnalyzer.hostAnalyzer.image.repository -}} {{- if .Values.nodeAnalyzer.hostAnalyzer.image.digest -}} @ {{- .Values.nodeAnalyzer.hostAnalyzer.image.digest -}} {{- else -}} : {{- .Values.nodeAnalyzer.hostAnalyzer.image.tag -}} {{- end -}}
{{- end -}}

{{/*
Return the proper image name for the Benchmark Runner
*/}}
{{- define "sysdig.image.benchmarkRunner" -}}
    {{- include "sysdig.imageRegistry" . -}} / {{- .Values.nodeAnalyzer.benchmarkRunner.image.repository -}} {{- if .Values.nodeAnalyzer.benchmarkRunner.image.digest -}} @ {{- .Values.nodeAnalyzer.benchmarkRunner.image.digest -}} {{- else -}} : {{- .Values.nodeAnalyzer.benchmarkRunner.image.tag -}} {{- end -}}
{{- end -}}

{{/*
Return the proper image name for the KSPM Analyzer
*/}}
{{- define "sysdig.image.kspmAnalyzer" -}}
    {{- include "sysdig.imageRegistry" . -}} / {{- .Values.nodeAnalyzer.kspmAnalyzer.image.repository -}} {{- if .Values.nodeAnalyzer.kspmAnalyzer.image.digest -}} @ {{- .Values.nodeAnalyzer.kspmAnalyzer.image.digest -}} {{- else -}} : {{- .Values.nodeAnalyzer.kspmAnalyzer.image.tag -}} {{- end -}}
{{- end -}}

Return the proper image name for the KSPM Collector
*/}}
{{- define "sysdig.image.kspmCollector" -}}
    {{- include "sysdig.imageRegistry" . -}} / {{- .Values.kspmCollector.image.repository -}} {{- if .Values.kspmCollector.image.digest -}} @ {{- .Values.kspmCollector.image.digest -}} {{- else -}} : {{- .Values.kspmCollector.image.tag -}} {{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "sysdig.labels" -}}
helm.sh/chart: {{ include "sysdig.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app: "sysdig-agent"
{{- end -}}

{{/*
Daemonset labels
*/}}
{{- define "daemonset.labels" -}}
  {{- if .Values.daemonset.labels }}
    {{- $tp := typeOf .Values.daemonset.labels }}
    {{- if eq $tp "string" }}
      {{- tpl .Values.daemonset.labels . }}
    {{- else }}
      {{- toYaml .Values.daemonset.labels }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
Node Analyzer labels
*/}}
{{- define "nodeAnalyzer.labels" -}}
  {{- if .Values.nodeAnalyzer.labels }}
    {{- $tp := typeOf .Values.nodeAnalyzer.labels }}
    {{- if eq $tp "string" }}
      {{- tpl .Values.nodeAnalyzer.labels . }}
    {{- else }}
      {{- toYaml .Values.nodeAnalyzer.labels }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
Use like: {{ include "get_or_fail_if_in_settings" (dict "root" . "key" "<mypath.key>" "setting" "<agent_setting>") }}
Return the value of key "<mypath.key>" and if "<agent_setting>" is also defined in sysdig.settings.<agent_setting>, and error is thrown
NOTE: I don't like the error message! Too much information.
*/}}
{{- define "get_or_fail_if_in_settings" -}}
{{- $keyValue := tpl (printf "{{- .Values.%s -}}" .key) .root }}
{{- if $keyValue -}}
    {{- if hasKey .root.Values.sysdig.settings .setting }}{{ fail (printf "Value '%s' is also set via .sysdig.settings.%s'." .key .setting) }}{{- end -}}
    {{- $keyValue -}}
{{- end -}}
{{- end -}}

{{- define "deploy-nia" -}}
{{- if or .Values.nodeImageAnalyzer.deploy .Values.nodeImageAnalyzer.settings.collectorEndpoint -}}
true
{{- end -}}
{{- end -}}

{{- define "deploy-na" -}}
{{- if and (not (include "deploy-nia" .)) .Values.nodeAnalyzer.deploy -}}
true
{{- end -}}
{{- end -}}

{{/*
Sysdig Eve Connector service URL
*/}}
{{- define "eveconnector.host" -}}
{{ include "sysdig.fullname" .}}-eveconnector.{{ .Release.Namespace }}
{{- end -}}

{{/*
Sysdig Eve Connector Secret generation (if not exists)
*/}}
{{- define "eveconnector.token" -}}
{{- $secret := lookup "v1" "Secret" .Release.Namespace "sysdig-eve-secret" -}}
{{- if $secret -}}
{{ $secret.data.token }}
{{- else -}}
{{ randAlphaNum 32 | b64enc | quote }}
{{- end -}}
{{- end -}}

{{/*
to help the maxUnavailable and max_parallel_cold_starts pick a reasonable value depending on the cluster size
*/}}
{{- define "sysdig.parallelStarts" -}}
{{- if .Values.daemonset.updateStrategy.rollingUpdate.maxUnavailable -}}
    {{- .Values.daemonset.updateStrategy.rollingUpdate.maxUnavailable -}}
{{- else if eq .Values.resourceProfile "small" -}}
    {{- 1 -}}
{{- else if or (eq .Values.resourceProfile "medium") (eq .Values.resourceProfile "large") -}}
    {{- 10 -}}
{{- else -}}
    {{- 1 -}}
{{- end -}}
{{- end -}}

{{/*
Sysdig NATS service URL
*/}}
{{- define "sysdig.natsUrl" -}}
{{- if .Values.natsUrl -}}
    {{- .Values.natsUrl -}}
{{- else -}}
    wss://{{ .Values.nodeAnalyzer.apiEndpoint }}:443
{{- end -}}
{{- end -}}

{{- define "nodeAnalyzer.deployHostAnalyzer" -}}
{{- if or (not (hasKey .Values.nodeAnalyzer.hostAnalyzer "deploy")) .Values.nodeAnalyzer.hostAnalyzer.deploy }}
true
{{- end -}}
{{- end -}}

{{- define "nodeAnalyzer.deployBenchmarkRunner" -}}
{{- if or (not (hasKey .Values.nodeAnalyzer.benchmarkRunner "deploy")) .Values.nodeAnalyzer.benchmarkRunner.deploy }}
true
{{- end -}}
{{- end -}}

{{- define "nodeAnalyzer.deployImageAnalyzer" -}}
{{- if or (not (hasKey .Values.nodeAnalyzer.imageAnalyzer "deploy")) .Values.nodeAnalyzer.imageAnalyzer.deploy }}
true
{{- end -}}
{{- end -}}
