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

{{- define "chronicle.id-provider.service.jwks.url" -}}
http://{{ include "chronicle.id-provider.service" . }}:8090/jwks
{{- end -}}

{{- define "chronicle.id-provider.service.userinfo.url" -}}
http://{{ include "chronicle.id-provider.service" . }}:8090/userinfo
{{- end -}}

{{- define "chronicle.id-claims" -}}
{{- if .Values.auth.id.claims -}}
--id-claims {{ .Values.auth.id.claims }} \
{{- else -}}
{{- /* Do nothing */ -}}
{{- end -}}
{{- end -}}

{{/* The JWKS and userinfo URLs are connected. */}}
{{/* If either is provided Chronicle will use the user-provided options. */}}
{{/* If neither is provided Chronicle should fall back to using the 'devIdProvider'.*/}}
{{- define "chronicle.jwks-url.url" -}}
{{- if or (.Values.auth.jwks.url) (.Values.auth.userinfo.url) -}}
{{- if .Values.auth.jwks.url -}}
{{ .Values.auth.jwks.url }}
{{- end -}}
{{- else -}}
{{- if .Values.devIdProvider.enabled -}}
{{ include "chronicle.id-provider.service.jwks.url" . }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "chronicle.jwks-url.cli" -}}
{{- if or (.Values.auth.jwks.url) (.Values.auth.userinfo.url) -}}
{{- if .Values.auth.jwks.url -}}
--jwks-address {{ include "chronicle.jwks-url.url" . }} \
{{- end -}}
{{- else -}}
{{- if .Values.devIdProvider.enabled -}}
--jwks-address {{ include "chronicle.jwks-url.url" . }} \
{{- end -}}
{{- end -}}
{{- end -}}

{{/* The JWKS and userinfo URLs are connected. */}}
{{/* If either is provided Chronicle will use the user-provided options. */}}
{{/* If neither is provided Chronicle should fall back to using the 'devIdProvider'.*/}}
{{- define "chronicle.userinfo-url" -}}
{{- if or (.Values.auth.jwks.url) (.Values.auth.userinfo.url) -}}
{{- if .Values.auth.userinfo.url -}}
{{ .Values.auth.userinfo.url }}
{{- end -}}
{{- else -}}
{{- if .Values.devIdProvider.enabled -}}
{{ include "chronicle.id-provider.service.userinfo.url" . }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "chronicle.userinfo-url.cli" -}}
{{- if or (.Values.auth.jwks.url) (.Values.auth.userinfo.url) -}}
{{- if .Values.auth.userinfo.url -}}
--userinfo-address {{ include "chronicle.userinfo-url" . }} \
{{- end -}}
{{- else -}}
{{- if .Values.devIdProvider.enabled -}}
--userinfo-address {{ include "chronicle.userinfo-url" . }} \
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "chronicle.root-key.secret" -}}
{{ include "common.names.fullname" . }}-root-key
{{- end -}}
