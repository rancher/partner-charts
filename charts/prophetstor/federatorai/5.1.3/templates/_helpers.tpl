{{/* vim: set filetype=mustache: */}}
{{/*
Render value based on value type
*/}}
{{ define "render-value" }}
  {{- if .value }}
    {{- if kindIs "string" .value }}
      {{- tpl .value .context }}
    {{- else if kindIs "slice" .value }}
      {{- tpl (.value | toYaml) .context }}
    {{- else if kindIs "map" .value }}
      {{- tpl (.value | toYaml) .context }}
    {{- else }}
      {{- tpl (.value | toYaml) .context }}
    {{- end }}
  {{- end }}
{{- end }}

{{/*
Return the appropriate apiVersion for ingress
*/}}
{{- define "ingress.apiVersion" -}}
  {{- if semverCompare "<1.19-0" .Capabilities.KubeVersion.Version -}}
    {{- print "networking.k8s.io/v1beta1" -}}
  {{- else -}}
    {{- print "networking.k8s.io/v1" -}}
  {{- end -}}
{{- end -}}
