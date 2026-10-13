{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "harikube.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "harikube.labels" -}}
app: harikube
helm.sh/chart: {{ include "harikube.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Generates a self-signed TLS Secret with component-specific SANs.
Usage:
  {{ include "harikube.generateTlsSecret" (dict "root" . "component" "middleware") }}
*/}}
{{- define "harikube.generateTlsSecret" -}}
{{- $root := .root -}}
{{- $comp := .component -}}
{{- $ns := $root.Release.Namespace -}}

{{- $secretName := printf "harikube-%s-crt" $comp -}}
{{- $cn := printf "harikube-%s" $comp -}}
{{- $svcName := printf "harikube-%s-svc" $comp -}}

{{- $existingSecret := lookup "v1" "Secret" $ns $secretName -}}

{{- $caCert := "" -}}
{{- $tlsCert := "" -}}
{{- $tlsKey := "" -}}

{{- if $existingSecret }}
  {{- $caCert = index $existingSecret.data "ca.crt" -}}
  {{- $tlsCert = index $existingSecret.data "tls.crt" -}}
  {{- $tlsKey = index $existingSecret.data "tls.key" -}}
{{- else }}
  {{- $ca := genCA (printf "%s-ca" $cn) 3650 -}}
  {{- $altNames := list
      "kubernetes.default.svc.cluster.local"
      "kubernetes.default.svc"
      "kubernetes.default"
      "kubernetes"
      "localhost"
      (printf "*.harikube.%s.nodes.vcluster.com" $ns)
      "*.nodes.vcluster.com"
      "harikube"
      (printf "harikube.%s" $ns)
      $svcName
      (printf "%s.%s" $svcName $ns)
      (printf "%s.%s.svc" $svcName $ns)
      (printf "%s.%s.cluster.local" $svcName $ns)
      (printf "%s.%s.svc.cluster.local" $svcName $ns)
  -}}
  {{- $cert := genSignedCert $cn nil $altNames 365 $ca -}}

  {{- $caCert = $ca.Cert | b64enc -}}
  {{- $tlsCert = $cert.Cert | b64enc -}}
  {{- $tlsKey = $cert.Key | b64enc -}}
{{- end }}

apiVersion: v1
kind: Secret
metadata:
  name: {{ $secretName }}
  namespace: {{ $ns }}
  labels:
    {{- include "harikube.labels" $root | nindent 4 }}
type: kubernetes.io/tls
data:
  ca.crt: {{ $caCert }}
  tls.crt: {{ $tlsCert }}
  tls.key: {{ $tlsKey }}
{{- end -}}