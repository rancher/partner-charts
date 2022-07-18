{{/* Generate service spec */}}
{{/* because of https://github.com/GoogleCloudPlatform/marketplace-k8s-app-tools/issues/165
we have to start using .Values.reportingSecret instead
of correct version .Values.metering.reportingSecret */}}
{{- define "k10-metering" }}
{{ $service := .k10_service }}
{{ $main := .main }}
{{- with .main }}
{{- $servicePort := .Values.service.externalPort -}}
{{- $optionalServices := .Values.optionalColocatedServices -}}
{{- $rbac := .Values.prometheus.rbac.create -}}
{{- if $.stateful }}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  namespace: {{ .Release.Namespace }}
  name: {{ $service }}-pv-claim
  labels:
{{ include "helm.labels" . | indent 4 }}
    component: {{ $service }}
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: {{ default .Values.global.persistence.size (index .Values.global.persistence $service "size") }}
{{- if .Values.global.persistence.storageClass }}
  {{- if (eq "-" .Values.global.persistence.storageClass) }}
  storageClassName: ""
  {{- else }}
  storageClassName: "{{ .Values.global.persistence.storageClass }}"
  {{- end }}
{{- end }}
---
{{- end }}{{/* if $.stateful */}}
kind: ConfigMap
apiVersion: v1
metadata:
  labels:
{{ include "helm.labels" . | indent 4 }}
  namespace: {{ .Release.Namespace }}
  name: {{ include "fullname" . }}-metering-config
data:
  config: |
{{- if .Values.metering.reportingKey }}
    identities:
    - name: gcp
      gcp:
        encodedServiceAccountKey: {{ .Values.metering.reportingKey }}
{{- end }}
    metrics:
    - name: node_time
      type: int
      passthrough: {}
      endpoints:
      - name: on_disk
{{- if .Values.metering.reportingKey }}
      - name: servicecontrol
{{- end }}
    endpoints:
    - name: on_disk
      disk:
{{- if .Values.global.persistence.enabled }}
        reportDir: /var/reports/ubbagent/reports
{{- else }}
        reportDir: /tmp/reports/ubbagent/reports
{{- end }}
        expireSeconds: 3600
{{- if .Values.metering.reportingKey }}
    - name: servicecontrol
      servicecontrol:
        identity: gcp
        serviceName: kasten-k10.mp-kasten-public.appspot.com
        consumerId: {{ .Values.metering.consumerId }}
{{- end }}
  prometheusTargets: |
{{- range append (include "k10.restServices" . | splitList " ") "kanister" }}
{{- if or (not (hasKey $optionalServices .)) (index $optionalServices .).enabled }}
{{ $tmpcontx := dict "main" $main "k10service" . -}}
{{ include "k10.prometheusTargetConfig" $tmpcontx | trim | indent 4 -}}
{{- end }}
{{- end }}
{{- range include "k10.services" . | splitList " " }}
{{- if (or (ne . "aggregatedapis") ($rbac)) }}
{{ $tmpcontx := dict "main" $main "k10service" . -}}
{{ include "k10.prometheusTargetConfig" $tmpcontx | indent 4 -}}
{{- end }}
{{- end }}
{{- range include "k10.additionalServices" . | splitList " " }}
{{- if not (eq . "frontend") }}
{{ $tmpcontx := dict "main" $main "k10service" . -}}
{{ include "k10.prometheusTargetConfig" $tmpcontx | indent 4 -}}
{{- end }}
{{- end }}

---
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: {{ .Release.Namespace }}
  name: {{ $service }}-svc
  labels:
{{ include "helm.labels" . | indent 4 }}
    component: {{ $service }}
spec:
  replicas: {{ $.replicas }}
  strategy:
    type: Recreate
  selector:
    matchLabels:
{{ include "k10.common.matchLabels" . | indent 6 }}
      component: {{ $service }}
      run: {{ $service }}-svc
  template:
    metadata:
      annotations:
        checksum/config: {{ include (print .Template.BasePath "/k10-config.yaml") . | sha256sum }}
        checksum/secret: {{ include (print .Template.BasePath "/secrets.yaml") . | sha256sum }}
      labels:
{{ include "helm.labels" . | indent 8 }}
        component: {{ $service }}
        run: {{ $service }}-svc
    spec:
      securityContext:
{{ toYaml .Values.services.securityContext | indent 8 }}
      serviceAccountName: {{ template "meteringServiceAccountName" . }}
      {{- include "k10.imagePullSecrets" . | indent 6 }}
{{- if $.stateful }}
      initContainers:
      - name: upgrade-init
        securityContext:
          runAsUser: 0
          allowPrivilegeEscalation: true
        {{- dict "main" . "k10_service" "upgrade" | include "serviceImage" | indent 8 }}
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        env:
          - name: MODEL_STORE_DIR
            value: /var/reports/
        volumeMounts:
        - name: {{ $service }}-persistent-storage
          mountPath: /var/reports/
{{- end }}
      containers:
      - name: {{ $service }}-svc
        {{- dict "main" . "k10_service" $service | include "serviceImage" | indent 8 }}
        imagePullPolicy: {{ .Values.image.pullPolicy }}
{{- if eq .Release.Namespace "default" }}
{{- $podName := (printf "%s-svc" $service) }}
{{- $containerName := (printf "%s-svc" $service) }}
{{- dict "main" . "k10_service_pod_name" $podName "k10_service_container_name" $containerName  | include "k10.resource.request" | indent 8}}
{{- end }}
        ports:
        - containerPort: {{ .Values.service.externalPort }}
        livenessProbe:
          httpGet:
            path: /v0/healthz
            port: {{ .Values.service.externalPort }}
          initialDelaySeconds: 90
          timeoutSeconds: 1
        env:
          - name: VERSION
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: version
{{- if .Values.clusterName }}
          - name: CLUSTER_NAME
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: clustername
{{- end }}
          - name: LOG_LEVEL
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: loglevel
          - name: POD_NAMESPACE
            valueFrom:
              fieldRef:
                fieldPath: metadata.namespace
{{- if .Values.useNamespacedAPI }}
          - name: K10_API_DOMAIN
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: apiDomain
{{- end }}
          - name: AGENT_CONFIG_FILE
            value: /var/ubbagent/config.yaml
          - name: AGENT_STATE_DIR
{{- if .Values.global.persistence.enabled }}
            value: "/var/reports/ubbagent"
{{- else }}
            value: "/tmp/reports/ubbagent"
          - name: K10_REPORTING_DIR
            value: "/tmp/reports/k10/syncV2"
          - name: K10SYNCSTATUSDIR
            value: "/tmp/reports/k10"
          - name: GRACE_PERIOD_STORE
            value: /tmp/reports/clustergraceperiod
          - name: NODE_USAGE_STORE
            value: /tmp/reports/node_usage_history
{{- end }}
{{- if eq "true" (include "overwite.kanisterToolsImage" .) }}
          - name: KANISTER_TOOLS
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: overwriteKanisterTools
{{- end }}
{{- if .Values.metering.awsRegion }}
          - name: AWS_REGION
            value: {{ .Values.metering.awsRegion }}
{{- end }}
{{- if .Values.metering.mode }}
          - name: K10REPORTMODE
            value: {{ .Values.metering.mode }}
{{- end }}
{{- if .Values.metering.reportCollectionPeriod }}
          - name: K10_REPORT_COLLECTION_PERIOD
            value: {{ .Values.metering.reportCollectionPeriod  | quote }}
{{- end }}
{{- if .Values.metering.reportPushPeriod }}
          - name: K10_REPORT_PUSH_PERIOD
            value: {{ .Values.metering.reportPushPeriod | quote }}
{{- end }}
{{- if .Values.metering.promoID }}
          - name: K10_PROMOTION_ID
            value: {{ .Values.metering.promoID }}
{{- end }}
{{- if .Values.reportingSecret }}
          - name: AGENT_CONSUMER_ID
            valueFrom:
              secretKeyRef:
                name: {{ .Values.reportingSecret }}
                key: consumer-id
          - name: AGENT_REPORTING_KEY
            valueFrom:
              secretKeyRef:
                name: {{ .Values.reportingSecret }}
                key: reporting-key
          - name: K10_RELEASE_NAME
            value: {{ .Release.Name }}
{{- end }}
{{- if .Values.metering.licenseConfigSecretName }}
          - name: AWS_WEB_IDENTITY_REFRESH_TOKEN_FILE
            value: "/var/run/secrets/product-license/license_token"
          - name: AWS_ROLE_ARN
            valueFrom:
              secretKeyRef:
                name: {{ .Values.metering.licenseConfigSecretName }}
                key: iam_role
{{- end }}
        volumeMounts:
        - name: meter-config
          mountPath: /var/ubbagent
{{- if $.stateful }}
        - name: {{ $service }}-persistent-storage
          mountPath: /var/reports/
{{- end }}
{{- if .Values.metering.licenseConfigSecretName }}
        - name: awsmp-product-license
          mountPath: "/var/run/secrets/product-license"
{{- end }}
      volumes:
        - name: meter-config
          configMap:
            name: {{ include "fullname" . }}-metering-config
            items:
            - key: config
              path: config.yaml
            - key: prometheusTargets
              path: prometheusTargets.yaml
{{- if $.stateful }}
        - name: {{ $service }}-persistent-storage
          persistentVolumeClaim:
            claimName: {{ $service }}-pv-claim
{{- end }}
{{- if .Values.metering.licenseConfigSecretName }}
        - name: awsmp-product-license
          secret:
            secretName: {{ .Values.metering.licenseConfigSecretName }}
{{- end }}
---
{{- end }}{{/* with .main */}}
{{- end }}{{/* define "k10-metering" */}}
