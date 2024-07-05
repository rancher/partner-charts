{{/* vim: set filetype=mustache: */}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
The components in this chart create additional resources that expand the longest created name strings.
The longest name that gets created of 20 characters, so truncation should be 63-20=43.
*/}}
{{- define "yugabyte.fullname" -}}
  {{- if .Values.fullnameOverride -}}
    {{- .Values.fullnameOverride | trunc 43 | trimSuffix "-" -}}
  {{- else -}}
    {{- $name := default .Chart.Name .Values.nameOverride -}}
    {{- if contains $name .Release.Name -}}
      {{- .Release.Name | trunc 43 | trimSuffix "-" -}}
    {{- else -}}
      {{- printf "%s-%s" .Release.Name $name | trunc 43 | trimSuffix "-" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Generate common labels.
*/}}
{{- define "yugabyte.labels" }}
heritage: {{ .Values.helm2Legacy | ternary "Tiller" (.Release.Service | quote) }}
release: {{ .Release.Name | quote }}
chart: {{ .Chart.Name | quote }}
component: {{ .Values.Component | quote }}
{{- if .Values.commonLabels}}
{{ toYaml .Values.commonLabels }}
{{- end }}
{{- end }}

{{/*
Generate app label.
*/}}
{{- define "yugabyte.applabel" }}
{{- if .root.Values.oldNamingStyle }}
app: "{{ .label }}"
{{- else }}
app.kubernetes.io/name: "{{ .label }}"
{{- end }}
{{- end }}

{{/*
Generate app selector.
*/}}
{{- define "yugabyte.appselector" }}
{{- if .root.Values.oldNamingStyle }}
app: "{{ .label }}"
{{- else }}
app.kubernetes.io/name: "{{ .label }}"
release: {{ .root.Release.Name | quote }}
{{- end }}
{{- end }}

{{/*
Create secrets in DBNamespace from other namespaces by iterating over envSecrets.
*/}}
{{- define "yugabyte.envsecrets" -}}
{{- range $v := .secretenv }}
{{- if $v.valueFrom.secretKeyRef.namespace }}
{{- $secretObj := (lookup
"v1"
"Secret"
$v.valueFrom.secretKeyRef.namespace
$v.valueFrom.secretKeyRef.name)
| default dict }}
{{- $secretData := (get $secretObj "data") | default dict }}
{{- $secretValue := (get $secretData $v.valueFrom.secretKeyRef.key) | default "" }}
{{- if (and (not $secretValue) (not $v.valueFrom.secretKeyRef.optional)) }}
{{- required (printf "Secret or key missing for %s/%s in namespace: %s"
$v.valueFrom.secretKeyRef.name
$v.valueFrom.secretKeyRef.key
$v.valueFrom.secretKeyRef.namespace)
nil }}
{{- end }}
{{- if $secretValue }}
apiVersion: v1
kind: Secret
metadata:
  {{- $secretfullname := printf "%s-%s-%s-%s"
  $.root.Release.Name
  $v.valueFrom.secretKeyRef.namespace
  $v.valueFrom.secretKeyRef.name
  $v.valueFrom.secretKeyRef.key
  }}
  name: {{ printf "%s-%s-%s-%s-%s-%s"
  $.root.Release.Name
  ($v.valueFrom.secretKeyRef.namespace | substr 0 5)
  ($v.valueFrom.secretKeyRef.name | substr 0 5)
  ( $v.valueFrom.secretKeyRef.key | substr 0 5)
  (sha256sum $secretfullname | substr 0 4)
  ($.suffix)
  | lower | replace "." "" | replace "_" ""
  }}
  namespace: "{{ $.root.Release.Namespace }}"
  labels:
    {{- include "yugabyte.labels" $.root | indent 4 }}
type: Opaque # should it be an Opaque secret?
data:
  {{ $v.valueFrom.secretKeyRef.key }}: {{ $secretValue | quote }}
{{- end }}
{{- end }}
---
{{- end }}
{{- end }}

{{/*
Add env secrets to DB statefulset.
*/}}
{{- define "yugabyte.addenvsecrets" -}}
{{- range $v := .secretenv }}
- name: {{ $v.name }}
  valueFrom:
    secretKeyRef:
      {{- if $v.valueFrom.secretKeyRef.namespace }}
      {{- $secretfullname := printf "%s-%s-%s-%s"
      $.root.Release.Name
      $v.valueFrom.secretKeyRef.namespace
      $v.valueFrom.secretKeyRef.name
      $v.valueFrom.secretKeyRef.key
      }}
      name: {{ printf "%s-%s-%s-%s-%s-%s"
      $.root.Release.Name
      ($v.valueFrom.secretKeyRef.namespace | substr 0 5)
      ($v.valueFrom.secretKeyRef.name | substr 0 5)
      ($v.valueFrom.secretKeyRef.key | substr 0 5)
      (sha256sum $secretfullname | substr 0 4)
      ($.suffix)
      | lower | replace "." "" | replace "_" ""
      }}
      {{- else }}
      name: {{ $v.valueFrom.secretKeyRef.name }}
      {{- end }}
      key: {{ $v.valueFrom.secretKeyRef.key }}
      optional: {{ $v.valueFrom.secretKeyRef.optional | default "false" }}
{{- end }}
{{- end }}
{{/*
Create Volume name.
*/}}
{{- define "yugabyte.volume_name" -}}
  {{- printf "%s-datadir" (include "yugabyte.fullname" .) -}}
{{- end -}}

{{/*
Derive the memory hard limit for each POD based on the memory limit.
Since the memory is represented in <x>GBi, we use this function to convert that into bytes.
Multiplied by 870 since 0.85 * 1024 ~ 870 (floating calculations not supported).
*/}}
{{- define "yugabyte.memory_hard_limit" -}}
  {{- printf "%d" .limits.memory | regexFind "\\d+" | mul 1024 | mul 1024 | mul 870 -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "yugabyte.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Generate a preflight check script invocation.
*/}}
{{- define "yugabyte.preflight_check" -}}
{{- if not .Values.preflight.skipAll -}}
{{- $port := .Preflight.Port -}}
{{- range $addr := split "," .Preflight.Addr -}}
if [ -f /home/yugabyte/tools/k8s_preflight.py ]; then
  PYTHONUNBUFFERED="true" /home/yugabyte/tools/k8s_preflight.py \
    dnscheck \
    --addr="{{ $addr }}" \
{{- if not $.Values.preflight.skipBind }}
    --port="{{ $port }}"
{{- else }}
    --skip_bind
{{- end }}
fi && \
{{ end }}
{{- end }}
{{- end }}

{{/*
Get YugaByte fs data directories.
*/}}
{{- define "yugabyte.fs_data_dirs" -}}
  {{- range $index := until (int (.count)) -}}
    {{- if ne $index 0 }},{{ end }}/mnt/disk{{ $index -}}
  {{- end -}}
{{- end -}}

{{/*
Get files from fs data directories for readiness / liveness probes.
*/}}
{{- define "yugabyte.fs_data_dirs_probe_files" -}}
  {{- range $index := until (int (.count)) -}}
    {{- if ne $index 0 }} {{ end }}"/mnt/disk{{ $index -}}/disk.check"
  {{- end -}}
{{- end -}}


{{/*
Generate server FQDN.
*/}}
{{- define "yugabyte.server_fqdn" -}}
  {{- if .Values.multicluster.createServicePerPod -}}
    {{- printf "$(HOSTNAME).$(NAMESPACE).svc.%s" .Values.domainName -}}
  {{- else if (and .Values.oldNamingStyle .Values.multicluster.createServiceExports) -}}
    {{ $membershipName := required "A valid membership name is required! Please set multicluster.kubernetesClusterId" .Values.multicluster.kubernetesClusterId }}
    {{- printf "$(HOSTNAME).%s.%s.$(NAMESPACE).svc.clusterset.local" $membershipName .Service.name -}}
  {{- else if .Values.oldNamingStyle -}}
    {{- printf "$(HOSTNAME).%s.$(NAMESPACE).svc.%s" .Service.name .Values.domainName -}}
  {{- else -}}
    {{- if .Values.multicluster.createServiceExports -}}
      {{ $membershipName := required "A valid membership name is required! Please set multicluster.kubernetesClusterId" .Values.multicluster.kubernetesClusterId }}
      {{- printf "$(HOSTNAME).%s.%s-%s.$(NAMESPACE).svc.clusterset.local" $membershipName (include "yugabyte.fullname" .) .Service.name -}}
    {{- else -}}
      {{- printf "$(HOSTNAME).%s-%s.$(NAMESPACE).svc.%s" (include "yugabyte.fullname" .) .Service.name .Values.domainName -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Generate server broadcast address.
*/}}
{{- define "yugabyte.server_broadcast_address" -}}
  {{- include "yugabyte.server_fqdn" . }}:{{ index .Service.ports "tcp-rpc-port" -}}
{{- end -}}

{{/*
Generate server RPC bind address.

In case of multi-cluster services (MCS), we set it to $(POD_IP) to
ensure YCQL uses a resolvable address.
See https://github.com/yugabyte/yugabyte-db/issues/16155

We use a workaround for above in case of Istio by setting it to
$(POD_IP) and localhost. Master doesn't support that combination, so
we stick to 0.0.0.0, which works for master.
*/}}
{{- define "yugabyte.rpc_bind_address" -}}
  {{- $port := index .Service.ports "tcp-rpc-port" -}}
  {{- if .Values.istioCompatibility.enabled -}}
    {{- if (eq .Service.name "yb-masters") -}}
      0.0.0.0:{{ $port }}
    {{- else -}}
      $(POD_IP):{{ $port }},127.0.0.1:{{ $port }}
    {{- end -}}
  {{- else if (or .Values.multicluster.createServiceExports .Values.multicluster.createServicePerPod) -}}
    $(POD_IP):{{ $port }}
  {{- else -}}
    {{- include "yugabyte.server_fqdn" . -}}
  {{- end -}}
{{- end -}}

{{/*
Generate server web interface.
*/}}
{{- define "yugabyte.webserver_interface" -}}
  {{- eq .Values.ip_version_support "v6_only" | ternary "[::]" "0.0.0.0" -}}
{{- end -}}

{{/*
Generate server CQL proxy bind address.
*/}}
{{- define "yugabyte.cql_proxy_bind_address" -}}
  {{- if or .Values.istioCompatibility.enabled .Values.multicluster.createServiceExports .Values.multicluster.createServicePerPod -}}
    0.0.0.0:{{ index .Service.ports "tcp-yql-port" -}}
  {{- else -}}
    {{- include "yugabyte.server_fqdn" . -}}
  {{- end -}}
{{- end -}}

{{/*
Generate server PGSQL proxy bind address.
*/}}
{{- define "yugabyte.pgsql_proxy_bind_address" -}}
  {{- eq .Values.ip_version_support "v6_only" | ternary "[::]" "0.0.0.0" -}}:{{ index .Service.ports "tcp-ysql-port" -}}
{{- end -}}

{{/*
Get YugaByte master addresses
*/}}
{{- define "yugabyte.master_addresses" -}}
  {{- $master_replicas := .Values.replicas.master | int -}}
  {{- $domain_name := .Values.domainName -}}
  {{- $newNamingStylePrefix := printf "%s-" (include "yugabyte.fullname" .) -}}
  {{- $prefix := ternary "" $newNamingStylePrefix $.Values.oldNamingStyle -}}
  {{- range .Values.Services -}}
    {{- if eq .name "yb-masters" -}}
      {{- range $index := until $master_replicas -}}
        {{- if ne $index 0 }},{{ end -}}
        {{- $prefix }}yb-master-{{ $index }}.{{ $prefix }}yb-masters.$(NAMESPACE).svc.{{ $domain_name }}:7100
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Compute the maximum number of unavailable pods based on the number of master replicas
*/}}
{{- define "yugabyte.max_unavailable_for_quorum" -}}
  {{- $master_replicas_100x := .Values.replicas.master | int | mul 100 -}}
  {{- $max_unavailable_master_replicas := 100 | div (100 | sub (2 | div ($master_replicas_100x | add 100))) -}}
  {{- printf "%d" $max_unavailable_master_replicas -}}
{{- end -}}

{{/*
Set consistent issuer name.
*/}}
{{- define "yugabyte.tls_cm_issuer" -}}
  {{- if .Values.tls.certManager.bootstrapSelfsigned -}}
    {{ .Values.oldNamingStyle | ternary "yugabyte-selfsigned" (printf "%s-selfsigned" (include "yugabyte.fullname" .)) }}
  {{- else -}}
    {{ .Values.tls.certManager.useClusterIssuer | ternary .Values.tls.certManager.clusterIssuer .Values.tls.certManager.issuer}}
  {{- end -}}
{{- end -}}

{{/*
  Verify the extraVolumes and extraVolumeMounts mappings.
  Every extraVolumes should have extraVolumeMounts
*/}}
{{- define "yugabyte.isExtraVolumesMappingExists" -}}
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
  Default nodeAffinity for multi-az deployments
*/}}
{{- define "yugabyte.multiAZNodeAffinity" -}}
requiredDuringSchedulingIgnoredDuringExecution:
  nodeSelectorTerms:
  - matchExpressions:
    - key: failure-domain.beta.kubernetes.io/zone
      operator: In
      values:
      - {{ .Values.AZ }}
  - matchExpressions:
    - key: topology.kubernetes.io/zone
      operator: In
      values:
      - {{ .Values.AZ }}
{{- end -}}

{{/*
  Default podAntiAffinity for master and tserver

  This requires "appLabelArgs" to be passed in - defined in service.yaml
  we have a .root and a .label in appLabelArgs
*/}}
{{- define "yugabyte.podAntiAffinity" -}}
preferredDuringSchedulingIgnoredDuringExecution:
- weight: 100
  podAffinityTerm:
    labelSelector:
      matchExpressions:
      {{- if .root.Values.oldNamingStyle }}
      - key: app
        operator: In
        values:
        - "{{ .label }}"
      {{- else }}
      - key: app.kubernetes.io/name
        operator: In
        values:
        - "{{ .label }}"
      - key: release
        operator: In
        values:
        - {{ .root.Release.Name | quote }}
      {{- end }}
    topologyKey: kubernetes.io/hostname
{{- end -}}
