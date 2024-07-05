{{/*
ui name
*/}}
{{- define "asserts.uiName" -}}
{{- if .Values.ui.nameOverride -}}
{{- .Values.ui.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{ include "asserts.name" . }}-ui
{{- end -}}
{{- end -}}

{{/*
ui fullname
*/}}
{{- define "asserts.uiFullname" -}}
{{- if .Values.ui.fullnameOverride -}}
{{- .Values.ui.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{ include "asserts.fullname" . }}-ui
{{- end -}}
{{- end -}}

{{/*
ui common labels
*/}}
{{- define "asserts.uiLabels" -}}
{{ include "asserts.labels" . }}
app.kubernetes.io/component: ui
{{- end }}

{{/*
ui selector labels
*/}}
{{- define "asserts.uiSelectorLabels" -}}
{{ include "asserts.selectorLabels" . }}
app.kubernetes.io/component: ui
{{- end }}
