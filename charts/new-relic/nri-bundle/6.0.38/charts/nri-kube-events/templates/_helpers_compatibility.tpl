{{/*
Returns a dictionary with legacy runAsUser config.
We know that it only has "one line" but it is separated from the rest of the helpers because it is a temporary things
that we should EOL. The EOL time of this will be marked when we GA the deprecation of Helm v2.
*/}}
{{- define "nri-kube-events.compatibility.securityContext.pod" -}}
{{- if .Values.runAsUser -}}
runAsUser: {{ .Values.runAsUser }}
{{- end -}}
{{- end -}}



{{- /*
Functions to get values from the globals instead of the common library
We make this because there could be difficult to see what is going under
the hood if we use the common-library here. So it is easy to read something
like:
{{- $registry := $oldRegistry | default $newRegistry | default $globalRegistry -}}
*/ -}}
{{- define "nri-kube-events.compatibility.global.registry" -}}
    {{- if .Values.global -}}
        {{- if .Values.global.images -}}
            {{- if .Values.global.images.registry -}}
                {{- .Values.global.images.registry -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
{{- end -}}

{{- /* Functions to fetch integration image configuration from the old .Values.image */ -}}
{{- /* integration's old registry */ -}}
{{- define "nri-kube-events.compatibility.old.integration.registry" -}}
    {{- if .Values.image -}}
        {{- if .Values.image.kubeEvents -}}
            {{- if .Values.image.kubeEvents.registry -}}
                {{- .Values.image.kubeEvents.registry -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
{{- end -}}

{{- /* integration's old repository */ -}}
{{- define "nri-kube-events.compatibility.old.integration.repository" -}}
    {{- if .Values.image -}}
        {{- if .Values.image.kubeEvents -}}
            {{- if .Values.image.kubeEvents.repository -}}
                {{- .Values.image.kubeEvents.repository -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
{{- end -}}

{{- /* integration's old tag */ -}}
{{- define "nri-kube-events.compatibility.old.integration.tag" -}}
    {{- if .Values.image -}}
        {{- if .Values.image.kubeEvents -}}
            {{- if .Values.image.kubeEvents.tag -}}
                {{- .Values.image.kubeEvents.tag -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
{{- end -}}

{{- /* integration's old imagePullPolicy */ -}}
{{- define "nri-kube-events.compatibility.old.integration.pullPolicy" -}}
    {{- if .Values.image -}}
        {{- if .Values.image.kubeEvents -}}
            {{- if .Values.image.kubeEvents.pullPolicy -}}
                {{- .Values.image.kubeEvents.pullPolicy -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
{{- end -}}

{{- /* Functions to fetch agent image configuration from the old .Values.image */ -}}
{{- /* agent's old registry */ -}}
{{- define "nri-kube-events.compatibility.old.agent.registry" -}}
    {{- if .Values.image -}}
        {{- if .Values.image.infraAgent -}}
            {{- if .Values.image.infraAgent.registry -}}
                {{- .Values.image.infraAgent.registry -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
{{- end -}}

{{- /* agent's old repository */ -}}
{{- define "nri-kube-events.compatibility.old.agent.repository" -}}
    {{- if .Values.image -}}
        {{- if .Values.image.infraAgent -}}
            {{- if .Values.image.infraAgent.repository -}}
                {{- .Values.image.infraAgent.repository -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
{{- end -}}

{{- /* agent's old tag */ -}}
{{- define "nri-kube-events.compatibility.old.agent.tag" -}}
    {{- if .Values.image -}}
        {{- if .Values.image.infraAgent -}}
            {{- if .Values.image.infraAgent.tag -}}
                {{- .Values.image.infraAgent.tag -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
{{- end -}}

{{- /* agent's old imagePullPolicy */ -}}
{{- define "nri-kube-events.compatibility.old.agent.pullPolicy" -}}
    {{- if .Values.image -}}
        {{- if .Values.image.infraAgent -}}
            {{- if .Values.image.infraAgent.pullPolicy -}}
                {{- .Values.image.infraAgent.pullPolicy -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
{{- end -}}



{{/*
Creates the image string needed to pull the integration image respecting the breaking change we made in the values file
Uses common-library functions to ensure proper registry precedence: local -> global -> docker.io
*/}}
{{- define "nri-kube-events.compatibility.images.integration" -}}
{{- /* Handle registry: old value takes precedence, otherwise use common-library (local -> global -> docker.io) */ -}}
{{- $oldRegistry := include "nri-kube-events.compatibility.old.integration.registry" . -}}
{{- $registry := "" -}}
{{- if $oldRegistry -}}
    {{- $registry = $oldRegistry -}}
{{- else -}}
    {{- $registry = include "newrelic.common.images.registry" ( dict "imageRoot" .Values.images.integration "context" .) -}}
{{- end -}}

{{- /* Handle repository: old value takes precedence */ -}}
{{- $oldRepository := include "nri-kube-events.compatibility.old.integration.repository" . -}}
{{- $repository := $oldRepository | default .Values.images.integration.repository -}}

{{- /* Handle tag: old value takes precedence, otherwise use common-library (value -> AppVersion) */ -}}
{{- $oldTag := include "nri-kube-events.compatibility.old.integration.tag" . -}}
{{- $tag := "" -}}
{{- if $oldTag -}}
    {{- $tag = $oldTag -}}
{{- else -}}
    {{- $tag = include "newrelic.common.images.tag" ( dict "imageRoot" .Values.images.integration "context" .) -}}
{{- end -}}

{{- /* Build image string - registry is always present due to docker.io fallback in common-library */ -}}
{{- printf "%s/%s:%s" $registry $repository $tag -}}
{{- end -}}



{{/*
Creates the image string needed to pull the agent's image respecting the breaking change we made in the values file
Uses common-library functions to ensure proper registry precedence: local -> global -> docker.io
*/}}
{{- define "nri-kube-events.compatibility.images.agent" -}}
{{- /* Handle registry: old value takes precedence, otherwise use common-library (local -> global -> docker.io) */ -}}
{{- $oldRegistry := include "nri-kube-events.compatibility.old.agent.registry" . -}}
{{- $registry := "" -}}
{{- if $oldRegistry -}}
    {{- $registry = $oldRegistry -}}
{{- else -}}
    {{- $registry = include "newrelic.common.images.registry" ( dict "imageRoot" .Values.images.agent "context" .) -}}
{{- end -}}

{{- /* Handle repository: old value takes precedence */ -}}
{{- $oldRepository := include "nri-kube-events.compatibility.old.agent.repository" . -}}
{{- $repository := $oldRepository | default .Values.images.agent.repository -}}

{{- /* Handle tag: old value takes precedence, otherwise use common-library (value -> AppVersion) */ -}}
{{- $oldTag := include "nri-kube-events.compatibility.old.agent.tag" . -}}
{{- $tag := "" -}}
{{- if $oldTag -}}
    {{- $tag = $oldTag -}}
{{- else -}}
    {{- $tag = include "newrelic.common.images.tag" ( dict "imageRoot" .Values.images.agent "context" .) -}}
{{- end -}}

{{- /* Build image string - registry is always present due to docker.io fallback in common-library */ -}}
{{- printf "%s/%s:%s" $registry $repository $tag -}}
{{- end -}}



{{/*
Returns the pull policy for the integration image taking into account that we made a breaking change on the values path.
*/}}
{{- define "nri-kube-events.compatibility.images.pullPolicy.integration" -}}
{{- $old := include "nri-kube-events.compatibility.old.integration.pullPolicy" . -}}
{{- $new := .Values.images.integration.pullPolicy -}}

{{- $old | default $new -}}
{{- end -}}



{{/*
Returns the pull policy for the agent image taking into account that we made a breaking change on the values path.
*/}}
{{- define "nri-kube-events.compatibility.images.pullPolicy.agent" -}}
{{- $old := include "nri-kube-events.compatibility.old.agent.pullPolicy" . -}}
{{- $new := .Values.images.agent.pullPolicy -}}

{{- $old | default $new -}}
{{- end -}}



{{/*
Returns a merged list of pull secrets ready to be used
*/}}
{{- define "nri-kube-events.compatibility.images.renderPullSecrets" -}}
{{- $list := list -}}

{{- if .Values.image -}}
    {{- if .Values.image.pullSecrets -}}
        {{- $list = append $list .Values.image.pullSecrets }}
    {{- end -}}
{{- end -}}

{{- if .Values.images.pullSecrets -}}
    {{- $list = append $list .Values.images.pullSecrets -}}
{{- end -}}

{{- include "newrelic.common.images.renderPullSecrets" ( dict "pullSecrets" $list "context" .) }}
{{- end -}}



{{- /* Messege to show to the user saying that image value is not supported anymore */ -}}
{{- define "nri-kube-events.compatibility.message.images" -}}
{{- $oldIntegrationRegistry := include "nri-kube-events.compatibility.old.integration.registry" . -}}
{{- $oldIntegrationRepository := include "nri-kube-events.compatibility.old.integration.repository" . -}}
{{- $oldIntegrationTag := include "nri-kube-events.compatibility.old.integration.tag" . -}}
{{- $oldIntegrationPullPolicy := include "nri-kube-events.compatibility.old.integration.pullPolicy" . -}}
{{- $oldAgentRegistry := include "nri-kube-events.compatibility.old.agent.registry" . -}}
{{- $oldAgentRepository := include "nri-kube-events.compatibility.old.agent.repository" . -}}
{{- $oldAgentTag := include "nri-kube-events.compatibility.old.agent.tag" . -}}
{{- $oldAgentPullPolicy := include "nri-kube-events.compatibility.old.agent.pullPolicy" . -}}

{{- if or $oldIntegrationRegistry $oldIntegrationRepository $oldIntegrationTag $oldIntegrationPullPolicy $oldAgentRegistry $oldAgentRepository $oldAgentTag $oldAgentPullPolicy }}
Configuring image repository an tag under 'image' is no longer supported.
This is the list values that we no longer support:
 - image.kubeEvents.registry
 - image.kubeEvents.repository
 - image.kubeEvents.tag
 - image.kubeEvents.pullPolicy
 - image.infraAgent.registry
 - image.infraAgent.repository
 - image.infraAgent.tag
 - image.infraAgent.pullPolicy

Please set:
 - images.agent.* to configure the infrastructure-agent forwarder.
 - images.integration.* to configure the image in charge of scraping k8s data.

------
{{- end }}
{{- end -}}



{{- /* Messege to show to the user saying that image value is not supported anymore */ -}}
{{- define "nri-kube-events.compatibility.message.securityContext.runAsUser" -}}
{{- if .Values.runAsUser }}
WARNING: `runAsUser` is deprecated
==================================

We have automatically translated your `runAsUser` setting to the new format, but this shimming will be removed in the
future. Please migrate your configs to the new format in the `securityContext` key.
{{- end }}
{{- end -}}
