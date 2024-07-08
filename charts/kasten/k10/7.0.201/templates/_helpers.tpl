{{/* Returns a string of the disabled K10 services */}}
{{- define "get.disabledServices" -}}
  {{/* Append services to this list based on helm values */}}
  {{- $disabledServices := list -}}

  {{- if .Values.reporting -}}
    {{- if eq .Values.reporting.pdfReports false -}}
      {{- $disabledServices = append $disabledServices "admin" -}}
    {{- end -}}
  {{- end -}}

  {{- $disabledServices | join " " -}}
{{- end -}}

{{/* Removes disabled service names from the provided string of service names */}}
{{- define "removeDisabledServicesFromList" -}}
  {{- $disabledServices := include "get.disabledServices" .main | splitList " " -}}
  {{- $services := .list | splitList " " -}}

  {{- range $disabledServices -}}
    {{- $services = without $services . -}}
  {{- end -}}

  {{- $services | join " " -}}
{{- end -}}

{{/* Removes keys with disabled service names from the provided YAML string */}}
{{- define "removeDisabledServicesFromYaml" -}}
  {{- $disabledServices := include "get.disabledServices" .main | splitList " " -}}
  {{- $services := .yaml | fromYaml -}}

  {{- range $disabledServices -}}
    {{- $services =  unset $services . -}}
  {{- end -}}

  {{- if gt (len $services) 0 -}}
    {{- $services | toYaml | trim | nindent 0}}
  {{- else -}}
    {{- print "" -}}
  {{- end -}}
{{- end -}}

{{/* Returns k10.additionalServices string with disabled services removed */}}
{{- define "get.enabledAdditionalServices" -}}
  {{- $list := include "k10.additionalServices" . -}}
  {{- dict "main" . "list" $list | include "removeDisabledServicesFromList" -}}
{{- end -}}

{{/* Returns k10.restServices string with disabled services removed */}}
{{- define "get.enabledRestServices" -}}
  {{- $list := include "k10.restServices" . -}}
  {{- dict "main" . "list" $list | include "removeDisabledServicesFromList" -}}
{{- end -}}

{{/* Returns k10.services string with disabled services removed */}}
{{- define "get.enabledServices" -}}
  {{- $list := include "k10.services" . -}}
  {{- dict "main" . "list" $list | include "removeDisabledServicesFromList" -}}
{{- end -}}

{{/* Returns k10.exposedServices string with disabled services removed */}}
{{- define "get.enabledExposedServices" -}}
  {{- $list := include "k10.exposedServices" . -}}
  {{- dict "main" . "list" $list | include "removeDisabledServicesFromList" -}}
{{- end -}}

{{/* Returns k10.statelessServices string with disabled services removed */}}
{{- define "get.enabledStatelessServices" -}}
  {{- $list := include "k10.statelessServices" . -}}
  {{- dict "main" . "list" $list | include "removeDisabledServicesFromList" -}}
{{- end -}}

{{/* Returns k10.colocatedServices string with disabled services removed */}}
{{- define "get.enabledColocatedServices" -}}
  {{- $yaml := include "k10.colocatedServices" . -}}
  {{- dict "main" . "yaml" $yaml | include "removeDisabledServicesFromYaml" -}}
{{- end -}}

{{/* Returns YAML of primary services mapped to their secondary services */}}
{{/* The content will only have services which are not disabled */}}
{{- define "get.enabledColocatedServiceLookup" -}}
  {{- $colocatedServicesLookup := include "k10.colocatedServiceLookup" . | fromYaml -}}
  {{- $disabledServices := include "get.disabledServices" . | splitList " " -}}
  {{- $filteredLookup := dict -}}

  {{/* construct filtered lookup */}}
  {{- range $primaryService, $secondaryServices := $colocatedServicesLookup -}}
    {{/* proceed only if primary service is enabled */}}
    {{- if not (has $primaryService $disabledServices) -}}
      {{/* filter out secondary services */}}
      {{- range $disabledServices -}}
        {{- $secondaryServices = without $secondaryServices . -}}
      {{- end -}}
      {{/* add entry for primary service only if secondary services exist */}}
      {{- if gt (len $secondaryServices) 0 -}}
        {{- $filteredLookup = set $filteredLookup $primaryService $secondaryServices -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{/* return filtered lookup */}}
  {{- if gt (len $filteredLookup) 0 -}}
    {{- $filteredLookup | toYaml | trim | nindent 0 -}}
  {{- else -}}
    {{- print "" -}}
  {{- end -}}
{{- end -}}

{{- define "k10.capabilities" -}}
  {{- /* Internal capabilities enabled by other Helm values are added here */ -}}
  {{- $internal_capabilities := list -}}

  {{- /* Multi-cluster */ -}}
  {{- if eq .Values.multicluster.enabled true -}}
    {{- $internal_capabilities = append $internal_capabilities "mc" -}}
  {{- end -}}

  {{- /* FIPS */ -}}
  {{- if .Values.fips.enabled -}}
    {{- $internal_capabilities = append $internal_capabilities "fips.strict" -}}
    {{- $internal_capabilities = append $internal_capabilities "crypto.k10.v2" -}}
    {{- $internal_capabilities = append $internal_capabilities "crypto.storagerepository.v2" -}}
    {{- $internal_capabilities = append $internal_capabilities "crypto.vbr.v2" -}}
    {{- $internal_capabilities = append $internal_capabilities "gateway" -}}
  {{- end -}}

  {{- concat $internal_capabilities (.Values.capabilities | default list) | join " " -}}
{{- end -}}

{{- define "k10.capabilities_mask" -}}
  {{- /* Internal capabilities masked by other Helm values are added here */ -}}
  {{- $internal_capabilities_mask := list -}}

  {{- /* Multi-cluster */ -}}
  {{- if eq .Values.multicluster.enabled false -}}
    {{- $internal_capabilities_mask = append $internal_capabilities_mask "mc" -}}
  {{- end -}}

  {{- concat $internal_capabilities_mask (.Values.capabilitiesMask | default list) | join " " -}}
{{- end -}}

{{/*
  k10.capability checks whether a given capability is enabled

  For example:

    include "k10.capability" (. | merge (dict "capability" "SOME.CAPABILITY"))
*/}}
{{- define "k10.capability" -}}
  {{- $capabilities := dict -}}
  {{- range $capability := include "k10.capabilities" . | splitList " " -}}
    {{- $_ := set $capabilities $capability "enabled" -}}
  {{- end -}}
  {{- range $capability := include "k10.capabilities_mask" . | splitList " " -}}
    {{- $_ := unset $capabilities $capability -}}
  {{- end -}}

  {{- index $capabilities .capability | default "" -}}
{{- end -}}

{{/*
  k10.capability.gateway checks whether the "gateway" capability is enabled
*/}}
{{- define "k10.capability.gateway" -}}
  {{- include "k10.capability" (. | merge (dict "capability" "gateway")) -}}
{{- end -}}

{{/* Check if basic auth is needed */}}
{{- define "basicauth.check" -}}
  {{- if .Values.auth.basicAuth.enabled }}
    {{- print true }}
  {{- end -}} {{/* End of check for auth.basicAuth.enabled */}}
{{- end -}}

{{/*
Check if trusted root CA certificate related configmap settings
have been configured
*/}}
{{- define "check.cacertconfigmap" -}}
{{- if .Values.cacertconfigmap.name -}}
{{- print true -}}
{{- else -}}
{{- print false -}}
{{- end -}}
{{- end -}}

{{/*
Check if the auth options are implemented using Dex
*/}}
{{- define "check.dexAuth" -}}
{{- if or .Values.auth.openshift.enabled .Values.auth.ldap.enabled -}}
{{- print true -}}
{{- end -}}
{{- end -}}

{{/* Check the only 1 auth is specified */}}
{{- define "singleAuth.check" -}}
{{- $count := dict "count" (int 0) -}}
{{- $authList := list .Values.auth.basicAuth.enabled .Values.auth.tokenAuth.enabled .Values.auth.oidcAuth.enabled .Values.auth.openshift.enabled .Values.auth.ldap.enabled -}}
{{- range $i, $val := $authList }}
{{ if $val }}
{{ $c := add1 $count.count | set $count "count" }}
{{ if gt $count.count 1 }}
{{- fail "Multiple auth types were selected. Only one type can be enabled." }}
{{ end }}
{{ end }}
{{- end }}
{{- end -}}{{/* Check the only 1 auth is specified */}}

{{/* Check if Auth is enabled */}}
{{- define "authEnabled.check" -}}
{{- $count := dict "count" (int 0) -}}
{{- $authList := list .Values.auth.basicAuth.enabled .Values.auth.tokenAuth.enabled .Values.auth.oidcAuth.enabled .Values.auth.openshift.enabled .Values.auth.ldap.enabled -}}
{{- range $i, $val := $authList }}
{{ if $val }}
{{ $c := add1 $count.count | set $count "count" }}
{{ end }}
{{- end }}
{{- if eq $count.count 0}}
  {{- fail "Auth is required to expose access to K10." }}
{{- end }}
{{- end -}}{{/*end of check  */}}

{{/* Return ingress class name annotation */}}
{{- define "ingressClassAnnotation" -}}
{{- if .Values.ingress.class -}}
kubernetes.io/ingress.class: {{ .Values.ingress.class | quote }}
{{- end -}}
{{- end -}}

{{/* Return ingress class name in spec */}}
{{- define "specIngressClassName" -}}
{{- if and .Values.ingress.class (semverCompare ">= 1.27-0" .Capabilities.KubeVersion.Version) -}}
ingressClassName: {{ .Values.ingress.class }}
{{- end -}}
{{- end -}}

{{/* Helm required labels */}}
{{- define "helm.labels" -}}
heritage: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "k10.common.matchLabels" . }}
{{- end -}}

{{- define "k10.common.matchLabels" -}}
app: {{ .Chart.Name }}
release: {{ .Release.Name }}
{{- end -}}

{{- define "k10.defaultRBACLabels" -}}
k10.kasten.io/default-rbac-object: "true"
{{- end -}}

{{/* Expand the name of the chart. */}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "serviceAccountName" -}}
{{- if and .Values.metering.awsMarketplace ( not .Values.serviceAccount.name ) -}}
    {{ print "k10-metering" }}
{{- else if .Values.serviceAccount.create -}}
    {{ default (include "fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the metering service account to use
*/}}
{{- define "meteringServiceAccountName" -}}
{{- if and .Values.metering.awsManagedLicense ( not .Values.serviceAccount.name ) ( not .Values.metering.serviceAccount.name )  ( not .Values.metering.licenseConfigSecretName ) -}}
    {{ print "k10-metering" }}
{{- else -}}
    {{ default (include "serviceAccountName" .) .Values.metering.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Prints annotations based on .Values.fqdn.type
*/}}
{{- define "dnsAnnotations" -}}
{{- if .Values.externalGateway.fqdn.name -}}
{{- if eq "route53-mapper" ( default "" .Values.externalGateway.fqdn.type) }}
domainName: {{ .Values.externalGateway.fqdn.name | quote }}
{{- end }}
{{- if eq "external-dns" (default "" .Values.externalGateway.fqdn.type) }}
external-dns.alpha.kubernetes.io/hostname: {{ .Values.externalGateway.fqdn.name | quote }}
{{- end }}
{{- end -}}
{{- end -}}

{{/*
Prometheus scrape config template for k10 services
*/}}
{{- define "k10.prometheusScrape" -}}
{{- $cluster_domain := "" -}}
{{- with .main.Values.cluster.domainName -}}
  {{- $cluster_domain = printf ".%s" . -}}
{{- end -}}
{{- $admin_port := default 8877 .main.Values.service.gatewayAdminPort -}}
- job_name: {{ .k10service }}
  metrics_path: /metrics
  {{- if eq "aggregatedapis" .k10service }}
  scheme: https
  tls_config:
    insecure_skip_verify: true
  bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
  {{- else }}
  scheme: http
  {{- end }}
  static_configs:
    - targets:
      {{- if eq "gateway" .k10service }}
      - {{ .k10service }}-admin.{{ .main.Release.Namespace }}.svc{{ $cluster_domain }}:{{ $admin_port }}
      {{- else if eq "aggregatedapis" .k10service }}
      - {{ .k10service }}-svc.{{ .main.Release.Namespace }}.svc{{ $cluster_domain }}:443
      {{- else }}
      {{- $service := default .k10service (index (include "get.enabledColocatedServices" . | fromYaml) .k10service).primary }}
      {{- $port := default .main.Values.service.externalPort (index (include "get.enabledColocatedServices" . | fromYaml) .k10service).port }}
      - {{ $service }}-svc.{{ .main.Release.Namespace }}.svc{{ $cluster_domain }}:{{ $port }}
      {{- end }}
      labels:
        application: {{ .main.Release.Name }}
        service: {{ .k10service }}
{{- end -}}

{{/*
Prometheus scrape config template for k10 services
*/}}
{{- define "k10.prometheusTargetConfig" -}}
{{- $cluster_domain := "" -}}
{{- with .main.Values.cluster.domainName -}}
  {{- $cluster_domain = printf ".%s" . -}}
{{- end -}}
{{- $admin_port := default 8877 .main.Values.service.gatewayAdminPort | toString -}}
- service: {{ .k10service }}
  metricsPath: /metrics
  {{- if eq "aggregatedapis" .k10service }}
  scheme: https
  tls_config:
    insecure_skip_verify: true
  bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
  {{- else }}
  scheme: http
  {{- end }}
  {{- $serviceFqdn := "" }}
  {{- $servicePort := "" }}
  {{- if eq "gateway" .k10service -}}
    {{- $serviceFqdn = printf "%s-admin.%s.svc%s" .k10service .main.Release.Namespace $cluster_domain -}}
    {{- $servicePort = $admin_port -}}
  {{- else if eq "aggregatedapis" .k10service -}}
    {{- $serviceFqdn = printf "%s-svc.%s.svc%s" .k10service .main.Release.Namespace $cluster_domain -}}
    {{- $servicePort = "443" -}}
  {{- else -}}
    {{- $service := default .k10service (index (include "get.enabledColocatedServices" .main | fromYaml) .k10service).primary -}}
    {{- $port := default .main.Values.service.externalPort (index (include "get.enabledColocatedServices" .main | fromYaml) .k10service).port | toString -}}
    {{- $serviceFqdn = printf "%s-svc.%s.svc%s" $service .main.Release.Namespace $cluster_domain -}}
    {{- $servicePort = $port -}}
  {{- end }}
  fqdn: {{ $serviceFqdn }}
  port: {{ $servicePort }}
  application: {{ .main.Release.Name }}
{{- end -}}

{{/*
Expands the name of the Prometheus chart. It is equivalent to what the
"prometheus.name" template does. It is needed because the referenced values in a
template are relative to where/when the template is called from, and not where
the template is defined at. This means that the value of .Chart.Name and
.Values.nameOverride are different depending on whether the template is called
from within the Prometheus chart or the K10 chart.
*/}}
{{- define "k10.prometheus.name" -}}
{{- default "prometheus" .Values.prometheus.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Expands the name of the Prometheus service created to expose the prometheus server.
*/}}
{{- define "k10.prometheus.service.name" -}}
{{- default (printf "%s-%s-%s" .Release.Name "prometheus" .Values.prometheus.server.name) .Values.prometheus.server.fullnameOverride }}
{{- end -}}

{{/*
Checks if EULA is accepted via cmd
Enforces eula.company and eula.email as required fields
returns configMap fields
*/}}
{{- define "k10.eula.fields" -}}
{{- if .Values.eula.accept -}}
accepted: "true"
company: {{ required "eula.company is required field if eula is accepted" .Values.eula.company }}
email: {{ required "eula.email is required field if eula is accepted" .Values.eula.email }}
{{- else -}}
accepted: ""
company: ""
email: ""
{{- end }}
{{- end -}}

{{/*
Helper to determine the API Domain
*/}}
{{- define "apiDomain" -}}
{{- if .Values.useNamespacedAPI -}}
kio.{{- replace "-" "." .Release.Namespace -}}
{{- else -}}
kio.kasten.io
{{- end -}}
{{- end -}}

{{/*
Get dex image, if user wants to
install certified version of upstream
images or not
*/}}

{{- define "get.dexImage" }}
  {{- (get .Values.global.images (include "dex.dexImageName" .)) | default (include "dex.dexImage" .)  }}
{{- end }}

{{- define "dex.dexImage" -}}
  {{- printf "%s:%s" (include "dex.dexImageRepo" .) (include "dex.dexImageTag" .) }}
{{- end -}}

{{- define "dex.dexImageRepo" -}}
  {{- if .Values.global.airgapped.repository }}
    {{- printf "%s/%s" .Values.global.airgapped.repository (include "dex.dexImageName" .) }}
  {{- else if .Values.global.azMarketPlace }}
    {{- printf "%s/%s" .Values.global.azure.images.dex.registry .Values.global.azure.images.dex.image }}
  {{- else }}
    {{- printf "%s/%s" .Values.global.image.registry (include "dex.dexImageName" .) }}
  {{- end }}
{{- end -}}

{{- define "dex.dexImageName" -}}
  {{- printf "dex" }}
{{- end -}}

{{- define "dex.dexImageTag" -}}
 {{- if .Values.global.azMarketPlace }}
    {{- print .Values.global.azure.images.dex.tag }}
 {{- else }}
  {{- .Values.global.image.tag | default .Chart.AppVersion }}
 {{- end -}}
{{- end -}}

{{/*
  Get dex frontend directory (in the dex image)
*/}}
{{- define "k10.dexFrontendDir" -}}
  {{- $dexImageDict := default $.Values.dexImage dict }}
  {{- index $dexImageDict "frontendDir" | default "/srv/dex/web" }}
{{- end -}}

{{/*
Get the emissary image.
*/}}
{{- define "get.emissaryImage" }}
  {{- (get .Values.global.images (include "k10.emissaryImageName" .)) | default (include "k10.emissaryImage" .)  }}
{{- end }}

{{- define "k10.emissaryImage" -}}
  {{- printf "%s:%s" (include "k10.emissaryImageRepo" .) (include "k10.emissaryImageTag" .) }}
{{- end -}}

{{- define "k10.emissaryImageRepo" -}}
  {{- if .Values.global.airgapped.repository }}
    {{- printf "%s/%s" .Values.global.airgapped.repository (include "k10.emissaryImageName" .) }}
  {{- else if .Values.global.azMarketPlace }}
    {{- printf "%s/%s" .Values.global.azure.images.emissary.registry .Values.global.azure.images.emissary.image }}
  {{- else }}
    {{- printf "%s/%s" .Values.global.image.registry (include "k10.emissaryImageName" .) }}
  {{- end }}
{{- end -}}

{{- define "k10.emissaryImageName" -}}
  {{- printf "emissary" }}
{{- end -}}

{{- define "k10.emissaryImageTag" -}}
  {{- if .Values.global.azMarketPlace }}
    {{- print .Values.global.azure.images.emissary.tag }}
  {{- else }}
    {{- include "get.k10ImageTag" . }}
  {{- end }}
{{- end -}}

{{/*
Check if AWS creds are specified
*/}}
{{- define "check.awscreds" -}}
{{- if or .Values.secrets.awsAccessKeyId .Values.secrets.awsSecretAccessKey -}}
{{- print true -}}
{{- end -}}
{{- end -}}

{{- define "check.awsSecretName" -}}
{{- if .Values.secrets.awsClientSecretName -}}
{{- print true -}}
{{- end -}}
{{- end -}}

{{/*
Check if Azure MSI with Default ID is specified
*/}}
{{- define "check.azureMSIWithDefaultID" -}}
{{- if .Values.azure.useDefaultMSI -}}
{{- print true -}}
{{- end -}}
{{- end -}}

{{/*
Check if Azure MSI with a specific Client ID is specified
*/}}
{{- define "check.azureMSIWithClientID" -}}
{{- if and (not (or .Values.secrets.azureClientSecret .Values.secrets.azureTenantId)) .Values.secrets.azureClientId -}}
{{- print true -}}
{{- end -}}
{{- end -}}

{{/*
Check if Azure ClientSecret creds are specified
*/}}
{{- define "check.azureClientSecretCreds" -}}
{{- if and (and .Values.secrets.azureTenantId .Values.secrets.azureClientId) .Values.secrets.azureClientSecret -}}
{{- print true -}}
{{- end -}}
{{- end -}}

{{/*
Checks and enforces only 1 set of azure creds is specified
*/}}
{{- define "enforce.singleazurecreds" -}}
{{ if and (eq (include "check.azureMSIWithClientID" .) "true") (eq (include "check.azureMSIWithDefaultID" .) "true") }}
{{- fail "useDefaultMSI is set to true, but an additional ClientID is also provided. Please choose one." }}
{{- end -}}
{{ if and ( or (eq (include "check.azureClientSecretCreds" .) "true") (eq (include "check.azuresecret" .) "true" )) (or (eq (include "check.azureMSIWithClientID" .) "true") (eq (include "check.azureMSIWithDefaultID" .) "true")) }}
{{- fail "Both Azure ClientSecret and Managed Identity creds are available, but only one is allowed. Please choose one." }}
{{- end -}}
{{- end -}}

{{/*
Get the kanister-tools image.
*/}}
{{- define "get.kanisterToolsImage" -}}
  {{- (get .Values.global.images (include "kan.kanisterToolsImageName" .)) | default (include "kan.kanisterToolsImage" .)  }}
{{- end }}

{{- define "kan.kanisterToolsImage" -}}
  {{- printf "%s:%s" (include "kan.kanisterToolsImageRepo" .) (include "kan.kanisterToolsImageTag" .) }}
{{- end -}}

{{- define "kan.kanisterToolsImageRepo" -}}
  {{- if .Values.global.airgapped.repository }}
    {{- printf "%s/%s" .Values.global.airgapped.repository (include "kan.kanisterToolsImageName" .) }}
  {{- else if .Values.global.azMarketPlace }}
    {{- printf "%s/%s" .Values.global.azure.images.kanistertools.registry .Values.global.azure.images.kanistertools.image }}
  {{- else }}
    {{- printf "%s/%s" .Values.global.image.registry (include "kan.kanisterToolsImageName" .) }}
  {{- end }}
{{- end -}}

{{- define "kan.kanisterToolsImageName" -}}
  {{- printf "kanister-tools" }}
{{- end -}}

{{- define "kan.kanisterToolsImageTag" -}}
 {{- if .Values.global.azMarketPlace }}
    {{- print .Values.global.azure.images.kanistertools.tag }}
  {{- else }}
    {{- include "get.k10ImageTag" . }}
  {{- end }}
{{- end -}}

{{/*
Check if Google Workload Identity Federation is enabled
*/}}
{{- define "check.gwifenabled" -}}
{{- if .Values.google.workloadIdentityFederation.enabled -}}
{{- print true -}}
{{- end -}}
{{- end -}}


{{/*
Check if Google Workload Identity Federation Identity Provider is set
*/}}
{{- define "check.gwifidptype" -}}
{{- if .Values.google.workloadIdentityFederation.idp.type -}}
{{- print true -}}
{{- end -}}
{{- end -}}

{{/*
Fail if Google Workload Identity Federation is enabled but no Identity Provider is set
*/}}
{{- define "validate.gwif.idp.type" -}}
{{- if and (eq (include "check.gwifenabled" .) "true") (ne (include "check.gwifidptype" .) "true") -}}
  {{- fail "Google Workload Federation is enabled but helm flag for idp type is missing. Please set helm value google.workloadIdentityFederation.idp.type" -}}
{{- end -}}
{{- end -}}

{{/*
Check if K8S Bound Service Account Token (aka Projected Service Account Token) is needed,
which is when GWIF is enabled and the IdP is kubernetes
*/}}
{{- define "check.projectSAToken" -}}
{{- if and (eq (include "check.gwifenabled" .) "true") (eq .Values.google.workloadIdentityFederation.idp.type "kubernetes") -}}
{{- print true -}}
{{- end -}}
{{- end -}}

{{/*
Check if the audience that the bound service account token is intended for is set
*/}}
{{- define "check.gwifidpaud" -}}
{{- if .Values.google.workloadIdentityFederation.idp.aud -}}
{{- print true -}}
{{- end -}}
{{- end -}}

{{/*
Fail if Service Account token projection is expected but no indented Audience is set
*/}}
{{- define "validate.gwif.idp.aud" -}}
{{- if and (eq (include "check.projectSAToken" .) "true") (ne (include "check.gwifidpaud" .) "true") -}}
  {{- fail "Kubernetes is set as the Identity Provider but an intended Audience is missing. Please set helm value google.workloadIdentityFederation.idp.aud" -}}
{{- end -}}
{{- end -}}


{{/*
Check if Google creds are specified
*/}}
{{- define "check.googlecreds" -}}
{{- if .Values.secrets.googleApiKey -}}
  {{- if eq (include "check.isBase64" .Values.secrets.googleApiKey) "false" -}}
    {{- fail "secrets.googleApiKey must be base64 encoded" -}}
  {{- end -}}
  {{- print true -}}
{{- end -}}
{{- end -}}

{{- define "check.googleCredsSecret" -}}
{{- if .Values.secrets.googleClientSecretName -}}
    {{- print true -}}
{{- end -}}
{{- end -}}

{{- define "check.googleCredsOrSecret" -}}
{{- if or (eq (include "check.googlecreds" .) "true") (eq (include "check.googleCredsSecret" .) "true")}}
    {{- print true -}}
{{- end -}}
{{- end -}}

{{/*
Check if Google Project ID is not set without Google API Key
*/}}
{{- define "check.googleproject" -}}
{{- if .Values.secrets.googleProjectId -}}
  {{- if not .Values.secrets.googleApiKey -}}
    {{- print false -}}
  {{- else -}}
    {{- print true -}}
  {{- end -}}
{{- else -}}
  {{- print true -}}
{{- end -}}
{{- end -}}

{{/*
Check if Azure creds are specified
*/}}
{{- define "check.azurecreds" -}}
{{- if or (eq (include "check.azureClientSecretCreds" .) "true") ( or (eq (include "check.azureMSIWithClientID" .) "true") (eq (include "check.azureMSIWithDefaultID" .) "true")) -}}
{{- print true -}}
{{- end -}}
{{- end -}}

{{- define "check.azuresecret" -}}
{{- if .Values.secrets.azureClientSecretName }}
{{- print true -}}
{{- end -}}
{{- end -}}

{{/*
Check if Vsphere creds are specified
*/}}
{{- define "check.vspherecreds" -}}
{{- if or (or .Values.secrets.vsphereEndpoint .Values.secrets.vsphereUsername) .Values.secrets.vspherePassword -}}
{{- print true -}}
{{- end -}}
{{- end -}}

{{- define "check.vsphereClientSecret" -}}
{{- if .Values.secrets.vsphereClientSecretName -}}
{{- print true -}}
{{- end -}}
{{- end -}}

{{/*
Check if Vault token secret creds are specified
*/}}
{{- define "check.vaulttokenauth" -}}
{{- if .Values.vault.secretName -}}
{{- print true -}}
{{- end -}}
{{- end -}}

{{/*
Check if K8s role is specified
*/}}
{{- define "check.vaultk8sauth" -}}
{{- if .Values.vault.role -}}
{{- print true -}}
{{- end -}}
{{- end -}}

{{/*
Check if Vault creds for token or k8s auth are specified
*/}}
{{- define "check.vaultcreds" -}}
{{- if or (eq (include "check.vaulttokenauth" .) "true") (eq (include "check.vaultk8sauth" .) "true") -}}
{{- print true -}}
{{- end -}}
{{- end -}}


{{/*
Checks and enforces only 1 set of cloud creds is specified
*/}}
{{- define "enforce.singlecloudcreds" -}}
{{- $count := dict "count" (int 0) -}}
{{- $main := . -}}
{{- range $ind, $cloud_provider := include "k10.cloudProviders" . | splitList " " }}
{{ if eq (include (printf "check.%screds" $cloud_provider) $main) "true" }}
{{ $c := add1 $count.count | set $count "count" }}
{{ if gt $count.count 1 }}
{{- fail "Credentials for different cloud providers were provided but only one is allowed. Please verify your .secrets.* values." }}
{{ end }}
{{ end }}
{{- end }}
{{- end -}}

{{/*
Converts .Values.features into k10-features: map[string]: "value"
*/}}
{{- define "k10.features" -}}
{{ range $n, $v := .Values.features }}
{{ $n }}: {{ $v | quote -}}
{{ end }}
{{- end -}}

{{/*
Checks if string is base64 encoded
*/}}
{{- define "check.isBase64" -}}
{{- not (. | b64dec | contains "illegal base64 data") -}}
{{- end -}}

{{/*
Returns a license base64 either from file or from values
or prints it for awsmarketplace or awsManagedLicense
*/}}
{{- define "k10.getlicense" -}}
{{- if .Values.metering.awsMarketplace -}}
  {{- print "Y3VzdG9tZXJOYW1lOiBhd3MtbWFya2V0cGxhY2UKZGF0ZUVuZDogJzIxMDAtMDEtMDFUMDA6MDA6MDAuMDAwWicKZGF0ZVN0YXJ0OiAnMjAxOC0wOC0wMVQwMDowMDowMC4wMDBaJwpmZWF0dXJlczoKICBjbG91ZE1ldGVyaW5nOiBhd3MKaWQ6IGF3cy1ta3QtNWMxMDlmZDUtYWI0Yy00YTE0LWJiY2QtNTg3MGU2Yzk0MzRiCnByb2R1Y3Q6IEsxMApyZXN0cmljdGlvbnM6IG51bGwKdmVyc2lvbjogdjEuMC4wCnNpZ25hdHVyZTogY3ZEdTNTWHljaTJoSmFpazR3THMwTk9mcTNFekYxQ1pqLzRJMUZVZlBXS0JETHpuZmh2eXFFOGUvMDZxNG9PNkRoVHFSQlY3VFNJMzVkQzJ4alllaGp3cWwxNHNKT3ZyVERKZXNFWVdyMVFxZGVGVjVDd21HczhHR0VzNGNTVk5JQXVseGNTUG9oZ2x2UlRJRm0wVWpUOEtKTzlSTHVyUGxyRjlGMnpnK0RvM2UyTmVnamZ6eTVuMUZtd24xWUNlbUd4anhFaks0djB3L2lqSGlwTGQzWVBVZUh5Vm9mZHRodGV0YmhSUGJBVnVTalkrQllnRklnSW9wUlhpYnpTaEMvbCs0eTFEYzcyTDZXNWM0eUxMWFB1SVFQU3FjUWRiYnlwQ1dYYjFOT3B3aWtKMkpsR0thMldScFE4ZUFJNU9WQktqZXpuZ3FPa0lRUC91RFBtSXFBPT0K" -}}
{{- else if or ( .Values.metering.awsManagedLicense ) ( .Values.metering.licenseConfigSecretName ) -}}
  {{- print "Y3VzdG9tZXJOYW1lOiBhd3MtdG90ZW0KZGF0ZUVuZDogJzIxMDAtMDEtMDFUMDA6MDA6MDAuMDAwWicKZGF0ZVN0YXJ0OiAnMjAyMS0wOS0wMVQwMDowMDowMC4wMDBaJwpmZWF0dXJlczoKICBleHRlcm5hbExpY2Vuc2U6IGF3cwogIHByb2R1Y3RTS1U6IGI4YzgyMWQ5LWJmNDAtNDE4ZC1iYTBiLTgxMjBiZjc3ZThmOQogIGtleUZpbmdlcnByaW50OiBhd3M6Mjk0NDA2ODkxMzExOkFXUy9NYXJrZXRwbGFjZTppc3N1ZXItZmluZ2VycHJpbnQKaWQ6IGF3cy1leHQtMWUxMTVlZjMtM2YyMC00MTJlLTgzODItMmE1NWUxMTc1OTFlCnByb2R1Y3Q6IEsxMApyZXN0cmljdGlvbnM6CiAgbm9kZXM6ICczJwp2ZXJzaW9uOiB2MS4wLjAKc2lnbmF0dXJlOiBkeEtLN3pPUXdzZFBOY2I1NExzV2hvUXNWeWZSVDNHVHZ0VkRuR1Vvb2VxSGlwYStTY25HTjZSNmdmdmtWdTRQNHh4RmV1TFZQU3k2VnJYeExOTE1RZmh2NFpBSHVrYmFNd3E5UXhGNkpGSmVXbTdzQmdtTUVpWVJ2SnFZVFcyMlNoakZEU1RWejY5c2JBTXNFMUd0VTdXKytITGk0dnhybjVhYkd6RkRHZW5iRE5tcXJQT3dSa3JIdTlHTFQ1WmZTNDFUL0hBMjNZZnlsTU54MGFlK2t5TGZvZXNuK3FKQzdld2NPWjh4eE94bFRJR3RuWDZ4UU5DTk5iYjhSMm5XbmljNVd0OElEc2VDR3lLMEVVRW9YL09jNFhsWVVra3FGQ0xPdVhuWDMxeFZNZ1NFQnVEWExFd3Y3K2RlSmcvb0pMaW9EVHEvWUNuM0lnem9VR2NTMGc9PQo=" -}}
{{- else -}}
  {{- $license := .Values.license -}}
  {{- if eq (include "check.isBase64" $license) "false" -}}
    {{- $license = $license | b64enc -}}
  {{- end -}}
  {{- print (default (.Files.Get "license") $license) -}}
{{- end -}}
{{- end -}}

{{/*
Returns resource usage given a pod name and container name
*/}}
{{- define "k10.resource.request" -}}
{{- $resourceDefaultList := (include "k10.serviceResources" .main | fromYaml) }}
{{- $podName := .k10_service_pod_name }}
{{- $containerName := .k10_service_container_name }}
{{- $resourceValue := "" }}
{{- if (hasKey $resourceDefaultList $podName) }}
    {{- $resourceValue = index (index $resourceDefaultList $podName) $containerName }}
{{- end }}
{{- if (hasKey .main.Values.resources $podName) }}
  {{- if (hasKey (index .main.Values.resources $podName) $containerName) }}
    {{- $resourceValue = index (index .main.Values.resources $podName) $containerName }}
  {{- end }}
{{- end }}
{{- /* If no resource usage value was provided, do not include the resources section */}}
{{- /* This allows users to set unlimited resources by providing a service key that is empty (e.g. `--set resources.<service>=`) */}}
{{- if $resourceValue }}
resources:
{{- $resourceValue | toYaml | trim | nindent 2 }}
{{- else if eq .main.Release.Namespace "default" }}
resources:
  requests:
    cpu: "0.01"
{{- end }}
{{- end -}}

{{/*
Adds priorityClassName field according to helm values.
*/}}
{{- define "k10.priorityClassName" }}
{{- $deploymentName := .k10_deployment_name }}
{{- $defaultPriorityClassName := default "" .main.Values.defaultPriorityClassName }}
{{- $priorityClassName := $defaultPriorityClassName }}

{{- if and (hasKey .main.Values "priorityClassName") (hasKey .main.Values.priorityClassName $deploymentName) }}
  {{- $priorityClassName = index .main.Values.priorityClassName $deploymentName }}
{{- end -}}

{{- if $priorityClassName }}
priorityClassName: {{ $priorityClassName }}
{{- end }}

{{- end }}{{/* define "k10.priorityClassName" */}}

{{- define "kanisterToolsResources" }}
{{- if .Values.genericVolumeSnapshot.resources.requests.memory }}
KanisterToolsMemoryRequests: {{ .Values.genericVolumeSnapshot.resources.requests.memory | quote }}
{{- end }}
{{- if .Values.genericVolumeSnapshot.resources.requests.cpu }}
KanisterToolsCPURequests: {{ .Values.genericVolumeSnapshot.resources.requests.cpu | quote }}
{{- end }}
{{- if .Values.genericVolumeSnapshot.resources.limits.memory }}
KanisterToolsMemoryLimits: {{ .Values.genericVolumeSnapshot.resources.limits.memory | quote }}
{{- end }}
{{- if .Values.genericVolumeSnapshot.resources.limits.cpu }}
KanisterToolsCPULimits: {{ .Values.genericVolumeSnapshot.resources.limits.cpu | quote }}
{{- end }}
{{- end }}

{{- define "kanisterPodMetricSidecarResources" }}
{{- if .Values.kanisterPodMetricSidecar.resources.requests.memory }}
KanisterPodMetricSidecarMemoryRequest: {{ .Values.kanisterPodMetricSidecar.resources.requests.memory | quote }}
{{- end }}
{{- if .Values.kanisterPodMetricSidecar.resources.requests.cpu }}
KanisterPodMetricSidecarCPURequest: {{ .Values.kanisterPodMetricSidecar.resources.requests.cpu | quote }}
{{- end }}
{{- if .Values.kanisterPodMetricSidecar.resources.limits.memory }}
KanisterPodMetricSidecarMemoryLimit: {{ .Values.kanisterPodMetricSidecar.resources.limits.memory | quote }}
{{- end }}
{{- if .Values.kanisterPodMetricSidecar.resources.limits.cpu }}
KanisterPodMetricSidecarCPULimit: {{ .Values.kanisterPodMetricSidecar.resources.limits.cpu | quote }}
{{- end }}
{{- end }}

{{- define "get.kanisterPodCustomLabels" -}}
{{- if .Values.kanisterPodCustomLabels }}
KanisterPodCustomLabels: {{ .Values.kanisterPodCustomLabels | quote }}
{{- end }}
{{- end }}

{{- define "get.gvsActivationToken" }}
{{- if .Values.genericStorageBackup.token }}
GVSActivationToken: {{ .Values.genericStorageBackup.token | quote }}
{{- end }}
{{- end }}

{{- define "get.kanisterPodCustomAnnotations" -}}
{{- if .Values.kanisterPodCustomAnnotations }}
KanisterPodCustomAnnotations: {{ .Values.kanisterPodCustomAnnotations | quote }}
{{- end }}
{{- end }}

{{/*
Lookup and return only enabled colocated services
*/}}
{{- define "get.enabledColocatedSvcList" -}}
{{- $enabledColocatedSvcList := dict }}
{{- $colocatedList := include "get.enabledColocatedServiceLookup" . | fromYaml }}
{{- range $primary, $secondaryList := $colocatedList }}
  {{- $enabledSecondarySvcList := list }}
  {{- range $skip, $secondary := $secondaryList }}
    {{- if or (not (hasKey $.Values.optionalColocatedServices $secondary)) ((index $.Values.optionalColocatedServices $secondary).enabled) }}
      {{- $enabledSecondarySvcList = append $enabledSecondarySvcList $secondary }}
    {{- end }}
  {{- end }}
  {{- if gt (len $enabledSecondarySvcList) 0 }}
    {{- $enabledColocatedSvcList = set $enabledColocatedSvcList $primary $enabledSecondarySvcList }}
  {{- end }}
{{- end }}
{{- $enabledColocatedSvcList | toYaml | trim | nindent 0}}
{{- end -}}

{{- define "get.serviceContainersInPod" -}}
{{- $podService := .k10_service_pod }}
{{- $colocatedList := include "get.enabledColocatedServices" .main | fromYaml }}
{{- $colocatedLookupByPod := include "get.enabledColocatedSvcList" .main | fromYaml }}
{{- $containerList := list $podService }}
{{- if hasKey $colocatedLookupByPod $podService }}
  {{- $containerList = concat $containerList (index $colocatedLookupByPod $podService)}}
{{- end }}
{{- $containerList | join " " }}
{{- end -}}

{{- define "get.statefulRestServicesInPod" -}}
{{- $statefulRestSvcsInPod := list }}
{{- $podService := .k10_service_pod }}
{{- $containerList := (dict "main" .main "k10_service_pod" $podService | include "get.serviceContainersInPod" | splitList " ") }}
{{- if .main.Values.global.persistence.enabled }}
  {{- range $skip, $containerInPod := $containerList }}
    {{- $isRestService := has $containerInPod (include "get.enabledRestServices" $.main | splitList " ") }}
    {{- $isStatelessService := has $containerInPod (include "get.enabledStatelessServices" $.main | splitList " ") }}
    {{- if and $isRestService (not $isStatelessService) }}
      {{- $statefulRestSvcsInPod = append $statefulRestSvcsInPod $containerInPod }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $statefulRestSvcsInPod | join " " }}
{{- end -}}

{{- define "k10.prefixPath" -}}
  {{- if .Values.route.enabled -}}
    /{{ .Values.route.path | default .Release.Name | trimPrefix "/" | trimSuffix "/" }}
  {{- else if .Values.ingress.create -}}
    /{{ .Values.ingress.urlPath | default .Release.Name | trimPrefix "/" | trimSuffix "/" }}
  {{- else -}}
    /{{ .Release.Name }}
  {{- end -}}
{{- end -}}

{{/*
Check if encryption keys are specified
*/}}
{{- define "check.primaryKey" -}}
{{- if (or .Values.encryption.primaryKey.awsCmkKeyId .Values.encryption.primaryKey.vaultTransitKeyName) -}}
{{- print true -}}
{{- end -}}
{{- end -}}

{{- define "check.validateImagePullSecrets" -}}
    {{/* Validate image pull secrets if a custom Docker config is provided */}}
    {{- if (or .Values.secrets.dockerConfig .Values.secrets.dockerConfigPath ) -}}
	{{- if (and .Values.grafana.enabled (not .Values.global.imagePullSecret) (not .Values.grafana.image.pullSecrets)) -}}
	    {{ fail "A custom Docker config was provided, but Grafana is not configured to use it. Please check that global.imagePullSecret is set correctly." }}
	{{- end -}}
	{{- if (and .Values.prometheus.server.enabled (not .Values.global.imagePullSecret) (not .Values.prometheus.imagePullSecrets)) -}}
	    {{ fail "A custom Docker config was provided, but Prometheus is not configured to use it. Please check that global.imagePullSecret is set correctly." }}
	{{- end -}}
    {{- end -}}
{{- end -}}

{{- define "k10.imagePullSecrets" }}
{{- $imagePullSecrets := list .Values.global.imagePullSecret }}{{/* May be empty, but the compact below will handle that */}}
{{- if (or .Values.secrets.dockerConfig .Values.secrets.dockerConfigPath) }}
  {{- $imagePullSecrets = concat $imagePullSecrets (list "k10-ecr") }}
{{- end }}
{{- $imagePullSecrets = $imagePullSecrets | compact | uniq }}

{{- if $imagePullSecrets }}
imagePullSecrets:
  {{- range $imagePullSecrets }}
  {{/* Check if the name is not empty string */}}
  - name: {{ . }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
k10.imagePullSecretNames gets us just the secret names that are going be used
as imagePullSecrets in the k10 services.
*/}}
{{- define "k10.imagePullSecretNames" }}
{{- $pullSecretsSpec := (include "k10.imagePullSecrets" . ) | fromYaml }}
{{- if $pullSecretsSpec }}
  {{- range $pullSecretsSpec.imagePullSecrets }}
    {{- $secretName := . }}
    {{- printf "%s " ( $secretName.name) }}
  {{- end}}
{{- end}}
{{- end }}

{{/*
Below helper template functions are referred from chart
https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/templates/_helpers.tpl
*/}}

{{/*
Return kubernetes version
*/}}
{{- define "k10.kubeVersion" -}}
  {{- default .Capabilities.KubeVersion.Version (regexFind "v[0-9]+\\.[0-9]+\\.[0-9]+" .Capabilities.KubeVersion.Version) -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "ingress.apiVersion" -}}
  {{- if and (.Capabilities.APIVersions.Has "networking.k8s.io/v1") (semverCompare ">= 1.19.x" (include "k10.kubeVersion" .)) -}}
      {{- print "networking.k8s.io/v1" -}}
  {{- else if .Capabilities.APIVersions.Has "extensions/v1beta1" -}}
    {{- print "extensions/v1beta1" -}}
  {{- else -}}
    {{- print "networking.k8s.io/v1beta1" -}}
  {{- end -}}
{{- end -}}

{{/*
Is ingress part of stable APIVersion.
*/}}
{{- define "ingress.isStable" -}}
  {{- eq (include "ingress.apiVersion" .) "networking.k8s.io/v1" -}}
{{- end -}}

{{/*
Check if `ingress.defaultBackend` is properly formatted when specified.
*/}}
{{- define "check.ingress.defaultBackend" -}}
  {{- if .Values.ingress.defaultBackend -}}
    {{- if and .Values.ingress.defaultBackend.service.enabled .Values.ingress.defaultBackend.resource.enabled -}}
      {{- fail "Both `service` and `resource` cannot be enabled in the `ingress.defaultBackend`. Provide only one." -}}
    {{- end -}}
    {{- if .Values.ingress.defaultBackend.service.enabled -}}
      {{- if and (not .Values.ingress.defaultBackend.service.port.name) (not .Values.ingress.defaultBackend.service.port.number) -}}
        {{- fail "Provide either `name` or `number` in the `ingress.defaultBackend.service.port`." -}}
      {{- end -}}
      {{- if and .Values.ingress.defaultBackend.service.port.name .Values.ingress.defaultBackend.service.port.number -}}
        {{- fail "Both `name` and `number` cannot be specified in the `ingress.defaultBackend.service.port`. Provide only one." -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "check.validatePrometheusConfig" -}}
    {{if and ( and .Values.global.prometheus.external.host .Values.global.prometheus.external.port) .Values.prometheus.server.enabled}}
        {{ fail "Both internal and external Prometheus configs are not allowed at same time"}}
    {{- end -}}
{{- end -}}

{{/*
Defines unique ID to be assigned to all the K10 ambassador resources.
This will ensure that the K10's ambassador does not conflict with any other ambassador instances
running in the same cluster.
*/}}
{{- define "k10.ambassadorId" -}}
"kasten.io/k10"
{{- end -}}

{{/* Check that image.values are not set. */}}
{{- define "image.values.check" -}}
  {{- if not (empty .main.Values.image) }}

    {{- $registry := .main.Values.image.registry }}
    {{- $repository := .main.Values.image.repository }}
    {{- if or $registry $repository }}
      {{- $registry = coalesce $registry "gcr.io" }}
      {{- $repository = coalesce $repository "kasten-images" }}

      {{- $oldCombinedRegistry := "" }}
      {{- if hasPrefix $registry $repository }}
        {{- $oldCombinedRegistry = $repository }}
      {{- else }}
        {{- $oldCombinedRegistry = printf "%s/%s" $registry $repository }}
      {{- end }}

      {{- if ne $oldCombinedRegistry .main.Values.global.image.registry }}
        {{- fail "Setting image.registry and image.repository is no longer supported use global.image.registry instead" }}
      {{- end }}
    {{- end }}

    {{- $tag := .main.Values.image.tag }}
    {{- if $tag }}
      {{- if ne $tag .main.Values.global.image.tag }}
        {{- fail "Setting image.tag is no longer supported use global.image.tag instead" }}
      {{- end }}
    {{- end }}

    {{- $pullPolicy := .main.Values.image.pullPolicy }}
    {{- if $pullPolicy }}
      {{- if ne $pullPolicy .main.Values.global.image.pullPolicy }}
        {{- fail "Setting image.pullPolicy is no longer supported use global.image.pullPolicy instead" }}
      {{- end }}
    {{- end }}

  {{- end }}
{{- end -}}

{{/* Used to verify if Ironbank is enabled */}}
{{- define "ironbank.enabled" -}}
  {{- if (.Values.global.ironbank | default dict).enabled -}}
    {{- print true -}}
  {{- end -}}
{{- end -}}

{{/* Get the K10 image tag. Fails if not set correctly */}}
{{- define "get.k10ImageTag" -}}
  {{- $imageTag := coalesce .Values.global.image.tag (include "k10.imageTag" .) }}
  {{- if not $imageTag }}
      {{- fail "global.image.tag must be set because helm chart does not include a default tag." }}
  {{- else }}
      {{- $imageTag }}
  {{- end }}
{{- end -}}

{{- define "get.initImage" -}}
  {{- (get .Values.global.images (include "init.ImageName" .)) | default (include "init.Image" .)  }}
{{- end -}}

{{- define "init.Image" -}}
  {{- printf "%s:%s" (include "init.ImageRepo" .) (include "get.k10ImageTag" .) }}
{{- end -}}

{{- define "init.ImageRepo" -}}
  {{- if .Values.global.airgapped.repository }}
    {{- printf "%s/%s" .Values.global.airgapped.repository (include "init.ImageName" .) }}
  {{- else if .main.Values.global.azMarketPlace }}
    {{- printf "%s/%s" .Values.global.azure.images.init.registry .Values.global.azure.images.init.image }}
  {{- else }}
    {{- printf "%s/%s" .Values.global.image.registry (include "init.ImageName" .) }}
  {{- end }}
{{- end -}}

{{- define "init.ImageName" -}}
  {{- printf "init" }}
{{- end -}}

{{- define "k10.splitImage" -}}
  {{- $split_repo_tag_and_hash := .image | splitList "@" -}}
  {{- $split_repo_and_tag := $split_repo_tag_and_hash | first | splitList ":" -}}
  {{- $repo := $split_repo_and_tag | first -}}

  {{- /* Error if there are extra pieces we don't understand in the image */ -}}
  {{- $split_repo_tag_and_hash_len := $split_repo_tag_and_hash | len -}}
  {{- $split_repo_and_tag_len := $split_repo_and_tag | len -}}
  {{- if or (gt $split_repo_tag_and_hash_len 2) (gt $split_repo_and_tag_len 2) -}}
    {{- fail (printf "Unsupported image format: %q (%s)" .image .path) -}}
  {{- end -}}

  {{- $digest := $split_repo_tag_and_hash | rest | first -}}
  {{- $tag := $split_repo_and_tag | rest | first -}}

  {{- $sha := "" -}}
  {{- if $digest -}}
    {{- if not ($digest | hasPrefix "sha256:") -}}
      {{- fail (printf "Unsupported image ...@hash type: %q (%s)" .image .path) -}}
    {{- end -}}
    {{- $sha = $digest | trimPrefix "sha256:" }}
  {{- end -}}

  {{- /* Split out the registry if the first component of the repo contains a "." */ -}}
  {{- $registry := "" }}
  {{- $split_repo := $repo | splitList "/" -}}
  {{- if first $split_repo | contains "." -}}
    {{- $registry = first $split_repo -}}
    {{- $split_repo = rest $split_repo -}}
  {{- end -}}
  {{- $repo = $split_repo | join "/" -}}

  {{-
    (dict
      "registry" $registry
      "repository" $repo
      "tag" ($tag | default "")
      "digest" ($digest | default "")
      "sha" ($sha | default "")
    ) | toJson
  -}}
{{- end -}}

{{/* Fail if Ironbank is enabled and the admin image is turned on  */}}
{{- define "k10.fail.ironbankPdfReports" -}}
  {{- if and (include "ironbank.enabled" .) (.Values.reporting.pdfReports) -}}
    {{- fail "global.ironbank.enabled and reporting.pdfReports cannot both be enabled at the same time" -}}
  {{- end -}}
{{- end -}}

{{/* Fail if Ironbank is enabled and images we don't support are turned on  */}}
{{- define "k10.fail.ironbankRHMarketplace" -}}
  {{- if and (include "ironbank.enabled" .) (.Values.global.rhMarketPlace) -}}
    {{- fail "global.ironbank.enabled and global.rhMarketPlace cannot both be enabled at the same time" -}}
  {{- end -}}
{{- end -}}

{{/* Fail if Ironbank is enabled and images we don't support are turned on  */}}
{{- define "k10.fail.ironbankGrafana" -}}
  {{- if (include "ironbank.enabled" .) -}}
    {{- range $key, $value := .Values.grafana.sidecar -}}
      {{/* 
        https://go.dev/doc/go1.18: the "and" used to evaluate all conditions and not terminate early
        if a predicate was met, so we must have the below as their own conditional for any customers
        used go version < 1.18.
       */}}
      {{- if kindIs "map" $value -}}
        {{- if hasKey $value "enabled" -}}
          {{- if $value.enabled -}}
            {{- fail (printf "Ironbank deployment does not support grafana sidecar %s" $key) -}}
          {{- end -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/* Fail if Ironbank is enabled and images we don't support are turned on  */}}
{{- define "k10.fail.ironbankPrometheus" -}}
  {{- if (include "ironbank.enabled" .) -}}
    {{- $prometheusDict := pick .Values.prometheus "alertmanager" "kube-state-metrics" "prometheus-node-exporter" "prometheus-pushgateway" -}}
    {{- range $key, $value := $prometheusDict -}}
      {{/* 
        https://go.dev/doc/go1.18: the "and" used to evaluate all conditions and not terminate early
        if a predicate was met, so we must have the below as their own conditional for any customers
        used go version < 1.18.
       */}}
      {{- if kindIs "map" $value -}}
        {{- if hasKey $value "enabled" -}}
          {{- if $value.enabled -}}
            {{- fail (printf "Ironbank deployment does not support prometheus %s" $key) -}}
          {{- end -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/* Fail if FIPS is enabled and Grafana is turned on  */}}
{{- define "k10.fail.fipsGrafana" -}}
  {{- if and (.Values.fips.enabled) (.Values.grafana.enabled) -}}
    {{- fail "fips.enabled and grafana.enabled cannot both be enabled at the same time" -}}
  {{- end -}}
{{- end -}}

{{/* Fail if FIPS is enabled and Prometheus is turned on  */}}
{{- define "k10.fail.fipsPrometheus" -}}
  {{- if and (.Values.fips.enabled) (.Values.prometheus.server.enabled) -}}
    {{- fail "fips.enabled and prometheus.server.enabled cannot both be enabled at the same time" -}}
  {{- end -}}
{{- end -}}

{{/* Fail if FIPS is enabled and Multicluster is turned on  */}}
{{- define "k10.fail.fipsMulticluster" -}}
  {{- if and (.Values.fips.enabled) (.Values.multicluster.enabled) -}}
    {{- fail "fips.enabled and multicluster.enabled cannot both be enabled at the same time" -}}
  {{- end -}}
{{- end -}}

{{/* Fail if FIPS is enabled and PDF reporting is turned on  */}}
{{- define "k10.fail.fipsPDFReports" -}}
  {{- if and (.Values.fips.enabled) (.Values.reporting.pdfReports) -}}
    {{- fail "fips.enabled and reporting.pdfReports cannot both be enabled at the same time" -}}
  {{- end -}}
{{- end -}}

{{/* Check to see whether SIEM logging is enabled */}}
{{- define "k10.siemEnabled" -}}
  {{- if or .Values.siem.logging.cluster.enabled .Values.siem.logging.cloud.awsS3.enabled -}}
    {{- true -}}
  {{- end -}}
{{- end -}}

{{/* Determine if logging should go to filepath instead of stdout */}}
{{- define "k10.siemLoggingClusterFile" -}}
  {{- if .Values.siem.logging.cluster.enabled -}}
    {{- if (.Values.siem.logging.cluster.file | default dict).enabled -}}
      {{- .Values.siem.logging.cluster.file.path | default "" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/* Determine if a max file size should be used */}}
{{- define "k10.siemLoggingClusterFileSize" -}}
  {{- if .Values.siem.logging.cluster.enabled -}}
    {{- if (.Values.siem.logging.cluster.file | default dict).enabled -}}
      {{- .Values.siem.logging.cluster.file.size | default "" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/* Returns a generated name for the OpenShift Service Account secret */}}
{{- define "get.openshiftServiceAccountSecretName" -}}
  {{ printf "%s-k10-secret" (include "get.openshiftServiceAccountName" .) | quote }}
{{- end -}}

{{/*
Returns a generated name for the OpenShift Service Account if a service account name
is not configuredby the user using the helm value auth.openshift.serviceAccount
*/}}
{{- define "get.openshiftServiceAccountName" -}}
  {{ default (include "k10.dexServiceAccountName" .) .Values.auth.openshift.serviceAccount}}
{{- end -}}

{{/*
Returns the required environment variables to enforce FIPS mode using
the Microsoft Go toolchain and Red Hat's OpenSSL.
*/}}
{{- define "k10.enforceFIPSEnvironmentVariables" }}
- name: GOFIPS
  value: "1"
- name: OPENSSL_FORCE_FIPS_MODE
  value: "1"
{{- if .Values.fips.disable_ems }}
- name: KASTEN_CRYPTO_POLICY
  value: disable_ems
{{- end }}
{{- end }}

{{/*
Returns a billing identifier label to be added to workloads for azure marketplace offer
*/}}
{{- define "k10.azMarketPlace.billingIdentifier" -}}
 {{- if .Values.global.azMarketPlace }}
        azure-extensions-usage-release-identifier: {{.Release.Name}}
 {{- end }}
{{- end }}