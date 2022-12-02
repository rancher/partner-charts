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
*/}}
{{- define "nri-kube-events.compatibility.images.integration" -}}
{{- $globalRegistry := include "nri-kube-events.compatibility.global.registry" . -}}
{{- $oldRegistry := include "nri-kube-events.compatibility.old.integration.registry" . -}}
{{- $newRegistry := .Values.images.integration.registry -}}
{{- $registry := $oldRegistry | default $newRegistry | default $globalRegistry -}}

{{- $oldRepository := include "nri-kube-events.compatibility.old.integration.repository" . -}}
{{- $newRepository := .Values.images.integration.repository -}}
{{- $repository := $oldRepository | default $newRepository }}

{{- $oldTag := include "nri-kube-events.compatibility.old.integration.tag" . -}}
{{- $newTag := .Values.images.integration.tag -}}
{{- $tag := $oldTag | default $newTag | default .Chart.AppVersion -}}

{{- if $registry -}}
    {{- printf "%s/%s:%s" $registry $repository $tag -}}
{{- else -}}
    {{- printf "%s:%s" $repository $tag -}}
{{- end -}}
{{- end -}}



{{/*
Creates the image string needed to pull the agent's image respecting the breaking change we made in the values file
*/}}
{{- define "nri-kube-events.compatibility.images.agent" -}}
{{- $globalRegistry := include "nri-kube-events.compatibility.global.registry" . -}}
{{- $oldRegistry := include "nri-kube-events.compatibility.old.agent.registry" . -}}
{{- $newRegistry := .Values.images.agent.registry -}}
{{- $registry := $oldRegistry | default $newRegistry | default $globalRegistry -}}

{{- $oldRepository := include "nri-kube-events.compatibility.old.agent.repository" . -}}
{{- $newRepository := .Values.images.agent.repository -}}
{{- $repository := $oldRepository | default $newRepository }}

{{- $oldTag := include "nri-kube-events.compatibility.old.agent.tag" . -}}
{{- $newTag := .Values.images.agent.tag -}}
{{- $tag := $oldTag | default $newTag -}}

{{- if $registry -}}
    {{- printf "%s/%s:%s" $registry $repository $tag -}}
{{- else -}}
    {{- printf "%s:%s" $repository $tag -}}
{{- end -}}
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
