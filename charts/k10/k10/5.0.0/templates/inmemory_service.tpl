{{ if .Values.features }}
{{ if .Values.features.multicluster }}
apiVersion: v1
kind: Service
metadata:
  namespace: {{ $.Release.Namespace }}
  name: inmemorystore-svc
  labels:
{{ include "helm.labels" $ | indent 4 }}
    component: inmemorystore
    run: inmemorystore-svc
spec:
  ports:
  - name: http
    protocol: TCP
    port: 8000
    targetPort: 8000
  selector:
    run: inmemorystore-svc
{{ end }}
{{ end }}
