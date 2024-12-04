{{/*
Expand the name of the chart.
*/}}
{{- define "dind-volume-provisioner.name" -}}
    {{- printf "%s-%s" (include "cf-runtime.name" .) "volume-provisioner" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "dind-volume-provisioner.fullname" -}}
    {{- printf "%s-%s" (include "cf-runtime.fullname" .) "volume-provisioner" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "dind-volume-cleanup.fullname" -}}
    {{- printf "%s-%s" (include "cf-runtime.fullname" .) "volume-cleanup" | trunc 52 | trimSuffix "-" }}
{{- end }}

{{- define "dind-lv-monitor.fullname" -}}
    {{- printf "%s-%s" (include "cf-runtime.fullname" .) "lv-monitor" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Provisioner name for storage class
*/}}
{{- define "dind-volume-provisioner.volumeProvisionerName" }}
    {{- printf "codefresh.io/dind-volume-provisioner-runner-%s" .Release.Namespace }}
{{- end }}

{{/*
Common labels for dind-lv-monitor
*/}}
{{- define "dind-lv-monitor.labels" -}}
{{ include "cf-runtime.labels" . }}
codefresh.io/application: lv-monitor
{{- end }}

{{/*
Selector labels for dind-lv-monitor
*/}}
{{- define "dind-lv-monitor.selectorLabels" -}}
{{ include "cf-runtime.selectorLabels" . }}
codefresh.io/application: lv-monitor
{{- end }}

{{/*
Common labels for dind-volume-provisioner
*/}}
{{- define "dind-volume-provisioner.labels" -}}
{{ include "cf-runtime.labels" . }}
codefresh.io/application: volume-provisioner
{{- end }}

{{/*
Selector labels for dind-volume-provisioner
*/}}
{{- define "dind-volume-provisioner.selectorLabels" -}}
{{ include "cf-runtime.selectorLabels" . }}
codefresh.io/application: volume-provisioner
{{- end }}

{{/*
Common labels for dind-volume-cleanup
*/}}
{{- define "dind-volume-cleanup.labels" -}}
{{ include "cf-runtime.labels" . }}
codefresh.io/application: pv-cleanup
{{- end }}

{{/*
Common labels for dind-volume-cleanup
*/}}
{{- define "dind-volume-cleanup.selectorLabels" -}}
{{ include "cf-runtime.selectorLabels" . }}
codefresh.io/application: pv-cleanup
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "dind-volume-provisioner.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "dind-volume-provisioner.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "dind-volume-provisioner.storageClassName" }}
{{- printf "dind-local-volumes-runner-%s" .Release.Namespace }}
{{- end }}