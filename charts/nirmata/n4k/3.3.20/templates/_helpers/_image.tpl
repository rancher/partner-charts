{{/* vim: set filetype=mustache: */}}

{{- define "kyverno.image" -}}
{{- $tag := default .defaultTag .image.tag -}}
{{- if not (typeIs "string" $tag) -}}
  {{ fail "Image tags must be strings." }}
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
  {{- print (required "An image repository is required" .image.repository) ":" $tag -}}
{{- end -}}
{{- end -}}
