{{/* Returns whether the kubelet scraper should run with hostNetwork: true based on the user configuration. */}}
{{- define "nriKubernetes.kubelet.hostNetwork" -}}
{{- /* `get` will return "" (empty string) if value is not found, and the value otherwise, so we can type-assert with kindIs */ -}}
{{- if get .Values.kubelet "hostNetwork" | kindIs "bool" -}}
    {{- if .Values.kubelet.hostNetwork -}}
        {{- .Values.kubelet.hostNetwork -}}
    {{- end -}}
{{- else if include "newrelic.common.hostNetwork" . -}}
    {{- include "newrelic.common.hostNetwork" . -}}
{{- end -}}
{{- end -}}



{{/* Abstraction of "nriKubernetes.kubelet.hostNetwork" that returns true of false directly */}}
{{- define "nriKubernetes.kubelet.hostNetwork.value" -}}
{{- if include "nriKubernetes.kubelet.hostNetwork" . -}}
    true
{{- else -}}
    false
{{- end -}}
{{- end -}}
