{{/* vim: set filetype=mustache: */}}

{{/*
Returns mergeTransformations
Helm can't merge maps of different types. Need to manually create a `transformations` section.
*/}}
{{- define "nri-prometheus.mergeTransformations" -}}
    {{/* Remove current `transformations` from config. */}}
    {{- omit .Values.config "transformations" | toYaml | nindent 4 -}}
    {{/* Create new `transformations` yaml section with merged configs from .Values.config.transformations and lowDataMode. */}}
    transformations:
    {{- .Values.config.transformations | toYaml | nindent 4 -}}
    {{ $lowDataDefault := .Files.Get "static/lowdatamodedefaults.yaml" | fromYaml }}
    {{- $lowDataDefault.transformations | toYaml | nindent 4 -}}
{{- end -}}
