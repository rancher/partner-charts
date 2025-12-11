{{/*
Returns if the template should render, it checks if the required values are set.
*/}}
{{- define "k8s-agents-operator.areValuesValid" -}}
{{- $licenseKey := include "newrelic.common.license._licenseKey" . -}}
{{- and (or $licenseKey)}}
{{- end -}}

{{- define "k8s-agents-operator.manager.image" -}}
{{- $globalRegistry := "" -}}
{{- if .Values.global -}}
{{- if .Values.global.images -}}
{{- $globalRegistry = .Values.global.images.registry | default "" -}}
{{- end -}}
{{- end -}}
{{- $registry := .Values.controllerManager.manager.image.registry | default $globalRegistry | default "" -}}
{{- $repository := .Values.controllerManager.manager.image.repository | default "newrelic/k8s-agents-operator" -}}
{{- $managerVersion := .Values.controllerManager.manager.image.version | default .Chart.AppVersion -}}
{{- if $registry -}}
{{- if eq (substr 0 7 $managerVersion) "sha256:" -}}
{{- printf "%s/%s@%s" $registry $repository $managerVersion -}}
{{- else -}}
{{- printf "%s/%s:%s" $registry $repository $managerVersion -}}
{{- end -}}
{{- else -}}
{{- if eq (substr 0 7 $managerVersion) "sha256:" -}}
{{- printf "%s@%s" $repository $managerVersion -}}
{{- else -}}
{{- printf "%s:%s" $repository $managerVersion -}}
{{- end -}}
{{- end -}}
{{- end -}}
