{{/*
Expand the name of the chart.
*/}}
{{- define "cf-vp.name" -}}
    {{- printf "%s-%s" (include "cf-runtime.name" .) "vp" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "cf-vp.fullname" -}}
    {{- printf "%s-%s" (include "cf-runtime.fullname" .) "vp" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "cf-vp.provisionerName" -}}
    {{- printf "%s-%s" (include "cf-runtime.fullname" .) "vp-provisioner" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "cf-vp.monitorName" -}}
    {{- printf "%s-%s" (include "cf-runtime.fullname" .) "vp-monitor" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "cf-vp.volumeProvisionerName" -}}
    codefresh.io/dind-volume-provisioner-{{ include "cf-runtime.fullname" . }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cf-vp.monitorLabels" -}}
{{ include "cf-runtime.labels" . }}
codefresh.io/application: volume-provisioner-monitor
{{- end }}

{{/*
Selector labels
*/}}
{{- define "cf-vp.monitorSelectorLabels" -}}
{{ include "cf-runtime.selectorLabels" . }}
codefresh.io/application: volume-provisioner-monitor
{{- end }}

{{/*
Common labels
*/}}
{{- define "cf-vp.provisionerLabels" -}}
{{ include "cf-runtime.labels" . }}
codefresh.io/application: volume-provisioner
{{- end }}

{{/*
Selector labels
*/}}
{{- define "cf-vp.provisionerSelectorLabels" -}}
{{ include "cf-runtime.selectorLabels" . }}
codefresh.io/application: volume-provisioner
{{- end }}

{{/*
Common labels
*/}}
{{- define "cf-vp.cleanupLabels" -}}
{{ include "cf-runtime.labels" . }}
codefresh.io/application: cleanup
{{- end }}


{{- define "cf-vp.docker-image-volume-utils" -}}
{{- if ne .Values.dockerRegistry ""}}
{{- .Values.dockerRegistry }}/codefresh/dind-volume-utils:1.26.0
{{- else }}codefresh/dind-volume-utils:1.26.0
{{- end}}
{{- end }}

{{- define "cf-vp.docker-image-volume-provisioner" -}}
{{ if ne .Values .dockerRegistry ""}}
{{- .dockerRegistry }}/{{ .Storage.VolumeProvisioner.Image }}
{{- else }}
{{- .Storage.VolumeProvisioner.Image }}
{{- end}}
{{- end }}

{{- define "cf-vp.docker-image-cleanup-cron" -}}
{{- if ne .Values.dockerRegistry ""}}
{{- .Values.dockerRegistry }}/codefresh/dind-volume-utils:1.26.0
{{- else }}codefresh/dind-volume-utils:1.26.0
{{- end}}
{{- end }}
