{{- /* Naming helpers*/ -}}
{{- define "nriKubernetes.ksm.fullname" -}}
{{- include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "nriKubernetes.naming.fullname" .) "suffix" "ksm") -}}
{{- end -}}

{{- define "nriKubernetes.ksm.fullname.agent" -}}
{{- include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "nriKubernetes.naming.fullname" .) "suffix" "agent-ksm") -}}
{{- end -}}
