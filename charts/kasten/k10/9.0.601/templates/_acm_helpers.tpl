{{/*
Remote write config for ACM.
With mTLS (clientCertSecretName set): emits tls_config.
Without mTLS: emits THANOS-TENANT header.
*/}}
{{- define "k10.acm.remoteWriteConfig" -}}
name: acm
{{- if .Values.global.acm.tls.clientCertSecretName }}
tls_config:
  cert_file: /etc/prometheus/acm-client-cert/tls.crt
  key_file: /etc/prometheus/acm-client-cert/tls.key
{{- if .Values.global.acm.tls.serverCAConfigMapName }}
  ca_file: /etc/prometheus/acm-server-ca/ca.crt
{{- end }}
{{- if .Values.global.acm.tls.insecureSkipVerify }}
  insecure_skip_verify: true
{{- end }}
{{- else }}
headers:
  THANOS-TENANT: {{ include "k10.acm.hubThanosTenantId" . }}
{{- end }}
{{- end -}}

{{/*
Cluster ID: uses managedClusterId, falls back to OpenShift ClusterVersion lookup.
Returns empty string if neither is available.
*/}}
{{- define "k10.acm.openshiftClusterID" -}}
{{- $clusterId := .Values.global.acm.managedClusterId -}}
{{- if not $clusterId -}}
  {{- $clusterVersion := (lookup "config.openshift.io/v1" "ClusterVersion" "" "version") -}}
  {{- if $clusterVersion -}}
    {{- $clusterId = $clusterVersion.spec.clusterID -}}
  {{- end -}}
{{- end -}}
{{- $clusterId -}}
{{- end -}}

{{/* ACM Tenant ID (required). */}}
{{- define "k10.acm.hubThanosTenantId" -}}
{{- required "A valid .Values.global.acm.hubThanosTenantId is required when global.acm.enabled is true!" .Values.global.acm.hubThanosTenantId -}}
{{- end -}}

{{/*
Cluster name: uses clusterName, falls back to OpenShift Infrastructure lookup when ACM is enabled.
*/}}
{{- define "k10.acm.clusterName" -}}
{{- $clusterName := .Values.clusterName -}}
{{- if and .Values.global.acm.enabled (not $clusterName) -}}
  {{- $infrastructure := (lookup "config.openshift.io/v1" "Infrastructure" "" "cluster") -}}
  {{- if $infrastructure -}}
    {{- $clusterName = $infrastructure.status.infrastructureName -}}
  {{- end -}}
{{- end -}}
{{- $clusterName -}}
{{- end -}}

{{/*
True if a remote write entry targets ACM (named "acm", or unnamed with dashboardUrl/metricsRegex).
*/}}
{{- define "k10.acm.isAcmEntry" -}}
{{- $isUnnamedAcmEntry := and (not (hasKey . "name")) (or (hasKey . "dashboardUrl") (hasKey . "metricsRegex")) -}}
{{- if or (eq .name "acm") $isUnnamedAcmEntry -}}
true
{{- end -}}
{{- end -}}

{{/*
Merges ACM config into remote writes and converts extension fields (dashboardUrl, metricsRegex)
to write_relabel_configs. Returns JSON.
Params: .root (template context), .remoteWrites (list).
*/}}
{{- define "k10.acm.mergeRemoteWrites" -}}
{{- $remoteWrites := .remoteWrites | default list }}
{{- $acmEnabled := .root.Values.global.acm.enabled }}
{{- $acmRequired := dict }}
{{- if $acmEnabled }}
  {{- $acmRequiredStr := include "k10.acm.remoteWriteConfig" .root }}
  {{- $acmRequired = fromYaml $acmRequiredStr }}
{{- end }}

{{- $newRemoteWrites := list }}
{{- range $rw := $remoteWrites }}
  {{- $currentRw := deepCopy $rw }}
  {{- if and $acmEnabled $acmRequired (include "k10.acm.isAcmEntry" $rw) }}
    {{- $currentRw = mergeOverwrite $currentRw $acmRequired }}
  {{- end }}

  {{- $relabelConfigs := $currentRw.write_relabel_configs | default list }}
  {{- if hasKey $currentRw "dashboardUrl" }}
    {{- if $currentRw.dashboardUrl }}
      {{- $relabelConfigs = append $relabelConfigs (dict "target_label" "k10_dashboard_url" "replacement" $currentRw.dashboardUrl) }}
    {{- end }}
    {{- $_ := unset $currentRw "dashboardUrl" }}
  {{- end }}
  {{- if hasKey $currentRw "metricsRegex" }}
    {{- if $currentRw.metricsRegex }}
      {{- $relabelConfigs = append $relabelConfigs (dict "source_labels" (list "__name__") "regex" $currentRw.metricsRegex "action" "keep") }}
    {{- end }}
    {{- $_ := unset $currentRw "metricsRegex" }}
  {{- end }}
  {{- if $relabelConfigs }}
    {{- $_ := set $currentRw "write_relabel_configs" $relabelConfigs }}
  {{- end }}
  {{- $newRemoteWrites = append $newRemoteWrites $currentRw }}
{{- end }}

{{- mustToJson $newRemoteWrites }}
{{- end -}}

{{/*
Validates ACM and TLS configuration. Fails on missing required fields or inconsistent TLS settings.
*/}}
{{- define "k10.acm.validate" -}}
{{- if .Values.global.acm.enabled -}}
  {{- $clusterId := include "k10.acm.openshiftClusterID" . -}}
  {{- if not $clusterId -}}
    {{- fail "global.acm.managedClusterId is required when global.acm.enabled is true. Auto-detection of the cluster ID failed or is not supported on this platform. Please set .Values.global.acm.managedClusterId explicitly." -}}
  {{- end -}}
  {{- if and .Values.global.acm.tls.serverCAConfigMapName (not .Values.global.acm.tls.clientCertSecretName) -}}
    {{- fail "global.acm.tls.serverCAConfigMapName requires global.acm.tls.clientCertSecretName to be set. The CA certificate is only used for mTLS server verification." -}}
  {{- end -}}
  {{- if and .Values.global.acm.tls.insecureSkipVerify (not .Values.global.acm.tls.clientCertSecretName) -}}
    {{- fail "global.acm.tls.insecureSkipVerify requires global.acm.tls.clientCertSecretName to be set. insecureSkipVerify only applies when mTLS is active." -}}
  {{- end -}}
  {{- if and .Values.global.acm.tls.serverCAConfigMapName .Values.global.acm.tls.insecureSkipVerify -}}
    {{- fail "global.acm.tls.serverCAConfigMapName and global.acm.tls.insecureSkipVerify cannot both be set. Provide a CA config map for verification or enable insecureSkipVerify, but not both." -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/* Volume mounts for ACM mTLS certificates. Emits nothing when mTLS is not configured. */}}
{{- define "k10.acm.tlsVolumeMounts" -}}
{{- if and .Values.global.acm.enabled .Values.global.acm.tls.clientCertSecretName }}
- name: acm-client-cert
  mountPath: /etc/prometheus/acm-client-cert
  readOnly: true
{{- if .Values.global.acm.tls.serverCAConfigMapName }}
- name: acm-server-ca
  mountPath: /etc/prometheus/acm-server-ca
  readOnly: true
{{- end }}
{{- end }}
{{- end -}}

{{/* Volumes for ACM mTLS certificates. Emits nothing when mTLS is not configured. */}}
{{- define "k10.acm.tlsVolumes" -}}
{{- if and .Values.global.acm.enabled .Values.global.acm.tls.clientCertSecretName }}
- name: acm-client-cert
  secret:
    secretName: {{ .Values.global.acm.tls.clientCertSecretName }}
{{- if .Values.global.acm.tls.serverCAConfigMapName }}
- name: acm-server-ca
  configMap:
    name: {{ .Values.global.acm.tls.serverCAConfigMapName }}
{{- end }}
{{- end }}
{{- end -}}
