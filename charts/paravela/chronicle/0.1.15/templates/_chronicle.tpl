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

{{- define "chronicle.sawtooth.rest" -}}
{{ include "lib.call-nested" (list . "sawtooth" "sawtooth.ports.rest") | int }}
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

{{- define "chronicle.api.service" -}}
{{ include "chronicle.service.name" . }}-chronicle-api
{{- end -}}

{{- define "chronicle.id-provider.service" -}}
{{ include "common.names.fullname" . }}-test-id-provider
{{- end -}}

{{- define "chronicle.jwksUrl" -}}
{{- if .Values.auth.jwks.url -}}
{{ .Values.auth.jwks.url }}
{{- else -}}
{{- if .Values.devIdProvider.enabled -}}
http://{{ include "chronicle.id-provider.service" . }}:8090/jwks
{{- else -}}
{{ required "devIdProvider.enabled must be true or auth.jwks.url must be set!" .Values.auth.jwks.url }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "chronicle.userinfoUrl" -}}
{{ .Values.auth.userinfo.url }}
{{- end -}}

{{- define "chronicle.root-key.secret" -}}
{{ include "common.names.fullname" . }}-root-key
{{- end -}}
