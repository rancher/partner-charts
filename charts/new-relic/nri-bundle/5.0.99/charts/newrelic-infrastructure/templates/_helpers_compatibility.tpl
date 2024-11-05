{{/*
Returns true if .Values.ksm.enabled is true and the legacy disableKubeStateMetrics is not set
*/}}
{{- define "newrelic.compatibility.ksm.enabled" -}}
{{- if and .Values.ksm.enabled (not .Values.disableKubeStateMetrics) -}}
true
{{- end -}}
{{- end -}}

{{/*
Returns legacy ksm values
*/}}
{{- define "newrelic.compatibility.ksm.legacyData" -}}
enabled: true
{{- if .Values.kubeStateMetricsScheme }}
scheme: {{ .Values.kubeStateMetricsScheme }}
{{- end -}}
{{- if .Values.kubeStateMetricsPort }}
port: {{ .Values.kubeStateMetricsPort }}
{{- end -}}
{{- if .Values.kubeStateMetricsUrl }}
staticURL: {{ .Values.kubeStateMetricsUrl }}
{{- end -}}
{{- if .Values.kubeStateMetricsPodLabel }}
selector: {{ printf "%s=kube-state-metrics" .Values.kubeStateMetricsPodLabel }}
{{- end -}}
{{- if  .Values.kubeStateMetricsNamespace }}
namespace: {{ .Values.kubeStateMetricsNamespace}}
{{- end -}}
{{- end -}}

{{/*
Returns the new value if available, otherwise falling back on the legacy one
*/}}
{{- define "newrelic.compatibility.valueWithFallback" -}}
{{- if .supported }}
{{- toYaml .supported}}
{{- else if .legacy -}}
{{- toYaml .legacy}}
{{- end }}
{{- end -}}

{{/*
Returns a dictionary with legacy runAsUser config
*/}}
{{- define "newrelic.compatibility.securityContext" -}}
{{- if  .Values.runAsUser -}}
{{ dict "runAsUser" .Values.runAsUser | toYaml }}
{{- end -}}
{{- end -}}

{{/*
Returns legacy annotations if available
*/}}
{{- define "newrelic.compatibility.annotations" -}}
{{- with  .Values.daemonSet -}}
{{- with  .annotations -}}
{{- toYaml . }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Returns agent configmap merged with legacy config and legacy eventQueueDepth config
*/}}
{{- define "newrelic.compatibility.agentConfig" -}}
{{- $oldConfig := deepCopy (.Values.config | default dict) -}}
{{- $newConfig := deepCopy .Values.common.agentConfig -}}
{{- $eventQueueDepth := dict -}}

{{- if .Values.eventQueueDepth -}}
{{- $eventQueueDepth = dict "event_queue_depth" .Values.eventQueueDepth -}}
{{- end -}}

{{- mustMergeOverwrite $oldConfig $newConfig $eventQueueDepth | toYaml -}}
{{- end -}}

{{- /*
Return a valid podSpec.affinity object from the old `.Values.nodeAffinity`.
*/ -}}
{{- define "newrelic.compatibility.nodeAffinity" -}}
{{- if .Values.nodeAffinity -}}
nodeAffinity:
  {{- toYaml .Values.nodeAffinity | nindent 2 }}
{{- end -}}
{{- end -}}

{{/*
Returns legacy integrations_config configmap data
*/}}
{{- define "newrelic.compatibility.integrations" -}}
{{- if .Values.integrations_config -}}
{{- range .Values.integrations_config }}
{{ .name -}}: |-
  {{- toYaml .data | nindent 2 }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "newrelic.compatibility.message.logFile" -}}
The 'logFile' option is no longer supported and has been replaced by:
 - common.agentConfig.log_file.

------
{{- end -}}

{{- define "newrelic.compatibility.message.resources" -}}
You have specified the legacy 'resources' option in your values, which is not fully compatible with the v3 version.
This version deploys three different components and therefore you'll need to specify resources for each of them.
Please use
 - ksm.resources,
 - controlPlane.resources,
 - kubelet.resources.

------
{{- end -}}

{{- define "newrelic.compatibility.message.apiServerSecurePort" -}}
You have specified the legacy 'apiServerSecurePort' option in your values, which is not fully compatible with the v3
version.
Please configure the API Server port as a part of 'apiServer.autodiscover[].endpoints'

------
{{- end -}}

{{- define "newrelic.compatibility.message.windows" -}}
nri-kubernetes v3 does not support deploying into windows Nodes.
Please use the latest 2.x version of the chart.

------
{{- end -}}

{{- define "newrelic.compatibility.message.etcdSecrets" -}}
Values "etcdTlsSecretName" and "etcdTlsSecretNamespace" are no longer supported, please specify them as a part of the
'etcd' config in the values, for example:
 - endpoints:
     - url: https://localhost:9979
       insecureSkipVerify: true
       auth:
         type: mTLS
         mtls:
           secretName: {{ .Values.etcdTlsSecretName | default "etcdTlsSecretName"}}
           secretNamespace: {{ .Values.etcdTlsSecretNamespace | default "etcdTlsSecretNamespace"}}

------
{{- end -}}

{{- define "newrelic.compatibility.message.apiURL" -}}
Values "controllerManagerEndpointUrl", "etcdEndpointUrl", "apiServerEndpointUrl", "schedulerEndpointUrl" are no longer
supported, please specify them as a part of the 'controlplane' config in the values, for example
  autodiscover:
    - selector: "tier=control-plane,component=etcd"
      namespace: kube-system
      matchNode: true
      endpoints:
        - url: https://localhost:4001
          insecureSkipVerify: true
          auth:
            type: bearer

------
{{- end -}}

{{- define "newrelic.compatibility.message.image" -}}
Configuring image repository an tag under 'image' is no longer supported.
The following values are no longer supported and are currently ignored:
 - image.repository
 - image.tag
 - image.pullPolicy
 - image.pullSecrets

Notice that the 3.x version of the integration uses 3 different images.
Please set:
 - images.forwarder.* to configure the infrastructure-agent forwarder.
 - images.agent.* to configure the image bundling the infrastructure-agent and on-host integrations.
 - images.integration.* to configure the image in charge of scraping k8s data.

------
{{- end -}}

{{- define "newrelic.compatibility.message.customAttributes" -}}
We still support using custom attributes but we support it as a map and dropped it as a string.
customAttributes: {{ .Values.customAttributes | quote }}

You should change your values to something like this:

customAttributes:
{{- range $k, $v := fromJson .Values.customAttributes -}}
  {{- $k | nindent 2 }}: {{ $v | quote }}
{{- end }}

**NOTE**: If you read above errors like "invalid character ':' after top-level value" or "json: cannot unmarshal string into Go value of type map[string]interface {}" means that the string you have in your values is not a valid JSON, Helm is not able to parse it and we could not show you how you should change it. Sorry.
{{- end -}}

{{- define "newrelic.compatibility.message.common" -}}
######
The chart cannot be rendered since the values listed below are not supported. Please replace those with the new ones compatible with newrelic-infrastructure V3.

Keep in mind that the flag "--reuse-values" is not supported when migrating from V2 to V3.
Further information can be found in the official docs https://docs.newrelic.com/docs/kubernetes-pixie/kubernetes-integration/get-started/changes-since-v3#migration-guide"
######
{{- end -}}
