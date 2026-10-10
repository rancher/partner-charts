{{/* vim: set filetype=mustache: */}}

{{- define "kyverno-notation-aws.test.labels" -}}
{{- template "kyverno-notation-aws.labels.merge" (list
  (include "kyverno-notation-aws.labels.common" .)
  (include "kyverno-notation-aws.labels.component" "test")
) -}}
{{- end -}}

{{- define "kyverno-notation-aws.test.annotations" -}}
helm.sh/hook: test
helm.sh/hook-delete-policy: hook-succeeded
{{- end -}}

{{- define "kyverno-notation-aws.test.image" -}}
{{- template "kyverno-notation-aws.image" (dict "image" .Values.test.image "defaultTag" "latest") -}}
{{- end -}}

{{- define "kyverno-notation-aws.test.imagePullPolicy" -}}
{{- default .Values.admissionController.container.image.pullPolicy .Values.test.image.pullPolicy -}}
{{- end -}}
