
{{/*
{{ include "utils.image.url" (dict "imageRoot" .Values.sawtooth.containers.validator.image "global" .Values.global)}}
*/}}
{{- define "utils.image.url" -}}
{{- $globalRegistryName := default "index.docker.io" .global.image.registry -}}
{{- $repository := .imageRoot.repository -}}
{{- $registryName := default $globalRegistryName .imageRoot.registry -}}
{{- $tag := default .global.image.tag .imageRoot.tag -}}
{{- printf "%s/%s:%s" $registryName $repository $tag -}}
{{- end -}}

{{/*
{{ include "utils.image" (dict "imageRoot" .Values.sawtooth.containers.validator.image "global" .Values.global)}}
*/}}
{{- define "utils.image" -}}
image: {{ include "utils.image.url" . }}
imagePullPolicy: {{ default "IfNotPresent" .imageRoot.pullPolicy }}
{{- end -}}

{{/* */}}
{{- define "utils.hostaliases" -}}
{{- if .Values.hostAliases -}}
{{ toYaml .Values.hostAliases }}
{{- end -}}
{{- end -}}

{{- define "utils.k8s.image" -}}
{{- include "utils.image" (dict "imageRoot" .Values.utils.k8s.image "global" .Values.global) -}}
{{- end -}}

{{/*
{{ include "utils.call-nested" (list . "subchart" "template_name") }}
*/}}
{{- define "utils.call-nested" }}
{{- $dot := index . 0 }}
{{- $subchart := index . 1 | splitList "." }}
{{- $template := index . 2 }}
{{- $values := $dot.Values }}
{{- range $subchart }}
{{- $values = index $values . }}
{{- end }}
{{- include $template (dict "Chart" (dict "Name" (last $subchart)) "Values" $values "Release" $dot.Release "Capabilities" $dot.Capabilities) }}
{{- end }}
