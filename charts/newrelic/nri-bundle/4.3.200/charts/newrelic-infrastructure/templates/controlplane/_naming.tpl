{{- /* Naming helpers*/ -}}
{{- define "nriKubernetes.controlplane.fullname" -}}
{{- include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "nriKubernetes.naming.fullname" .) "suffix" "controlplane") -}}
{{- end -}}

{{- define "nriKubernetes.controlplane.fullname.agent" -}}
{{- include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "nriKubernetes.naming.fullname" .) "suffix" "agent-controlplane") -}}
{{- end -}}
