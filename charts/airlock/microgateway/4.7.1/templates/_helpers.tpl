{{/*
Expand the name of the chart.
We truncate at 49 chars because some Kubernetes name fields are limited to 63 chars (by the DNS naming spec)
and the longest explicit suffix is 14 characters.
*/}}
{{- define "airlock-microgateway.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 49 | trimSuffix "-" }}
{{- end }}

{{/*
Convert an image configuration object into an image ref string.
*/}}
{{- define "airlock-microgateway.image" -}}
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
We truncate at 26 chars because some Kubernetes name fields are limited to 63 chars (by the DNS naming spec)
and the longest implicit suffix is 37 characters.
If release name contains chart name it will be used as a full name.
*/}}
{{- define "airlock-microgateway.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 26 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 26 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 26 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "airlock-microgateway.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "airlock-microgateway.sharedLabels" -}}
helm.sh/chart: {{ include "airlock-microgateway.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ .Chart.Name }}
{{- with .Values.commonLabels }}
{{ toYaml .}}
{{- end }}
{{- end }}

{{/*
Common Selector labels
*/}}
{{- define "airlock-microgateway.sharedSelectorLabels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Restricted Container Security Context
*/}}
{{- define "airlock-microgateway.restrictedSecurityContext" -}}
allowPrivilegeEscalation: false
privileged: false
runAsNonRoot: true
capabilities:
  drop: ["ALL"]
readOnlyRootFilesystem: true
seccompProfile:
  type: RuntimeDefault
{{- end }}

{{/* Precondition: May only be used if AppVersion is isSemver */}}
{{- define "airlock-microgateway.supportedCRDVersionPattern" -}}
{{- $version := (semver .Chart.AppVersion) -}}
{{- if $version.Prerelease -}}
>= {{ $version.Major }}.{{ $version.Minor }}.{{ $version.Patch }}-{{ $version.Prerelease }}
{{- else -}}
>= {{ $version.Major }}.{{ $version.Minor }}.0 || >= {{ $version.Major }}.{{ $version.Minor }}.{{ add1 $version.Patch }}-0
{{- end -}}
{{- end -}}

{{- define "airlock-microgateway.outdatedCRDs" -}}
{{- if (eq "true" (include "airlock-microgateway.isSemver" .Chart.AppVersion)) -}}
    {{- $supportedVersion := (include "airlock-microgateway.supportedCRDVersionPattern" .) -}}
    {{- range $path, $_  := .Files.Glob "crds/*.yaml" -}}
        {{- $api := ($.Files.Get $path | fromYaml).metadata.name -}}
        {{- $crd := (lookup "apiextensions.k8s.io/v1" "CustomResourceDefinition" "" $api) -}}
        {{- $isOutdated := false -}}
        {{- if $crd -}}
            {{/* If CRD is already present in the cluster, it must have the minimum supported version */}}
            {{- $isOutdated = true -}}
            {{- if hasKey $crd.metadata "labels" -}}
                {{- $crdVersion := get $crd.metadata.labels "app.kubernetes.io/version" -}}
                {{- if (eq "true" (include "airlock-microgateway.isSemver" $crdVersion)) -}}
                    {{- if (semverCompare $supportedVersion $crdVersion) }}
                        {{- $isOutdated = false -}}
                    {{- end }}
                {{- end -}}
            {{- end -}}
        {{- end -}}
        {{- if $isOutdated }}
{{ base $path }}
        {{- end }}
    {{- end -}}
{{- end -}}
{{- end -}}

{{- define "airlock-microgateway.isSemver" -}}
{{- regexMatch `^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$` . -}}
{{- end -}}

{{- define "airlock-microgateway.docsVersion" -}}
{{- if and (eq "true" (include "airlock-microgateway.isSemver" .Chart.AppVersion)) (not (contains "-" .Chart.AppVersion)) -}}
    {{- $version := (semver .Chart.AppVersion) -}}
    {{- $version.Major }}.{{ $version.Minor -}}
{{- else -}}
    {{- print "latest" -}}
{{- end -}}
{{- end -}}

{{- define "airlock-microgateway.watchNamespaceSelector.labelQuery" -}}
{{- $list := list -}}
{{- with .matchLabels -}}
    {{- range $key, $value := . -}}
        {{- $list = append $list (printf "%s=%s" $key $value) -}}
    {{- end -}}
{{- end -}}
{{- with .matchExpressions -}}
    {{- range . -}}
        {{- if has .operator (list "In" "NotIn") -}}
            {{- $list = append $list (printf "%s %s (%s)" .key (lower .operator) (join "," .values)) -}}
        {{- else if eq .operator "Exists" -}}
            {{- $list = append $list .key -}}
        {{- else if eq .operator "DoesNotExist" -}}
            {{- $list = append $list (printf "!%s" .key) -}}
        {{- end -}}
    {{- end -}}
{{- end -}}
{{- join "," $list -}}
{{- end -}}

{{/*
Convert a label map to comma-separated string.
*/}}
{{- define "airlock-microgateway.toCommaSeparatedList" -}}
{{- $list := list -}}
    {{- range $key, $value := . -}}
        {{- $list = append $list (printf "%s=%s" $key $value) -}}
    {{- end -}}
{{- join "," $list -}}
{{- end }}