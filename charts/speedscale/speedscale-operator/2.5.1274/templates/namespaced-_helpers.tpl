{{/*
Shared helpers for the namespaced chart.

Hand-written per the S-12913 spike decision (hand-written templates + the
parity harness in operator/controlplane/parity, never generated). Where a
helper differs from the spike's generated seed the reason is stated inline.
*/}}

{{/*
speedscale.instanceID is the per-install id that becomes PROCESS_ID in BOTH the
forwarder and inspector ConfigMaps, and INSTANCE_ID in the replay coordinator's.
One id, three ConfigMaps, two key names: the forwarder and inspector are built
by lib/kube/build (PROCESS_ID), the coordinator is the operator binary and reads
`mapstructure:"instance_id"` -> INSTANCE_ID, which Settings.Validate() requires
to be non-blank.

The operator generates ONE settings.InstanceID per process and hands it to both
components. Helm has no process to generate it in, and `uuidv4` is re-evaluated
on every include -- the spike's helper fell straight through to it and handed
the two ConfigMaps DIFFERENT ids (SPIKE.md R4). The order below is what keeps
them equal:

  1. .Values.namespaced.instanceID, when the operator set it. Deterministic across
     includes, upgrades and `helm template` runs, so this is the supported way
     to pin it.
  2. The live speedscale-forwarder ConfigMap's PROCESS_ID, so an upgrade of an
     already-installed release keeps the id the components have been reporting
     under. `lookup` returns an empty map under `helm template`, so this branch
     is inert at render time by design.
  3. clusterName + the release namespace + the release name. NOT uuidv4:
     derived from data that is identical for every include in one render,
     which is exactly the property the invariant needs. It is stable across
     upgrades of the same release, and distinct across releases, namespaces
     and clusters. The namespace is load-bearing: Helm release names are only
     namespace-scoped, so two app namespaces can both install a release named
     "speedscale" in one cluster - without the namespace they would share an
     id and their telemetry and inventory identity would merge. Installs that
     already wrote a ConfigMap keep their old id through branch 2 above.

operator/controlplane/parity/invariants.go asserts the forwarder and inspector
ConfigMaps agree, so a regression here fails CI rather than shipping.
*/}}
{{- define "speedscale.namespaced.instanceID" -}}
{{- if .Values.namespaced.instanceID -}}
{{- .Values.namespaced.instanceID -}}
{{- else -}}
{{- $cm := (lookup "v1" "ConfigMap" .Release.Namespace "speedscale-forwarder") -}}
{{- if and $cm $cm.data (index (default dict $cm.data) "PROCESS_ID") -}}
{{- index $cm.data "PROCESS_ID" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Values.namespaced.clusterName .Release.Namespace .Release.Name -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
speedscale.apiKeySecretName is the name of the pre-existing API key Secret. The
chart never creates it; see values.yaml.
*/}}
{{- define "speedscale.namespaced.apiKeySecretName" -}}
{{- .Values.namespaced.apiKeySecret | default "speedscale-apikey" -}}
{{- end -}}

{{/*
speedscale.certsSecretName is the TLS Secret the components mount. When
tls.create is on the chart renders speedscale-certs and that name is fixed;
otherwise the user names an existing Secret.
*/}}
{{- define "speedscale.namespaced.certsSecretName" -}}
{{- if .Values.namespaced.tls.create -}}
speedscale-certs
{{- else -}}
{{- required "tls.certsSecret must name an existing TLS Secret when tls.create is false" .Values.namespaced.tls.certsSecret -}}
{{- end -}}
{{- end -}}

{{- define "speedscale.namespaced.inspectorServiceAccountName" -}}
{{- .Values.namespaced.inspector.serviceAccountName | default "speedscale-inspector" -}}
{{- end -}}

{{/*
speedscale.replayRuntimeName is the fixed name of the static replay runtime
ServiceAccount, Role and RoleBinding. It matches
build.StaticReplayRuntimeRoleName() / SvcAccountName("") -- the DNS1035 form of
libkube.NameDefault -- because the replay components look their account up by
that name.
*/}}
{{- define "speedscale.namespaced.replayRuntimeName" -}}
{{- .Values.namespaced.replayRuntime.serviceAccountName | default "speedscale" -}}
{{- end -}}

{{/*
speedscale.secretNames lists every Secret a namespaced install may read, as
individual resourceNames. There is deliberately no blanket Secret rule anywhere
in this chart: the whole point of the namespaced install is that a security
reviewer can enumerate exactly which Secrets Speedscale can see.
*/}}
{{- define "speedscale.namespaced.secretNames" -}}
{{- $names := list (include "speedscale.namespaced.apiKeySecretName" .) -}}
{{- if .Values.namespaced.tls.create -}}
{{- $names = append $names "speedscale-certs" -}}
{{- else if .Values.namespaced.tls.certsSecret -}}
{{- $names = append $names .Values.namespaced.tls.certsSecret -}}
{{- end -}}
{{- if .Values.namespaced.tls.createJKS -}}
{{- $names = append $names (.Values.namespaced.tls.jksSecret | default "speedscale-jks") -}}
{{- end -}}
{{- range .Values.namespaced.secretAccessList -}}
{{- $names = append $names . -}}
{{- end -}}
{{- toYaml (uniq (compact $names)) -}}
{{- end -}}

{{/*
speedscale.durationSeconds turns a whole-unit Go duration ("5m", "300s", "2h")
into seconds, for the Kubernetes fields that take an integer. It fails loudly on
anything it cannot convert rather than silently producing 0, which would make a
Job's activeDeadlineSeconds reject the Job.
*/}}
{{- define "speedscale.namespaced.durationSeconds" -}}
{{- $d := . | toString -}}
{{- if regexMatch "^[0-9]+h$" $d -}}
{{- mul (trimSuffix "h" $d | int) 3600 -}}
{{- else if regexMatch "^[0-9]+m$" $d -}}
{{- mul (trimSuffix "m" $d | int) 60 -}}
{{- else if regexMatch "^[0-9]+s$" $d -}}
{{- trimSuffix "s" $d | int -}}
{{- else if regexMatch "^[0-9]+$" $d -}}
{{- $d | int -}}
{{- else -}}
{{- fail (printf "cannot convert duration %q to seconds: use a whole number of h, m or s (e.g. 5m)" $d) -}}
{{- end -}}
{{- end -}}
