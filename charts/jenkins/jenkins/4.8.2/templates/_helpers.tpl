{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "jenkins.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Expand the label of the chart.
*/}}
{{- define "jenkins.label" -}}
{{- printf "%s-%s" (include "jenkins.name" .) .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts.
*/}}
{{- define "jenkins.namespace" -}}
  {{- if .Values.namespaceOverride -}}
    {{- .Values.namespaceOverride -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{- define "jenkins.agent.namespace" -}}
  {{- if .Values.agent.namespace -}}
    {{- tpl .Values.agent.namespace . -}}
  {{- else -}}
    {{- if .Values.namespaceOverride -}}
      {{- .Values.namespaceOverride -}}
    {{- else -}}
      {{- .Release.Namespace -}}
    {{- end -}}
  {{- end -}}
{{- end -}}


{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "jenkins.fullname" -}}
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
Returns the admin password
https://github.com/helm/charts/issues/5167#issuecomment-619137759
*/}}
{{- define "jenkins.password" -}}
  {{ if .Values.controller.adminPassword -}}
    {{- .Values.controller.adminPassword | b64enc | quote }}
  {{- else -}}
    {{- $secret := (lookup "v1" "Secret" .Release.Namespace (include "jenkins.fullname" .)).data -}}
    {{- if $secret -}}
      {{/*
        Reusing current password since secret exists
      */}}
      {{- index $secret ( .Values.controller.admin.passwordKey | default "jenkins-admin-password" ) -}}
    {{- else -}}
      {{/*
          Generate new password
      */}}
      {{- randAlphaNum 22 | b64enc | quote }}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Returns the Jenkins URL
*/}}
{{- define "jenkins.url" -}}
{{- if .Values.controller.jenkinsUrl }}
  {{- .Values.controller.jenkinsUrl }}
{{- else }}
  {{- if .Values.controller.ingress.hostName }}
    {{- if .Values.controller.ingress.tls }}
      {{- default "https" .Values.controller.jenkinsUrlProtocol }}://{{ tpl .Values.controller.ingress.hostName $ }}{{ default "" .Values.controller.jenkinsUriPrefix }}
    {{- else }}
      {{- default "http" .Values.controller.jenkinsUrlProtocol }}://{{ tpl .Values.controller.ingress.hostName $ }}{{ default "" .Values.controller.jenkinsUriPrefix }}
    {{- end }}
  {{- else }}
      {{- default "http" .Values.controller.jenkinsUrlProtocol }}://{{ template "jenkins.fullname" . }}:{{.Values.controller.servicePort}}{{ default "" .Values.controller.jenkinsUriPrefix }}
  {{- end}}
{{- end}}
{{- end -}}

{{/*
Returns configuration as code default config
*/}}
{{- define "jenkins.casc.defaults" -}}
jenkins:
  {{- $configScripts := toYaml .Values.controller.JCasC.configScripts }}
  {{- if and (.Values.controller.JCasC.authorizationStrategy) (not (contains "authorizationStrategy:" $configScripts)) }}
  authorizationStrategy:
    {{- tpl .Values.controller.JCasC.authorizationStrategy . | nindent 4 }}
  {{- end }}
  {{- if and (.Values.controller.JCasC.securityRealm) (not (contains "securityRealm:" $configScripts)) }}
  securityRealm:
    {{- tpl .Values.controller.JCasC.securityRealm . | nindent 4 }}
  {{- end }}
  disableRememberMe: {{ .Values.controller.disableRememberMe }}
  {{- if .Values.controller.legacyRemotingSecurityEnabled }}
  remotingSecurity:
    enabled: true
  {{- end }}
  mode: {{ .Values.controller.executorMode }}
  numExecutors: {{ .Values.controller.numExecutors }}
  {{- if not (kindIs "invalid" .Values.controller.customJenkinsLabels) }}
  labelString: "{{ join " " .Values.controller.customJenkinsLabels }}"
  {{- end }}
  {{- if .Values.controller.projectNamingStrategy }}
  {{- if kindIs "string" .Values.controller.projectNamingStrategy }}
  projectNamingStrategy: "{{ .Values.controller.projectNamingStrategy }}"
  {{- else }}
  projectNamingStrategy:
    {{- toYaml .Values.controller.projectNamingStrategy | nindent 4 }}
  {{- end }}
  {{- end }}
  markupFormatter:
    {{- if .Values.controller.enableRawHtmlMarkupFormatter }}
    rawHtml:
      disableSyntaxHighlighting: true
    {{- else }}
    {{- toYaml .Values.controller.markupFormatter | nindent 4 }}
    {{- end }}
  clouds:
  - kubernetes:
      containerCapStr: "{{ .Values.agent.containerCap }}"
      {{- if .Values.agent.jnlpregistry }}
      jnlpregistry: "{{ .Values.agent.jnlpregistry }}"
      {{- end }}
      defaultsProviderTemplate: "{{ .Values.agent.defaultsProviderTemplate }}"
      connectTimeout: "{{ .Values.agent.kubernetesConnectTimeout }}"
      readTimeout: "{{ .Values.agent.kubernetesReadTimeout }}"
      {{- if .Values.agent.directConnection }}
      directConnection: true
      {{- else }}
      {{- if .Values.agent.jenkinsUrl }}
      jenkinsUrl: "{{ tpl .Values.agent.jenkinsUrl . }}"
      {{- else }}
      jenkinsUrl: "http://{{ template "jenkins.fullname" . }}.{{ template "jenkins.namespace" . }}.svc.{{.Values.clusterZone}}:{{.Values.controller.servicePort}}{{ default "" .Values.controller.jenkinsUriPrefix }}"
      {{- end }}
      {{- if not .Values.agent.websocket }}
      {{- if .Values.agent.jenkinsTunnel }}
      jenkinsTunnel: "{{ tpl .Values.agent.jenkinsTunnel . }}"
      {{- else }}
      jenkinsTunnel: "{{ template "jenkins.fullname" . }}-agent.{{ template "jenkins.namespace" . }}.svc.{{.Values.clusterZone}}:{{ .Values.controller.agentListenerPort }}"
      {{- end }}
      {{- else }}
      webSocket: true
      {{- end }}
      {{- end }}
      maxRequestsPerHostStr: {{ .Values.agent.maxRequestsPerHostStr | quote }}
      retentionTimeout: {{ .Values.agent.retentionTimeout | quote }}
      waitForPodSec: {{ .Values.agent.waitForPodSec | quote }}
      name: "{{ .Values.controller.cloudName }}"
      namespace: "{{ template "jenkins.agent.namespace" . }}"
      serverUrl: "{{ .Values.kubernetesURL }}"
      {{- if .Values.agent.enabled }}
      podLabels:
      - key: "jenkins/{{ .Release.Name }}-{{ .Values.agent.componentName }}"
        value: "true"
      {{- range $key, $val := .Values.agent.podLabels }}
      - key: {{ $key | quote }}
        value: {{ $val | quote }}
      {{- end }}
      templates:
    {{- if not .Values.agent.disableDefaultAgent }}
      {{- include "jenkins.casc.podTemplate" . | nindent 8 }}
    {{- end }}
    {{- if .Values.additionalAgents }}
      {{- /* save .Values.agent */}}
      {{- $agent := .Values.agent }}
      {{- range $name, $additionalAgent := .Values.additionalAgents }}
        {{- $additionalContainersEmpty := and (hasKey $additionalAgent "additionalContainers") (empty $additionalAgent.additionalContainers)  }}
        {{- /* merge original .Values.agent into additional agent to ensure it at least has the default values */}}
        {{- $additionalAgent := merge $additionalAgent $agent }}
        {{- /* clear list of additional containers in case it is configured empty for this agent (merge might have overwritten that) */}}
        {{- if $additionalContainersEmpty }}
        {{- $_ := set $additionalAgent "additionalContainers" list }}
        {{- end }}
        {{- /* set .Values.agent to $additionalAgent */}}
        {{- $_ := set $.Values "agent" $additionalAgent }}
        {{- include "jenkins.casc.podTemplate" $ | nindent 8 }}
      {{- end }}
      {{- /* restore .Values.agent */}}
      {{- $_ := set .Values "agent" $agent }}
    {{- end }}
      {{- if .Values.agent.podTemplates }}
        {{- range $key, $val := .Values.agent.podTemplates }}
          {{- tpl $val $ | nindent 8 }}
        {{- end }}
      {{- end }}
      {{- end }}
  {{- if .Values.controller.csrf.defaultCrumbIssuer.enabled }}
  crumbIssuer:
    standard:
      excludeClientIPFromCrumb: {{ if .Values.controller.csrf.defaultCrumbIssuer.proxyCompatability }}true{{ else }}false{{- end }}
  {{- end }}
{{- include "jenkins.casc.security" . }}
{{- if .Values.controller.scriptApproval }}
  scriptApproval:
    approvedSignatures:
{{- range $key, $val := .Values.controller.scriptApproval }}
    - "{{ $val }}"
{{- end }}
{{- end }}
unclassified:
  location:
    adminAddress: {{ default "" .Values.controller.jenkinsAdminEmail }}
    url: {{ template "jenkins.url" . }}
{{- end -}}

{{/*
Returns a name template to be used for jcasc configmaps, using
suffix passed in at call as index 0
*/}}
{{- define "jenkins.casc.configName" -}}
{{- $name := index . 0 -}}
{{- $root := index . 1 -}}
"{{- include "jenkins.fullname" $root -}}-jenkins-{{ $name }}"
{{- end -}}

{{/*
Returns kubernetes pod template configuration as code
*/}}
{{- define "jenkins.casc.podTemplate" -}}
- name: "{{ .Values.agent.podName }}"
  namespace: "{{ template "jenkins.agent.namespace" . }}"
{{- if .Values.agent.annotations }}
  annotations:
  {{- range $key, $value := .Values.agent.annotations }}
  - key: {{ $key }}
    value: {{ $value | quote }}
  {{- end }}
{{- end }}
  id: {{ sha256sum (toYaml .Values.agent) }}
  containers:
  - name: "{{ .Values.agent.sideContainerName }}"
    alwaysPullImage: {{ .Values.agent.alwaysPullImage }}
    args: "{{ .Values.agent.args | replace "$" "^$" }}"
    command: {{ .Values.agent.command }}
    envVars:
      - envVar:
        {{- if .Values.agent.directConnection }}
          key: "JENKINS_DIRECT_CONNECTION"
          {{- if .Values.agent.jenkinsTunnel }}
          value: "{{ tpl .Values.agent.jenkinsTunnel . }}"
          {{- else }}
          value: "{{ template "jenkins.fullname" . }}-agent.{{ template "jenkins.namespace" . }}.svc.{{.Values.clusterZone}}:{{ .Values.controller.agentListenerPort }}"
          {{- end }}
        {{- else }}
          key: "JENKINS_URL"
          {{- if .Values.agent.jenkinsUrl }}
          value: {{ tpl .Values.agent.jenkinsUrl . }}
          {{- else }}
          value: "http://{{ template "jenkins.fullname" . }}.{{ template "jenkins.namespace" . }}.svc.{{.Values.clusterZone}}:{{.Values.controller.servicePort}}{{ default "/" .Values.controller.jenkinsUriPrefix }}"
          {{- end }}
        {{- end }}
    image: "{{ .Values.agent.image }}:{{ .Values.agent.tag }}"
    {{- if .Values.agent.livenessProbe }}
    livenessProbe:
      execArgs: {{.Values.agent.livenessProbe.execArgs | quote}}
      failureThreshold: {{.Values.agent.livenessProbe.failureThreshold}}
      initialDelaySeconds: {{.Values.agent.livenessProbe.initialDelaySeconds}}
      periodSeconds: {{.Values.agent.livenessProbe.periodSeconds}}
      successThreshold: {{.Values.agent.livenessProbe.successThreshold}}
      timeoutSeconds: {{.Values.agent.livenessProbe.timeoutSeconds}}
    {{- end }}
    privileged: "{{- if .Values.agent.privileged }}true{{- else }}false{{- end }}"
    resourceLimitCpu: {{.Values.agent.resources.limits.cpu}}
    resourceLimitMemory: {{.Values.agent.resources.limits.memory}}
    {{- if .Values.agent.resources.limits.ephemeralStorage }}
    resourceLimitEphemeralStorage: {{.Values.agent.resources.limits.ephemeralStorage}}
    {{- end }}
    resourceRequestCpu: {{.Values.agent.resources.requests.cpu}}
    resourceRequestMemory: {{.Values.agent.resources.requests.memory}}
    {{- if .Values.agent.resources.requests.ephemeralStorage }}
    resourceRequestEphemeralStorage: {{.Values.agent.resources.requests.ephemeralStorage}}
    {{- end }}
    runAsUser: {{ .Values.agent.runAsUser }}
    runAsGroup: {{ .Values.agent.runAsGroup }}
    ttyEnabled: {{ .Values.agent.TTYEnabled }}
    workingDir: {{ .Values.agent.workingDir }}
{{- range $additionalContainers := .Values.agent.additionalContainers }}
  - name: "{{ $additionalContainers.sideContainerName }}"
    alwaysPullImage: {{ $additionalContainers.alwaysPullImage | default $.Values.agent.alwaysPullImage }}
    args: "{{ $additionalContainers.args | replace "$" "^$" }}"
    command: {{ $additionalContainers.command }}
    envVars:
      - envVar:
          key: "JENKINS_URL"
          {{- if $additionalContainers.jenkinsUrl }}
          value: {{ tpl ($additionalContainers.jenkinsUrl) . }}
          {{- else }}
          value: "http://{{ template "jenkins.fullname" $ }}.{{ template "jenkins.namespace" $ }}.svc.{{ $.Values.clusterZone }}:{{ $.Values.controller.servicePort }}{{ default "/" $.Values.controller.jenkinsUriPrefix }}"
          {{- end }}
    image: "{{ $additionalContainers.image }}:{{ $additionalContainers.tag }}"
    {{- if $additionalContainers.livenessProbe }}
    livenessProbe:
      execArgs: {{$additionalContainers.livenessProbe.execArgs | quote}}
      failureThreshold: {{$additionalContainers.livenessProbe.failureThreshold}}
      initialDelaySeconds: {{$additionalContainers.livenessProbe.initialDelaySeconds}}
      periodSeconds: {{$additionalContainers.livenessProbe.periodSeconds}}
      successThreshold: {{$additionalContainers.livenessProbe.successThreshold}}
      timeoutSeconds: {{$additionalContainers.livenessProbe.timeoutSeconds}}
    {{- end }}
    privileged: "{{- if $additionalContainers.privileged }}true{{- else }}false{{- end }}"
    resourceLimitCpu: {{ if $additionalContainers.resources }}{{ $additionalContainers.resources.limits.cpu }}{{ else }}{{ $.Values.agent.resources.limits.cpu }}{{ end }}
    resourceLimitMemory: {{ if $additionalContainers.resources }}{{ $additionalContainers.resources.limits.memory }}{{ else }}{{ $.Values.agent.resources.limits.memory }}{{ end }}
    resourceRequestCpu: {{ if $additionalContainers.resources }}{{ $additionalContainers.resources.requests.cpu }}{{ else }}{{ $.Values.agent.resources.requests.cpu }}{{ end }}
    resourceRequestMemory: {{ if $additionalContainers.resources }}{{ $additionalContainers.resources.requests.memory }}{{ else }}{{ $.Values.agent.resources.requests.memory }}{{ end }}
    runAsUser: {{ $additionalContainers.runAsUser | default $.Values.agent.runAsUser }}
    runAsGroup: {{ $additionalContainers.runAsGroup | default $.Values.agent.runAsGroup }}
    ttyEnabled: {{ $additionalContainers.TTYEnabled | default $.Values.agent.TTYEnabled }}
    workingDir: {{ $additionalContainers.workingDir | default $.Values.agent.workingDir }}
{{- end }}
{{- if or .Values.agent.envVars .Values.agent.secretEnvVars }}
  envVars:
  {{- range $index, $var := .Values.agent.envVars }}
    - envVar:
        key: {{ $var.name }}
        value: {{ tpl $var.value $ }}
  {{- end }}
  {{- range $index, $var := .Values.agent.secretEnvVars }}
    - secretEnvVar:
        key: {{ $var.key }}
        secretName: {{ $var.secretName }}
        secretKey: {{ $var.secretKey }}
        optional: {{ $var.optional | default false }}
  {{- end }}
{{- end }}
  idleMinutes: {{ .Values.agent.idleMinutes }}
  instanceCap: 2147483647
  {{- if .Values.agent.hostNetworking }}
  hostNetwork: {{ .Values.agent.hostNetworking }}
  {{- end }}
  {{- if .Values.agent.imagePullSecretName }}
  imagePullSecrets:
  - name: {{ .Values.agent.imagePullSecretName }}
  {{- end }}
  label: "{{ .Release.Name }}-{{ .Values.agent.componentName }} {{ .Values.agent.customJenkinsLabels  | join " " }}"
{{- if .Values.agent.nodeSelector }}
  nodeSelector:
  {{- $local := dict "first" true }}
  {{- range $key, $value := .Values.agent.nodeSelector }}
    {{- if $local.first }} {{ else }},{{ end }}
    {{- $key }}={{ tpl $value $ }}
    {{- $_ := set $local "first" false }}
  {{- end }}
{{- end }}
  nodeUsageMode: {{ quote .Values.agent.nodeUsageMode }}
  podRetention: {{ .Values.agent.podRetention }}
  showRawYaml: {{ .Values.agent.showRawYaml }}
  serviceAccount: "{{ include "jenkins.serviceAccountAgentName" . }}"
  slaveConnectTimeoutStr: "{{ .Values.agent.connectTimeout }}"
{{- if .Values.agent.volumes }}
  volumes:
  {{- range $index, $volume := .Values.agent.volumes }}
    -{{- if (eq $volume.type "ConfigMap") }} configMapVolume:
     {{- else if (eq $volume.type "EmptyDir") }} emptyDirVolume:
     {{- else if (eq $volume.type "HostPath") }} hostPathVolume:
     {{- else if (eq $volume.type "Nfs") }} nfsVolume:
     {{- else if (eq $volume.type "PVC") }} persistentVolumeClaim:
     {{- else if (eq $volume.type "Secret") }} secretVolume:
     {{- else }} {{ $volume.type }}:
     {{- end }}
    {{- range $key, $value := $volume }}
      {{- if not (eq $key "type") }}
        {{ $key }}: {{ if kindIs "string" $value }}{{ tpl $value $ | quote }}{{ else }}{{ $value }}{{ end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- if .Values.agent.workspaceVolume }}
  workspaceVolume:
    {{- if (eq .Values.agent.workspaceVolume.type "DynamicPVC") }}
    dynamicPVC:
    {{- else if (eq .Values.agent.workspaceVolume.type "EmptyDir") }}
    emptyDirWorkspaceVolume:
    {{- else if (eq .Values.agent.workspaceVolume.type "HostPath") }}
    hostPathWorkspaceVolume:
    {{- else if (eq .Values.agent.workspaceVolume.type "Nfs") }}
    nfsWorkspaceVolume:
    {{- else if (eq .Values.agent.workspaceVolume.type "PVC") }}
    persistentVolumeClaimWorkspaceVolume:
    {{- else }}
    {{ .Values.agent.workspaceVolume.type }}:
    {{- end }}
  {{- range $key, $value := .Values.agent.workspaceVolume }}
    {{- if not (eq $key "type") }}
      {{ $key }}: {{ if kindIs "string" $value }}{{ tpl $value $ | quote }}{{ else }}{{ $value }}{{ end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- if .Values.agent.yamlTemplate }}
  yaml: |-
    {{- tpl (trim .Values.agent.yamlTemplate) . | nindent 4 }}
{{- end }}
  yamlMergeStrategy: {{ .Values.agent.yamlMergeStrategy }}
{{- end -}}

{{- define "jenkins.kubernetes-version" -}}
  {{- if .Values.controller.installPlugins -}}
    {{- range .Values.controller.installPlugins -}}
      {{ if hasPrefix "kubernetes:" . }}
        {{- $split := splitList ":" . }}
        {{- printf "%s" (index $split 1 ) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "jenkins.casc.security" }}
security:
{{- with .Values.controller.JCasC }}
{{- if .security }}
  {{- .security | toYaml | nindent 2 }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "jenkins.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "jenkins.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account for Jenkins agents to use
*/}}
{{- define "jenkins.serviceAccountAgentName" -}}
{{- if .Values.serviceAccountAgent.create -}}
    {{ default (printf "%s-%s" (include "jenkins.fullname" .) "agent") .Values.serviceAccountAgent.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccountAgent.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account for Jenkins backup to use
*/}}
{{- define "backup.serviceAccountBackupName" -}}
{{- if .Values.backup.serviceAccount.create -}}
    {{ default (printf "%s-%s" (include "jenkins.fullname" .) "backup") .Values.backup.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.backup.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create a full tag name for controller image
*/}}
{{- define "controller.tag" -}}
{{- if .Values.controller.tagLabel -}}
    {{- default (printf "%s-%s" .Chart.AppVersion .Values.controller.tagLabel) .Values.controller.tag -}}
{{- else -}}
    {{- default .Chart.AppVersion .Values.controller.tag -}}
{{- end -}}
{{- end -}}

{{/*
Create the HTTP port for interacting with the controller
*/}}
{{- define "controller.httpPort" -}}
{{- if .Values.controller.httpsKeyStore.enable -}}
    {{- .Values.controller.httpsKeyStore.httpPort -}}
{{- else -}}
    {{- .Values.controller.targetPort -}}
{{- end -}}
{{- end -}}

{{- define "jenkins.configReloadContainer" -}}
{{- $root := index . 0 -}}
{{- $containerName := index . 1 -}}
{{- $containerType := index . 2 -}}
- name: {{ $containerName }}
  image: "{{ $root.Values.controller.sidecars.configAutoReload.image }}"
  imagePullPolicy: {{ $root.Values.controller.sidecars.configAutoReload.imagePullPolicy }}
  {{- if $root.Values.controller.sidecars.configAutoReload.containerSecurityContext }}
  securityContext: {{- toYaml $root.Values.controller.sidecars.configAutoReload.containerSecurityContext | nindent 4 }}
  {{- end }}
  {{- if $root.Values.controller.sidecars.configAutoReload.envFrom }}
  envFrom:
{{ (tpl (toYaml $root.Values.controller.sidecars.configAutoReload.envFrom) $root) | indent 4 }}
  {{- end }}
  env:
    - name: POD_NAME
      valueFrom:
        fieldRef:
          fieldPath: metadata.name
    - name: LABEL
      value: "{{ template "jenkins.fullname" $root }}-jenkins-config"
    - name: FOLDER
      value: "{{ $root.Values.controller.sidecars.configAutoReload.folder }}"
    - name: NAMESPACE
      value: '{{ $root.Values.controller.sidecars.configAutoReload.searchNamespace | default (include "jenkins.namespace" $root) }}'
    {{- if eq $containerType "init" }}
    - name: METHOD
      value: "LIST"
    {{- else if $root.Values.controller.sidecars.configAutoReload.sleepTime }}
    - name: METHOD
      value: "SLEEP"
    - name: SLEEP_TIME
      value: "{{ $root.Values.controller.sidecars.configAutoReload.sleepTime }}"
    {{- end }}
    {{- if eq $containerType "sidecar" }}
    - name: REQ_URL
      value: "http://localhost:{{- include "controller.httpPort" $root -}}{{- $root.Values.controller.jenkinsUriPrefix -}}/reload-configuration-as-code/?casc-reload-token=$(POD_NAME)"
    - name: REQ_METHOD
      value: "POST"
    - name: REQ_RETRY_CONNECT
      value: "{{ $root.Values.controller.sidecars.configAutoReload.reqRetryConnect }}"
    {{- end }}

    {{- if $root.Values.controller.sidecars.configAutoReload.env }}
    {{- range $envVarItem := $root.Values.controller.sidecars.configAutoReload.env -}}
        {{- if or (ne $containerType "init") (ne .name "METHOD") }}
{{- (tpl (toYaml (list $envVarItem)) $root) | nindent 4 }}
        {{- end -}}
    {{- end -}}
    {{- end }}

  resources:
{{ toYaml $root.Values.controller.sidecars.configAutoReload.resources | indent 4 }}
  volumeMounts:
    - name: sc-config-volume
      mountPath: {{ $root.Values.controller.sidecars.configAutoReload.folder | quote }}
    - name: jenkins-home
      mountPath: {{ $root.Values.controller.jenkinsHome }}
      {{- if $root.Values.persistence.subPath }}
      subPath: {{ $root.Values.persistence.subPath }}
      {{- end }}

{{- end -}}
