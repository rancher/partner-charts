{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "grafana.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "grafana.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "grafana.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account
*/}}
{{- define "grafana.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "grafana.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "grafana.serviceAccountNameTest" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (print (include "grafana.fullname" .) "-test") .Values.serviceAccount.nameTest }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.nameTest }}
{{- end -}}
{{- end -}}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts
*/}}
{{- define "grafana.namespace" -}}
  {{- if .Values.namespaceOverride -}}
    {{- .Values.namespaceOverride -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "grafana.labels" -}}
helm.sh/chart: {{ include "grafana.chart" . }}
{{ include "grafana.selectorLabels" . }}
{{- if or .Chart.AppVersion .Values.image.tag }}
app.kubernetes.io/version: {{ .Values.image.tag | default .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.extraLabels }}
{{ toYaml .Values.extraLabels }}
{{- end }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "grafana.selectorLabels" -}}
app: {{ include "grafana.name" . }}
release: {{ .Release.Name }}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "grafana.imageRenderer.labels" -}}
helm.sh/chart: {{ include "grafana.chart" . }}
{{ include "grafana.imageRenderer.selectorLabels" . }}
{{- if or .Chart.AppVersion .Values.image.tag }}
app.kubernetes.io/version: {{ .Values.image.tag | default .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels ImageRenderer
*/}}
{{- define "grafana.imageRenderer.selectorLabels" -}}
app: {{ include "grafana.name" . }}-image-renderer
release: {{ .Release.Name }}
{{- end -}}

{{/*
Looks if there's an existing secret and reuse its password. If not it generates
new password and use it.
*/}}
{{- define "grafana.password" -}}
{{- $secret := (lookup "v1" "Secret" (include "grafana.namespace" .) (include "grafana.fullname" .) ) -}}
  {{- if $secret -}}
    {{-  index $secret "data" "admin-password" -}}
  {{- else -}}
    {{- (randAlphaNum 40) | b64enc | quote -}}
  {{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for rbac.
*/}}
{{- define "grafana.rbac.apiVersion" -}}
  {{- if .Capabilities.APIVersions.Has "rbac.authorization.k8s.io/v1" }}
    {{- print "rbac.authorization.k8s.io/v1" -}}
  {{- else -}}
    {{- print "rbac.authorization.k8s.io/v1beta1" -}}
  {{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "grafana.ingress.apiVersion" -}}
  {{- if and (.Capabilities.APIVersions.Has "networking.k8s.io/v1") (semverCompare ">= 1.19-0" .Capabilities.KubeVersion.Version) -}}
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
{{- define "grafana.ingress.isStable" -}}
  {{- eq (include "grafana.ingress.apiVersion" .) "networking.k8s.io/v1" -}}
{{- end -}}

{{/*
Return if ingress supports ingressClassName.
*/}}
{{- define "grafana.ingress.supportsIngressClassName" -}}
  {{- or (eq (include "grafana.ingress.isStable" .) "true") (and (eq (include "grafana.ingress.apiVersion" .) "networking.k8s.io/v1beta1") (semverCompare ">= 1.18-0" .Capabilities.KubeVersion.Version)) -}}
{{- end -}}

{{/*
Return if ingress supports pathType.
*/}}
{{- define "grafana.ingress.supportsPathType" -}}
  {{- or (eq (include "grafana.ingress.isStable" .) "true") (and (eq (include "grafana.ingress.apiVersion" .) "networking.k8s.io/v1beta1") (semverCompare ">= 1.18-0" .Capabilities.KubeVersion.Version)) -}}
{{- end -}}

{{/*
Figure out the grafana image tag
based on the value of global.upstreamCertifiedImages
*/}}
{{- define "get.grafanaImageTag"}}
{{- if .Values.global.airgapped.repository }}
{{- printf "k10-%s" (include "k10.grafanaImageTag" .) }}
{{- else }}
{{- printf "%s" (include "k10.grafanaImageTag" .) }}
{{- end }}
{{- end }}

{{- define "get.grafanaImageRepo" }}
{{- if .Values.global.upstreamCertifiedImages }}
{{- printf "%s/%s/grafana" .Values.k10image.registry .Values.k10image.repository }}
{{- else }}
{{- print .Values.image.repository }}
{{- end }}
{{- end }}

{{/*
Figure out the config based on
the value of airgapped.repository
*/}}
{{- define "get.grafanaServerimage" }}
{{- if not .Values.global.rhMarketPlace }}
{{- if .Values.global.airgapped.repository }}
{{- printf "%s/grafana:%s" .Values.global.airgapped.repository (include "get.grafanaImageTag" .) }}
{{- else }}
{{- printf "%s:%s" (include "get.grafanaImageRepo" .) (include "get.grafanaImageTag" .) }}
{{- end }}
{{- else }}
{{- printf "%s" .Values.global.images.grafana }}
{{- end -}}
{{- end }}

{{/*
Figure out the grafana init container busy box image tag
based on the value of global.airgapped.repository
*/}}
{{- define "get.grafanaInitContainerImageTag"}}
{{- if .Values.global.airgapped.repository }}
{{- printf "k10-%s" (include "k10.grafanaInitContainerImageTag" .) }}
{{- else }}
{{- printf "%s" (include "k10.grafanaInitContainerImageTag" .) }}
{{- end }}
{{- end }}

{{- define "get.grafanaInitContainerImageRepo" }}
{{- if .Values.global.upstreamCertifiedImages }}
{{- printf "%s/%s/ubi-minimal" .Values.k10image.registry .Values.k10image.repository }}
{{- else }}
{{- print .Values.ubi.image.repository }}
{{- end }}
{{- end }}

{{/*
Figure out the config based on
the value of airgapped.repository
*/}}
{{- define "get.grafanaInitContainerImage" }}
{{- if not .Values.global.rhMarketPlace }}
{{- if .Values.global.airgapped.repository }}
{{- printf "%s/ubi-minimal:%s" .Values.global.airgapped.repository (include "get.grafanaInitContainerImageTag" .) }}
{{- else }}
{{- printf "%s:%s" (include "get.grafanaInitContainerImageRepo" .) (include "get.grafanaInitContainerImageTag" .) }}
{{- end }}
{{- else }}
{{- printf "%s:%s" (include "get.grafanaInitContainerImageRepo" .) (include "get.grafanaInitContainerImageTag" .) }}
{{- end }}
{{- end }}
