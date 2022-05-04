{{/*
Expand the name of the chart.
*/}}
{{- define "dkube-deployer.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "dkube-deployer.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "dkube-deployer.labels" -}}
helm.sh/chart: {{ include "dkube-deployer.chart" . }}
{{ include "dkube-deployer.selectorLabels" . }}
app.kubernetes.io/version: {{ .Values.version | quote }}
app.kubernetes.io/managed-by: "dkube.io"
{{- end }}

{{/*
Selector labels
*/}}
{{- define "dkube-deployer.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dkube-deployer.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{/*
Image pull secret
*/}}
{{- define "dkube-deployer.imagePullSecretData" -}}
{{- with .Values.registry }}
{{- printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"email\":\"ocdlgit@oneconvergence.com\",\"auth\":\"%s\"}}}" .name .username .password (printf "%s:%s" .username .password | b64enc) | b64enc }}
{{- end }}
{{- end }}


{{/*
model catalog enable flag
*/}}
{{- define "dkube-deployer.modelCatalog" -}}
{{- if hasPrefix "2.1" .Values.version }}
{{- printf "false" }}
{{- else }}
{{- printf "true" }}
{{- end }}
{{- end }}