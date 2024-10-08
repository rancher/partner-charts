{{/*
Given a setup like the following:

# global and on down are optional
global:
  image:
    registry: my-registry.com
    tag: latest

# This is the imageRoot
somecomponent:
  image:
    registry: my-other-registry.com
    tag: 1.0.0
    repository: bobs/coolthing

*/}}
{{/*
{{ include "lib.image.url" (dict "imageRoot" .Values.sawtooth.containers.validator.image "global" .Values.global)}}
*/}}
{{- define "lib.image.url" -}}
  {{- $globalRegistryName := "" -}}
  {{- $globalTag := "latest" -}}
  {{- if .global -}}
    {{- if .global.image -}}
      {{- if .global.image.registry -}}
        {{- $globalRegistryName = .global.image.registry -}}
      {{- end -}}
      {{- if .global.image.tag -}}
        {{- $globalTag = .global.image.tag -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- $repository := .imageRoot.repository -}}
  {{- $registry := default $globalRegistryName .imageRoot.registry -}}
  {{- $tag := default $globalTag .imageRoot.tag -}}
  {{- if $registry -}}
    {{- printf "%s/%s:%s" $registry $repository $tag -}}
  {{- else -}}
    {{- printf "%s:%s" $repository $tag -}}
  {{- end -}}
{{- end -}}

{{/*
{{ include "utils.image" (dict "imageRoot" .Values.sawtooth.containers.validator.image "global" .Values.global)}}
*/}}
{{- define "lib.image" -}}
image: {{ include "lib.image.url" . }}
imagePullPolicy: {{ default "IfNotPresent" .imageRoot.pullPolicy }}
{{- end -}}
