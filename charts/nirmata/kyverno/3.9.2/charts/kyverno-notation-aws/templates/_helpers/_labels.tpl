{{/* vim: set filetype=mustache: */}}

{{- define "kyverno-notation-aws.labels.merge" -}}
{{- $labels := dict -}}
{{- range . -}}
  {{- $labels = merge $labels (fromYaml .) -}}
{{- end -}}
{{- with $labels -}}
  {{- toYaml $labels -}}
{{- end -}}
{{- end -}}

{{- define "kyverno-notation-aws.labels" -}}
{{- template "kyverno-notation-aws.labels.merge" (list
  (include "kyverno-notation-aws.labels.common" .)
  (include "kyverno-notation-aws.matchLabels.common" .)
) -}}
{{- end -}}

{{- define "kyverno-notation-aws.labels.helm" -}}
helm.sh/chart: {{ template "kyverno-notation-aws.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "kyverno-notation-aws.labels.version" -}}
app.kubernetes.io/version: {{ template "kyverno-notation-aws.chartVersion" . }}
{{- end -}}

{{- define "kyverno-notation-aws.labels.common" -}}
{{- template "kyverno-notation-aws.labels.merge" (list
  (include "kyverno-notation-aws.labels.helm" .)
  (include "kyverno-notation-aws.labels.version" .)
  (toYaml .Values.customLabels)
) -}}
{{- end -}}

{{- define "kyverno-notation-aws.matchLabels.common" -}}
app.kubernetes.io/part-of: {{ template "kyverno-notation-aws.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}


{{- define "kyverno-notation-aws.labels.component" -}}
app.kubernetes.io/component: {{ . }}
{{- end -}}
