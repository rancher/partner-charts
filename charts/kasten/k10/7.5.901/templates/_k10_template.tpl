{{/* Generate service spec */}}
{{- define "k10-default" }}
{{- $service := .k10_service }}
{{- $deploymentName := (printf "%s-svc" $service) }}
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
  name: {{ $deploymentName }}
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
      run: {{ $deploymentName }}
  template:
    metadata:
      annotations:
{{-
$requiredAnnotations := (dict
  "run" $deploymentName
  "checksum/frontend-nginx-config" (include (print .Template.BasePath "/frontend-nginx-configmap.yaml") . | sha256sum)
)
-}}
{{- if .Values.auth.ldap.restartPod -}}
  {{- $_ := set $requiredAnnotations "rollme" (randAlphaNum 5) -}}
{{- end -}}
        {{- with merge (dict "requiredAnnotations" $requiredAnnotations) . }}
          {{- include "k10.deploymentPodAnnotations" . | nindent 8 }}
        {{- end }}
      labels:
{{-
$requiredLabels := (dict
  "component" $service
  "run" $deploymentName
)
-}}
{{- if list "executor" "controllermanager" | has $service}}
  {{- if eq (include "check.azureFederatedIdentity" .) "true" }}
        azure.workload.identity/use: "true"
  {{- end }}
{{- end }}
        {{- with merge (dict "requiredLabels" $requiredLabels) . }}
          {{- include "k10.deploymentPodLabels" . | nindent 8 }}
        {{- end }}
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
      {{- dict "main" . "k10_deployment_name" $deploymentName | include "k10.priorityClassName" | indent 6}}
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
  {{- else if and (eq $service "controllermanager") (or $main_context.Values.injectGenericVolumeBackupSidecar.enabled $main_context.Values.injectKanisterSidecar.enabled) }}
    {{- $needsVolumesHeader = true }}
  {{- else if or (eq (include "check.cacertconfigmap" $main_context) "true") (include "k10.ocpcacertsautoextraction" $main_context) }}
    {{- $needsVolumesHeader = true }}
  {{- else if and ( eq $service "auth" ) ( eq (include "check.dexAuth" $main_context) "true" ) }}
    {{- $needsVolumesHeader = true }}
  {{- else if eq $service "frontend" }}
    {{- $needsVolumesHeader = true }}
  {{- else if and (list "controllermanager" "executor" "catalog" | has $pod) (eq (include "check.projectSAToken" $main_context) "true")}}
    {{- $needsVolumesHeader = true }}
  {{- else if and (eq $service "aggregatedapis") (include "k10.siemEnabled" $main_context) }}
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
{{- if list "executor" | has $pod}}
      - name: datastore-cache-vol
        emptyDir: {}
{{- end }}
{{- if list "dashboardbff" "auth" "controllermanager" "vbrintegrationapi" | has $pod}}
{{- if eq (include "basicauth.check" .) "true" }}
      - name: k10-basic-auth
        secret:
          secretName: {{ default "k10-basic-auth" .Values.auth.basicAuth.secretName }}
{{- end }}
{{- if .Values.auth.oidcAuth.enabled }}
      - name: {{ include "k10.oidcSecretName" .}}
        secret:
          secretName: {{ default (include "k10.oidcSecretName" .) .Values.auth.oidcAuth.secretName }}
{{- if .Values.auth.oidcAuth.clientSecretName }}
      - name: {{ include "k10.oidcCustomerSecretName" . }}
        secret:
          secretName: {{ .Values.auth.oidcAuth.clientSecretName }}
{{- end }}
{{- end }}
{{- if .Values.auth.openshift.enabled }}
      - name: {{ include "k10.oidcSecretName" .}}
        secret:
          secretName: {{ default (include "k10.oidcSecretName" .) .Values.auth.openshift.secretName }}
{{- end }}
{{- if .Values.auth.ldap.enabled }}
      - name: {{ include "k10.oidcSecretName" .}}
        secret:
          secretName: {{ default (include "k10.oidcSecretName" .) .Values.auth.ldap.secretName }}
      - name: k10-logos-dex
        configMap:
          name: k10-logos-dex
{{- end }}
{{- end }}
{{- range $skip, $statefulContainer := compact (dict "main" . "k10_service_pod" $pod | include "get.statefulRestServicesInPod" | splitList " ") }}
      - name: {{ $statefulContainer }}-persistent-storage
        persistentVolumeClaim:
          claimName: {{ $statefulContainer }}-pv-claim
{{- end }}
{{- if eq (include "check.googleCredsOrSecret" .) "true"  }}
{{- $gkeSecret := default "google-secret" .Values.secrets.googleClientSecretName }}
      - name: service-account
        secret:
          secretName: {{ $gkeSecret }}
{{- end }}
{{- if and (list "controllermanager" "executor" "catalog" | has $pod) (eq (include "check.projectSAToken" .) "true")}}
      - name: bound-sa-token
        projected:
            sources:
            - serviceAccountToken:
{{- if eq (include "check.gwifidpaud" .) "true" }}
                audience:  {{ .Values.google.workloadIdentityFederation.idp.aud }}
{{- end }}
                expirationSeconds: 3600
                path: token
{{- end }}
{{- with (include "k10.cacertconfigmapname" .) }}
      - name: {{ . }}
        configMap:
          name: {{ . }}
{{- end }}
{{- if eq $pod "frontend" }}
      - name: frontend-config
        configMap:
          name: frontend-config
{{- end }}
{{- if and (eq $pod "aggregatedapis") (include "k10.siemEnabled" .) }}
      - name: aggauditpolicy-config
        configMap:
          name: aggauditpolicy-config
{{- end }}
{{- $containersInThisPod := (dict "main" . "k10_service_pod" $pod | include "get.serviceContainersInPod" | splitList " ") }}
{{- if has "logging" $containersInThisPod }}
      - name: logging-configmap-storage
        configMap:
          name: fluentbit-configmap
{{- end }}
{{- if and (has "controllermanager" $containersInThisPod) (or .Values.injectGenericVolumeBackupSidecar.enabled .Values.injectKanisterSidecar.enabled) }}
      - name: mutating-webhook-certs
        secret:
          secretName: controllermanager-certs
{{- end }}
{{- if and ( has "auth" $containersInThisPod) ( eq (include "check.dexAuth" .) "true" ) }}
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
