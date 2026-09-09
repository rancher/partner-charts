{{/*** MATCH LABELS ***
  NOTE: The match labels here (`app` and `release`) are divergent from
  the match labels set by the upstream chart. This is intentional since a
  Deployment's `spec.selector` is immutable and K10 has already been shipped
  with these values.

  A change to these selector labels will mean that all customers must manually
  delete the Prometheus Deployment before upgrading, which is a situation we don't
  want for our customers.

  Instead, the `app.kubernetes.io/name` and `app.kubernetes.io/instance` labels
  are included in the `prometheus.commonMetaLabels` in:
  `helm/k10/templates/{values}/prometheus/charts/{charts}/values/prometheus_values.tpl`.
*/}}
{{- define "prometheus.common.matchLabels" -}}
app: {{ include "prometheus.name" . }}
release: {{ .Release.Name }}
{{- end -}}

{{- define "prometheus.server.labels" -}}
{{ include "prometheus.server.matchLabels" . }}
{{ include "prometheus.common.metaLabels" . }}
app.kubernetes.io/component: {{ .Values.server.name }}
{{- end -}}

{{- define "prometheus.server.matchLabels" -}}
component: {{ .Values.server.name | quote }}
{{ include "prometheus.common.matchLabels" . }}
{{- end -}}
