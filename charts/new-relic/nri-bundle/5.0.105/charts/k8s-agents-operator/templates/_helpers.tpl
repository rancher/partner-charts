{{/*
Returns if the template should render, it checks if the required values are set.
*/}}
{{- define "k8s-agents-operator.areValuesValid" -}}
{{- $licenseKey := include "newrelic.common.license._licenseKey" . -}}
{{- and (or $licenseKey)}}
{{- end -}}

{{- define "k8s-agents-operator.manager.image" -}}
{{- $managerVersion := .Values.controllerManager.manager.image.version | default .Chart.AppVersion -}}
{{- if eq (substr 0 7 $managerVersion) "sha256:" -}}
{{- printf "%s@%s" .Values.controllerManager.manager.image.repository $managerVersion -}}
{{- else -}}
{{- printf "%s:%s" .Values.controllerManager.manager.image.repository $managerVersion -}}
{{- end -}}
{{- end -}}

{{- define "k8s-agents-operator.kubeRbacProxy.image" -}}
{{- $kubeRbacProxyVersion := .Values.controllerManager.kubeRbacProxy.image.version | default .Chart.AppVersion -}}
{{- if eq (substr 0 7 $kubeRbacProxyVersion) "sha256:" -}}
{{- printf "%s@%s" .Values.controllerManager.kubeRbacProxy.image.repository $kubeRbacProxyVersion -}}
{{- else -}}
{{- printf "%s:%s" .Values.controllerManager.kubeRbacProxy.image.repository $kubeRbacProxyVersion -}}
{{- end -}}
{{- end -}}