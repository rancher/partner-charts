{{/* Generate service spec */}}
{{- define "k10-default" }}
{{- $service := .k10_service }}
{{- with .main }}
{{- $main_context := . }}
{{- range $skip, $statefulContainer := compact (dict "main" $main_context "k10_service_pod" $service | include "get.statefulRestServicesInPod" | splitList " ") }}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  namespace: {{ $main_context.Release.Namespace }}
  name: {{ $statefulContainer }}-pv-claim
  labels:
{{ include "helm.labels" $main_context | indent 4 }}
    component: {{ $statefulContainer }}
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: {{ index (index $main_context.Values.global.persistence $statefulContainer | default dict) "size" | default $main_context.Values.global.persistence.size }}
{{- if $main_context.Values.global.persistence.storageClass }}
  {{- if (eq "-" $main_context.Values.global.persistence.storageClass) }}
  storageClassName: ""
  {{- else }}
  storageClassName: "{{ $main_context.Values.global.persistence.storageClass }}"
  {{- end }}
{{- end }}
---
{{- end }}{{/* if $.stateful */}}
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
        checksum/frontend-nginx-config: {{ include (print .Template.BasePath "/frontend-nginx-configmap.yaml") . | sha256sum }}
{{- if .Values.auth.ldap.restartPod }}
        rollme: {{ randAlphaNum 5 | quote }}
{{- end}}
      labels:
{{ include "helm.labels" . | indent 8 }}
        component: {{ $service }}
        run: {{ $service }}-svc
    spec:
{{- if eq $service "executor" }}
{{- if .Values.services.executor.hostNetwork }}
      hostNetwork: true
{{- end }}{{/* .Values.services.executor.hostNetwork */}}
{{- end }}{{/* eq $service "executor" */}}
{{- if eq $service "aggregatedapis" }}
{{- if .Values.services.aggregatedapis.hostNetwork }}
      hostNetwork: true
{{- end }}{{/* .Values.services.aggregatedapis.hostNetwork */}}
{{- end }}{{/* eq $service "aggregatedapis" */}}
{{- if eq $service "dashboardbff" }}
{{- if .Values.services.dashboardbff.hostNetwork }}
      hostNetwork: true
{{- end }}{{/* .Values.services.dashboardbff.hostNetwork */}}
{{- end }}{{/* eq $service "dashboardbff" */}}
      securityContext:
{{ toYaml .Values.services.securityContext | indent 8 }}
      serviceAccountName: {{ template "serviceAccountName" . }}
      {{- include "k10.imagePullSecrets" . | indent 6 }}
{{- /* initContainers: */}}
{{- (dict "main" . "k10_pod" $service | include "k10-init-container-header") }}
{{- (dict "main" . "k10_pod" $service | include "k10-init-container") }}
{{- /* containers: */}}
{{- (dict "main" . "k10_pod" $service | include "k10-containers") }}
{{- /* volumes: */}}
{{- (dict "main" . "k10_pod" $service | include "k10-deployment-volumes-header") }}
{{- (dict "main" . "k10_pod" $service | include "k10-deployment-volumes") }}
---
{{- end }}{{/* with .main */}}
{{- end }}{{/* define "k10-default" */}}

{{- define "k10-deployment-volumes-header" }}
{{- $pod := .k10_pod }}
{{- with .main }}
{{- $main_context := . }}
{{- $containerList := (dict "main" $main_context "k10_service_pod" $pod | include "get.serviceContainersInPod" | splitList " ") }}
{{- $needsVolumesHeader := false }}
{{- range $skip, $service := $containerList }}
  {{- $serviceStateful := has $service (dict "main" $main_context "k10_service_pod" $pod | include "get.statefulRestServicesInPod" | splitList " ") }}
  {{- if or $serviceStateful (or (eq (include "check.googlecreds" $main_context) "true") (eq $service "auth" "logging")) }}
    {{- $needsVolumesHeader = true }}
  {{- else if or (or (eq (include "basicauth.check" $main_context) "true") (or $main_context.Values.auth.oidcAuth.enabled (eq (include "check.dexAuth" $main_context) "true"))) $main_context.Values.features }}
    {{- $needsVolumesHeader = true }}
  {{- else if and (eq $service "controllermanager") ($main_context.Values.injectKanisterSidecar.enabled) }}
    {{- $needsVolumesHeader = true }}
  {{- else if eq (include "check.cacertconfigmap" $main_context) "true" }}
    {{- $needsVolumesHeader = true }}
  {{- else if and ( eq $service "auth" ) ( or $main_context.Values.auth.dex.enabled (eq (include "check.dexAuth" $main_context) "true")) }}
    {{- $needsVolumesHeader = true }}
  {{- else if eq $service "frontend" }}
    {{- $needsVolumesHeader = true }}
  {{- end }}{{/* volumes header needed check */}}
{{- end }}{{/* range $skip, $service := $containerList */}}
{{- if $needsVolumesHeader }}
      volumes:
{{- end }}
{{- end }}{{/* with .main */}}
{{- end }}{{/* define "k10-init-container-header" */}}

{{- define "k10-deployment-volumes" }}
{{- $pod := .k10_pod }}
{{- with .main }}
{{- if .Values.features }}
      - name: k10-features
        configMap:
          name: k10-features
{{- end }}
{{- if eq (include "basicauth.check" .) "true" }}
      - name: k10-basic-auth
        secret:
          secretName: {{ default "k10-basic-auth" .Values.auth.basicAuth.secretName }}
{{- end }}
{{- if .Values.auth.oidcAuth.enabled }}
      - name: k10-oidc-auth
        secret:
          secretName: {{ default "k10-oidc-auth" .Values.auth.oidcAuth.secretName }}
{{- end }}
{{- if .Values.auth.openshift.enabled }}
      - name: k10-oidc-auth
        secret:
          secretName: {{ default "k10-oidc-auth" .Values.auth.openshift.secretName }}
{{- end }}
{{- if .Values.auth.ldap.enabled }}
      - name: k10-oidc-auth
        secret:
          secretName: {{ default "k10-oidc-auth" .Values.auth.ldap.secretName }}
      - name: k10-logos-dex
        configMap:
          name: k10-logos-dex
{{- end }}
{{- range $skip, $statefulContainer := compact (dict "main" . "k10_service_pod" $pod | include "get.statefulRestServicesInPod" | splitList " ") }}
      - name: {{ $statefulContainer }}-persistent-storage
        persistentVolumeClaim:
          claimName: {{ $statefulContainer }}-pv-claim
{{- end }}
{{- if eq (include "check.googlecreds" .) "true" }}
      - name: service-account
        secret:
          secretName: google-secret
{{- end }}
{{- if eq (include "check.cacertconfigmap" .) "true" }}
      - name: {{ .Values.cacertconfigmap.name }}
        configMap:
          name: {{ .Values.cacertconfigmap.name }}
{{- end }}
{{- if eq $pod "frontend" }}
      - name: frontend-config
        configMap:
          name: frontend-config
{{- end }}
{{- $containersInThisPod := (dict "main" . "k10_service_pod" $pod | include "get.serviceContainersInPod" | splitList " ") }}
{{- if has "logging" $containersInThisPod }}
      - name: logging-configmap-storage
        configMap:
          name: fluentbit-configmap
{{- end }}
{{- if and (has "controllermanager" $containersInThisPod) (.Values.injectKanisterSidecar.enabled) }}
      - name: mutating-webhook-certs
        secret:
          secretName: controllermanager-certs
{{- end }}
{{- if and ( has "auth" $containersInThisPod) (or .Values.auth.dex.enabled (eq (include "check.dexAuth" .) "true")) }}
      - name: config
        configMap:
          name: k10-dex
          items:
          - key: config.yaml
            path: config.yaml
{{- if .Values.auth.ldap.enabled }}
      - name: dex-config
        emptyDir: {}
      - name: bind-secret
        secret:
          secretName: {{ default "k10-dex" .Values.auth.ldap.bindPWSecretName }}
{{- end }}
{{- end }}
{{- end }}{{/* with .main */}}
{{- end }}{{/* define "k10-init-container-header" */}}
