{{- define "alchemi-compute-api.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- define "alchemi-compute-api.fullname" -}}
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
{{- define "alchemi-compute-api.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- define "alchemi-compute-api.labels" -}}
helm.sh/chart: {{ include "alchemi-compute-api.chart" . }}
{{ include "alchemi-compute-api.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
{{- define "alchemi-compute-api.selectorLabels" -}}
app.kubernetes.io/name: {{ include "alchemi-compute-api.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
{{- define "alchemi-compute-api.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "alchemi-compute-api.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
