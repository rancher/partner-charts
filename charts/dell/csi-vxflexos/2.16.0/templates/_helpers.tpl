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
