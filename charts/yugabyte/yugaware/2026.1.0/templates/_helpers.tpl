{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "yugaware.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "yugaware.fullname" -}}
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
{{- define "yugaware.chart" -}}
{{- printf "%s" .Chart.Name | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Implements customization for the registry for component images.

The preference is to use the image.commonRegistry field first if it is set.
Otherwise the local registry override for each image is used if set, for ex: image.postgres.registry

In both cases, the image name and tag can be customized by using the overrides for each image, for ex: image.postgres.name
*/}}
{{- define "full_image" -}}
  {{- $specific_registry := (get (get .root.Values.image .containerName) "registry") -}}
  {{- if not (empty .root.Values.image.commonRegistry) -}}
    {{- $specific_registry = .root.Values.image.commonRegistry -}}
  {{- end -}}
 {{- if not (empty $specific_registry) -}}
    {{- $specific_registry = printf "%s/" $specific_registry -}}
  {{- end -}}
  {{- $specific_name := (toString (get (get .root.Values.image .containerName) "name")) -}}
  {{- $specific_tag := (toString (get (get .root.Values.image .containerName) "tag")) -}}
  {{- printf "%s%s:%s" $specific_registry $specific_name $specific_tag  -}}
{{- end -}}

{{/*
Implements customization for the registry for the yugaware docker image.

The preference is to use the image.commonRegistry field first if it is set.
Otherwise the image.repository field is used.

In both cases, image.tag can be used to customize the tag of the yugaware image.
*/}}
{{- define "full_yugaware_image" -}}
  {{- $specific_registry := .Values.image.repository -}}
  {{- if not (empty .Values.image.commonRegistry) -}}
    {{- $specific_registry = printf "%s/%s" .Values.image.commonRegistry "yugabyte/yugaware" -}}
  {{- end -}}
  {{- $specific_tag := (toString .Values.image.tag) -}}
  {{- printf "%s:%s" $specific_registry $specific_tag  -}}
{{- end -}}

{{/*
Get or generate PG password
Source - https://github.com/helm/charts/issues/5167#issuecomment-843962731
*/}}
{{- define "getOrGeneratePassword" }}
{{- $len := (default 8 .Length) | int -}}
{{- $obj := (lookup "v1" .Kind .Namespace .Name).data -}}
{{- if $obj }}
{{- index $obj .Key -}}
{{- else if (eq (lower .Kind) "secret") -}}
{{- randAlphaNum $len | b64enc -}}
{{- else -}}
{{- randAlphaNum $len -}}
{{- end -}}
{{- end -}}

{{/*
Similar to getOrGeneratePassword but written for migration from
ConfigMap to Secret. Secret is given precedence, and then the upgrade
case of ConfigMap to Secret is handled.
TODO: remove this after few releases i.e. once all old platform
installations are upgraded, and use getOrGeneratePassword.
*/}}
{{- define "getOrGeneratePasswordConfigMapToSecret" }}
{{- $len := (default 8 .Length) | int -}}
{{- $obj := (lookup "v1" "Secret" .Namespace .Name).data -}}
{{- if $obj }}
{{- index $obj .Key -}}
{{- else -}}
{{- $obj := (lookup "v1" "ConfigMap" .Namespace .Name).data -}}
{{- if $obj }}
{{- index $obj .Key | b64enc -}}
{{- else -}}
{{- randAlphaNum $len | b64enc -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Make list of allowed CORS origins
*/}}
{{- define "allowedCorsOrigins" -}}
[
{{- range .Values.yugaware.additionAllowedCorsOrigins -}}
{{- . | quote }},
{{- end -}}
{{- if .Values.tls.enabled -}}
"https://{{ .Values.tls.hostname }}"
{{- else -}}
"http://{{ .Values.tls.hostname }}"
{{- end -}}
]
{{- end -}}

{{/*
Get or generate server cert and key
*/}}
{{- define "getOrCreateServerCert" -}}
{{- $root := .Root -}}
{{- if and $root.Values.tls.certificate $root.Values.tls.key -}}
server.key: {{ $root.Values.tls.key }}
server.crt: {{ $root.Values.tls.certificate }}
  {{- if $root.Values.tls.ca_certificate -}}
ca.crt: {{ $root.Values.tls.ca_certificate }}
  {{- end -}}
{{- else -}}
  {{- $result := (lookup "v1" "Secret" .Namespace .Name).data -}}
  {{- if and $result (index $result "server.pem") (index $result "ca.pem") -}}
server.key: {{ index $result "server.key" }}
server.crt: {{ index $result "server.crt" }}
ca.crt: {{ index $result "ca.crt" }}
  {{- else -}}
    {{- $caCert := genCA $root.Values.tls.hostname 3650 -}}
    {{- $cert := genSignedCert $root.Values.tls.hostname nil nil 3650 $caCert -}}
server.key: {{ $cert.Key | b64enc }}
server.crt: {{ $cert.Cert | b64enc }}
ca.crt: {{ $caCert.Cert | b64enc }}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Get or generate server key cert in pem format
*/}}
{{- define "getOrCreateServerPem" -}}
{{- $root := .Root -}}
{{- if and $root.Values.tls.certificate $root.Values.tls.key -}}
{{- $decodedKey := $root.Values.tls.key | b64dec -}}
{{- $decodedCert := $root.Values.tls.certificate | b64dec -}}
{{- $serverPemContentTemp := ( printf "%s\n%s" $decodedKey $decodedCert ) -}}
{{- $serverPemContent := $serverPemContentTemp | b64enc -}}
  {{- if $root.Values.tls.ca_certificate -}}
    {{- $caPemContent := $root.Values.tls.ca_certificate -}}
ca.pem: {{ $caPemContent }}
  {{- end}}
server.pem: {{ $serverPemContent }}
{{- else -}}
  {{- $result := (lookup "v1" "Secret" .Namespace .Name).data -}}
    {{- if and $result (index $result "server.pem") (index $result "ca.pem") -}}
    {{- $serverPemContent := ( index $result "server.pem" ) -}}
    {{- $caPemContent := ( index $result "ca.pem" ) -}}
ca.pem: {{ $caPemContent }}
server.pem: {{ $serverPemContent }}
  {{- else -}}
    {{- $caCert := genCA $root.Values.tls.hostname 3650 -}}
    {{- $cert := genSignedCert $root.Values.tls.hostname nil nil 3650 $caCert -}}
    {{- $serverPemContentTemp := ( printf "%s\n%s" $cert.Key $cert.Cert ) -}}
    {{- $serverPemContent := $serverPemContentTemp | b64enc -}}
    {{- $caPemContentTemp := ( printf "%s" $caCert.Cert ) -}}
    {{- $caPemContent := $caPemContentTemp | b64enc -}}
server.pem: {{ $serverPemContent }}
ca.pem: {{ $caPemContent }}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Check export of nss_wrapper environment variables required
*/}}
{{- define "checkNssWrapperExportRequired" -}}
  {{- if .Values.securityContext.enabled -}}
    {{- if and (ne (int .Values.securityContext.runAsUser) 0) (ne (int .Values.securityContext.runAsUser) 10001) -}}
      {{- printf "true" -}}
    {{- end -}}
  {{- else -}}
      {{- printf "false" -}}
  {{- end -}}
{{- end -}}


{{/*
  Verify the extraVolumes and extraVolumeMounts mappings.
  Every extraVolumes should have extraVolumeMounts
*/}}
{{- define "yugaware.isExtraVolumesMappingExists" -}}
  {{- $lenExtraVolumes := len .extraVolumes -}}
  {{- $lenExtraVolumeMounts := len .extraVolumeMounts -}}

  {{- if and (eq $lenExtraVolumeMounts 0) (gt $lenExtraVolumes 0) -}}
    {{- fail "You have not provided the extraVolumeMounts for extraVolumes." -}}
  {{- else if and (eq $lenExtraVolumes 0) (gt $lenExtraVolumeMounts 0) -}}
    {{- fail "You have not provided the extraVolumes for extraVolumeMounts." -}}
  {{- else if and (gt $lenExtraVolumes 0) (gt $lenExtraVolumeMounts 0) -}}
      {{- $volumeMountsList := list -}}
      {{- range .extraVolumeMounts -}}
        {{- $volumeMountsList = append $volumeMountsList .name -}}
      {{- end -}}

      {{- $volumesList := list -}}
      {{- range .extraVolumes -}}
        {{- $volumesList = append $volumesList .name -}}
      {{- end -}}

      {{- range $volumesList -}}
        {{- if not (has . $volumeMountsList) -}}
          {{- fail (printf "You have not provided the extraVolumeMounts for extraVolume %s" .) -}}
        {{- end -}}
      {{- end -}}

      {{- range $volumeMountsList -}}
        {{- if not (has . $volumesList) -}}
          {{- fail (printf "You have not provided the extraVolumes for extraVolumeMounts %s" .) -}}
        {{- end -}}
      {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
  Get Security Context.
*/}}
{{- define "getSecurityContext" }}
securityContext:
  runAsUser: {{ required "runAsUser cannot be empty" .Values.securityContext.runAsUser }}
  runAsGroup: {{ .Values.securityContext.runAsGroup | default 0 }}
  runAsNonRoot: {{ .Values.securityContext.runAsNonRoot }}
  {{- if .Values.securityContext.additionalSettings }}
{{ toYaml .Values.securityContext.additionalSettings | indent 2}}
  {{- end }}
{{- end -}}

{{/*
  Get TServer/Master flags to start yugabyted.
*/}}
{{- define "getYbdbFlags" -}}
  {{- $flagsList := "" -}}
  {{- if .flags -}}
  {{- range $key, $value := .flags -}}
  {{- if not $flagsList -}}
  {{- $flagsList = printf "%s=%v" $key $value -}}
  {{- else -}}
  {{- $flagsList = printf "%s,%s=%v" $flagsList $key $value -}}
  {{- end -}}
  {{- end -}}
  {{- end -}}
  {{- printf $flagsList -}}

{{- end -}}

{{/*
Make list of custom http headers
*/}}
{{- define "customHeaders" -}}
[
{{- $headers := .Values.yugaware.custom_headers -}}
{{- range $index, $element := $headers -}}
  {{- if ne $index (sub (len $headers) 1) -}}
    {{- . | quote }},
  {{- else -}}
    {{- . | quote }}
  {{- end -}}
{{- end -}}
]
{{- end -}}

{{/*
Common labels to be applied to all objects
*/}}
{{- define "yugaware.commonLabels" -}}
{{- $commonLabels := .Values.commonLabels | default dict -}}
{{- if $commonLabels -}}
{{- toYaml $commonLabels -}}
{{- end -}}
{{- end -}}

{{/*
Compare a version string to stable and preview versions. Versions must not include build numbers
Usage: {{ include "yb_version_compare" (list $version $stable $preview) }}
Returns: 1 if version > target, 0 if equal, -1 if version < target. Target is stable if version matches stable pattern, else preview.
*/}}
{{- define "yb_version_compare" -}}
  {{- $args := . -}}
  {{- $ver := index $args 0 -}}
  {{- $stable := index $args 1 -}}
  {{- $preview := index $args 2 -}}
  {{- $stablePattern := "^[0-9]{4}\\.[0-9]+\\.[0-9]+\\.[0-9]+$" -}}
  {{- $target := "" -}}
  {{- if regexMatch $stablePattern $ver -}}
    {{- $target = $stable -}}
  {{- else -}}
    {{- $target = $preview -}}
  {{- end -}}
  {{- $verParts := splitList "." $ver -}}
  {{- $targetParts := splitList "." $target -}}
  {{- $maxParts := (int (max (len $verParts) (len $targetParts))) -}}
  {{- $result := 0 -}}
  {{- range $i, $v := until $maxParts -}}
    {{- $verNum := (int (default "0" (index $verParts (int $i)))) -}}
    {{- $targetNum := (int (default "0" (index $targetParts (int $i)))) -}}
    {{- if gt $verNum $targetNum -}}
      {{- $result = 1 -}}
      {{- break -}}
    {{- else if lt $verNum $targetNum -}}
      {{- $result = -1 -}}
      {{- break -}}
    {{- end -}}
  {{- end -}}
  {{- if eq $result 1 -}}1{{- else if eq $result 0 -}}0{{- else -}}-1{{- end -}}
{{- end -}}