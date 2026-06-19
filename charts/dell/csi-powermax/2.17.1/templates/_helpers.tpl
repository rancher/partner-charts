
{{- define "csi-powermax.isStorageCapacitySupported" -}}
{{- if eq .Values.storageCapacity.enabled true -}}
  {{- if and (eq .Capabilities.KubeVersion.Major "1") (ge (trimSuffix "+" .Capabilities.KubeVersion.Minor) "24") -}}
      {{- true -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return true if volumeGroupSnapshot is enabled and properly configured
*/}}
{{- define "csi-powermax.isVgsnapshotEnabled" -}}
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
