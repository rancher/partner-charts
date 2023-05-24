{{/* vim: set filetype=mustache: */}}

{{/*
Create the fullname, with suffix of deployment.name
Unless `ingress.path: /` or `name: default`

!! to be called from scope of a `deployment.xyz` entry.
*/}}
{{- define "webservice.fullname.withSuffix" -}}
{{- printf "%s-%s" .fullname .name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Returns the secret name for the Secret containing the TLS certificate and key.
Uses `ingress.tls.secretName` first and falls back to `global.ingress.tls.secretName`
if there is a shared tls secret for all ingresses.
*/}}
{{- define "webservice.tlsSecret" -}}
{{- $defaultName := (dict "secretName" "") -}}
{{- if $.Values.global.ingress.configureCertmanager -}}
{{- $_ := set $defaultName "secretName" (printf "%s-gitlab-tls" $.Release.Name) -}}
{{- else -}}
{{- $_ := set $defaultName "secretName" (include "gitlab.wildcard-self-signed-cert-name" .) -}}
{{- end -}}
{{- pluck "secretName" $.Values.ingress.tls $.Values.global.ingress.tls $defaultName | first -}}
{{- end -}}

{{/*
Returns the secret name for the Secret containing the TLS certificate and key for
the smartcard host.
Uses `ingress.tls.secretName` first and falls back to `global.ingress.tls.secretName`
if there is a shared tls secret for all ingresses.
*/}}
{{- define "smartcard.tlsSecret" -}}
{{- $defaultName := (dict "secretName" "") -}}
{{- if $.Values.global.ingress.configureCertmanager -}}
{{- $_ := set $defaultName "secretName" (printf "%s-gitlab-tls-smartcard" $.Release.Name) -}}
{{- else -}}
{{- $_ := set $defaultName "secretName" (include "gitlab.wildcard-self-signed-cert-name" .) -}}
{{- end -}}
{{- coalesce $.Values.ingress.tls.smartcardSecretName (pluck "secretName" $.Values.global.ingress.tls $defaultName | first) -}}
{{- end -}}

{{/*
Returns the workhorse image repository depending on the value of global.edition.

Used to switch the deployment from Enterprise Edition (default) to Community
Edition. If global.edition=ce, returns the Community Edition image repository
set in the Gitlab values.yaml, otherwise returns the Enterprise Edition
image repository.
*/}}
{{- define "workhorse.repository" -}}
{{- if eq "ce" $.Values.global.edition -}}
{{ index $.Values "global" "communityImages" "workhorse" "repository" }}
{{- else -}}
{{ index $.Values "global" "enterpriseImages" "workhorse" "repository" }}
{{- end -}}
{{- end -}}

{{/*
Returns the webservice image depending on the value of global.edition.

Used to switch the deployment from Enterprise Edition (default) to Community
Edition. If global.edition=ce, returns the Community Edition image repository
set in the Gitlab values.yaml, otherwise returns the Enterprise Edition
image repository.
*/}}
{{- define "webservice.image" -}}
{{ coalesce $.Values.image.repository (include "image.repository" .) }}:{{ coalesce .Values.image.tag (include "gitlab.versionTag" . ) }}{{ include "gitlab.image.tagSuffix" . }}
{{- end -}}

{{/*
Returns gomplate section for Workhorse direct object storage configuration.

If Minio in use, set AWS and keys.
If consolidated object storage is in use, read the connection YAML
  If provider is AWS, render enabled as true.
*/}}
{{- define "workhorse.object_storage.config" -}}
{%- $supported_providers := slice "AWS" "AzureRM" "Google" -%}
{%- $connection := coll.Dict "provider" "" -%}
{%- if file.Exists "/etc/gitlab/minio/accesskey" %}
  {%- $aws_access_key_id := file.Read "/etc/gitlab/minio/accesskey" | strings.TrimSpace -%}
  {%- $aws_secret_access_key := file.Read "/etc/gitlab/minio/secretkey" | strings.TrimSpace -%}
  {%- $connection = coll.Dict "provider" "AWS" "aws_access_key_id" $aws_access_key_id "aws_secret_access_key" $aws_secret_access_key -%}
{%- end %}
{%- if file.Exists "/etc/gitlab/objectstorage/object_store" %}
  {%- $connection = file.Read "/etc/gitlab/objectstorage/object_store" | strings.TrimSpace | data.YAML -%}
{%- end %}
{%- if has $supported_providers $connection.provider %}
[object_storage]
provider = "{% $connection.provider %}"
{%-   if eq $connection.provider "AWS" %}
{%-     $connection = coll.Merge $connection (coll.Dict "aws_access_key_id" "" "aws_secret_access_key" "" ) %}
# AWS / S3 object storage configuration.
[object_storage.s3]
# access/secret can be blank!
aws_access_key_id = {% $connection.aws_access_key_id | strings.TrimSpace | data.ToJSON %}
aws_secret_access_key = {% $connection.aws_secret_access_key | strings.TrimSpace | data.ToJSON %}
{%-   else if eq $connection.provider "AzureRM" %}
{%- $connection = coll.Merge $connection (coll.Dict "azure_storage_account_name" "" "azure_storage_account_name" "" ) %}
# Azure Blob storage configuration.
[object_storage.azurerm]
azure_storage_account_name = {% $connection.azure_storage_account_name | strings.TrimSpace | data.ToJSON %}
azure_storage_access_key = {% $connection.azure_storage_access_key | strings.TrimSpace | data.ToJSON %}
{%-   else if eq $connection.provider "Google" %}
# Google storage configuration.
[object_storage.google]
{% $connection | coll.Omit "provider" | data.ToTOML %}
{%-   end %}
{%- end %}
{{- end -}}

{{/*
Returns the extraEnv keys and values to inject into containers. Allows
pod-level values for extraEnv.

Takes a dict with `local` being the pod-level configuration and `parent`
being the chart-level configuration.

Pod values take precedence, then chart values, and finally global
values.
*/}}
{{- define "webservice.podExtraEnv" -}}
{{- $allExtraEnv := merge (default (dict) .local.extraEnv) (default (dict) .context.Values.extraEnv) .context.Values.global.extraEnv -}}
{{- range $key, $value := $allExtraEnv }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- end -}}
{{- end -}}

{{/*
Output a .spec.selector YAML section

To be consumed by: Deployment and PodDisruptionBudget
*/}}
{{- define "webservice.spec.selector" -}}
matchLabels:
  app: {{ template "name" $ }}
  release: {{ $.Release.Name }}
  {{ template "webservice.labels" . | nindent 2 }}
{{- end -}}

{{/*
Output labels specifically for webservice
*/}}
{{- define "webservice.labels" -}}
gitlab.com/webservice-name: {{ .name }}
{{- end -}}

{{/*
Returns a list of _common_ labels to be shared across all
Webservice deployments and other shared objects.
*/}}
{{- define "webservice.commonLabels" -}}
{{- $commonLabels := default (dict) .common.labels -}}
{{- if $commonLabels }}
{{-   range $key, $value := $commonLabels }}
{{ $key }}: {{ $value | quote }}
{{-   end }}
{{- end -}}
{{- end -}}

{{/*
Returns a list of _pod_ labels to be shared across all
Webservice deployments.
*/}}
{{- define "webservice.podLabels" -}}
{{- range $key, $value := .pod.labels }}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- end -}}

{{/*
Returns the extraEnv keys and values to inject into containers.

Global values will override any chart-specific values.
*/}}
{{- define "webservice.extraEnv" -}}
{{- $allExtraEnv := merge (default (dict) .local.extraEnv) .global.extraEnv -}}
{{- range $key, $value := $allExtraEnv }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- end -}}
{{- end -}}

{{/*

*/}}
{{/*
Defines a volume containing all public host SSH keys, fingerprints of which will become available
under /help/instance_configuration for users to be able to verify the server

It expects a dictionary with three entries:
- `local` which contains sshHostKeys configuration of a single webservice Deployment
- `Release` being a copy of .Release
- `Values` being a copy of .Values

The `Release` and `Values` keys are needed because of the usage of the
`gitlab.gitlab-shell.hostKeys.secret` helper.
*/}}
{{- define "webservice.sshHostKeys.volume" -}}
- name: {{ .local.sshHostKeys.mountName }}
  secret:
    secretName: {{ template "gitlab.gitlab-shell.hostKeys.secret" . }}
    items:
    {{- range .local.sshHostKeys.types }}
    - key: ssh_host_{{ . }}_key.pub
      path: ssh_host_{{ . }}_key.pub
    {{- end -}}
{{- end -}}

{{/*
Return the webservice TLS secret name
*/}}
{{- define "webservice.tls.secret" -}}
{{- default (printf "%s-webservice-tls" .Release.Name) $.Values.tls.secretName | quote -}}
{{- end -}}

{{/*
Return the webservice-metrics TLS secret name.
*/}}
{{- define "webservice-metrics.tls.secret" -}}
{{- $.Values.metrics.tls.secretName | default (include "webservice.tls.secret" .) }}
{{- end -}}

{{/*
Return whether the webservice has TLS for metrics enabled.
*/}}
{{- define "webservice-metrics.tls.enabled" -}}
{{- if hasKey $.Values.metrics.tls "enabled" }}
{{-   $.Values.metrics.tls.enabled }}
{{- else }}
{{-   $.Values.tls.enabled }}
{{- end }}
{{- end -}}

{{/*
Return the Workhorse TLS Secret name
*/}}
{{- define "workhorse.tls.secret" -}}
{{- default (printf "%s-workhorse-tls" .Release.Name) $.Values.workhorse.tls.secretName | quote -}}
{{- end -}}

{{/*
Return whether the Workhorse exporter has TLS enabled.
*/}}
{{- define "workhorse.monitoring.exporter.tls.enabled" -}}
{{- if hasKey $.Values.workhorse.monitoring.exporter.tls "enabled" }}
{{-   $.Values.workhorse.monitoring.exporter.tls.enabled }}
{{- else }}
{{-   $.Values.global.workhorse.tls.enabled }}
{{- end }}
{{- end -}}
