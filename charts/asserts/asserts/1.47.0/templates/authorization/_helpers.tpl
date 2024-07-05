{{/*
authorization name
*/}}
{{- define "asserts.authorizationName" -}}
{{- if .Values.authorization.nameOverride -}}
{{- .Values.authorization.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{ include "asserts.name" . }}-authorization
{{- end -}}
{{- end -}}

{{/*
authorization fullname
*/}}
{{- define "asserts.authorizationFullname" -}}
{{- if .Values.authorization.fullnameOverride -}}
{{- .Values.authorization.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{ include "asserts.fullname" . }}-authorization
{{- end -}}
{{- end -}}

{{/*
authorization common labels
*/}}
{{- define "asserts.authorizationLabels" -}}
{{ include "asserts.labels" . }}
app.kubernetes.io/component: authorization
{{- end }}

{{/*
authorization selector labels
*/}}
{{- define "asserts.authorizationSelectorLabels" -}}
{{ include "asserts.selectorLabels" . }}
app.kubernetes.io/component: authorization
{{- end }}
