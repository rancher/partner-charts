{{/*
include "ingress" (dict "ingressName" "myingress" "ingress" path.to.ingress "serviceName" "the-service" "servicePort" 9090 "context" $)

ingress:
  enabled: true
  certManager: false
  pathType: ImplementationSpecific
  apiVersion: ""
  hostname: theservice.local
  path: /
  annotations: {}
  tls: false
  extraHosts: []
  extraPaths: []
  extraTls: []
  secrets: []
*/}}
{{- define "lib.ingress" -}}
{{- $ctx := .context -}}
{{- $ingressName := .ingressName -}}
{{- $serviceName := .serviceName -}}
{{- $servicePort := .servicePort -}}
{{- $extraPaths := .ingress.extraPaths -}}
{{- if .ingress.enabled -}}
apiVersion: {{ include "common.capabilities.ingress.apiVersion" $ctx }}
kind: Ingress
metadata:
  name: {{ $ingressName }}
  namespace: {{ $ctx.Release.Namespace | quote }}
  labels: {{- include "common.labels.standard" $ctx | nindent 4 }}
    {{- if $ctx.Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" $ctx.Values.commonLabels "context" $ctx ) | nindent 4 }}
    {{- end }}
  annotations:
    {{- if .ingress.certManager }}
    kubernetes.io/tls-acme: "true"
    {{- end }}
    {{- if .ingress.annotations }}
    {{- include "common.tplvalues.render" ( dict "value" .ingress.annotations "context" $ctx ) | nindent 4 }}
    {{- end }}
    {{- if $ctx.Values.commonAnnotations }}
    {{- include "common.tplvalues.render" ( dict "value" $ctx.Values.commonAnnotations "context" $ctx ) | nindent 4 }}
    {{- end }}
spec:
  rules:
    {{- if .ingress.hostname }}
    - host: {{ .ingress.hostname }}
      http:
        paths:
          - path: {{ .ingress.path }}
            {{- if eq "true" (include "common.ingress.supportsPathType" $ctx) }}
            pathType: {{ default "ImplementationSpecific" .ingress.pathType }}
            {{- end }}
            backend: {{- include "common.ingress.backend" (dict "serviceName" $serviceName "servicePort" $servicePort "context" $ctx) | nindent 14 }}
          {{- include "lib.safeToYaml" $extraPaths | nindent 10 }}
    {{- end }}
    {{- range .ingress.extraHosts }}
    - host: {{ .name | quote }}
      http:
        paths:
          - path: {{ default "/" .path }}
            {{- if eq "true" (include "common.ingress.supportsPathType" $ctx) }}
            pathType: {{ default "ImplementationSpecific" .pathType }}
            {{- end }}
            backend: {{- include "common.ingress.backend" (dict "serviceName" $serviceName "servicePort" $servicePort "context" $ctx) | nindent 14 }}
          {{- include "lib.safeToYaml" $extraPaths | nindent 10 }}
    {{- end }}
    {{/* .ingress.hosts is deprecated */}}
    {{- range .ingress.hosts }}
    - host: {{ .host | quote }}
      http:
        paths:
          {{- if .path }}
          - path: {{ default "/" .path }}
            {{- if eq "true" (include "common.ingress.supportsPathType" $ctx) }}
            pathType: {{ default "ImplementationSpecific" .pathType }}
            {{- end }}
            backend: {{- include "common.ingress.backend" (dict "serviceName" $serviceName "servicePort" $servicePort "context" $ctx) | nindent 14 }}
          {{- end }}
          {{- range .paths }}
          - path: {{ . | quote }}
            {{- if eq "true" (include "common.ingress.supportsPathType" $ctx) }}
            pathType: ImplementationSpecific
            {{- end }}
            backend: {{- include "common.ingress.backend" (dict "serviceName" $serviceName "servicePort" $servicePort "context" $ctx) | nindent 14 }}
          {{- end }}
    {{- end }}
    {{/* .ingress.hosts is deprecated */}}
  {{- if or .ingress.tls .ingress.extraTls }}
  tls:
    {{- if .ingress.tls }}
    - hosts:
        - {{ .ingress.hostname }}
      secretName: {{ printf "%s-tls" .ingress.hostname }}
    {{- end }}
    {{- if .ingress.extraTls }}
    {{- include "common.tplvalues.render" ( dict "value" .ingress.extraTls "context" $ctx ) | nindent 4 }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end -}}
