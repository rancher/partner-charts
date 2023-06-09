{{/*
Expand the name of the chart.
*/}}
{{- define "s3gw.name" -}}
{{- .Chart.Name }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "s3gw.fullname" -}}
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
{{- define "s3gw.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "s3gw.labels" -}}
helm.sh/chart: {{ include "s3gw.chart" . }}
{{ include "s3gw.commonSelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "s3gw.commonSelectorLabels" -}}
app.kubernetes.io/name: {{ include "s3gw.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "s3gw.selectorLabels" -}}
{{ include "s3gw.commonSelectorLabels" . }}
app.kubernetes.io/component: gateway
{{- end }}

{{- define "s3gw-ui.selectorLabels" -}}
{{ include "s3gw.commonSelectorLabels" . }}
app.kubernetes.io/component: ui
{{- end }}

{{- define "s3gw-cosi.selectorLabels" -}}
{{ include "s3gw.commonSelectorLabels" . }}
app.kubernetes.io/component: cosi
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "s3gw.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "s3gw.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Version helpers for the image tag
*/}}
{{- define "s3gw.image" -}}
{{- $defaulttag := printf "v%s" .Chart.Version }}
{{- $tag := default $defaulttag .Values.imageTag }}
{{- $name := default "s3gw/s3gw" .Values.imageName }}
{{- $registry := default "quay.io" .Values.imageRegistry }}
{{- printf "%s/%s:%s" $registry $name $tag }}
{{- end }}

{{- define "s3gw-ui.image" -}}
{{- $tag := default (printf "v%s" .Chart.Version) .Values.ui.imageTag }}
{{- $name := default "s3gw/s3gw-ui" .Values.ui.imageName }}
{{- $registry := default "quay.io" .Values.imageRegistry }}
{{- printf "%s/%s:%s" $registry $name $tag }}
{{- end }}

{{/*
Image Pull Secret
*/}}
{{- define "s3gw.imagePullSecret" -}}
{{- $un := .Values.imageCredentials.username }}
{{- $pw := .Values.imageCredentials.password }}
{{- $em := .Values.imageCredentials.email }}
{{- $rg := .Values.imageRegistry }}
{{- $au := (printf "%s:%s" $un $pw | b64enc) }}
{{- printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"email\":\"%s\",\"auth\":\"%s\"}}}" $rg $un $pw $em $au | b64enc}}
{{- end }}


{{/*
Default Access Credentials
*/}}
{{- define "s3gw.defaultAccessKey" -}}
{{- $key := default (randAlphaNum 32) .Values.accessKey }}
{{- printf "%s" $key }}
{{- end }}
{{- define "s3gw.defaultSecretKey" -}}
{{- $key := default (randAlphaNum 32) .Values.secretKey }}
{{- printf "%s" $key }}
{{- end }}

{{/*
Backend service name
*/}}
{{- define "s3gw.serviceName" -}}
{{- $dsn := printf "%s-%s" .Release.Name .Release.Namespace }}
{{- $name := default $dsn .Values.serviceName }}
{{- $name }}
{{- end }}

{{/*
Frontend service name
*/}}
{{- define "s3gw.uiServiceName" -}}
{{- $dsn := printf "%s-%s-ui" .Release.Name .Release.Namespace }}
{{- $name := default $dsn .Values.ui.serviceName }}
{{- $name }}
{{- end }}

{{/*
User credentials secret for S3 backend service
*/}}
{{- define "s3gw.defaultUserCredentialsSecret" -}}
{{- $dsn := printf "%s-%s-creds" .Release.Name .Release.Namespace }}
{{- $name := default $dsn .Values.defaultUserCredentialsSecret }}
{{- $name }}
{{- end }}

{{/*
Config map name
*/}}
{{- define "s3gw.configMap" -}}
{{- $dcmn := printf "%s-%s-config" .Release.Name .Release.Namespace }}
{{- $name := $dcmn }}
{{- $name }}
{{- end }}

{{/*
Traefik Middleware CORS name
*/}}
{{- define "s3gw.CORSMiddlewareName" -}}
{{- $dmcn := printf "%s-%s-cors-header" .Release.Name .Release.Namespace }}
{{- $name := $dmcn }}
{{- $name }}
{{- end }}

{{/*
Version helpers for the cosi-driver image tag
*/}}
{{- define "s3gw-cosi.driverImage" -}}
{{- $defaulttag := printf "v%s" .Chart.Version }}
{{- $tag := default $defaulttag .Values.cosi.driver.imageTag }}
{{- $name := default "s3gw-cosi-driver" .Values.cosi.driver.imageName }}
{{- $registry := default "quay.io/s3gw" .Values.cosi.driver.imageRegistry }}
{{- printf "%s/%s:%s" $registry $name $tag }}
{{- end }}

{{/*
Version helpers for the cosi-sidecar image tag
*/}}
{{- define "s3gw-cosi.sidecarImage" -}}
{{- $defaulttag := printf "v%s" .Chart.Version }}
{{- $tag := default $defaulttag .Values.cosi.sidecar.imageTag }}
{{- $name := default "s3gw-cosi-sidecar" .Values.cosi.sidecar.imageName }}
{{- $registry := default "quay.io/s3gw" .Values.cosi.sidecar.imageRegistry }}
{{- printf "%s/%s:%s" $registry $name $tag }}
{{- end }}

{{/*
COSI driver name
*/}}
{{- define "s3gw-cosi.driverName" -}}
{{- $sn := .Release.Name }}
{{- $ns := .Release.Namespace }}
{{- $defaultname := printf "%s.%s.objectstorage.k8s.io" $sn $ns }}
{{- $name := default $defaultname .Values.cosi.driver.name }}
{{- printf "%s" $name }}
{{- end }}

{{/*
COSI service account name
*/}}
{{- define "s3gw-cosi.ServiceAccountName" -}}
{{- $dcsan := printf "%s-%s-objectstorage-provisioner-sa" .Release.Name .Release.Namespace }}
{{- $name := $dcsan }}
{{- $name }}
{{- end }}

{{/*
COSI driver secret name
*/}}
{{- define "s3gw-cosi.driverSecretName" -}}
{{- $ddsn := printf "%s-%s-objectstorage-provisioner" .Release.Name .Release.Namespace }}
{{- $name := $ddsn }}
{{- $name }}
{{- end }}

{{/*
COSI cluster role name
*/}}
{{- define "s3gw-cosi.ClusterRoleName" -}}
{{- $dcrn := printf "%s-%s-objectstorage-provisioner-role" .Release.Name .Release.Namespace }}
{{- $name := $dcrn }}
{{- $name }}
{{- end }}

{{/*
COSI cluster role binding name
*/}}
{{- define "s3gw-cosi.ClusterRoleBindingName" -}}
{{- $dcrn := printf "%s-%s-objectstorage-provisioner-role-binding" .Release.Name .Release.Namespace }}
{{- $name := $dcrn }}
{{- $name }}
{{- end }}

{{/*
COSI endpoint
*/}}
{{- define "s3gw-cosi.endpoint" -}}
{{- $sn := include "s3gw.serviceName" . }}
{{- $defaultendpoint := printf "http://%s.%s.%s" $sn .Release.Namespace .Values.privateDomain}}
{{- $endpoint := default $defaultendpoint .Values.cosi.driver.endpoint }}
{{- $endpoint }}
{{- end }}
