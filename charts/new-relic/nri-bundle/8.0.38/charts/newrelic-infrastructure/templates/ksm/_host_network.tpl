{{/* Returns whether the ksm scraper should run with hostNetwork: true based on the user configuration. */}}
{{- define "nriKubernetes.ksm.hostNetwork" -}}
{{- /* `get` will return "" (empty string) if value is not found, and the value otherwise, so we can type-assert with kindIs */ -}}
{{- if get .Values.ksm "hostNetwork" | kindIs "bool" -}}
    {{- if .Values.ksm.hostNetwork -}}
        {{- .Values.ksm.hostNetwork -}}
    {{- end -}}
{{- else if include "newrelic.common.hostNetwork" . -}}
    {{- include "newrelic.common.hostNetwork" . -}}
{{- end -}}
{{- end -}}



{{/* Abstraction of "nriKubernetes.ksm.hostNetwork" that returns true of false directly */}}
{{- define "nriKubernetes.ksm.hostNetwork.value" -}}
{{- if include "nriKubernetes.ksm.hostNetwork" . -}}
    true
{{- else -}}
    false
{{- end -}}
{{- end -}}
