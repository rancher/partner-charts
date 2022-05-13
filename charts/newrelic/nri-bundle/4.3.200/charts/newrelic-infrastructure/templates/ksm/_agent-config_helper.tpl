{{- /*
Defaults for ksm's agent config
*/ -}}
{{- define "nriKubernetes.ksm.agentConfig.defaults" -}}
is_forward_only: true
overide_host_root: ""  # Typo from here: https://github.com/newrelic/infrastructure-agent/blob/master/pkg/config/config.go#L267
http_server_enabled: true
http_server_port: 8002
{{- end -}}



{{- define "nriKubernetes.ksm.agentConfig" -}}
{{- $agentDefaults := fromYaml ( include "newrelic.common.agentConfig.defaults" . ) -}}
{{- $ksm := fromYaml ( include "nriKubernetes.ksm.agentConfig.defaults" . ) -}}
{{- $agentConfig := fromYaml ( include "newrelic.compatibility.agentConfig" . ) -}}
{{- $customAttributes := dict "custom_attributes" (dict "clusterName" (include "newrelic.common.cluster" . )) -}}

{{- mustMergeOverwrite $agentDefaults $ksm $agentConfig $customAttributes | toYaml -}}
{{- end -}}
