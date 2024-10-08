
{{/*
Sawtooth Selector labels
*/}}
{{- define "sawtooth.labels" -}}
{{ include "lib.labels" . }}
app: {{ include "common.names.fullname" . }}
{{- end -}}

{{- define "sawtooth.kind" -}}
{{ $consensus := .Values.sawtooth.consensus | int }}
{{- if or .Values.sawtooth.statefulset.enabled (eq $consensus 100) -}}
StatefulSet
{{- else -}}
DaemonSet
{{- end -}}
{{- end -}}

{{/*
Sawtooth Selector labels
*/}}
{{- define "sawtooth.labels.matchLabels" -}}
{{ include "common.labels.matchLabels" . }}
app: {{ include "common.names.fullname" . }}
component: sawtooth
{{- end -}}

{{/* if the consensus type is devmode replicas is always 1 */}}
{{- define "sawtooth.replicas" -}}
{{- $consensus := .Values.sawtooth.consensus | int -}}
{{- if eq $consensus 100 -}}
{{- 1 | int -}}
{{- else -}}
{{- default 4 .Values.sawtooth.statefulset.replicas | int -}}
{{- end -}}
{{- end -}}

{{/*
Sawtooth networking specifications
*/}}
{{- define "sawtooth.bind.component" -}}
component:tcp://0.0.0.0:{{ include "sawtooth.ports.sawcomp" . }}
{{- end -}}

{{/*
Consensus binding should always be local under normal circumstances
*/}}
{{- define "sawtooth.bind.consensus" -}}
{{- if .Values.sawtooth.ports.consensus_local -}}
consensus:tcp://127.0.0.1:{{ include "sawtooth.ports.consensus" . }}
{{- else -}}
consensus:tcp://0.0.0.0:{{ include "sawtooth.ports.consensus" . }}
{{- end -}}
{{- end -}}

{{- define "sawtooth.bind.network" -}}
network:tcp://0.0.0.0:{{ include "sawtooth.ports.sawnet" . }}
{{- end -}}

{{- define "sawtooth.binds" -}}
--bind {{ include "sawtooth.bind.component" . }} \
--bind {{ include "sawtooth.bind.consensus" . }} \
--bind {{ include "sawtooth.bind.network" . }}
{{- end -}}

{{- define "sawtooth.opentsdb" -}}
{{- if .Values.sawtooth.opentsdb.enabled -}}
--opentsdb-db {{ .Values.sawtooth.opentsdb.db }}  \
--opentsdb-url {{ .Values.sawtooth.opentsdb.url }}
{{- end -}}
{{- end -}}

{{- define "sawtooth.peering" -}}
{{- $peering:= .Values.sawtooth.dynamicPeering -}}
--peering {{ if ($peering)}}dynamic{{ else }}static{{end }} \
{{ range .Values.sawtooth.externalSeeds }}{{ if ($peering) }}--seeds{{ else }}--peers{{ end }} tcp://{{ .hostname }}:{{ .port }} {{end }} \
{{ if ($peering)}}${SEEDS}{{ else }}${PEERS}{{end }} \
--maximum-peer-connectivity 255
{{- end -}}

{{- define "sawtooth.network" -}}
{{ include "sawtooth.binds" . }} \
{{ include "sawtooth.peering" . }} \
{{ include "sawtooth.opentsdb" . }}
{{- end -}}

{{/*
Genesis Templates
*/}}
{{- define "sawtooth.genesis.create" -}}
{{- $consensus := .Values.sawtooth.consensus | int -}}
if [ ! -r /etc/sawtooth/initialized ]; then
  if [ $RUN_GENESIS -eq 1 ]; then
    {{- if eq $consensus 400 }}
    bash -x /usr/local/bin/pbft_genesis_config.sh {{ .Release.Namespace }}
    {{- else if eq $consensus 300 }}
    bash -x /usr/local/bin/raft_genesis_config.sh {{ .Release.Namespace }}
    {{- else if eq $consensus 200 }}
    bash -x /usr/local/bin/poet_genesis_config.sh {{ .Release.Namespace }}
    {{- else }}
    bash -x /usr/local/bin/devmode_genesis_config.sh {{ .Release.Namespace }}
    {{- end }}
    {{ if .Values.sawtooth.permissioned -}}
    /usr/local/bin/identity_genesis_config.sh {{ .Release.Namespace }}
    {{- end -}}
    sawset genesis -k /etc/sawtooth/keys/validator.priv \
      -o /etc/sawtooth/genesis/000-genesis.batch
    cd /etc/sawtooth/genesis
    sawadm genesis `ls |sort`
    cd -
  fi
  touch /etc/sawtooth/initialized;
fi
{{- end -}}

{{- define "sawtooth.genesis.reset" -}}
if [ -r /etc/sawtooth/genesis.seed ]; then
  OLD_SEED=`cat /etc/sawtooth/genesis.seed`
  if [ "$OLD_SEED" != "{{ .Values.sawtooth.genesis.seed }}" ];  then
    echo "${OLD_SEED} != {{ .Values.sawtooth.genesis.seed }} -- resetting  environment"
    rm -rf /var/lib/sawtooth/*
    rm -f /etc/sawtooth/genesis/*
    rm -f /etc/sawtooth/initialized
    echo {{ .Values.sawtooth.genesis.seed }} > /etc/sawtooth/genesis.seed
  fi
else
    echo "No genesis seed. Resetting environment and setting Seed to {{ .Values.sawtooth.genesis.seed }}"
    rm -rf /var/lib/sawtooth/*
    rm -f /etc/sawtooth/genesis/*
    rm -f /etc/sawtooth/initialized
    echo {{ .Values.sawtooth.genesis.seed }} > /etc/sawtooth/genesis.seed
fi
{{- end -}}
{{/*
END Genesis Templates
*/}}

{{- define "sawtooth.hostpath" -}}
{{ .Values.sawtooth.volumes.hostPathBaseDir | trimSuffix "/" }}/{{.Release.Namespace}}/{{.Release.Name }}
{{- end -}}

{{- define "sawtooth.etc.volume.name" -}}
sawtooth-etc
{{- end -}}

{{- define "sawtooth.etc.volume" -}}
- name: {{ include "sawtooth.etc.volume.name" . }}
  hostPath:
    type: DirectoryOrCreate
    path: {{ include "sawtooth.hostpath" . }}/{{ include "sawtooth.data.volume.name" . }}
{{- end -}}

{{- define "sawtooth.etc.volume.vct" -}}
- metadata:
    name: {{ include "sawtooth.etc.volume.name" . }}
      {{- if .Values.sawtooth.persistence.annotations }}
      annotations: {{- toYaml .Values.sawtooth.persistence.annotations | nindent 10 }}
      {{- end }}
  spec:
    accessModes: {{- toYaml .Values.sawtooth.persistence.accessModes | nindent 10 }}
    {{ if .Values.sawtooth.persistence.storageClass }}
    storageClassName: {{ .Values.sawtooth.persistence.storageClass | quote }}
    {{ end }}
    resources:
      requests:
        storage: 1Gi
{{- end -}}

{{- define "sawtooth.etc.mount" -}}
- mountPath: /etc/sawtooth
  name: {{ include "sawtooth.etc.volume.name" . }}
{{- end -}}

{{- define "sawtooth.scripts.volume" -}}
- name: {{ include "sawtooth.scripts.volume.name" . }}
  configMap:
    name: {{ include "common.names.fullname" . }}-scripts
{{- end -}}

{{- define "sawtooth.scripts.volume.name" -}}
chart-scripts
{{- end -}}

{{- define "sawtooth.scripts.mount" -}}
- mountPath: /opt/chart/scripts
  name: {{ include "sawtooth.scripts.volume.name" . }}
{{- end -}}

{{- define "sawtooth.data.volume.name" -}}
sawtooth-data
{{- end -}}

{{- define "sawtooth.data.volume" -}}
- name: {{ include "sawtooth.data.volume.name" . }}
  hostPath:
    type: DirectoryOrCreate
    path: {{ include "sawtooth.hostpath" . }}/{{ include "sawtooth.data.volume.name" . }}
{{- end -}}

{{- define "sawtooth.data.volume.vct" -}}
- metadata:
    name: {{ include "sawtooth.data.volume.name" . }}
      {{- if .Values.sawtooth.persistence.annotations }}
      annotations: {{- toYaml .Values.sawtooth.persistence.annotations | nindent 8 }}
      {{- end }}
  spec:
    accessModes: {{- toYaml .Values.sawtooth.persistence.accessModes | nindent 6 }}
    {{ if .Values.sawtooth.persistence.storageClass }}
    storageClassName: {{ .Values.sawtooth.persistence.storageClass | quote }}
    {{ end }}
    resources:
      requests:
        storage: {{ .Values.sawtooth.persistence.size | quote }}
{{- end -}}

{{- define "sawtooth.data.mount" -}}
- mountPath: /var/lib/sawtooth
  name: {{ include "sawtooth.data.volume.name" . }}
{{- end -}}

{{/*
Sawtooth Signals Templates
*/}}
{{/*
Use as in
{{ include "sawtooth.signal.postStart" "pbft-engine" }
*/}}
{{- define "sawtooth.signal.postStart" -}}
postStart:
  exec:
    command:
      - sh
      - -c
      - |
        rm -f {{ include "sawtooth.signals.dir" . }}/{{ . }}
{{- end -}}

{{- define "sawtooth.signal.livenessProbe" -}}
livenessProbe:
  exec:
    command:
      - sh
      - -c
      - |
        if [ -r {{ include "sawtooth.signals.dir" . }}/{{ . }} ]; then
          exit 1
        else
          exit 0
        fi
{{- end -}}

{{- define "sawtooth.signal.fire" -}}
exit_code=$?
export EXIT_SIGNALS="{{ .Values.sawtooth.livenessProbe.exitSignals }}"
for signal in ${EXIT_SIGNALS}; do
  touch "{{ include "sawtooth.signals.dir" . }}/$signal"
done
exit $exit_code
{{- end -}}

{{- define "sawtooth.signals.volume.name" -}}
sawtooth-signals
{{- end -}}

{{- define "sawtooth.signals.dir" -}}
/var/run/sawtooth
{{- end -}}

{{- define "sawtooth.signals.mount" -}}
- mountPath: {{ include "sawtooth.signals.dir" . }}
  name: {{ include "sawtooth.signals.volume.name" . }}
{{- end -}}

{{- define "sawtooth.signals.volume" -}}
- name: {{ include "sawtooth.signals.volume.name" . }}
  emptyDir: {}
{{- end -}}
{{/*
END Sawtooth Signals Templates
*/}}

{{- define "sawtooth.affinity" -}}
{{- if .Values.affinity.enabled -}}
nodeAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
      - matchExpressions:
        - key: app
          operator: In
          values:
          - {{- include "common.names.fullname" . -}}
{{- else -}}
{{- if .Values.sawtooth.affinity -}}
{{- toYaml .Values.sawtooth.affinity }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "sawtooth.hostaliases" -}}
{{ range .Values.sawtooth.externalSeeds }}
- ip: {{ .ip }}
  hostnames:
  - {{ .hostname }}
{{ end }}
{{ include "utils.hostaliases" . }}
{{- end -}}

{{- define "sawtooth.containers" -}}
{{- $consensus := .Values.sawtooth.consensus | int -}}
{{- if eq $consensus 400 -}}
{{- include "sawtooth.container.pbft-engine" . | nindent 0 }}
{{- else if eq $consensus 300 -}}
{{- include "sawtooth.container.raft-engine" . | nindent 0 }}
{{- else if eq $consensus 200 -}}
{{- include "sawtooth.container.poet-engine" . | nindent 0 }}
{{- else -}}
{{- include "sawtooth.container.devmode-engine" . | nindent 0 }}
{{- end -}}
{{- include "sawtooth.container.settings-tp" . | nindent 0 }}
{{- include "sawtooth.container.block-info-tp" . | nindent 0 }}
{{- include "sawtooth.container.intkey-tp" . | nindent 0 }}
{{- include "sawtooth.container.identity-tp" . | nindent 0 }}
{{- include "sawtooth.container.seth-tp" . | nindent 0 }}
{{- include "sawtooth.container.seth-rpc" . | nindent 0 }}
{{- include "sawtooth.container.smallbank-tp" . | nindent 0 }}
{{- include "sawtooth.container.xo-tp" . | nindent 0 }}
{{- $ctx := .Values -}}
{{- range .Values.sawtooth.customTPs -}}
{{- include "sawtooth.container.customtp" (dict "tp" . "values" $ctx) | nindent 0 }}
{{- end -}}
{{- include "sawtooth.container.rest-api" . | nindent 0 }}
{{- include "sawtooth.container.monitor" . | nindent 0 }}
{{- include "sawtooth.container.validator" . | nindent 0 }}
{{- end -}}

{{/*
{{ include "sawtooth.loglevel" "container" .Values.sawtooth.containers.validator "global" .Values.global }}
*/}}
{{- define "sawtooth.logLevel" -}}
{{- $defaultLevel := "WARN" -}}
{{- if .global.logLevel -}}
{{- $defaultLevel = (default $defaultLevel .global.logLevel) | upper -}}
{{- end -}}
{{- $level := (default $defaultLevel .container.logLevel) | upper -}}
{{- if eq $level "INFO" -}}
-v
{{- else if eq $level "DEBUG" -}}
-vv
{{- else if eq $level "TRACE" -}}
-vvv
{{- end -}}
{{- end -}}
