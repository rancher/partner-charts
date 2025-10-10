{{/*
Expand the name of the chart.
*/}}
{{- define "airlock-microgateway-cni.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Convert an image configuration object into an image ref string.
*/}}
{{- define "airlock-microgateway-cni.image" -}}
    {{- if .digest -}}
        {{- printf "%s@%s" .repository .digest -}}
    {{- else if .tag -}}
        {{- printf "%s:%s" .repository .tag -}}
    {{- else -}}
        {{- printf "%s" .repository -}}
    {{- end -}}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 50 chars because some Kubernetes name fields are limited to 63 chars (by the DNS naming spec)
and the longest suffix is 13 characters.
If release name contains chart name it will be used as a full name.
*/}}
{{- define "airlock-microgateway-cni.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 50 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 50 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 50 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "airlock-microgateway-cni.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "airlock-microgateway-cni.labels" -}}
helm.sh/chart: {{ include "airlock-microgateway-cni.chart" . }}
{{ include "airlock-microgateway-cni.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml .}}
{{- end }}
{{- end }}

{{/*
Common labels without component
*/}}
{{- define "airlock-microgateway-cni.labelsWithoutComponent" -}}
{{- $labels := fromYaml (include "airlock-microgateway-cni.labels" .) -}}
{{ unset $labels "app.kubernetes.io/component" | toYaml }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "airlock-microgateway-cni.selectorLabels" -}}
app.kubernetes.io/component: cni-plugin-installer
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/name: {{ include "airlock-microgateway-cni.name" . }}
{{- end }}

{{/*
Create the name of the service account to use for the CNI Plugin
*/}}
{{- define "airlock-microgateway-cni.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "airlock-microgateway-cni.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "airlock-microgateway-cni.isSemver" -}}
{{- regexMatch `^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$` . -}}
{{- end -}}

{{- define "airlock-microgateway-cni.docsVersion" -}}
{{- if and (eq "true" (include "airlock-microgateway-cni.isSemver" .Chart.AppVersion)) (not (contains "-" .Chart.AppVersion)) -}}
    {{- $version := (semver .Chart.AppVersion) -}}
    {{- $version.Major }}.{{ $version.Minor -}}
{{- else -}}
    {{- print "latest" -}}
{{- end -}}
{{- end -}}

{{/*
Normalize imagePullSecrets into the required structure.
*/}}
{{- define "airlock-microgateway.imagePullSecrets" -}}
{{- $list := list }}
{{- range . }}
    {{- if typeIs "string" . }}
        {{- $list = append $list (dict "name" .) }}
  {{- else }}
        {{- $list = append $list . }}
  {{- end }}
{{- end -}}
{{- toYaml $list }}
{{- end }}