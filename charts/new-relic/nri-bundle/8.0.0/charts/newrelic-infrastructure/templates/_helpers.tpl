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
{{- if include "nriKubernetes.privileged" . -}}
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

TODO: Remove this
This is still being used instead of a full migration to newrelic.common.fargate
because we're checking global for fargate.
Removing this would be a minor breaking change.
*/}}
{{- define "newrelic.fargate" -}}
{{- if include "newrelic.common.fargate" . -}}
true
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

{{- define "nriKubernetes.controlPlane.enabled" -}}
{{- if and .Values.controlPlane.enabled (not (include "newrelic.common.gkeAutopilot" .) ) -}}
{{- .Values.controlPlane.enabled -}}
{{- end -}}
{{- end -}}

{{- define "nriKubernetes.privileged" -}}
{{- if and (include "newrelic.common.privileged" .) (not (include "newrelic.common.gkeAutopilot" .)) -}}
{{- include "newrelic.common.privileged" . -}}
{{- end -}}
{{- end -}}

{{/*
Windows-specific privileged mode check.
Returns the privileged mode for Windows nodes, checking windows.privileged first,
then falling back to the global privileged setting.
Outputs "true" when privileged, outputs nothing (empty string) when unprivileged.
*/}}
{{- define "nriKubernetes.windows.privileged" -}}
{{- if kindIs "bool" .Values.windows.privileged -}}
    {{- if .Values.windows.privileged -}}
        {{- .Values.windows.privileged -}}
    {{- end -}}
{{- else -}}
    {{- include "nriKubernetes.privileged" . -}}
{{- end -}}
{{- end -}}

{{- /* Windows Agent */ -}}
{{- define "nriKubernetes.windowsAgentImage" -}}
  {{ include "newrelic.common.images.image" ( dict "imageRoot" $.Values.images.windowsAgent "context" $ ) }}
{{- end}}

{{- /* Windows Integration */ -}}
{{- define "nriKubernetes.windowsIntegrationImage" -}}
  {{ include "newrelic.common.images.image" ( dict "imageRoot" $.Values.images.windowsIntegration "context" $ ) }}
{{- end}}



{{/*
Returns resources for the kubelet scraper container.
If .kubelet.resources is set it takes precedence over per-container values (behavior-change
period — .kubelet.resources will become pod-level once K8s pod-level resources are GA).
Otherwise uses the per-container .kubelet.kubelet.resources default.
*/}}
{{- define "nriKubernetes.kubelet.resources.kubelet" -}}
{{- if .Values.kubelet.resources -}}
{{- toYaml .Values.kubelet.resources -}}
{{- else -}}
{{- toYaml .Values.kubelet.kubelet.resources -}}
{{- end -}}
{{- end -}}

{{/*
Returns resources for the kubelet agent sidecar container.
If .kubelet.resources is set it takes precedence over per-container values (behavior-change
period — .kubelet.resources will become pod-level once K8s pod-level resources are GA).
Otherwise uses the per-container .kubelet.agent.resources default.
*/}}
{{- define "nriKubernetes.kubelet.resources.agent" -}}
{{- if .Values.kubelet.resources -}}
{{- toYaml .Values.kubelet.resources -}}
{{- else -}}
{{- toYaml .Values.kubelet.agent.resources -}}
{{- end -}}
{{- end -}}

{{/*
Returns resources for the Windows kubelet scraper container.
If .kubelet.resources is set it takes precedence over per-container values (behavior-change
period — .kubelet.resources will become pod-level once K8s pod-level resources are GA).
Otherwise uses the per-container .kubelet.windows.kubelet.resources default.
*/}}
{{- define "nriKubernetes.kubelet.resources.windows.kubelet" -}}
{{- if .Values.kubelet.resources -}}
{{- toYaml .Values.kubelet.resources -}}
{{- else -}}
{{- toYaml .Values.kubelet.windows.kubelet.resources -}}
{{- end -}}
{{- end -}}

{{/*
Returns resources for the Windows agent sidecar container.
If .kubelet.resources is set it takes precedence over per-container values (behavior-change
period — .kubelet.resources will become pod-level once K8s pod-level resources are GA).
Otherwise uses the per-container .kubelet.windows.agent.resources default.
*/}}
{{- define "nriKubernetes.kubelet.resources.windows.agent" -}}
{{- if .Values.kubelet.resources -}}
{{- toYaml .Values.kubelet.resources -}}
{{- else -}}
{{- toYaml .Values.kubelet.windows.agent.resources -}}
{{- end -}}
{{- end -}}

{{/*
Returns resources for the controlplane scraper container.
If .controlPlane.resources is set it takes precedence over per-container values (behavior-change
period — .controlPlane.resources will become pod-level once K8s pod-level resources are GA).
Otherwise uses the per-container .controlPlane.controlplane.resources default.
*/}}
{{- define "nriKubernetes.controlPlane.resources.controlplane" -}}
{{- if .Values.controlPlane.resources -}}
{{- toYaml .Values.controlPlane.resources -}}
{{- else -}}
{{- toYaml .Values.controlPlane.controlplane.resources -}}
{{- end -}}
{{- end -}}

{{/*
Returns resources for the controlplane forwarder sidecar container.
If .controlPlane.resources is set it takes precedence over per-container values (behavior-change
period — .controlPlane.resources will become pod-level once K8s pod-level resources are GA).
Otherwise uses the per-container .controlPlane.forwarder.resources default.
*/}}
{{- define "nriKubernetes.controlPlane.resources.forwarder" -}}
{{- if .Values.controlPlane.resources -}}
{{- toYaml .Values.controlPlane.resources -}}
{{- else -}}
{{- toYaml .Values.controlPlane.forwarder.resources -}}
{{- end -}}
{{- end -}}

