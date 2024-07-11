{{- /*This defines the defaults that the privileged mode has for the agent's securityContext */ -}}
{{- define "nriKubernetes.kubelet.securityContext.privileged" -}}
runAsUser: 0
runAsGroup: 0
allowPrivilegeEscalation: true
privileged: true
readOnlyRootFilesystem: true
{{- end -}}



{{- /* This is the container security context for the agent */ -}}
{{- define "nriKubernetes.kubelet.securityContext.agentContainer" -}}
{{- $defaults := dict -}}
{{- if include "newrelic.common.privileged" . -}}
{{- $defaults = fromYaml ( include "nriKubernetes.kubelet.securityContext.privileged" . ) -}}
{{- else -}}
{{- $defaults = fromYaml ( include "nriKubernetes.securityContext.containerDefaults" . ) -}}
{{- end -}}

{{- $compatibilityLayer := include "newrelic.compatibility.securityContext" . | fromYaml -}}
{{- $commonLibrary := include "newrelic.common.securityContext.container" . | fromYaml -}}

{{- $finalSecurityContext := dict -}}
{{- if $commonLibrary -}}
    {{- $finalSecurityContext = mustMergeOverwrite $commonLibrary $compatibilityLayer -}}
{{- else -}}
    {{- $finalSecurityContext = mustMergeOverwrite $defaults $compatibilityLayer -}}
{{- end -}}

{{- toYaml $finalSecurityContext -}}
{{- end -}}
