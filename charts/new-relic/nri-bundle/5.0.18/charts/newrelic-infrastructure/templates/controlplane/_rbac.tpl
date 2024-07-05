{{/*
Returns the list of namespaces where secrets need to be accessed by the controlPlane integration to do mTLS Auth
*/}}
{{- define "nriKubernetes.controlPlane.roleBindingNamespaces" -}}
{{ $namespaceList := list }}
{{- range $components := .Values.controlPlane.config }}
  {{- if $components }}
  {{- if kindIs "map" $components -}}
  {{- if $components.staticEndpoint }}
      {{- if $components.staticEndpoint.auth }}
      {{- if $components.staticEndpoint.auth.mtls }}
      {{- if $components.staticEndpoint.auth.mtls.secretNamespace }}
      {{- $namespaceList = append $namespaceList $components.staticEndpoint.auth.mtls.secretNamespace -}}
      {{- end }}
      {{- end }}
      {{- end }}
  {{- end }}
  {{- if $components.autodiscover }}
    {{- range $autodiscover := $components.autodiscover }}
      {{- if $autodiscover }}
      {{- if $autodiscover.endpoints }}
        {{- range $endpoint := $autodiscover.endpoints }}
            {{- if $endpoint.auth }}
            {{- if $endpoint.auth.mtls }}
            {{- if $endpoint.auth.mtls.secretNamespace }}
            {{- $namespaceList = append $namespaceList $endpoint.auth.mtls.secretNamespace -}}
            {{- end }}
            {{- end }}
            {{- end }}
        {{- end }}
      {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- end }}
  {{- end }}
{{- end }}
roleBindingNamespaces:
  {{- uniq $namespaceList | toYaml | nindent 2 }}
{{- end -}}
