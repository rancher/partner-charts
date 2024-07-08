{{/*
grafana name
*/}}
{{- define "asserts.grafanaName" -}}
{{- if .Values.grafana.nameOverride -}}
{{- .Values.grafana.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{ include "asserts.name" . }}-grafana
{{- end -}}
{{- end -}}

{{/*
grafana fullname
*/}}
{{- define "asserts.grafanaFullname" -}}
{{- if .Values.grafana.fullnameOverride -}}
{{- .Values.grafana.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{ include "asserts.fullname" . }}-grafana
{{- end -}}
{{- end -}}

{{/*
grafana common labels
*/}}
{{- define "asserts.grafanaLabels" -}}
{{ include "asserts.labels" . }}
app.kubernetes.io/component: grafana
{{- end }}

{{/*
grafana selector labels
*/}}
{{- define "asserts.grafanaSelectorLabels" -}}
{{ include "asserts.selectorLabels" . }}
app.kubernetes.io/component: grafana
{{- end }}

{{/*
Get the password secret.
*/}}
{{- define "asserts.grafanaSecretName" -}}
{{- if .Values.grafana.auth.existingSecret }}
    {{- printf "%s" (tpl .Values.grafana.auth.existingSecret $) -}}
{{- else -}}
    {{- printf "%s" (include "asserts.grafanaFullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a secret object should be created
*/}}
{{- define "asserts.createGrafanaSecret" -}}
{{- if not .Values.grafana.auth.existingSecret -}}
    {{- true -}}
{{- end -}}
{{- end -}}