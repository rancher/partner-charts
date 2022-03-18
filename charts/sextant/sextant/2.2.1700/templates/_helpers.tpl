{{/* vim: set filetype=mustache: */}}

{{/*
Create a random alphanumeric password string.
We append a random number to the string to avoid password validation errors
*/}}
{{- define "sextant.randomPassword" -}}
{{- randAlphaNum 25 -}}{{- randNumeric 1 -}}
{{- end -}}

{{/*
{{ include "sextant.image" (dict "imageRoot" .Values.sawtooth.containers.validator.image "editionRoot" .Values.editionImages.api "edition" .Values.edition "global" .Values.global)}}
*/}}
{{- define "sextant.image" -}}
image: {{ include "sextant.image.url" . }}
imagePullPolicy: {{ default "IfNotPresent" .imageRoot.pullPolicy }}
{{- end -}}

{{/*
{{ include "sextant.image.url" (dict "imageRoot" .Values.api.image "editionRoot" .Values.editionImages.api "edition" .Values.edition "global" .Values.global)}}
*/}}
{{- define "sextant.image.url" -}}
  {{- $registry := .imageRoot.registry -}}
  {{- $repository := .imageRoot.repository -}}
  {{- $tag := .imageRoot.tag -}}
  {{- if eq .edition "development" -}}
    {{- $registry = .imageRoot.registry -}}
    {{- $repository = .imageRoot.repository -}}
    {{- $tag = .imageRoot.tag -}}
  {{- else if eq .edition "aws-standard" -}}
    {{- $registry = .editionRoot.awsStandard.registry -}}
    {{- $repository = .editionRoot.awsStandard.repository -}}
    {{- $tag = .editionRoot.awsStandard.tag -}}
  {{- else if eq .edition "aws-premium" -}}
    {{- $registry = .editionRoot.awsPremium.registry -}}
    {{- $repository = .editionRoot.awsPremium.repository -}}
    {{- $tag = .editionRoot.awsPremium.tag -}}
  {{- else if eq .edition "aws-enterprise" -}}
    {{- $registry = .editionRoot.awsEnterprise.registry -}}
    {{- $repository = .editionRoot.awsEnterprise.repository -}}
    {{- $tag = .editionRoot.awsEnterprise.tag -}}
  {{- else if eq .edition "enterprise" -}}
    {{- $registry = .editionRoot.enterprise.registry -}}
    {{- $repository = .editionRoot.enterprise.repository -}}
    {{- $tag = .editionRoot.enterprise.tag -}}
  {{- else if eq .edition "community" -}}
    {{- $registry = .editionRoot.community.registry -}}
    {{- $repository = .editionRoot.community.repository -}}
    {{- $tag = .editionRoot.community.tag -}}
  {{- else -}}
    {{- $registry = .imageRoot.registry -}}
    {{- $repository = .imageRoot.repository -}}
    {{- $tag = .imageRoot.tag -}}
  {{- end -}}
  {{- if $registry -}}
    {{- printf "%s/%s:%s" $registry $repository $tag -}}
  {{- else -}}
    {{- printf "%s:%s" $repository $tag -}}
  {{- end -}}
{{- end -}}

{{/*
Local alternative of lib.image.url until the correct version is stable
{{ include "lib.image.url" (dict "imageRoot" .Values.sawtooth.containers.validator.image "global" .Values.global)}}
*/}}
{{- define "override.lib.image.url" -}}
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
Local alternative of lib.image.url until the correct version is stable
{{ include "lib.image" (dict "imageRoot" .Values.sawtooth.containers.validator.image "global" .Values.global)}}
*/}}
{{- define "override.lib.image" -}}
image: {{ include "override.lib.image.url" . }}
imagePullPolicy: {{ default "IfNotPresent" .imageRoot.pullPolicy }}
{{- end -}}

{{- define "dockerconfigjson" }}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" .Values.imagePullSecrets.createSecret.registryUrl (printf "%s:%s" .Values.imagePullSecrets.createSecret.registryUser .Values.imagePullSecrets.createSecret.registryPassword | b64enc) | b64enc }}
{{- end }}
