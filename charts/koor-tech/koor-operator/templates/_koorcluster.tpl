{{/*
Create the koorCluster
*/}}
{{- define "koor-operator.koorCluster" -}}
apiVersion: storage.koor.tech/v1alpha1
kind: KoorCluster
metadata:
  name: {{ include "koor-operator.fullname" . }}-koorcluster
  {{- if .Values.koorCluster.namespace }}
  namespace: {{ .Release.Namespace }}
  {{- end }}
  labels:
    app.kubernetes.io/created-by: koor-operator
    app.kubernetes.io/part-of: koor-operator
    {{- include "koor-operator.labels" . | nindent 4 }}
spec:
{{ toYaml .Values.koorCluster.spec | indent 2 }}
{{- end }}

{{/*
Koor cluster job that installs the custom resource
*/}}
{{- define "koor-operator.jobName" -}}
{{- include "koor-operator.fullname" . }}-koorcluster-job
{{- end }}
