{{- define "alchemi-worker.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "alchemi-worker.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "alchemi-worker.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "alchemi-worker.labels" -}}
helm.sh/chart: {{ include "alchemi-worker.chart" . }}
{{ include "alchemi-worker.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "alchemi-worker.selectorLabels" -}}
app.kubernetes.io/name: {{ include "alchemi-worker.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* Name of the ConfigMap that holds non-sensitive worker env vars.
     Returns config.existingConfigMap when set; otherwise <fullname>-config. */}}
{{- define "alchemi-worker.configmapName" -}}
{{- if .Values.config.existingConfigMap -}}
{{- .Values.config.existingConfigMap -}}
{{- else -}}
{{- printf "%s-config" (include "alchemi-worker.fullname" .) -}}
{{- end -}}
{{- end }}

{{/* Name of the Secret that holds sensitive worker env vars.
     Returns secret.existingSecret when set; otherwise <fullname>-secrets. */}}
{{- define "alchemi-worker.secretName" -}}
{{- if .Values.secret.existingSecret -}}
{{- .Values.secret.existingSecret -}}
{{- else -}}
{{- printf "%s-secrets" (include "alchemi-worker.fullname" .) -}}
{{- end -}}
{{- end }}
