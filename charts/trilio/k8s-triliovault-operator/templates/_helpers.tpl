{{/*
Expand the name of the chart.
*/}}
{{- define "k8s-triliovault-operator.name" -}}
{{- default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "k8s-triliovault-operator.appName" -}}
{{- printf "%s" .Chart.Name -}}
{{- end -}}


{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "k8s-triliovault-operator.fullname" -}}
{{- printf "%s" .Chart.Name -}}
{{- end -}}

{{/*
Return the proper TrilioVault Operator image name
*/}}
{{- define "k8s-triliovault-operator.image" -}}
{{- $registryName := .Values.image.registry -}}
{{- $repositoryName := .Values.image.repository -}}
{{- $tag := .Values.image.tag | toString -}}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}

{{/*
Validation of the secret of CA bundle if provided
*/}}
{{- define "k8s-triliovault-operator.caBundleValidation" -}}
{{- if .Values.proxySettings.CA_BUNDLE_CONFIGMAP }}
{{- if not (lookup "v1" "ConfigMap" .Release.Namespace .Values.proxySettings.CA_BUNDLE_CONFIGMAP) }}
   {{ fail "Proxy CA bundle proxy is not present in the release namespace" }}
{{- else }}
    {{- $caMap := (lookup "v1" "ConfigMap" .Release.Namespace .Values.proxySettings.CA_BUNDLE_CONFIGMAP).data }}
        {{- if not (get $caMap "ca-bundle.crt") }}
            {{ fail "Proxy CA certificate file key should be ca-bundle.crt" }}
        {{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Validation for the ingress tlsSecret, should exists if provided
*/}}

{{- define "k8s-triliovault-operator.tlsSecretValidation" }}
{{- if .Values.installTVK.ingressConfig.tlsSecretName -}}
{{- if not (lookup "v1" "Secret" .Release.Namespace .Values.installTVK.ingressConfig.tlsSecretName ) -}}
    {{ fail "Ingress tls secret is not present in the release namespace" }}
{{- end -}}
{{- end -}}
{{- end -}}


{{- define "k8s-triliovault-operator.preFlightValidation" }}
{{- if not .Values.preflight.storageClass }}
    {{ fail "Provide the name of storage class as you have enabled the preflight" }}
{{- else }}
    {{- if not (lookup "storage.k8s.io/v1" "StorageClass" "" .Values.preflight.storageClass) }}
        {{ fail "Storage class provided is not present in the cluster" }}
    {{- end }}
{{- end }}
{{- end }}

{{- define "k8s-triliovault-operator.priorityClassValidator" }}
{{- if .Values.priorityClassName -}}
{{- if not (lookup "scheduling.k8s.io/v1" "PriorityClass" "" .Values.priorityClassName) }}
     {{ fail "Priority class provided is not present in the cluster" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create unified labels for k8s-triliovault-operator components
*/}}
{{- define "k8s-triliovault-operator.labels" -}}
app.kubernetes.io/part-of: {{ template "k8s-triliovault-operator.appName" . }}
app.kubernetes.io/name: {{ template "k8s-triliovault-operator.appName" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "k8s-triliovault-operator.serviceAccountName" -}}
    {{- if eq .Values.svcAccountName "" -}}
        {{- printf "%s" "k8s-triliovault-operator-service-account" -}}
    {{- else -}}
        {{- printf "%s" .Values.svcAccountName -}}
    {{- end -}}
{{- end -}}

{{- define "k8s-triliovault-operator.preflightServiceAccountName" -}}
    {{- if eq .Values.svcAccountName "" -}}
        {{- printf "%s" "k8s-triliovault-operator-preflight-service-account" -}}
    {{- else -}}
        {{- printf "%s" .Values.svcAccountName -}}
    {{- end -}}
{{- end -}}

{{/*
Return the imagePullSecret name in below priority order
1. Returns imagePullSecret name if imagePullSecret is supplied via helm value during installation time
2. If the helm value is not provided and a service account name is provided via svcAccountName parameter, this extracts and returns imagePullSecret from service account if available.
   (In case of multiple imagePullSecrets are attached to a service account, only the first one is taken into the consideration)
3. Returns empty string not imagePullSecret is not found in any of the above two
*/}}
{{- define "k8s-triliovault-operator.imagePullSecret" -}}
    {{- if eq .Values.imagePullSecret "" -}}
        {{- if eq .Values.svcAccountName "" -}}
            {{- printf "" -}}
        {{- else -}}
            {{- if (lookup "v1" "ServiceAccount" .Release.Namespace .Values.svcAccountName).imagePullSecrets -}}
                {{- if (index (lookup "v1" "ServiceAccount" .Release.Namespace .Values.svcAccountName).imagePullSecrets 0).name -}}
                    {{- printf "%s" (index (lookup "v1" "ServiceAccount" .Release.Namespace .Values.svcAccountName).imagePullSecrets 0).name -}}
                {{- else -}}
                    {{- printf "" -}}
                {{- end -}}
            {{- else -}}
                {{- printf "" -}}
            {{- end -}}
        {{- end -}}
    {{- else -}}
        {{- printf "%s" .Values.imagePullSecret -}}
    {{- end -}}
{{- end -}}

{{- define "k8s-triliovault-operator.observability" -}}
app.kubernetes.io/part-of: k8s-triliovault-operator
app.kubernetes.io/managed-by: k8s-triliovault-operator
app.kubernetes.io/name: k8s-triliovault-operator
{{- end -}}
