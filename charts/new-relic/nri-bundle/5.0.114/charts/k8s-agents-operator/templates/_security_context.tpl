{{- /*
A helper to return the container security context to apply to the manager.
*/ -}}
{{- define "k8s-agents-operator.manager.securityContext.container" -}}
{{- if .Values.controllerManager.manager.containerSecurityContext -}}
    {{- toYaml .Values.controllerManager.manager.containerSecurityContext -}}
{{- else if include "newrelic.common.securityContext.container" . -}}
    {{- include "newrelic.common.securityContext.container" . -}}
{{- end -}}
{{- end -}}