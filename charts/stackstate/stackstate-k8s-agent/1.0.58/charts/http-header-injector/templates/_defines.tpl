{{- define "http-header-injector.app.name" -}}
{{ .Release.Name }}-http-header-injector
{{- end -}}

{{- define "http-header-injector.webhook-service.name" -}}
{{ .Release.Name }}-http-header-injector
{{- end -}}

{{- define "http-header-injector.webhook-service.fqname" -}}
{{ .Release.Name }}-http-header-injector.{{ .Release.Namespace }}.svc
{{- end -}}

{{- define "http-header-injector.cert-secret.name" -}}
{{- if eq .Values.webhook.tls.mode "secret" -}}
{{ .Values.webhook.tls.secret.name }}
{{- else -}}
{{ .Release.Name }}-http-injector-cert
{{- end -}}
{{- end -}}

{{- define "http-header-injector.cert-clusterrole.name" -}}
{{ .Release.Name }}-http-injector-cert-cluster-role
{{- end -}}

{{- define "http-header-injector.cert-serviceaccount.name" -}}
{{ .Release.Name }}-http-injector-cert-sa
{{- end -}}

{{- define "http-header-injector.cert-config.name" -}}
{{ .Release.Name }}-cert-config
{{- end -}}

{{- define "http-header-injector.mutatingwebhookconfiguration.name" -}}
{{ .Release.Name }}-http-header-injector-webhook.stackstate.io
{{- end -}}

{{- define "http-header-injector.webhook-config.name" -}}
{{ .Release.Name }}-http-header-injector-config
{{- end -}}

{{- define "http-header-injector.mutating-webhook.name" -}}
{{ .Release.Name }}-http-header-injector-webhook
{{- end -}}

{{- define "http-header-injector.pull-secret.name" -}}
{{ include "http-header-injector.app.name" . }}-pull-secret
{{- end -}}

{{/* If the issuer is located in a different namespace, it is possible to set that, else default to the release namespace */}}
{{- define "cert-manager.certificate.namespace" -}}
{{ .Values.webhook.tls.certManager.issuerNamespace | default .Release.Namespace }}
{{- end -}}

{{- define "http-header-injector.image.registry.global" -}}
  {{- if .Values.global }}
    {{- .Values.global.imageRegistry | default "quay.io" -}}
  {{- else -}}
    quay.io
  {{- end -}}
{{- end -}}

{{- define "http-header-injector.image.registry" -}}
  {{- if ((.ContainerConfig).image).registry -}}
    {{- tpl .ContainerConfig.image.registry . -}}
  {{- else -}}
    {{- include "http-header-injector.image.registry.global" . }}
  {{- end -}}
{{- end -}}

{{- define "http-header-injector.image.pullSecrets" -}}
  {{- $pullSecrets := list }}
  {{- $pullSecrets = append $pullSecrets (include "http-header-injector.pull-secret.name" .) }}
  {{- range .Values.global.imagePullSecrets -}}
    {{- $pullSecrets = append $pullSecrets .  -}}
  {{- end -}}
  {{- if (not (empty $pullSecrets)) -}}
imagePullSecrets:
    {{- range $pullSecrets | uniq }}
  - name: {{ . }}
    {{- end }}
  {{- end -}}
{{- end -}}
