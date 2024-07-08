{{/*
Expand the name of the chart.
*/}}
{{- define "asserts.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "asserts.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "asserts.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "asserts.labels" -}}
helm.sh/chart: {{ include "asserts.chart" . }}
{{ include "asserts.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "asserts.selectorLabels" -}}
app.kubernetes.io/name: {{ include "asserts.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "asserts.serviceAccountName" -}}
asserts
{{- end }}

{{/*
The asserts tenant name
{{ include "asserts.tenant"  . }}
*/}}
{{- define "asserts.tenant" -}}
bootstrap
{{- end }}

{{/*
redisgraph service endpoint depending if in standalone or sentinel mode
*/}}
{{- define "asserts.redisgraphServiceEndpoint" -}}
{{- if .Values.redisgraph.sentinel.enabled -}}
{{ .Values.redisgraph.fullnameOverride }}.{{ include "domain"  . }}:26379
{{- else -}}
{{.Values.redisgraph.fullnameOverride}}-master.{{ include "domain"  . }}:6379
{{- end }}
{{- end }}

{{/*
redisearch service endpoint depending if in standalone or sentinel mode
*/}}
{{- define "asserts.redisearchServiceEndpoint" -}}
{{- if .Values.redisearch.sentinel.enabled -}}
{{.Values.redisearch.fullnameOverride}}.{{ include "domain"  . }}:26379
{{- else -}}
{{.Values.redisearch.fullnameOverride}}-master.{{ include "domain"  . }}:6379
{{- end }}
{{- end }}

{{/*
Get KubeVersion removing pre-release information.
*/}}
{{- define "kubeVersion" -}}
  {{- default .Capabilities.KubeVersion.Version (regexFind "v[0-9]+\\.[0-9]+\\.[0-9]+" .Capabilities.KubeVersion.Version) -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "ingress.apiVersion" -}}
  {{- if and (.Capabilities.APIVersions.Has "networking.k8s.io/v1") (semverCompare ">= 1.19.x" (include "kubeVersion" .)) -}}
      {{- print "networking.k8s.io/v1" -}}
  {{- else if .Capabilities.APIVersions.Has "networking.k8s.io/v1beta1" -}}
    {{- print "networking.k8s.io/v1beta1" -}}
  {{- else -}}
    {{- print "extensions/v1beta1" -}}
  {{- end -}}
{{- end -}}

{{/*
Return if ingress is stable.
*/}}
{{- define "ingress.isStable" -}}
  {{- eq (include "ingress.apiVersion" .) "networking.k8s.io/v1" -}}
{{- end -}}

{{/*
Return if ingress supports ingressClassName.
*/}}
{{- define "ingress.supportsIngressClassName" -}}
  {{- or (eq (include "ingress.isStable" .) "true") (and (eq (include "ingress.apiVersion" .) "networking.k8s.io/v1beta1") (semverCompare ">= 1.18.x" (include "kubeVersion" .))) -}}
{{- end -}}

{{/*
Return if ingress supports pathType.
*/}}
{{- define "ingress.supportsPathType" -}}
  {{- or (eq (include "ingress.isStable" .) "true") (and (eq (include "ingress.apiVersion" .) "networking.k8s.io/v1beta1") (semverCompare ">= 1.18.x" (include "kubeVersion" .))) -}}
{{- end -}}

{{/*
Return the domain to use
{{ include "domain"  . }}
*/}}
{{- define "domain" -}}
{{ .Release.Namespace }}.{{ .Values.clusterDomain }}
{{- end -}}