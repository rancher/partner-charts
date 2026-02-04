{{/*
Returns if the template should render, it checks if the required values are set.
*/}}
{{- define "k8s-agents-operator.areValuesValid" -}}
{{- $licenseKey := include "newrelic.common.license._licenseKey" . -}}
{{- and (or $licenseKey)}}
{{- end -}}

{{- define "k8s-agents-operator.manager.image" -}}
{{- $imageRoot := .Values.controllerManager.manager.image -}}
{{- /* Create a normalized imageRoot with .tag field for common-library compatibility */ -}}
{{- $normalizedImageRoot := dict "registry" $imageRoot.registry "repository" $imageRoot.repository "tag" $imageRoot.version -}}
{{- $registry := include "newrelic.common.images.registry" ( dict "imageRoot" $normalizedImageRoot "context" .) -}}
{{- $repository := include "newrelic.common.images.repository" $normalizedImageRoot -}}
{{- $tag := include "newrelic.common.images.tag" ( dict "imageRoot" $normalizedImageRoot "context" .) -}}
{{- if eq (substr 0 7 $tag) "sha256:" -}}
{{- printf "%s/%s@%s" $registry $repository $tag -}}
{{- else -}}
{{- printf "%s/%s:%s" $registry $repository $tag -}}
{{- end -}}
{{- end -}}
