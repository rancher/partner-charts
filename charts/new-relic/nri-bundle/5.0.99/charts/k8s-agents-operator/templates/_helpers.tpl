{{/*
Returns if the template should render, it checks if the required values are set.
*/}}
{{- define "k8s-agents-operator.areValuesValid" -}}
{{- $licenseKey := include "newrelic.common.license._licenseKey" . -}}
{{- and (or $licenseKey)}}
{{- end -}}
