{{ if .Values.features }}
{{ if .Values.features.multicluster }}
{{- $main_context := . }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: inmemorystore-svc
  namespace: {{ $.Release.Namespace }}
  labels:
{{ include "helm.labels" $main_context | indent 4 }}
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
{{ include "k10.common.matchLabels" . | indent 6 }}
      component: inmemorystore
      run: inmemorystore-svc
  strategy:
    type: Recreate
  template:
    metadata:
      annotations:
        checksum/config: {{ include (print .Template.BasePath "/k10-config.yaml") . | sha256sum }}
        checksum/secret: {{ include (print .Template.BasePath "/secrets.yaml") . | sha256sum }}
      labels:
{{ include "helm.labels" . | indent 8 }}
        component: inmemorystore
        run: inmemorystore-svc
    spec:
      containers:
      - env:
        - name: GOOGLE_APPLICATION_CREDENTIALS
          value: /var/run/secrets/kasten.io/kasten-gke-sa.json
        - name: VERSION
          valueFrom:
            configMapKeyRef:
              key: version
              name: k10-config
        - name: CLUSTER_NAME
          valueFrom:
            configMapKeyRef:
              key: clustername
              name: k10-config
        - name: MODEL_STORE_DIR
          valueFrom:
            configMapKeyRef:
              key: modelstoredirname
              name: k10-config
        - name: LOG_LEVEL
          valueFrom:
            configMapKeyRef:
              key: loglevel
              name: k10-config
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: metadata.namespace
        - name: AWS_ASSUME_ROLE_DURATION
          valueFrom:
            configMapKeyRef:
              key: AWSAssumeRoleDuration
              name: k10-config
        - name: JAEGER_AGENT_HOST
          value: jaeger-all-in-one-agent.kube-system.svc.cluster.local
        - name: CACERT_CONFIGMAP_NAME
          value: custom-ca-bundle-store
        - name: K10_RELEASE_NAME
          value: k10
        - name: KANISTER_FUNCTION_VERSION
          valueFrom:
            configMapKeyRef:
              key: kanisterFunctionVersion
              name: k10-config
        {{- dict "main" . "k10_service" "inmemorystore" | include "serviceImage" | indent 8 }}
        imagePullPolicy: Always
        livenessProbe:
          failureThreshold: 3
          httpGet:
            path: /v0/healthz
            port: 8000
            scheme: HTTP
          initialDelaySeconds: 300
          periodSeconds: 10
          successThreshold: 1
          timeoutSeconds: 1
        name: inmemorystore-svc
        ports:
        - containerPort: 8000
          protocol: TCP
        readinessProbe:
          failureThreshold: 3
          httpGet:
            path: /v0/healthz
            port: 8000
            scheme: HTTP
          initialDelaySeconds: 3
          periodSeconds: 10
          successThreshold: 1
          timeoutSeconds: 1
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /var/run/secrets/kasten.io/k10-oidc-auth
          name: k10-oidc-auth
          readOnly: true
        - mountPath: /var/run/secrets/kasten.io
          name: service-account
        - mountPath: /etc/ssl/certs/custom-ca-bundle.pem
          name: custom-ca-bundle-store
          subPath: custom-ca-bundle.pem
      dnsPolicy: ClusterFirst
      imagePullSecrets:
      - name: k10-ecr
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext:
        fsGroup: 1000
        runAsUser: 1000
      serviceAccount: k10-k10
      serviceAccountName: k10-k10
      terminationGracePeriodSeconds: 30
      volumes:
      - name: k10-oidc-auth
        secret:
          defaultMode: 420
          secretName: k10-oidc-auth
      - configMap:
          defaultMode: 420
          name: k10-logos-dex
        name: k10-logos-dex
      - name: service-account
        secret:
          defaultMode: 420
          secretName: google-secret
      - configMap:
          defaultMode: 420
          name: custom-ca-bundle-store
        name: custom-ca-bundle-store
{{ end }}
{{ end }}
