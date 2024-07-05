
{{/*
Call a template function in the context of a sub-chart, as opposed to the
current context of the caller
{{ include "lib.call-nested" (list . "subchart" "template_name") }}
*/}}
{{- define "lib.call-nested" }}
{{- $dot := index . 0 }}
{{- $subchart := index . 1 | splitList "." }}
{{- $template := index . 2 }}
{{- $values := $dot.Values }}
{{- range $subchart }}
{{- $values = index $values . }}
{{- end }}
{{- include $template (dict "Chart" (dict "Name" (last $subchart)) "Values" $values "Release" $dot.Release "Capabilities" $dot.Capabilities) }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "lib.labels" -}}
helm.sh/chart: {{ include "common.names.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "common.labels.matchLabels" . }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "lib.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}


{{/*
Given a variable, if it is not false, output as Yaml

include "lib.safeToYaml" .Values.something
*/}}
{{- define "lib.safeToYaml" -}}
{{- if . -}}
{{ toYaml . }}
{{- end -}}
{{- end -}}
