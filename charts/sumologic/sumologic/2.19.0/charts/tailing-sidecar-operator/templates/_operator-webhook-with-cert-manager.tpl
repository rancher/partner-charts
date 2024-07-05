{{- define "tailing-sidecar-operator.webhookWithCertManager" }}
apiVersion: admissionregistration.k8s.io/v1
kind: MutatingWebhookConfiguration
metadata:
  annotations:
    cert-manager.io/inject-ca-from: {{ .Release.Namespace }}/tailing-sidecar-serving-cert
  name: tailing-sidecar-mutating-webhook-configuration
  namespace: {{ .Release.Namespace }}
webhooks:
- admissionReviewVersions:
  - v1
  - v1beta1
  clientConfig:
    caBundle: Cg==
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
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  labels:
    {{- include "tailing-sidecar-operator.labels" . | nindent 4 }}
  name: tailing-sidecar-serving-cert
  namespace: {{ .Release.Namespace }}
spec:
  dnsNames:
  - {{ include "tailing-sidecar-operator.fullname" . }}.{{ .Release.Namespace }}.svc
  - {{ include "tailing-sidecar-operator.fullname" . }}.{{ .Release.Namespace }}.svc.cluster.local
  issuerRef:
    kind: Issuer
    name: tailing-sidecar-selfsigned-issuer
  secretName: webhook-server-cert
---
apiVersion: cert-manager.io/v1alpha2
kind: Issuer
metadata:
  labels:
    {{- include "tailing-sidecar-operator.labels" . | nindent 4 }}
  name: tailing-sidecar-selfsigned-issuer
  namespace: {{ .Release.Namespace }}
spec:
  selfSigned: {}
{{- end }}
