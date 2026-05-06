{{/* Returns whether the controlPlane scraper should run with hostNetwork: true based on the user configuration. */}}
{{- define "nriKubernetes.controlPlane.hostNetwork" -}}
{{- /* `get` will return "" (empty string) if value is not found, and the value otherwise, so we can type-assert with kindIs */ -}}
{{- if get .Values.controlPlane "hostNetwork" | kindIs "bool" -}}
    {{- if .Values.controlPlane.hostNetwork -}}
        {{- .Values.controlPlane.hostNetwork -}}
    {{- end -}}
{{- else if include "newrelic.common.hostNetwork" . -}}
    {{- include "newrelic.common.hostNetwork" . -}}
{{- end -}}
{{- end -}}



{{/* Abstraction of "nriKubernetes.controlPlane.hostNetwork" that returns true of false directly */}}
{{- define "nriKubernetes.controlPlane.hostNetwork.value" -}}
{{- if include "nriKubernetes.controlPlane.hostNetwork" . -}}
    true
{{- else -}}
    false
{{- end -}}
{{- end -}}
