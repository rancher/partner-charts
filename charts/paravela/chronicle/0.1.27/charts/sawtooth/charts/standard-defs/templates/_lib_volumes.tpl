

{{/*
given a variable list, create a list of volumes

extraVolumes:
  - name: pv-data
    persistentVolumeClaim:
      claimName: pvc-persistent-cfg
  - name: scratch
    emptyDir: {}

include "lib.volumes" .Values.extraVolumes

*/}}
{{- define "lib.volumes" -}}
{{ include "lib.safeToYaml" . }}
{{- end -}}

{{/*
given a variable list, create a list of volumeMounts

extraVolumeMounts:
  - name: pv-data
    mountPath: /data
  - name: scratch
    mountPath: /scratch

include "lib.volumeMounts" .Values.extraVolumeMounts

*/}}
{{- define "lib.volumeMounts" -}}
{{ include "lib.safeToYaml" . }}
{{- end -}}
