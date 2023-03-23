{{/* Templates for certificates injection */}}

{{- define "gitlab.certificates.initContainer" -}}
{{- $customCAsEnabled := .Values.global.certificates.customCAs }}
{{- $internalGitalyTLSEnabled := $.Values.global.gitaly.tls.enabled }}
{{- $internalPraefectTLSEnabled := $.Values.global.praefect.tls.enabled }}
{{- $certmanagerDisabled := not (or $.Values.global.ingress.configureCertmanager $.Values.global.ingress.tls) }}
{{- $imageCfg := dict "global" .Values.global.image "local" .Values.global.certificates.image -}}
- name: certificates
  image: {{ include "gitlab.certificates.image" . }}
  {{- include "gitlab.image.pullPolicy" $imageCfg | indent 2 }}
  {{- include "gitlab.init.containerSecurityContext" . | indent 2 }}
  env:
  {{- include "gitlab.extraEnv" . | nindent 2 }}
  {{- include "gitlab.extraEnvFrom" (dict "root" $ "local" (dict)) | nindent 2 }}
  volumeMounts:
  - name: etc-ssl-certs
    mountPath: /etc/ssl/certs
    readOnly: false
  - name: etc-pki-ca-trust-extracted-pem
    mountPath: /etc/pki/ca-trust/extracted/pem
    readOnly: false
{{- if or $customCAsEnabled (or $certmanagerDisabled $internalGitalyTLSEnabled $internalPraefectTLSEnabled) }}
  - name: custom-ca-certificates
    mountPath: /usr/local/share/ca-certificates
    readOnly: true
{{- end }}
  resources:
    {{- toYaml .Values.init.resources | nindent 4 }}
{{- end -}}

{{- define "gitlab.certificates.volumes" -}}
{{- $customCAsEnabled := .Values.global.certificates.customCAs }}
{{- $internalGitalyTLSEnabled := $.Values.global.gitaly.tls.enabled }}
{{- $internalPraefectTLSEnabled := $.Values.global.praefect.tls.enabled }}
{{- $certmanagerDisabled := not (or $.Values.global.ingress.configureCertmanager $.Values.global.ingress.tls) }}
- name: etc-ssl-certs
  emptyDir:
    medium: "Memory"
- name: etc-pki-ca-trust-extracted-pem
  emptyDir:
    medium: "Memory"
{{- if or $customCAsEnabled (or $certmanagerDisabled $internalGitalyTLSEnabled $internalPraefectTLSEnabled) }}
- name: custom-ca-certificates
  projected:
    defaultMode: 0440
    sources:
    {{- range $index, $customCA := .Values.global.certificates.customCAs }}
    {{- if $customCA.secret }}
    - secret:
        name: {{ $customCA.secret }}
        {{- if $customCA.keys }}
        items:
          {{- range $customCA.keys }}
          - key: {{ . }}
            path: {{ . }}
          {{- end }}
        {{- end }}
    {{- else if $customCA.configMap }}
    - configMap:
        name: {{ $customCA.configMap }}
        {{- if $customCA.keys }}
        items:
          {{- range $customCA.keys }}
          - key: {{ . }}
            path: {{ . }}
          {{- end }}
        {{- end }}
    {{- end }}
    {{- end }}
    {{- if not (or $.Values.global.ingress.configureCertmanager $.Values.global.ingress.tls) }}
    - secret:
        name: {{ template "gitlab.wildcard-self-signed-cert-name" $ }}-ca
    {{- end }}
    {{- if $internalGitalyTLSEnabled }}
    {{-   if $.Values.global.praefect.enabled }}
    {{-     range $vs := $.Values.global.praefect.virtualStorages }}
    - secret:
        name: {{ $vs.tlsSecretName }}
        items:
        - key: "tls.crt"
          path: "gitaly-{{ $vs.name }}-tls.crt"
    {{-     end }}
    {{-   else }}
    - secret:
        name: {{ template "gitlab.gitaly.tls.secret" $ }}
        items:
          - key: "tls.crt"
            path: "gitaly-internal-tls.crt"
    {{-   end }}
    {{- end }}
    {{- if $internalPraefectTLSEnabled }}
    - secret:
        name: {{ template "gitlab.praefect.tls.secret" $ }}
        items:
          - key: "tls.crt"
            path: "praefect-internal-tls.crt"
    {{- end }}
{{- end -}}
{{- end -}}

{{- define "gitlab.certificates.volumeMount" -}}
- name: etc-ssl-certs
  mountPath: /etc/ssl/certs/
  readOnly: true
- name: etc-pki-ca-trust-extracted-pem
  mountPath: /etc/pki/ca-trust/extracted/pem
  readOnly: true
{{- end -}}
