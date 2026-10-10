{{/* vim: set filetype=mustache: */}}

{{- define "kyverno-notation-aws.license.secretName" -}}
{{- if .Values.license.create -}}
  {{- default (printf "%s-license" (include "kyverno-notation-aws.fullname" .)) .Values.license.name -}}
{{- else -}}
  {{- .Values.license.existingSecret -}}
{{- end -}}
{{- end -}}

{{- define "kyverno-notation-aws.license.enabled" -}}
{{- if or .Values.license.create .Values.license.existingSecret -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{- define "kyverno-notation-aws.license.mountPath" -}}
/var/run/kyverno/license
{{- end -}}

{{- define "kyverno-notation-aws.license.filePath" -}}
{{- printf "%s/%s" (include "kyverno-notation-aws.license.mountPath" .) (default "license" .Values.license.key) -}}
{{- end -}}
