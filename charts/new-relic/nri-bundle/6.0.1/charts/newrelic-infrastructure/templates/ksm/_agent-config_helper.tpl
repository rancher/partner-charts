{{- /*
Defaults for ksm's agent config
*/ -}}
{{- define "nriKubernetes.ksm.agentConfig.defaults" -}}
is_forward_only: true
http_server_enabled: true
http_server_port: 8002
{{- end -}}



{{- define "nriKubernetes.ksm.agentConfig" -}}
{{- $agentDefaults := fromYaml ( include "newrelic.common.agentConfig.defaults" . ) -}}
{{- $ksm := fromYaml ( include "nriKubernetes.ksm.agentConfig.defaults" . ) -}}
{{- $agentConfig := fromYaml ( include "newrelic.compatibility.agentConfig" . ) -}}
{{- $ksmAgentConfig := .Values.ksm.agentConfig -}}
{{- $customAttributes := dict "custom_attributes" (dict "clusterName" (include "newrelic.common.cluster" . )) -}}

{{- mustMergeOverwrite $agentDefaults $ksm $agentConfig $ksmAgentConfig $customAttributes | toYaml -}}
{{- end -}}
