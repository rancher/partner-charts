{{/*
Expand the name of the chart.
*/}}
{{- define "cf-vp.name" -}}
    {{- printf "%s-%s" (include "cf-runtime.name" .) "vp" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "cf-vp.fullname" -}}
    {{- printf "%s-%s" (include "cf-runtime.fullname" .) "volume-provisioner" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "cf-vp.volumeCleanupCronName" -}}
    {{- printf "%s-%s" (include "cf-runtime.fullname" .) "volume-cleanup" | trunc 52 | trimSuffix "-" }}
{{- end }}

{{- define "cf-vp.provisionerName" -}}
    {{- printf "%s-%s" (include "cf-runtime.fullname" .) "volume-provisioner" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "cf-vp.monitorName" -}}
    {{- printf "%s-%s" (include "cf-runtime.fullname" .) "lv-monitor" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "cf-vp.volumeProvisionerName" -}}
    codefresh.io/dind-volume-provisioner-runner-{{ .Release.Namespace }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cf-vp.monitorLabels" -}}
{{ include "cf-runtime.labels" . }}
codefresh.io/application: lv-monitor
{{- end }}

{{/*
Selector labels
*/}}
{{- define "cf-vp.monitorSelectorLabels" -}}
{{ include "cf-runtime.selectorLabels" . }}
codefresh.io/application: lv-monitor
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
codefresh.io/application: pv-cleanup
{{- end }}


{{- define "cf-vp.docker-image-volume-utils" -}}
{{- if ne .Values.dockerRegistry ""}}
{{- .Values.dockerRegistry }}/codefresh/dind-volume-utils:1.29.2
{{- else }}codefresh/dind-volume-utils:1.29.2
{{- end}}
{{- end }}

{{- define "cf-vp.docker-image-volume-provisioner" -}}
{{- if ne .Values.dockerRegistry ""}}
{{- .Values.dockerRegistry }}/{{ .Values.volumeProvisioner.image }}
{{- else }}
{{- .Values.volumeProvisioner.image }}
{{- end }}
{{- end }}

{{- define "cf-vp.docker-image-cleanup-cron" -}}
{{- if ne .Values.dockerRegistry ""}}
{{- .Values.dockerRegistry }}/codefresh/dind-volume-cleanup:1.2.0
{{- else }}codefresh/dind-volume-cleanup:1.2.0
{{- end}}
{{- end }}
