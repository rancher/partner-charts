{{/*
Return true if metrics is enabled
*/}}
{{- define "csi-isilon.isMetricsEnabled" -}}
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
Return true if storage capacity tracking is enabled and is supported based on k8s version
*/}}
{{- define "csi-isilon.isStorageCapacitySupported" -}}
{{- if eq .Values.storageCapacity.enabled true -}}
  {{- if and (eq .Capabilities.KubeVersion.Major "1") (ge (trimSuffix "+" .Capabilities.KubeVersion.Minor) "24") -}}
      {{- true -}}
  {{- end -}}
{{- end -}}
{{- end -}}
