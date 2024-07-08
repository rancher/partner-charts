{{/* vim: set filetype=mustache: */}}

{{- define "nri-kube-events.securityContext.pod" -}}
{{- $defaults := fromYaml ( include "nriKubernetes.securityContext.podDefaults" . ) -}}
{{- $compatibilityLayer := include "nri-kube-events.compatibility.securityContext.pod" . | fromYaml -}}
{{- $commonLibrary := fromYaml ( include "newrelic.common.securityContext.pod" . ) -}}

{{- $finalSecurityContext := dict -}}
{{- if $commonLibrary -}}
    {{- $finalSecurityContext = mustMergeOverwrite $commonLibrary $compatibilityLayer  -}}
{{- else -}}
    {{- $finalSecurityContext = mustMergeOverwrite $defaults $compatibilityLayer  -}}
{{- end -}}
{{- toYaml $finalSecurityContext -}}
{{- end -}}



{{- /* These are the defaults that are used for all the containers in this chart */ -}}
{{- define "nriKubernetes.securityContext.podDefaults" -}}
runAsUser: 1000
runAsNonRoot: true
{{- end -}}



{{- define "nri-kube-events.securityContext.container" -}}
{{- if include "newrelic.common.securityContext.container" . -}}
{{- include "newrelic.common.securityContext.container" . -}}
{{- else -}}
privileged: false
allowPrivilegeEscalation: false
readOnlyRootFilesystem: true
{{- end -}}
{{- end -}}



{{- /*  */ -}}
{{- define "nri-kube-events.agentConfig" -}}
is_forward_only: true
http_server_enabled: true
http_server_port: 8001
{{ include "newrelic.common.agentConfig.defaults" . }}
{{- end -}}