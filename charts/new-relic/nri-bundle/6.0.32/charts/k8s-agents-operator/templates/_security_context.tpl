{{- /*
A helper to return the container security context to apply to the manager.
Implements 4-level precedence (highest to lowest):
1. controllerManager.manager.containerSecurityContext (component-specific, highest priority)
2. containerSecurityContext (chart-local value)
3. global.containerSecurityContext (global value)
4. Secure defaults: allowPrivilegeEscalation=false, capabilities.drop=[ALL] (lowest priority)

Precedence model: Uses the FIRST non-empty value found, then merges it with secure defaults.
This ensures local/manager values completely override global values (not merge with them).
*/ -}}
{{- define "k8s-agents-operator.manager.securityContext.container" -}}
  {{- /* Define secure defaults (lowest precedence) */ -}}
  {{- $defaults := dict "allowPrivilegeEscalation" false "capabilities" (dict "drop" (list "ALL")) -}}
  
  {{- /* Check precedence levels and use first non-empty value */ -}}
  {{- $userSecCtx := dict -}}
  {{- if .Values.controllerManager.manager.containerSecurityContext -}}
    {{- $userSecCtx = .Values.controllerManager.manager.containerSecurityContext -}}
  {{- else if .Values.containerSecurityContext -}}
    {{- $userSecCtx = .Values.containerSecurityContext -}}
  {{- else if .Values.global -}}
    {{- if .Values.global.containerSecurityContext -}}
      {{- $userSecCtx = .Values.global.containerSecurityContext -}}
    {{- end -}}
  {{- end -}}

  {{- /* Merge user config with defaults (user values take precedence) */ -}}
  {{- $merged := merge $userSecCtx $defaults -}}

  {{- if $merged -}}
    {{- toYaml $merged -}}
  {{- end -}}
{{- end -}}