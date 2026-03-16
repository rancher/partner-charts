{{/*
Expand the name of the chart.
*/}}
{{- define "epinio.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "epinio.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "epinio.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "epinio.labels" -}}
helm.sh/chart: {{ include "epinio.chart" . }}
app.kubernetes.io/component: epinio
app.kubernetes.io/instance: default
app.kubernetes.io/name: epinio-server
app.kubernetes.io/part-of: epinio
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ default .Chart.AppVersion .Values.image.epinio.tag }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "epinio.selectorLabels" -}}
app.kubernetes.io/component: epinio-server
app.kubernetes.io/instance: default
app.kubernetes.io/name: epinio-server
app.kubernetes.io/part-of: epinio
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "epinio.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "epinio.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
URL prefix for container images to be compatible with Rancher
*/}}
{{- define "registry-url" -}}
{{- if .Values.global.cattle.systemDefaultRegistry -}}
{{ trimSuffix "/" .Values.global.cattle.systemDefaultRegistry }}/
{{- end -}}
{{- end -}}

{{/*
URL of the registry epinio uses to store workload images
*/}}
{{- define "epinio.registry-url" -}}
{{- if .Values.containerregistry.enabled -}}
{{-   printf "registry.%s.svc.cluster.local:5000" .Release.Namespace }}
{{- else -}}
{{-   .Values.global.registryURL }}
{{- end -}}
{{- end -}}

{{/*
URL of the minio epinio installed
*/}}
{{- define "epinio.minio-url" -}}
{{- if .Values.minio.enabled -}}
{{-   printf "%s.%s.svc.cluster.local:9000" .Values.minio.fullnameOverride .Release.Namespace }}
{{- else -}}
{{-  .Values.s3.endpoint }}
{{- end -}}
{{- end -}}

{{/*
Host name of the minio epinio installed
*/}}
{{- define "epinio.minio-hostname" -}}
{{- printf "%s.%s.svc.cluster.local" .Values.minio.fullnameOverride .Release.Namespace }}
{{- end -}}

{{/*
URL of the s3gw epinio installed
*/}}
{{- define "epinio.s3gw-url" -}}
{{- if .Values.s3gw.enabled -}}
{{-   printf "%s.%s.svc.cluster.local" .Values.s3gw.serviceName .Release.Namespace }}
{{- else -}}
{{-  .Values.s3.endpoint }}
{{- end -}}
{{- end -}}

{{/*
Host name of the s3gw epinio installed
*/}}
{{- define "epinio.s3gw-hostname" -}}
{{- printf "%s.%s.svc.cluster.local" .Values.s3gw.serviceName .Release.Namespace }}
{{- end -}}

{{/*
PVC cleanup hooks for bitnami helm chart based catalog services
# https://github.com/epinio/epinio/issues/1386
# https://docs.bitnami.com/kubernetes/apps/aspnet-core/administration/deploy-extra-resources/
*/}}
{{- define "epinio.catalog-service-values" -}}
{{ printf `
extraDeploy:
  - |
    # Create a service account, role and binding to allow to list, get and
    # delete PVCs. It should be used by the job below.

    # To ensure the resources are deleted, use this annotation:
    #
    # annotations:
    #  "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded

    # https://helm.sh/docs/topics/charts_hooks/#hook-resources-are-not-managed-with-corresponding-releases
    # https://helm.sh/docs/topics/charts_hooks/#hook-deletion-policies

    ---
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: "pvc-deleter-{{ .Release.Name }}"
      namespace: {{ .Release.Namespace }}
      annotations:
        "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
        "helm.sh/hook": post-delete
        "helm.sh/hook-weight": "-6"

    ---
    apiVersion: {{ include "common.capabilities.rbac.apiVersion" . }}
    kind: Role
    metadata:
      name: "pvc-deleter-{{ .Release.Name }}"
      namespace: {{ .Release.Namespace }}
      annotations:
        "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
        "helm.sh/hook": post-delete
        "helm.sh/hook-weight": "-6"
    rules:
      - apiGroups:
          - ""
        resources:
          - persistentvolumeclaims
        verbs:
          - get
          - delete
          - list

    ---
    kind: RoleBinding
    apiVersion: {{ include "common.capabilities.rbac.apiVersion" . }}
    metadata:
      name: "pvc-deleter-{{ .Release.Name }}"
      namespace: {{ .Release.Namespace }}
      annotations:
        "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
        "helm.sh/hook": post-delete
        "helm.sh/hook-weight": "-5"
    subjects:
      - kind: ServiceAccount
        name: "pvc-deleter-{{ .Release.Name }}"
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: Role
      name: "pvc-deleter-{{ .Release.Name }}"

    ---
    apiVersion: batch/v1
    kind: Job
    metadata:
      name: "pvc-deleter-{{ .Release.Name }}"
      labels:
        app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
        app.kubernetes.io/instance: {{ .Release.Name | quote }}
        app.kubernetes.io/version: {{ .Chart.AppVersion }}
        helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
      annotations:
        # This is what defines this resource as a hook. Without this line, the
        # job is considered part of the release.
        "helm.sh/hook": post-delete
        "helm.sh/hook-weight": "-4"
        "helm.sh/hook-delete-policy": hook-succeeded
    spec:
      template:
        metadata:
          name: "pvc-deleter-{{ .Release.Name }}"
          labels:
            app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
            app.kubernetes.io/instance: {{ .Release.Name | quote }}
            helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
        spec:
          restartPolicy: Never
          serviceAccountName: "pvc-deleter-{{ .Release.Name }}"
          containers:
          - name: post-install-job
            image: "%s"
            command: ["kubectl", "delete", "pvc", "-n", "{{ .Release.Namespace }}", "-l", "app.kubernetes.io/instance={{ .Release.Name }}"]
` (print (include "registry-url" .) .Values.image.kubectl.repository ":" .Values.image.kubectl.tag) | indent 4}}
{{- end -}}

{{/*
Removes characters that are invalid for kubernetes resource names from the
given string
*/}}
{{- define "epinio-name-sanitize" -}}
{{ regexReplaceAll "[^-a-z0-9]*" . "" }}
{{- end }}

{{/*
Resource name sanitization and truncation.
- Always suffix the sha1sum (40 characters long)
- Always add an "r" prefix to make sure we don't have leading digits
- The rest of the characters up to 63 are the original string with invalid
character removed.
*/}}
{{- define "epinio-truncate" -}}
{{ print "r" (trunc 21 (include "epinio-name-sanitize" .)) "-" (sha1sum .) }}
{{- end }}
