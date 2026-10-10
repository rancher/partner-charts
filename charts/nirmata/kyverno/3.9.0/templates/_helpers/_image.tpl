{{/* vim: set filetype=mustache: */}}

{{- define "kyverno.image" -}}
{{- $tag := default .defaultTag .image.tag -}}
{{- if kindIs "invalid" $tag -}}
  {{- fail "An image tag is required. Please set a tag value or ensure defaultTag is provided." -}}
{{- else if not (typeIs "string" $tag) -}}
  {{- fail "Image tags must be strings." -}}
{{- end -}}
{{- if eq $tag "" -}}
  {{- fail "An image tag is required. Please set a tag value or ensure defaultTag is provided." -}}
{{- end -}}
{{- $imageRegistry := default (default .image.defaultRegistry .globalRegistry) .image.registry -}}
{{- $fipsEnabled := .fipsEnabled -}}
{{- if $imageRegistry -}}
  {{- if $fipsEnabled -}}
    {{- print $imageRegistry "/" (required "An image repository is required" .image.repository) "-fips:" $tag -}}
  {{- else -}}
    {{- print $imageRegistry "/" (required "An image repository is required" .image.repository) ":" $tag -}}
  {{- end -}}
{{- else -}}
  {{- if $fipsEnabled -}}
    {{- print (required "An image repository is required" .image.repository) "-fips:" $tag -}}
  {{- else -}}
    {{- print (required "An image repository is required" .image.repository) ":" $tag -}}
  {{- end -}}
{{- end -}}
{{- end -}}
