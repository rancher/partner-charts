{{/*
Return true if storage capacity tracking is enabled and is supported based on k8s version
*/}}
{{- define "csi-vxflexos.isStorageCapacitySupported" -}}
  {{- if eq .Values.storageCapacity.enabled true -}}
    {{- if and (eq .Capabilities.KubeVersion.Major "1") (ge (trimSuffix "+" .Capabilities.KubeVersion.Minor) "24") -}}
        {{- true -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "vxflexos.validateVolumeNamePrefix" -}}
{{- if and .Values.authorization.enabled .Values.controller.replication.enabled -}}
  {{- if gt (len .Values.controller.volumeNamePrefix) 5 -}}
    {{- fail (printf "The volumeNamePrefix '%s' should not exceed the 5-character limit when both authorization and replication are enabled." .Values.volumeNamePrefix) -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return true if metrics is enabled
*/}}
{{- define "csi-vxflexos.isMetricsEnabled" -}}
{{- if hasKey .Values "metrics" -}}
  {{- if (eq .Values.metrics.enabled true) -}}
      {{- true -}}
  {{- else -}}
      {{- false -}}
  {{- end -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/*
Return true if volumeGroupSnapshot is enabled and properly configured
*/}}
{{- define "csi-vxflexos.isVgsnapshotEnabled" -}}
{{- if hasKey .Values.controller "volumeGroupSnapshot" -}}
  {{- if (eq .Values.controller.volumeGroupSnapshot.enabled true) -}}
      {{- true -}}
  {{- else -}}
      {{- false -}}
  {{- end -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/*
Return the leader election value for PowerFlex Gateway Monitoring.
Defaults to "true" when leaderElectionEnabled is not explicitly set.
*/}}
{{- define "csi-vxflexos.gatewayMonitoringLeaderElect" -}}
  {{- $leaderElect := true -}}
  {{- if hasKey .Values "metrics" -}}
    {{- if hasKey .Values.metrics "gatewayMonitoring" -}}
      {{- if hasKey .Values.metrics.gatewayMonitoring "leaderElectionEnabled" -}}
        {{- $leaderElect = .Values.metrics.gatewayMonitoring.leaderElectionEnabled -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- $leaderElect | quote -}}
{{- end -}}