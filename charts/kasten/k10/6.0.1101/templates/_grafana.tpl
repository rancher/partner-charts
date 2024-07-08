{{/*** SELECTOR LABELS ***
  NOTE: The selector labels here (`app` and `release`) are divergent from
  the selector labels set by the upstream chart. This is intentional since a
  Deployment's `spec.selector` is immutable and K10 has already been shipped
  with these values.

  A change to these selector labels will mean that all customers must manually
  delete the Grafana Deployment before upgrading, which is a situation we don't
  want for our customers.

  Instead, the `app.kubernetes.io/name` and `app.kubernetes.io/instance` labels
  are included in the `grafana.extraLabels` in:
  `templates/{values}/grafana/values/grafana_values.tpl`.
*/}}
{{- define "grafana.selectorLabels" -}}
app: {{ include "grafana.name" . }}
release: {{ .Release.Name }}
{{- end -}}
