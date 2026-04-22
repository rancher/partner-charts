{{- /* Naming helpers*/ -}}
{{- define "nriKubernetes.controlplane.fullname" -}}
{{- include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "nriKubernetes.naming.fullname" .) "suffix" "controlplane") -}}
{{- end -}}

{{- define "nriKubernetes.controlplane.fullname.agent" -}}
{{- include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "nriKubernetes.naming.fullname" .) "suffix" "agent-controlplane") -}}
{{- end -}}

{{- define "nriKubernetes.controlplane.fullname.serviceAccount" -}}
{{- if include "newrelic.common.serviceAccount.create" . -}}
  {{- include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "nriKubernetes.naming.fullname" .) "suffix" "controlplane") -}}
{{- else -}}
  {{- include "newrelic.common.serviceAccount.name" . -}}
{{- end -}}
{{- end -}}
