{{- define "chronicle.replicas" -}}
{{ .Values.replicas }}
{{- end -}}

{{- define "tp.replicas" -}}
{{ include "lib.call-nested" (list . "sawtooth" "sawtooth.replicas") | int }}
{{- end -}}

{{- define "chronicle.service.name" -}}
{{- $svc := include "common.names.fullname" . -}}
{{ printf "%s" $svc }}
{{- end -}}

{{- define "chronicle.labels.matchLabels" -}}
{{ include "common.labels.matchLabels" . }}
{{ include "chronicle.labels.appLabels" . }}
{{- end -}}

{{- define "chronicle.labels.appLabels" -}}
app: {{ include "common.names.fullname" . }}
chronicle: {{ include "common.names.fullname" . }}
{{- end -}}

{{- define "chronicle.labels" -}}
{{ include "lib.labels" . }}
{{ include "chronicle.labels.appLabels" . }}
{{- end -}}

{{- define "chronicle.sawtooth.sawcomp" -}}
{{ include "lib.call-nested" (list . "sawtooth" "sawtooth.ports.sawcomp") | int }}
{{- end -}}

{{- define "chronicle.sawtooth.service" -}}
{{- $svc := include "lib.call-nested" (list . "sawtooth" "common.names.fullname") -}}
{{- $ns := .Release.Namespace -}}
{{- $domain := "svc.cluster.local" -}}
{{ printf "%s.%s.%s" $svc $ns $domain }}
{{- end -}}

{{- define "chronicle.affinity" -}}
{{- if .Values.affinity -}}
{{- toYaml .Values.affinity }}
{{- end -}}
{{- end -}}
