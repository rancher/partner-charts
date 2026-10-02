{{/*
Expand the name of the chart.
*/}}
{{- define "runtime.name" -}}
    {{- printf "%s" (include "cf-runtime.name" .)  | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "runtime.fullname" -}}
    {{- printf "%s" (include "cf-runtime.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "runtime.labels" -}}
{{ include "cf-runtime.labels" . }}
codefresh.io/application: runtime
{{- end }}

{{/*
Selector labels
*/}}
{{- define "runtime.selectorLabels" -}}
{{ include "cf-runtime.selectorLabels" . }}
codefresh.io/application: runtime
{{- end }}

{{/*
Return runtime image (classic runtime) with private registry prefix
*/}}
{{- define "runtime.runtimeImageName" -}}
  {{- if .registry -}}
    {{- $imageName :=  (trimPrefix "quay.io/" .imageFullName) -}}
    {{- printf "%s/%s" .registry $imageName -}}
  {{- else -}}
    {{- printf "%s" .imageFullName -}}
  {{- end -}}
{{- end -}}

{{/*
Environment variable value of Codefresh installation token
*/}}
{{- define "runtime.installation-token-env-var-value" -}}
  {{- if .Values.global.codefreshToken }}
valueFrom:
  secretKeyRef:
    name: {{ include "runtime.installation-token-secret-name" . }}
    key: codefresh-api-token
  {{- else if .Values.global.codefreshTokenSecretKeyRef  }}
valueFrom:
  secretKeyRef:
  {{- .Values.global.codefreshTokenSecretKeyRef | toYaml | nindent 4 }}
  {{- end }}
{{- end }}

{{/*
Environment variable value of Codefresh agent token
*/}}
{{- define "runtime.agent-token-env-var-value" -}}
  {{- if .Values.global.agentToken }}
{{- printf "%s" .Values.global.agentToken | toYaml }}
  {{- else if .Values.global.agentTokenSecretKeyRef  }}
valueFrom:
  secretKeyRef:
  {{- .Values.global.agentTokenSecretKeyRef | toYaml | nindent 4 }}
  {{- end }}
{{- end }}

{{/*
Print Codefresh API token secret name
*/}}
{{- define "runtime.installation-token-secret-name" }}
{{- print "codefresh-user-token" }}
{{- end }}

{{/*
Print Codefresh host
*/}}
{{- define "runtime.runtime-environment-spec.codefresh-host" }}
{{- if and (not .Values.global.codefreshHost) }}
  {{- fail "ERROR: .global.codefreshHost is required" }}
{{- else }}
  {{- printf "%s" (trimSuffix "/" .Values.global.codefreshHost) }}
{{- end }}
{{- end }}

{{/*
Print runtime-environment name
*/}}
{{- define "runtime.runtime-environment-spec.runtime-name" }}
{{- if and (not .Values.global.runtimeName) }}
  {{- printf "%s/%s" .Values.global.context .Release.Namespace }}
{{- else }}
  {{- printf "%s" .Values.global.runtimeName }}
{{- end }}
{{- end }}

{{/*
Print agent name
*/}}
{{- define "runtime.runtime-environment-spec.agent-name" }}
{{- if and (not .Values.global.agentName) }}
  {{- printf "%s_%s" .Values.global.context .Release.Namespace }}
{{- else }}
  {{- printf "%s" .Values.global.agentName }}
{{- end }}
{{- end }}

{{/*
Print context
*/}}
{{- define "runtime.runtime-environment-spec.context-name" }}
{{- if and (not .Values.global.context) }}
  {{- fail "ERROR: .global.context is required" }}
{{- else }}
  {{- printf "%s" .Values.global.context }}
{{- end }}
{{- end }}

{{/*
Print normalized runtime-environment name
Usage:
{{ include "runtime.runtime-environment-spec.runtime-name-normalized" "runtimeName" $runtimeName ) }}
*/}}
{{- define "runtime.runtime-environment-spec.runtime-name-normalized" }}
  {{- $runtimeName := .runtimeName }}
  {{- printf "%s" ( trimPrefix "system/" $runtimeName | replace "_" "-" | replace "/" "-" | lower ) }}
{{- end }}

{{/*
Print normalized runtime-environment filename
Usage:
{{ include "runtime.runtime-environment-spec.runtime-filename-normalized" "runtimeName" $runtimeName ) }}
*/}}
{{- define "runtime.runtime-environment-spec.runtime-filename-normalized" }}
  {{- $runtimeName := .runtimeName }}
  {{- printf "%s.yaml" ( trimPrefix "system/" $runtimeName | replace "_" "-" | replace "/" "-" | lower ) }}
{{- end }}
