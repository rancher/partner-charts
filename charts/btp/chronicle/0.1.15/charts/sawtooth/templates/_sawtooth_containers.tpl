
{{- define "sawtooth.ports.sawcomp" -}}
{{ .Values.sawtooth.ports.sawcomp }}
{{- end -}}

{{- define "sawtooth.ports.consensus" -}}
{{ .Values.sawtooth.ports.consensus }}
{{- end -}}

{{- define "sawtooth.ports.rest" -}}
{{ .Values.sawtooth.ports.rest }}
{{- end -}}

{{- define "sawtooth.ports.sawnet" -}}
{{ .Values.sawtooth.ports.sawnet }}
{{- end -}}


{{- define "sawtooth.container.env.nodename" -}}
{{- $consensus := .values.sawtooth.consensus | int -}}
- name: POD_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
- name: POD_IP
  valueFrom:
    fieldRef:
      fieldPath: status.podIP
- name: NODE_NAME
  # Since this a stateful set we use the pod name as the node name
  valueFrom:
    fieldRef:
{{- if or .values.sawtooth.statefulset.enabled (eq $consensus 100) }}
      fieldPath: metadata.name
{{- else }}
      fieldPath: spec.nodeName
{{- end }}
{{- end -}}

{{/*
{{ include "sawtooth.container.env" (dict "container" .Values.sawtooth.containers.validator "values" .Values)}}
*/}}
{{- define "sawtooth.container.env" -}}
env:
  {{- include "sawtooth.container.env.nodename" . | nindent 2 -}}
  {{- if .values.pagerduty.enabled }}
  - name: ALERT_TOKEN
    value: {{ .values.pagerduty.token | quote }}
  - name: SERVICE_ID
    value: {{ .values.pagerduty.serviceid | quote }}
  {{ end -}}
{{- if .container.env -}}
  {{- toYaml .container.env | nindent 2 }}
{{- end -}}
{{- end -}}

{{- define "sawtooth.container.resources" -}}
{{- if .container.resources -}}
resources: {{- toYaml .container.resources | nindent 2 }}
{{- end -}}
{{- end -}}

{{/*
{{ include "sawtooth.container" (dict "container" .Values.sawtooth.containers.validator "values" .Values "global" .Values.global)}}
*/}}
{{- define "sawtooth.container" -}}
{{- include "lib.image" (dict "imageRoot" .container.image "values" .values "global" .global ) |nindent 0 }}
{{- include "sawtooth.container.command" . | nindent 0 }}
{{- include "sawtooth.container.env" . | nindent 0 }}
{{- include "sawtooth.container.resources" . | nindent 0 }}
{{- end -}}

{{- define "sawtooth.container.command" -}}
command: [ "bash", "-xc"]
{{- end -}}

{{- define "sawtooth.container.pbft-engine" -}}
{{ $ctx := dict "container" .Values.sawtooth.containers.pbft_engine "values" .Values "global" .Values.global }}
{{- $signal := "pbft-engine" -}}
- name: pbft-engine
  {{- include "sawtooth.container" $ctx | nindent 2 }}
  args:
    - |
      rm -f /var/lib/sawtooth/pbft.log
      pbft-engine {{ include "sawtooth.logLevel" $ctx }} \
        -C tcp://127.0.0.1:{{ include "sawtooth.ports.consensus" . }} \
        --storage-location disk+/var/lib/sawtooth/pbft.log
  lifecycle:
    {{- include "sawtooth.signal.postStart" "pbft-engine" | nindent 4 }}
  {{- include "sawtooth.signal.livenessProbe" "pbft-engine" | nindent 2 }}
  volumeMounts:
    {{- include "sawtooth.signals.mount" . | nindent 4 }}
    {{- include "sawtooth.data.mount" . | nindent 4 }}
    {{- include "lib.volumeMounts" .Values.extraVolumeMounts | nindent 4 }}
{{- end -}}

{{- define "sawtooth.container.raft-engine" -}}
{{- $ctx := dict "container" .Values.sawtooth.containers.raft_engine "values" .Values "global" .Values.global -}}
- name: raft-engine
  {{- include "sawtooth.container" $ctx | nindent 2 }}
  args:
    - |
      raft-engine {{ include "sawtooth.logLevel" $ctx }} \
        -C tcp://127.0.0.1:{{ include "sawtooth.ports.consensus" . }}
  volumeMounts:
    {{- include "sawtooth.signals.mount" . | nindent 4 }}
    {{- include "sawtooth.etc.mount" . | nindent 4 }}
    {{- include "sawtooth.data.mount" . | nindent 4 }}
    {{- include "lib.volumeMounts" .Values.extraVolumeMounts | nindent 4 }}
{{- end -}}

{{- define "sawtooth.container.poet-engine" -}}
{{- $ctx := dict "container" .Values.sawtooth.containers.poet_engine "values" .Values "global" .Values.global -}}
- name: poet-engine
  {{- include "sawtooth.container" $ctx | nindent 2 }}
  args:
    - |
      poet-engine {{ include "sawtooth.logLevel" $ctx }} \
        --connect tcp://127.0.0.1:{{ include "sawtooth.ports.consensus" . }}  \
        --component tcp://127.0.0.1:{{ include "sawtooth.ports.sawcomp" . }}
  volumeMounts:
    {{- include "sawtooth.signals.mount" . | nindent 4 }}
    {{- include "sawtooth.etc.mount" . | nindent 4 }}
    {{- include "sawtooth.data.mount" . | nindent 4 }}
    {{- include "lib.volumeMounts" .Values.extraVolumeMounts | nindent 4 }}
- name: poet-validator-registry-tp
  {{- include "sawtooth.container" $ctx | nindent 2 }}
  args:
    - |
      poet-validator-registry-tp {{ include "sawtooth.logLevel" $ctx }} \
        -C tcp://127.0.0.1:{{ include "sawtooth.ports.sawcomp" . }}
  volumeMounts:
    {{- include "sawtooth.signals.mount" . | nindent 4 }}
    {{- include "sawtooth.etc.mount" . | nindent 4 }}
    {{- include "sawtooth.data.mount" .| nindent 4 }}
    {{- include "lib.volumeMounts" .Values.extraVolumeMounts | nindent 4 }}
{{- end -}}

{{- define "sawtooth.container.devmode-engine" -}}
{{- $ctx := dict "container" .Values.sawtooth.containers.devmode_engine "values" .Values "global" .Values.global -}}
- name: devmode-engine
  {{- include "sawtooth.container" $ctx | nindent 2 }}
  args:
    - |
      devmode-engine-rust {{ include "sawtooth.logLevel" $ctx }} \
        -C tcp://127.0.0.1:{{ include "sawtooth.ports.consensus" . }}
  volumeMounts:
    {{- include "sawtooth.signals.mount" . | nindent 4 }}
    {{- include "lib.volumeMounts" .Values.extraVolumeMounts | nindent 4 }}
{{- end -}}

{{- define "sawtooth.container.settings-tp" -}}
{{- $ctx := dict "container" .Values.sawtooth.containers.settings_tp "values" .Values "global" .Values.global -}}
- name: settings-tp
  {{- include "sawtooth.container" $ctx | nindent 2 }}
  args:
    - |
      settings-tp {{ include "sawtooth.logLevel" $ctx }} \
        {{ .Values.sawtooth.containers.settings_tp.args }}  \
        --connect tcp://127.0.0.1:{{ include "sawtooth.ports.sawcomp" . }}
  volumeMounts:
    {{- include "sawtooth.signals.mount" . | nindent 4 }}
    {{- include "lib.volumeMounts" .Values.extraVolumeMounts | nindent 4 }}
{{- end -}}

{{- define "sawtooth.container.intkey-tp" -}}
{{- $ctx := dict "container" .Values.sawtooth.containers.intkey_tp "values" .Values "global" .Values.global -}}
- name: intkey-tp
  {{- include "sawtooth.container" $ctx | nindent 2 }}
  args:
    - |
      intkey-tp-go {{ include "sawtooth.logLevel" $ctx }} \
        --connect tcp://127.0.0.1:{{ include "sawtooth.ports.sawcomp" . }}
  volumeMounts:
    {{- include "sawtooth.signals.mount" . | nindent 4 }}
    {{- include "lib.volumeMounts" .Values.extraVolumeMounts | nindent 4 }}
{{- end -}}

{{- define "sawtooth.container.identity-tp" -}}
{{- $ctx := dict "container" .Values.sawtooth.containers.identity_tp "values" .Values "global" .Values.global -}}
{{- if .Values.sawtooth.permissioned -}}
- name: identity-tp
  {{- include "sawtooth.container" $ctx | nindent 2 }}
  args:
  - |
    identity-tp {{ include "sawtooth.logLevel" $ctx }} \
      {{ .Values.sawtooth.containers.identity_tp.args }}  \
      -C tcp://127.0.0.1:{{ include "sawtooth.ports.sawcomp" . }}
  volumeMounts:
    {{- include "sawtooth.signals.mount" . | nindent 4 }}
    {{- include "lib.volumeMounts" .Values.extraVolumeMounts | nindent 4 }}
{{- else -}}
# no identity-tp
{{- end -}}
{{- end -}}

{{- define "sawtooth.container.block-info-tp" -}}
{{- $ctx := dict "container" .Values.sawtooth.containers.block_info "values" .Values "global" .Values.global -}}
- name: block-info-tp
  {{- include "sawtooth.container" $ctx | nindent 2 }}
  args:
    - |
      block-info-tp {{ include "sawtooth.logLevel" $ctx }} \
        {{ .Values.sawtooth.containers.block_info.args }}  \
        -C tcp://127.0.0.1:{{ include "sawtooth.ports.sawcomp" . }}
  lifecycle:
    {{- include "sawtooth.signal.postStart" "block-info-tp" | nindent 4 }}
  {{- include "sawtooth.signal.livenessProbe" "block-info-tp" | nindent 2 }}
  volumeMounts:
    {{- include "sawtooth.signals.mount" . | nindent 4 }}
    {{- include "lib.volumeMounts" .Values.extraVolumeMounts | nindent 4 }}
{{- end -}}

{{- define "sawtooth.container.monitor" -}}
{{- $ctx := dict "container" .Values.sawtooth.containers.monitor "values" .Values "global" .Values.global -}}
- name: monitor
  {{- include "sawtooth.container" $ctx | nindent 2 }}
  args:
    - |
      sawtooth keygen && \
      sleep {{ .Values.sawtooth.client_wait }} &&  \
      /usr/local/bin/heartbeat_loop.sh \
        http://127.0.0.1:{{ include "sawtooth.ports.rest" . }}  \
        test-$RANDOM {{ .Values.sawtooth.heartbeat.interval }}
  volumeMounts:
    {{- include "sawtooth.signals.mount" . | nindent 4 }}
    {{- include "sawtooth.etc.mount" . | nindent 4 }}
    {{- include "lib.volumeMounts" .Values.extraVolumeMounts | nindent 4 }}
{{- end -}}

{{- define "sawtooth.container.xo-tp" -}}
{{- $ctx := dict "container" .Values.sawtooth.containers.xo_tp "values" .Values "global" .Values.global -}}
{{- if .Values.sawtooth.xo.enabled -}}
- name: xo-tp
  {{- include "sawtooth.container" $ctx | nindent 2 }}
  args:
    - |
      xo-tp-go {{ include "sawtooth.logLevel" $ctx }} \
        --connect tcp://127.0.0.1:{{ include "sawtooth.ports.sawcomp" . }}
  volumeMounts:
    {{- include "sawtooth.signals.mount" . | nindent 4 }}
    {{- include "lib.volumeMounts" .Values.extraVolumeMounts | nindent 4 }}
{{- else -}}
# no xo-tp
{{- end -}}
{{- end -}}

{{- define "sawtooth.container.smallbank-tp" -}}
{{- $ctx := dict "container" .Values.sawtooth.containers.smallbank_tp "values" .Values "global" .Values.global -}}
{{- if .Values.sawtooth.smallbank.enabled -}}
- name: smallbank-tp
  {{- include "sawtooth.container" $ctx | nindent 2 }}
  args:
    - |
      smallbank-tp-go {{ include "sawtooth.logLevel" $ctx }} \
        --connect tcp://127.0.0.1:{{ include "sawtooth.ports.sawcomp" . }}
  volumeMounts:
    {{- include "sawtooth.signals.mount" . | nindent 4 }}
    {{- include "lib.volumeMounts" .Values.extraVolumeMounts | nindent 4 }}
{{- else -}}
# no smallbank-tp
{{- end -}}
{{- end -}}

{{- define "sawtooth.container.rest-api" -}}
{{- $ctx := dict "container" .Values.sawtooth.containers.rest_api "values" .Values "global" .Values.global -}}
- name: rest-api
  {{- include "sawtooth.container" $ctx | nindent 2 }}
  args:
    - |
      sleep {{ .Values.sawtooth.client_wait }}
      sawtooth-rest-api {{ include "sawtooth.logLevel" $ctx }} \
        {{ .Values.sawtooth.containers.rest_api.args }}  \
        --bind 0.0.0.0:{{ include "sawtooth.ports.rest" . }}  \
        --connect tcp://127.0.0.1:{{ include "sawtooth.ports.sawcomp" . }}  \
        {{ include "sawtooth.opentsdb" . | indent 8 }}
  ports:
    - containerPort: {{ include "sawtooth.ports.rest" . }}
      name: sawrest
  volumeMounts:
    {{- include "sawtooth.signals.mount" . | nindent 4 }}
    {{- include "lib.volumeMounts" .Values.extraVolumeMounts | nindent 4 }}
{{- end -}}

{{- define "sawtooth.container.customtp" -}}
- name: {{ .tp.name }}
  image: {{ .tp.image }}
  {{ if .tp.command }}command: [ {{ range .tp.command }}"{{ . }}",{{ end }} ]{{end  }}
  {{ if .tp.args }}args: [ {{ range .tp.args }}"{{ . }}", {{ end }} ]{{end  }}
  env:
    {{- include "sawtooth.container.env.nodename" (dict "values" .values) | nindent 4 }}
  lifecycle: {{- include "sawtooth.signal.postStart" .tp.name | nindent 4 }}
  {{- include "sawtooth.signal.livenessProbe" .tp.name | nindent 2 }}
  volumeMounts:
    {{- include "sawtooth.signals.mount" . | nindent 4 }}
    {{- include "lib.volumeMounts" .values.extraVolumeMounts | nindent 4 }}
  resources: {{- default (dict) .tp.resources | toYaml  | nindent 4 }}
{{- end -}}

{{- define "sawtooth.container.poet-registration" -}}
{{- $consensus := .Values.sawtooth.consensus | int -}}
{{- $ctx := dict "container" .Values.sawtooth.containers.poet_registration "values" .Values "global" .Values.global -}}
{{ if eq $consensus 200 }}
- name: poet-registration
  {{- include "sawtooth.container" $ctx | nindent 2 }}
  args:
    - |
      mkdir -p /etc/sawtooth/poet
      cp /etc/sawtooth/simulator_rk_pub.pem /etc/sawtooth/;
      if [ ! -f /etc/sawtooth/poet/poet-enclave-measurement ]; then
        poet enclave measurement > /etc/sawtooth/poet/poet-enclave-measurement;
      fi
      if [ ! -f /etc/sawtooth/poet/poet-enclave-basename ]; then
        poet enclave basename > /etc/sawtoothetc/poet/poet-enclave-basename;
      fi
      if [ ! -f /etc/sawtooth/initialized ]; then
        poet registration create --enclave-module simulator \
              -k /etc/sawtooth/keys/validator.priv \
              -o /etc/sawtooth/genesis/200.poet.batch
      fi
  volumeMounts:
    {{- include "sawtooth.etc.mount" . | nindent 4 }}
    {{- include "sawtooth.data.mount" . | nindent 4 }}
    {{- include "lib.volumeMounts" .Values.extraVolumeMounts | nindent 4 }}
{{- end -}}
{{- end -}}

{{- define "sawtooth.container.seth-tp" -}}
{{- $ctx := dict "container" .Values.sawtooth.containers.seth_tp "values" .Values "global" .Values.global -}}
{{- if .Values.sawtooth.seth.enabled -}}
- name: seth-tp
  {{- include "sawtooth.container" $ctx | nindent 2 }}
  args:
    - |
      seth-tp {{ include "sawtooth.logLevel" $ctx }} \
        --connect tcp://127.0.0.1:{{ include "sawtooth.ports.sawcomp" . }}
  volumeMounts:
    {{- include "sawtooth.signals.mount" . | nindent 4 }}
    {{- include "lib.volumeMounts" .Values.extraVolumeMounts | nindent 4 }}
{{- else -}}
# no seth-tp
{{- end -}}
{{- end -}}

{{- define "sawtooth.container.seth-rpc" -}}
{{- $ctx := dict "container" .Values.sawtooth.containers.seth_rpc "values" .Values "global" .Values.global -}}
{{- if .Values.sawtooth.seth.enabled -}}
- name: seth-rpc
  {{- include "sawtooth.container" $ctx | nindent 2 }}
  args:
    - |
      sleep {{ .Values.sawtooth.client_wait }} &&  \
        seth-rpc {{ include "sawtooth.logLevel" $ctx }} \
          --bind 0.0.0.0:3030 \
          --connect tcp://127.0.0.1:{{ include "sawtooth.ports.sawcomp" . }}
  volumeMounts:
    {{- include "sawtooth.signals.mount" . | nindent 4 }}
    {{- include "lib.volumeMounts" .Values.extraVolumeMounts | nindent 4 }}
  ports:
    - containerPort: 3030
      name: seth-rpc
{{- else -}}
# no seth-rpc
{{- end -}}
{{- end -}}

{{- define "sawtooth.container.validator.livenessProbe" -}}
{{if .Values.sawtooth.livenessProbe.enabled }}
exec:
  command:
    - /bin/bash
    - -c
    - |
      export SIGNALS_DIR={{ include "sawtooth.signals.dir" . }}
      export EXIT_SIGNALS="{{ .Values.sawtooth.livenessProbe.exitSignals }}"
      export LIVENESS_PROBE_ACTIVE="{{ .Values.sawtooth.livenessProbe.active }}"
      /usr/local/bin/liveness_probe.sh
initialDelaySeconds: {{ .Values.sawtooth.livenessProbe.initialDelaySeconds }}
periodSeconds: {{ .Values.sawtooth.livenessProbe.periodSeconds }}
{{- end -}}
{{- end -}}

{{- define "sawtooth.container.validator.lifecycle" -}}
preStop:
  exec:
    command:
      - bash
      - -c
      - |
        export EXIT_SIGNALS="{{ .Values.sawtooth.livenessProbe.exitSignals }}"
        for signal in ${EXIT_SIGNALS}; do
          touch "{{ include "sawtooth.signals.dir" . }}/$signal"
        done
postStart:
  exec:
    command:
      - bash
      - -c
      - |
        RUN_DIR=/var/run/sawtooth
        rm -f $RUN_DIR/probe.*
        rm -f $RUN_DIR/catchup.started
        rm -f $RUN_DIR/last*
        rm -f $RUN_DIR/pbft_seq*
{{- end -}}

{{- define "sawtooth.container.validator" -}}
{{- $ctx := dict "container" .Values.sawtooth.containers.validator "values" .Values "global" .Values.global -}}
- name: validator
  {{- include "sawtooth.container" $ctx | nindent 2 }}
  lifecycle:
    {{- include "sawtooth.container.validator.lifecycle" . | nindent 4 }}
  args:
    - |
      source /opt/chart/scripts/validator-env
      {{- include "sawtooth.genesis.create" . | nindent 6 }}
      sawtooth-validator {{ include "sawtooth.logLevel" $ctx }} \
        {{ .Values.sawtooth.containers.validator.args}} --scheduler {{ .Values.sawtooth.scheduler }} \
        --endpoint tcp://${NODE_NAME}:{{ include "sawtooth.ports.sawnet" . }} \
        {{- include "sawtooth.network" . | nindent 8 -}} \
        ;
      {{- include "sawtooth.signal.fire" . | nindent 6 }}
  volumeMounts:
    {{- include "sawtooth.signals.mount" . | nindent 4 }}
    {{- include "sawtooth.etc.mount" . | nindent 4 }}
    {{- include "sawtooth.data.mount" . | nindent 4 }}
    {{- include "sawtooth.scripts.mount" . | nindent 4 }}
    {{- include "lib.volumeMounts" .Values.extraVolumeMounts | nindent 4 }}
  livenessProbe:
    {{- include "sawtooth.container.validator.livenessProbe" . | nindent 4 }}
  ports:
    - containerPort: {{ include "sawtooth.ports.sawcomp" . }}
      name: sawcomp
    - containerPort: {{ include "sawtooth.ports.sawnet" . }}
      {{- if not .Values.sawtooth.statefulset.enabled }}
      hostPort: {{ include "sawtooth.ports.sawnet" . }}
      {{- end }}
      name: sawnet
    - containerPort: {{ include "sawtooth.ports.consensus" . }}
      name: consensus
{{- end -}}
