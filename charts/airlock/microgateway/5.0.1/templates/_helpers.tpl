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
{{- define "airlock-microgateway.labels" -}}
{{ include "airlock-microgateway.sharedLabels" . }}
{{ include "airlock-microgateway.selectorLabels" . }}
{{- end }}

{{/*
Shared labels
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
Selector labels
*/}}
{{- define "airlock-microgateway.selectorLabels" -}}
{{ include "airlock-microgateway.sharedSelectorLabels" . }}
app.kubernetes.io/name: {{ include "airlock-microgateway.name" . }}-operator
app.kubernetes.io/component: controller
{{- end }}

{{/*
Shared Selector labels
*/}}
{{- define "airlock-microgateway.sharedSelectorLabels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* Controller name with static prefix removed */}}
{{- define "airlock-microgateway.controllerNameWithoutPrefix" -}}
{{ trimPrefix "microgateway.airlock.com/" .Values.controllerName }}
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

{{/*
Create the name of the service account to use for the operator
*/}}
{{- define "airlock-microgateway.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "airlock-microgateway.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
ServiceMonitor metrics regex pattern for leader only metrics
*/}}
{{- define "airlock-microgateway.metricsLeaderOnlyRegexPattern" -}}
^(microgateway_license).*$
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


{{/* Returns true for helm install or helm template with --dry-run=server */}}
{{- define "airlock-microgateway.isClusterAvailable" -}}
{{- if (lookup "v1" "Namespace" "" "default") -}}
true
{{- end -}}
{{- end -}}

{{- define "airlock-microgateway.hasGatewayCRDWithSupportedVersion" -}}
{{- $gwcrd := (lookup "apiextensions.k8s.io/v1" "CustomResourceDefinition" "" "gateways.gateway.networking.k8s.io") -}}
{{- if $gwcrd }}
    {{- $isSupportedGWAPIVersion := false }}
    {{- range $gwcrd.spec.versions }}
        {{- if eq .name "v1" }}
            {{- $isSupportedGWAPIVersion = true }}
        {{- end }}
    {{- end }}
    {{- if $isSupportedGWAPIVersion -}}
    true
    {{- end -}}
{{- end -}}
{{- end -}}

{{- define "airlock-microgateway.gatewayAPICheck" -}}
{{- if include "airlock-microgateway.isClusterAvailable" . -}}
{{- if .Values.crds.skipGatewayAPICheck }}

Warning: Gateway API check skipped
{{- else -}}
{{- if not (include "airlock-microgateway.hasGatewayCRDWithSupportedVersion" .) -}}
    {{- fail (printf `

Airlock Microgateway requires Gateway API v1 CRDs to be installed in the cluster.
Please check https://gateway-api.sigs.k8s.io/guides/getting-started/#installing-gateway-api for instructions on how to install Gateway API CRDs and install a compatible version.

To simply install the latest supported standard channel, use the following command:

kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/%s/standard-install.yaml

If you still want to proceed, you can suppress this error by setting the helm value 'crds.skipGatewayAPICheck=true'.`
    (include "airlock-microgateway-operator.latestSupportedGatewayAPIVersion" .))
    -}}
{{- end -}}
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