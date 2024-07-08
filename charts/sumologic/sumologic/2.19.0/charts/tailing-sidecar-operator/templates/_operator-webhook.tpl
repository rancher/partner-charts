{{- define "tailing-sidecar-operator.webhook" -}}
{{- $altNames := list ( printf "%s.%s" (include "tailing-sidecar-operator.fullname" .) .Release.Namespace ) ( printf "%s.%s.svc" (include "tailing-sidecar-operator.fullname" .) .Release.Namespace ) -}}
{{- $ca := genCA "tailing-sidecar-operator-ca" 365 -}}
{{- $cert := genSignedCert ( include "tailing-sidecar-operator.fullname" . ) nil $altNames 365 $ca -}}
apiVersion: admissionregistration.k8s.io/v1
kind: MutatingWebhookConfiguration
metadata:
  name: tailing-sidecar-mutating-webhook-configuration
  namespace: {{ .Release.Namespace }}
webhooks:
- admissionReviewVersions:
  - v1
  - v1beta1
  clientConfig:
    caBundle: {{ $ca.Cert | b64enc }}
    service:
      name: {{ include "tailing-sidecar-operator.fullname" . }}
      namespace: {{ .Release.Namespace }}
      path: /add-tailing-sidecars-v1-pod
  failurePolicy:  {{ .Values.webhook.failurePolicy }}
  reinvocationPolicy: {{ .Values.webhook.reinvocationPolicy }}
  objectSelector: 
  {{- toYaml .Values.webhook.objectSelector | nindent 4 }}
  namespaceSelector: 
  {{- toYaml .Values.webhook.namespaceSelector | nindent 4 }}
  name: tailing-sidecar.sumologic.com 
  rules:
  - apiGroups:
    - ""
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - pods
  sideEffects: None
---
apiVersion: v1
kind: Secret
type: kubernetes.io/tls
metadata:
  annotations:
    "helm.sh/hook": "pre-install,pre-upgrade"
    "helm.sh/hook-delete-policy": "before-hook-creation"
  labels:
    {{- include "tailing-sidecar-operator.labels" . | nindent 4 }}
  name: webhook-server-cert
  namespace: {{ .Release.Namespace }}
data:
  tls.crt: {{ $cert.Cert | b64enc }}
  tls.key: {{ $cert.Key | b64enc }}
{{- end }}
