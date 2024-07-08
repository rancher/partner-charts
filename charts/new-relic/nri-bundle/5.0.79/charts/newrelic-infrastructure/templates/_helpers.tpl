{{/*
Create a default fully qualified app name.

This is a copy and paste from the common-library's name helper because the overriding system was broken.
As we have to change the logic to use "nrk8s" instead of `.Chart.Name` we need to maintain here a version
of the fullname helper

By default the full name will be "<release_name>" just in if it has "nrk8s" included in that, if not
it will be concatenated like "<release_name>-nrk8s". This could change if fullnameOverride or
nameOverride are set.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "nriKubernetes.naming.fullname" -}}
{{- $name := .Values.nameOverride | default "nrk8s" -}}

{{- if .Values.fullnameOverride -}}
    {{- $name = .Values.fullnameOverride  -}}
{{- else if not (contains $name .Release.Name) -}}
    {{- $name = printf "%s-%s" .Release.Name $name -}}
{{- end -}}

{{- include "newrelic.common.naming.truncateToDNS" $name -}}
{{- end -}}



{{- /* Naming helpers*/ -}}
{{- define "nriKubernetes.naming.secrets" }}
{{- include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "nriKubernetes.naming.fullname" .) "suffix" "secrets") -}}
{{- end -}}



{{- /* Return a YAML with the mode to be added to the labels */ -}}
{{- define "nriKubernetes._mode" -}}
{{- if include "newrelic.common.privileged" . -}}
    mode: privileged
{{- else -}}
    mode: unprivileged
{{- end -}}
{{- end -}}



{{/*
Add `mode` label to the labels that come from the common library for all the objects
*/}}
{{- define "nriKubernetes.labels" -}}
{{- $labels := include "newrelic.common.labels" . | fromYaml -}}
{{- $mode := fromYaml ( include "nriKubernetes._mode" . ) -}}

{{- mustMergeOverwrite $labels $mode | toYaml -}}
{{- end -}}



{{/*
Add `mode` label to the labels that come from the common library for podLabels
*/}}
{{- define "nriKubernetes.labels.podLabels" -}}
{{- $labels := include "newrelic.common.labels.podLabels" . | fromYaml -}}
{{- $mode := fromYaml ( include "nriKubernetes._mode" . ) -}}

{{- mustMergeOverwrite $labels $mode | toYaml -}}
{{- end -}}



{{/*
Returns fargate
*/}}
{{- define "newrelic.fargate" -}}
{{- if .Values.fargate -}}
  {{- .Values.fargate -}}
{{- else if .Values.global -}}
  {{- if .Values.global.fargate -}}
    {{- .Values.global.fargate -}}
  {{- end -}}
{{- end -}}
{{- end -}}



{{- define "newrelic.integrationConfigDefaults" -}}
{{- if include "newrelic.common.lowDataMode" . -}}
interval: 30s
{{- else  -}}
interval: 15s
{{- end -}}
{{- end -}}



{{- /* These are the defaults that are used for all the containers in this chart (except the kubelet's agent */ -}}
{{- define "nriKubernetes.securityContext.containerDefaults" -}}
runAsUser: 1000
runAsGroup: 2000
allowPrivilegeEscalation: false
readOnlyRootFilesystem: true
{{- end -}}



{{- /* Allow to change pod defaults dynamically based if we are running in privileged mode or not */ -}}
{{- define "nriKubernetes.securityContext.container" -}}
{{- $defaults := fromYaml ( include "nriKubernetes.securityContext.containerDefaults" . ) -}}
{{- $compatibilityLayer := include "newrelic.compatibility.securityContext" . | fromYaml -}}
{{- $commonLibrary := include "newrelic.common.securityContext.container" . | fromYaml -}}

{{- $finalSecurityContext := dict -}}
{{- if $commonLibrary -}}
    {{- $finalSecurityContext = mustMergeOverwrite $commonLibrary $compatibilityLayer  -}}
{{- else -}}
    {{- $finalSecurityContext = mustMergeOverwrite $defaults $compatibilityLayer  -}}
{{- end -}}

{{- toYaml $finalSecurityContext -}}
{{- end -}}
