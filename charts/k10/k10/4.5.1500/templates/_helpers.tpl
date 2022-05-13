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
      - {{ .k10service }}-admin.{{ .main.Release.Namespace }}.svc.{{ .main.Values.cluster.domainName }}:{{ $admin_port }}
      {{- else if eq "aggregatedapis" .k10service }}
      - {{ .k10service }}-svc.{{ .main.Release.Namespace }}.svc.{{ .main.Values.cluster.domainName }}:443
      {{- else }}
      {{- $service := default .k10service (index (include "k10.colocatedServices" . | fromYaml) .k10service).primary }}
      {{- $port := default .main.Values.service.externalPort (index (include "k10.colocatedServices" . | fromYaml) .k10service).port }}
      - {{ $service }}-svc.{{ .main.Release.Namespace }}.svc.{{ .main.Values.cluster.domainName }}:{{ $port }}
      {{- end }}
      labels:
        application: {{ .main.Release.Name }}
        service: {{ .k10service }}
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
{{- define "k10.dexImage" -}}
{{- if not .Values.rhMarketPlace }}
{{- printf "%s:%s" ( include "k10.dexImageRepo" . ) (include "k10.dexTag" .) }}
{{- else }}
{{- printf "%s" (get .Values.images "dex") }}
{{- end -}}
{{- end -}}

{{/*
Get dex image repo based on conditions
if its airgapped and red hat images are
required
*/}}
{{- define "k10.dexImageRepo" -}}
{{- if .Values.global.upstreamCertifiedImages }}
{{- if .Values.global.airgapped.repository }}
{{- printf "%s/dex" .Values.global.airgapped.repository }}
{{- else }}
{{- printf "%s/%s/dex"  .Values.image.registry .Values.image.repository }}
{{- end}}
{{- else }}
{{- if .Values.global.airgapped.repository }}
{{- printf "%s/dex" .Values.global.airgapped.repository }}
{{- else }}
{{- printf "%s/%s/%s" .Values.dexImage.registry .Values.dexImage.repository .Values.dexImage.image }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Get dex image tag based on conditions
if its airgapped and red hat images are
required
*/}}
{{- define "k10.dexTag" -}}
{{- if .Values.global.upstreamCertifiedImages }}
{{- if .Values.global.airgapped.repository }}
{{- printf "k10-%s-rh-ubi" (include "k10.dexImageTag" .) }}
{{- else }}
{{- printf "%s-rh-ubi" (include "k10.dexImageTag" .) }}
{{- end}}
{{- else }}
{{- if .Values.global.airgapped.repository }}
{{- printf "k10-%s" (include "k10.dexImageTag" .) }}
{{- else }}
{{- printf "%s" (include "k10.dexImageTag" .) }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Get ambassador image base on whether
we or not we are installing k10 on openshift
*/}}
{{- define "k10.ambImage" -}}
{{- if not .Values.global.rhMarketPlace }}
{{- printf "%s:%s" ( include "k10.ambImageRepo" .) (include "k10.ambImageTag" .) }}
{{- else }}
{{- printf "%s" (get .Values.global.images "emissary") }}
{{- end -}}
{{- end -}}

{{- define "k10.ambImageRepo" -}}
{{- if .Values.global.upstreamCertifiedImages }}
{{- if .Values.global.airgapped.repository }}
{{- printf "%s/emissary" .Values.global.airgapped.repository }}
{{- else }}
{{- printf "%s/%s/emissary" .Values.image.registry .Values.image.repository }}
{{- end }}
{{- else }}
{{- if .Values.global.airgapped.repository }}
{{- printf "%s/emissary" .Values.global.airgapped.repository }}
{{- else }}
{{- printf "%s/%s/%s" .Values.ambassadorImage.registry .Values.ambassadorImage.repository .Values.ambassadorImage.image }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "k10.ambImageTag" -}}
{{- if .Values.global.upstreamCertifiedImages }}
{{- if .Values.global.airgapped.repository }}
{{- printf "k10-%s-rh-ubi" (include "k10.rhAmbassadorImageTag" .) }}
{{- else }}
{{- printf "%s-rh-ubi" (include "k10.rhAmbassadorImageTag" .) }}
{{- end }}
{{- else }}
{{- if .Values.global.airgapped.repository }}
{{- printf "k10-%s" (include "k10.ambassadorImageTag" .) }}
{{- else }}
{{- printf "%s" (include "k10.ambassadorImageTag" .) }}
{{- end }}
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

{{/*
Check if kanister-tools image has k10- in name
this means we need to overwrite kanister image in the system
*/}}
{{- define "overwite.kanisterToolsImage" -}}
{{- if or .Values.global.airgapped.repository .Values.global.rhMarketPlace -}}
{{- print true -}}
{{- end -}}
{{- end -}}

{{/*
Figure out the kanisterToolsImage.image based on
the value of airgapped.repository value
The details on how these image are being generated
is in below issue
https://kasten.atlassian.net/browse/K10-4036
Using substr to remove repo from kanisterToolsImage
*/}}
{{- define "get.kanisterToolsImage" }}
{{- if not .Values.global.rhMarketPlace }}
{{- if .Values.global.airgapped.repository }}
{{- printf "%s/%s:k10-%s" (.Values.global.airgapped.repository) (.Values.kanisterToolsImage.image) (include "k10.kanisterToolsImageTag" .) -}}
{{- else }}
{{- printf "%s/%s/%s:%s" (.Values.kanisterToolsImage.registry) (.Values.kanisterToolsImage.repository) (.Values.kanisterToolsImage.image) (include "k10.kanisterToolsImageTag" .) -}}
{{- end }}
{{- else }}
{{- printf "%s" (get .Values.global.images "kanister-tools") -}}
{{- end }}
{{- end }}

{{/*
Check if Google creds are specified
*/}}
{{- define "check.googlecreds" -}}
{{- if .Values.secrets.googleApiKey -}}
{{- print true -}}
{{- end -}}
{{- end -}}

{{/*
Check if IBM SL api key is specified
*/}}
{{- define "check.ibmslcreds" -}}
{{- if or .Values.secrets.ibmSoftLayerApiKey .Values.secrets.ibmSoftLayerApiUsername -}}
{{- print true -}}
{{- end -}}
{{- end -}}

{{/*
Check if Azure creds are specified
*/}}
{{- define "check.azurecreds" -}}
{{- if or (or .Values.secrets.azureTenantId .Values.secrets.azureClientId) .Values.secrets.azureClientSecret -}}
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

{{/*
Check if Vault creds are specified
*/}}
{{- define "check.vaultcreds" -}}
{{- if .Values.vault.secretName -}}
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
Returns a license base64 either from file or from values
or prints it for awsmarketplace or awsManagedLicense
*/}}
{{- define "k10.getlicense" -}}
{{- if .Values.metering.awsMarketplace -}}
{{- print "Y3VzdG9tZXJOYW1lOiBhd3MtbWFya2V0cGxhY2UKZGF0ZUVuZDogJzIxMDAtMDEtMDFUMDA6MDA6MDAuMDAwWicKZGF0ZVN0YXJ0OiAnMjAxOC0wOC0wMVQwMDowMDowMC4wMDBaJwpmZWF0dXJlczoKICBjbG91ZE1ldGVyaW5nOiBhd3MKaWQ6IGF3cy1ta3QtNWMxMDlmZDUtYWI0Yy00YTE0LWJiY2QtNTg3MGU2Yzk0MzRiCnByb2R1Y3Q6IEsxMApyZXN0cmljdGlvbnM6IG51bGwKdmVyc2lvbjogdjEuMC4wCnNpZ25hdHVyZTogY3ZEdTNTWHljaTJoSmFpazR3THMwTk9mcTNFekYxQ1pqLzRJMUZVZlBXS0JETHpuZmh2eXFFOGUvMDZxNG9PNkRoVHFSQlY3VFNJMzVkQzJ4alllaGp3cWwxNHNKT3ZyVERKZXNFWVdyMVFxZGVGVjVDd21HczhHR0VzNGNTVk5JQXVseGNTUG9oZ2x2UlRJRm0wVWpUOEtKTzlSTHVyUGxyRjlGMnpnK0RvM2UyTmVnamZ6eTVuMUZtd24xWUNlbUd4anhFaks0djB3L2lqSGlwTGQzWVBVZUh5Vm9mZHRodGV0YmhSUGJBVnVTalkrQllnRklnSW9wUlhpYnpTaEMvbCs0eTFEYzcyTDZXNWM0eUxMWFB1SVFQU3FjUWRiYnlwQ1dYYjFOT3B3aWtKMkpsR0thMldScFE4ZUFJNU9WQktqZXpuZ3FPa0lRUC91RFBtSXFBPT0K" -}}
{{- else if or ( .Values.metering.awsManagedLicense ) ( .Values.metering.licenseConfigSecretName ) -}}
{{- print "Y3VzdG9tZXJOYW1lOiBhd3MtdG90ZW0KZGF0ZUVuZDogJzIxMDAtMDEtMDFUMDA6MDA6MDAuMDAwWicKZGF0ZVN0YXJ0OiAnMjAyMS0wOS0wMVQwMDowMDowMC4wMDBaJwpmZWF0dXJlczoKICBleHRlcm5hbExpY2Vuc2U6IGF3cwogIHByb2R1Y3RTS1U6IGI4YzgyMWQ5LWJmNDAtNDE4ZC1iYTBiLTgxMjBiZjc3ZThmOQogIGtleUZpbmdlcnByaW50OiBhd3M6Mjk0NDA2ODkxMzExOkFXUy9NYXJrZXRwbGFjZTppc3N1ZXItZmluZ2VycHJpbnQKaWQ6IGF3cy1leHQtMWUxMTVlZjMtM2YyMC00MTJlLTgzODItMmE1NWUxMTc1OTFlCnByb2R1Y3Q6IEsxMApyZXN0cmljdGlvbnM6CiAgbm9kZXM6ICczJwp2ZXJzaW9uOiB2MS4wLjAKc2lnbmF0dXJlOiBkeEtLN3pPUXdzZFBOY2I1NExzV2hvUXNWeWZSVDNHVHZ0VkRuR1Vvb2VxSGlwYStTY25HTjZSNmdmdmtWdTRQNHh4RmV1TFZQU3k2VnJYeExOTE1RZmh2NFpBSHVrYmFNd3E5UXhGNkpGSmVXbTdzQmdtTUVpWVJ2SnFZVFcyMlNoakZEU1RWejY5c2JBTXNFMUd0VTdXKytITGk0dnhybjVhYkd6RkRHZW5iRE5tcXJQT3dSa3JIdTlHTFQ1WmZTNDFUL0hBMjNZZnlsTU54MGFlK2t5TGZvZXNuK3FKQzdld2NPWjh4eE94bFRJR3RuWDZ4UU5DTk5iYjhSMm5XbmljNVd0OElEc2VDR3lLMEVVRW9YL09jNFhsWVVra3FGQ0xPdVhuWDMxeFZNZ1NFQnVEWExFd3Y3K2RlSmcvb0pMaW9EVHEvWUNuM0lnem9VR2NTMGc9PQo=" -}}
{{- else -}}
{{- print (default (.Files.Get "license") .Values.license) -}}
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

{{- define "get.kanisterPodCustomLabels" -}}
{{- if .Values.kanisterPodCustomLabels }}
KanisterPodCustomLabels: {{ .Values.kanisterPodCustomLabels | quote }}
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
{{- $colocatedList := include "k10.colocatedServiceLookup" . | fromYaml }}
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
{{- $colocatedList := include "k10.colocatedServices" . | fromYaml }}
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
    {{- $isRestService := has $containerInPod (include "k10.restServices" . | splitList " ") }}
    {{- $isStatelessService := has $containerInPod (include "k10.statelessServices" . | splitList " ") }}
    {{- if and $isRestService (not $isStatelessService) }}
      {{- $statefulRestSvcsInPod = append $statefulRestSvcsInPod $containerInPod }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $statefulRestSvcsInPod | join " " }}
{{- end -}}

{{- define "k10.ingressPath" -}}
    {{- if and .Values.global.ingress.create .Values.global.route.enabled -}}
        {{  fail "Either enable ingress or route"}}
    {{- end -}}
    {{- if .Values.global.ingress.create -}}
        {{ if .Values.global.ingress.urlPath }}
            {{- print .Values.global.ingress.urlPath -}}
        {{ else }}
            {{- print .Release.Name -}}
        {{- end -}}
    {{- else if .Values.global.route.enabled -}}
        {{ if .Values.global.route.path }}
            {{- print .Values.global.route.path -}}
         {{ else }}
            {{- print .Release.Name -}}
        {{- end -}}
     {{ else }}
            {{- print .Release.Name -}}
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

{{- define "check.validateMonitoringProperties" -}}
{{- include "check.monitoringPrefix" . -}}
{{- include "check.monitoringFullNameOverride" . -}}
{{- end -}}

{{- define "check.monitoringPrefix" -}}
{{- if eq .Values.prometheus.server.enabled .Values.grafana.enabled -}}
{{- if not (eq .Values.prometheus.server.prefixURL .Values.grafana.prometheusPrefixURL) -}}
{{ fail "Prometheus and Grafana prefixURL should match. Please check values of prometheus.server.prefixURL and grafana.prometheusPrefixURL" }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "check.monitoringFullNameOverride" -}}
{{- if eq .Values.prometheus.server.enabled .Values.grafana.enabled -}}
{{- if not (eq .Values.prometheus.server.fullnameOverride .Values.grafana.prometheusName) -}}
{{ fail "The Prometheus name overrides must match. Please check values of prometheus.server.fullnameOverride and grafana.prometheusName" }}
{{- end -}}
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
