{{/* vim: set filetype=mustache: */}}


{{/* finding storageClass */}}
{{- define "rabbitmq.storageClass" -}}
{{- if .Values.global.storageClassName -}}
   {{- .Values.global.storageClassName -}}
{{- else -}}
  {{- $storageClass:= "" -}}
  {{- range $index, $sc := (lookup "storage.k8s.io/v1" "StorageClass" "" "").items -}}
    {{- if eq (get $sc.metadata.annotations "storageclass.kubernetes.io/is-default-class") "true" -}}
            {{- $storageClass = $sc.metadata.name -}}
    {{- end -}}
  {{- end -}}
  {{- $storageClass -}}
{{- end -}}
{{- end -}}


{{/* finding airgapped mode or not */}}
{{-  define "gopaddle.registryUrl" -}}
{{- if .Values.global.airgapped.enabled -}}
    {{- $registryUrl := .Values.global.airgapped.imageRegistryInfo.registryUrl | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/"  -}}
    {{- $repoPath := .Values.global.airgapped.imageRegistryInfo.repoPath | trimPrefix "/" | trimSuffix "/"  -}}
    {{- printf "%s/%s" $registryUrl $repoPath -}}
{{- else -}}
    {{- printf "gcr.io/bluemeric-1308" -}}
{{- end -}}
{{- end -}}


{{/*
routingType for rabbitmq
*/}}
{{- define "rabbitmq.routingType" -}}
{{- if eq (.Values.global.routingType | toString) "NodePortWithIngress" -}}
  {{- "NodePort" -}}
{{- else if eq (.Values.global.routingType | toString) "LoadBalancer" -}}
  {{- "LoadBalancer" -}}
{{- else if eq (.Values.global.routingType | toString) "NodePortWithOutIngress" -}}
  {{- "NodePort" -}}
{{- end -}}
{{- end -}}

{{/* rabbitmq */}}
{{- define "gopaddle.rabbitmq" -}}
{{- if ne (.Values.global.installer.arch | toString) "arm64" -}}
    {{- printf "rabbitmq" -}}
{{- else -}}
    {{- printf "arm64v8/rabbitmq" -}}
{{- end -}}
{{- end -}}