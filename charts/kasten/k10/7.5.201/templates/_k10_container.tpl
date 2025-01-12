{{- define "k10-containers" }}
{{- $pod := .k10_pod }}
{{- with .main }}
{{- $main_context := . }}
{{- $colocatedList := include "get.enabledColocatedServices" . | fromYaml }}
{{- $containerList := (dict "main" $main_context "k10_service_pod" $pod | include "get.serviceContainersInPod" | splitList " ") }}
      containers:
{{- range $skip, $container := $containerList }}
  {{- $port := default $main_context.Values.service.externalPort (index $colocatedList $container).port }}
  {{- $serviceStateful := has $container (dict "main" $main_context "k10_service_pod" $pod | include "get.statefulRestServicesInPod" | splitList " ") }}
  {{- dict "main" $main_context "k10_pod" $pod "k10_container" $container "externalPort" $port "stateful" $serviceStateful | include "k10-container" }}
{{- end }}
{{- end }}{{/* with .main */}}
{{- end }}{{/* define "k10-containers" */}}

{{- define "k10-container" }}
{{- $pod := .k10_pod }}
{{- $service := .k10_container }}
{{- $externalPort := .externalPort }}
{{- with .main }}
      - name: {{ $service }}-svc
        {{- dict "main" . "k10_service" $service | include "serviceImage" | indent 8 }}
        imagePullPolicy: {{ .Values.global.image.pullPolicy }}
{{- if eq $service "aggregatedapis" }}
        args:
        - "--secure-port={{ .Values.service.aggregatedApiPort }}"
        - "--cert-dir=/tmp/apiserver.local.config/certificates/"
        {{- if include "k10.siemEnabled" . }}
        - "--audit-policy-file=/etc/kubernetes/{{ include "k10.aggAuditPolicyFile" .}}"
        {{/* SIEM cloud logging */}}
        - "--enable-k10-audit-cloud-aws-s3={{ .Values.siem.logging.cloud.awsS3.enabled }}"
        - "--audit-cloud-path={{ .Values.siem.logging.cloud.path }}"
        {{/* SIEM cluster logging */}}
        - "--enable-k10-audit-cluster={{ .Values.siem.logging.cluster.enabled }}"
        - "--audit-log-file={{ include "k10.siemLoggingClusterFile" . | default (include "k10.siemAuditLogFilePath" .) }}"
        - "--audit-log-file-size={{ include "k10.siemLoggingClusterFileSize" . | default (include "k10.siemAuditLogFileSize" .) }}"
        {{- end }}
{{- if .Values.useNamespacedAPI }}
        - "--k10-api-domain={{  template "apiDomain" . }}"
{{- end }}{{/* .Values.useNamespacedAPI */}}
{{/*
We need this explicit conversion because installation using operator hub was failing
stating that types are not same for the equality check
*/}}
{{- else if not (eq (int .Values.service.externalPort) (int $externalPort) ) }}
        args:
          - "--port={{ $externalPort }}"
          - "--host=0.0.0.0"
{{- end }}{{/* eq $service "aggregatedapis" */}}
{{- $podName := (printf "%s-svc" $pod) }}
{{- $containerName := (printf "%s-svc" $service) }}
{{- dict "main" . "k10_service_pod_name" $podName "k10_service_container_name" $containerName  | include "k10.resource.request" | indent 8}}
        ports:
{{- if eq $service "aggregatedapis" }}
        - containerPort: {{ .Values.service.aggregatedApiPort }}
{{- else }}
        - containerPort: {{ $externalPort }}
  {{- if eq $service "controllermanager" }}
        - containerPort: {{ include "k10.mcExternalPort" nil }}
  {{- end }}
{{- end }}
{{- if eq $service "logging" }}
        - containerPort: 24224
          protocol: TCP
        - containerPort: 24225
          protocol: TCP
{{- end }}
        securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: false
            capabilities:
                drop: ["ALL"]
        livenessProbe:
{{- if eq $service "aggregatedapis" }}
          tcpSocket:
            port: {{ .Values.service.aggregatedApiPort }}
          timeoutSeconds: 5
{{- else }}
          httpGet:
            path: /v0/healthz
            port: {{ $externalPort }}
          timeoutSeconds: 1
{{- end }}
          initialDelaySeconds: 300
{{- if ne $service "aggregatedapis" }}
        readinessProbe:
          httpGet:
            path: /v0/healthz
            port: {{ $externalPort }}
          initialDelaySeconds: 3
{{- end }}
        env:
{{- if eq $service "dashboardbff" }}
          - name: {{ include "k10.disabledServicesEnvVar" . }}
            value: {{ include "get.disabledServices" . | quote }}
{{- end -}}
{{- if list "dashboardbff" "executor" "garbagecollector" "controllermanager" "kanister" | has $service}}
{{- if not (eq (include "check.googleproject" . ) "true") -}}
    {{- fail "secrets.googleApiKey field is required when using secrets.googleProjectId" -}}
{{- end -}}
{{- $gkeSecret := default "google-secret" .Values.secrets.googleClientSecretName }}
{{- $gkeProjectId := "kasten-gke-project" }}
{{- $gkeApiKey :=  "/var/run/secrets/kasten.io/kasten-gke-sa.json"}}
{{- if eq (include "check.googleCredsSecret" .) "true" }}
    {{- $gkeProjectId = "google-project-id" }}
    {{- $gkeApiKey =  "/var/run/secrets/kasten.io/google-api-key" }}
{{- end }}
{{- if eq (include "check.googleCredsOrSecret" .) "true" }}
          - name: GOOGLE_APPLICATION_CREDENTIALS
            value: {{ $gkeApiKey }}
{{- end }}
{{- if eq (include "check.googleCredsOrSecret" .) "true"  }}
          - name: projectID
            valueFrom:
              secretKeyRef:
                name: {{ $gkeSecret }}
                key: {{ $gkeProjectId }}
                optional: true
{{- end }}
{{- end }}
{{- if list "dashboardbff" "executor" "garbagecollector" "controllermanager" "kanister" | has $service}}
{{- if or  (eq (include "check.azuresecret" .) "true") (eq (include "check.azurecreds" .) "true" )  }}
{{- if eq (include "check.azuresecret" .) "true" }}
          - name: {{ include "k10.azureClientIDEnvVar" . }}
            valueFrom:
              secretKeyRef:
                name: {{ .Values.secrets.azureClientSecretName }}
                key: azure_client_id
          - name: {{ include "k10.azureTenantIDEnvVar" . }}
            valueFrom:
              secretKeyRef:
                name: {{ .Values.secrets.azureClientSecretName }}
                key: azure_tenant_id
          - name: {{ include "k10.azureClientSecretEnvVar" . }}
            valueFrom:
             secretKeyRef:
               name: {{ .Values.secrets.azureClientSecretName }}
               key: azure_client_secret
{{- else }}
{{- if and (or (eq (include "check.azureMSIWithClientID" .) "true") (eq (include "check.azureClientSecretCreds" .) "true")) (not (eq (include "check.azureFederatedIdentity" . ) "true")) }}
          - name: {{ include "k10.azureClientIDEnvVar" . }}
            valueFrom:
              secretKeyRef:
                name: azure-creds
                key: azure_client_id
{{- end }}
{{- if eq (include "check.azureClientSecretCreds" .) "true" }}
          - name: {{ include "k10.azureTenantIDEnvVar" . }}
            valueFrom:
              secretKeyRef:
                name: azure-creds
                key: azure_tenant_id
          - name: {{ include "k10.azureClientSecretEnvVar" . }}
            valueFrom:
              secretKeyRef:
                name: azure-creds
                key: azure_client_secret
{{- end }}
{{- end }}
{{- if .Values.secrets.azureResourceGroup }}
          - name: AZURE_RESOURCE_GROUP
            valueFrom:
              secretKeyRef:
                name: azure-creds
                key: azure_resource_group
{{- end }}
{{- if .Values.secrets.azureSubscriptionID }}
          - name: AZURE_SUBSCRIPTION_ID
            valueFrom:
              secretKeyRef:
                name: azure-creds
                key: azure_subscription_id
{{- end }}
{{- if .Values.secrets.azureResourceMgrEndpoint }}
          - name: AZURE_RESOURCE_MANAGER_ENDPOINT
            valueFrom:
              secretKeyRef:
                name: azure-creds
                key: azure_resource_manager_endpoint
{{- end }}
{{- if or .Values.secrets.azureADEndpoint .Values.secrets.microsoftEntraIDEndpoint }}
          - name: AZURE_AD_ENDPOINT
            valueFrom:
              secretKeyRef:
                name: azure-creds
                key: entra_id_endpoint
{{- end }}
{{- if or .Values.secrets.azureADResourceID .Values.secrets.microsoftEntraIDResourceID }}
          - name: AZURE_AD_RESOURCE
            valueFrom:
              secretKeyRef:
                name: azure-creds
                key: entra_id_resource_id
{{- end }}
{{- if .Values.secrets.azureCloudEnvID }}
          - name: AZURE_CLOUD_ENV_ID
            valueFrom:
              secretKeyRef:
                name: azure-creds
                key: azure_cloud_env_id
{{- end }}
{{- if  eq (include "check.azureMSIWithDefaultID" .) "true" }}
          - name: USE_AZURE_DEFAULT_MSI
            value: "{{ .Values.azure.useDefaultMSI }}"
{{- end }}
{{- if eq (include "check.azureFederatedIdentity" .) "true" }}
          - name: USE_AZURE_FEDERATED_IDENTITY
            value: "{{ .Values.azure.useFederatedIdentity }}"
{{- end }}
{{- end }}
{{- end }}

{{- /*
There are 3 valid states of the secret provided by customer:
1. Only role set
2. Both aws_access_key_id and aws_secret_access_key are set
3. All of role, aws_access_key_id and aws_secret_access_key are set.
*/}}
{{- if eq (include "check.awsSecretName" .) "true"  }}
    {{- $customerSecret := (lookup "v1" "Secret" .Release.Namespace .Values.secrets.awsClientSecretName )}}
    {{- if $customerSecret }}
        {{- if and (not $customerSecret.data.role) (not $customerSecret.data.aws_access_key_id) (not $customerSecret.data.aws_secret_access_key) }}
                {{ fail "Provided secret must contain at least AWS IAM Role or AWS access key ID together with AWS secret access key"}}
        {{- end }}
        {{- if not (or (and $customerSecret.data.aws_access_key_id $customerSecret.data.aws_secret_access_key) (and (not $customerSecret.data.aws_access_key_id) (not $customerSecret.data.aws_secret_access_key))) }}
            {{ fail "Provided secret lacks aws_access_key_id or aws_secret_access_key" }}
        {{- end }}
    {{- end }}
{{- end }}
{{- if list "dashboardbff" "executor" "garbagecollector" "controllermanager" "metering" "kanister" | has $service}}
{{- $awsSecretName := default "aws-creds" .Values.secrets.awsClientSecretName }}
          - name: AWS_ACCESS_KEY_ID
            valueFrom:
              secretKeyRef:
                name: {{ $awsSecretName }}
                key: aws_access_key_id
                optional: true
          - name: AWS_SECRET_ACCESS_KEY
            valueFrom:
              secretKeyRef:
                name: {{ $awsSecretName }}
                key: aws_secret_access_key
                optional: true
          - name: K10_AWS_IAM_ROLE
            valueFrom:
              secretKeyRef:
                name: {{ $awsSecretName }}
                key: role
                optional: true
{{- end }}
{{- if list "controllermanager" "executor" "catalog" | has $service}}
{{- if eq (include "check.gwifenabled" .) "true"}}
          - name: GOOGLE_WORKLOAD_IDENTITY_FEDERATION_ENABLED
            value: "true"
{{- if eq (include "check.gwifidptype" .) "true"}}
          - name: GOOGLE_WORKLOAD_IDENTITY_FEDERATION_IDP
            value: {{ .Values.google.workloadIdentityFederation.idp.type }}
{{- end }}
{{- if eq (include "check.gwifidpaud" .) "true"}}
          - name: GOOGLE_WORKLOAD_IDENTITY_FEDERATION_AUD
            value: {{ .Values.google.workloadIdentityFederation.idp.aud }}
{{- end }}
{{- end }} {{/* if eq (include "check.gwifenabled" .) "true" */}}
{{- end }} {{/* list "controllermanager" "executor" "catalog" | has $service */}}
{{- if or (eq $service "crypto") (eq $service "executor") (eq $service "dashboardbff") (eq $service "repositories") (eq $service "aggregatedapis") }}
{{- if eq (include "check.vaultcreds" .) "true" }}
          - name: VAULT_ADDR
            value: {{ .Values.vault.address }}
{{- if eq (include "check.vaultk8sauth" .) "true" }}
          - name: VAULT_AUTH_ROLE
            value: {{ .Values.vault.role }}
          - name: VAULT_K8S_SERVICE_ACCOUNT_TOKEN_PATH
            value: {{ .Values.vault.serviceAccountTokenPath }}
{{- end }}
{{- if (eq (include "check.vaulttokenauth" .) "true") }}
          - name: VAULT_TOKEN
            valueFrom:
              secretKeyRef:
                name: {{.Values.vault.secretName }}
                key: vault_token
{{- end }}
{{- end }}
{{- end }}
{{- if list "dashboardbff" "executor" "garbagecollector" "controllermanager" | has $service}}
{{- if or (eq (include "check.vspherecreds" .) "true") (eq (include "check.vsphereClientSecret" .) "true") }}
{{- $vsphereSecretName := default "vsphere-creds" .Values.secrets.vsphereClientSecretName }}
          - name: VSPHERE_ENDPOINT
            valueFrom:
              secretKeyRef:
                name: {{ $vsphereSecretName }}
                key: vsphere_endpoint
          - name: VSPHERE_USERNAME
            valueFrom:
              secretKeyRef:
                name: {{ $vsphereSecretName }}
                key: vsphere_username
          - name: VSPHERE_PASSWORD
            valueFrom:
              secretKeyRef:
                name: {{ $vsphereSecretName }}
                key: vsphere_password
{{- end }}
{{- end }}
          - name: VERSION
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: version
          - name: {{ include "k10.fluentbitEndpointEnvVar" . }}
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: fluentbitEndpoint
                optional: true
{{- if .Values.clusterName }}
          - name: CLUSTER_NAME
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: clustername
{{- end }}
{{- if .Values.fips.enabled }}
          {{- include "k10.enforceFIPSEnvironmentVariables" . | indent 10 }}
{{- end }}
          {{- with $capabilities := include "k10.capabilities" . }}
          - name: K10_CAPABILITIES
            value: {{ $capabilities | quote }}
          {{- end }}
          {{- with $capabilities_mask := include "k10.capabilities_mask" . }}
          - name: K10_CAPABILITIES_MASK
            value: {{ $capabilities_mask | quote }}
          {{- end }}
          - name: K10_HOST_SVC
            value: {{ $pod }}
{{- if eq $service "controllermanager" }}
          - name: K10_STATEFUL
            value: "{{ .Values.global.persistence.enabled }}"
{{- if .Values.workerPodCRDs.resourcesRequests.maxMemory }}
          - name: EPHEMERAL_POD_MAX_MEMORY_REQUESTS
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: workerPodMaxMemoryRequest
{{- end }}
{{- if .Values.workerPodCRDs.resourcesRequests.maxCPU }}                
          - name: EPHEMERAL_POD_MAX_CPU_REQUESTS
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: workerPodMaxCPURequest         
{{- end }} 
{{- end }}
{{- if eq $service "executor" }}
          - name: KUBEVIRT_VM_UNFREEZE_TIMEOUT
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: kubeVirtVMsUnFreezeTimeout
{{- end }}
{{- if eq $service "executor" }}
          - name: QUICK_DISASTER_RECOVERY_ENABLED
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: quickDisasterRecoveryEnabled
{{- end }}
{{- if or (eq $service "executor") (eq $service "controllermanager") }}
{{- if or  .Values.global.imagePullSecret (or .Values.secrets.dockerConfig .Values.secrets.dockerConfigPath)  }}
          - name: IMAGE_PULL_SECRET_NAMES
            value: {{  (trimSuffix " " (include "k10.imagePullSecretNames" .)) | toJson }}
{{- end }}
{{- end }}
          - name: MODEL_STORE_DIR
{{- if or (eq $service "state") (not .Values.global.persistence.enabled) }}
            value: "/tmp/k10store"
{{- else }}
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: modelstoredirname
{{- end }}
{{- if or (eq $service "kanister") (eq $service "executor")}}
          - name: DATA_MOVER_IMAGE
            value: {{ include "get.datamoverImage" . }}        
{{- end }}
{{- if or (eq $service "kanister") (eq $service "executor")}}
          - name: DATA_STORE_LOG_LEVEL
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: DataStoreLogLevel
          - name: DATA_STORE_FILE_LOG_LEVEL
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: DataStoreFileLogLevel
{{- end }}
          - name: LOG_LEVEL
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: loglevel
{{- if .Values.kanisterPodCustomLabels }}
          - name: KANISTER_POD_CUSTOM_LABELS
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: KanisterPodCustomLabels
{{- end }}
{{- if .Values.kanisterPodCustomAnnotations }}
          - name: KANISTER_POD_CUSTOM_ANNOTATIONS
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: KanisterPodCustomAnnotations
{{- end }}
          - name: POD_NAMESPACE
            valueFrom:
              fieldRef:
                fieldPath: metadata.namespace
          - name: K10_LIMITER_SNAPSHOT_EXPORTS_PER_ACTION
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10LimiterSnapshotExportsPerAction
          - name: K10_LIMITER_WORKLOAD_SNAPSHOTS_PER_ACTION
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10LimiterWorkloadSnapshotsPerAction
          - name: K10_DATA_STORE_PARALLEL_UPLOAD
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: k10DataStoreParallelUpload
          - name: K10_DATA_STORE_PARALLEL_DOWNLOAD
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: k10DataStoreParallelDownload
          - name: K10_DATA_STORE_PARALLEL_BLOCK_UPLOAD
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: k10DataStoreParallelBlockUpload
          - name: K10_DATA_STORE_PARALLEL_BLOCK_DOWNLOAD
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: k10DataStoreParallelBlockDownload
          - name: K10_DATA_STORE_ESTIMATION_TYPE
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: k10DataStoreEstimationType
          - name: K10_DATA_STORE_ADAPTIVE_ESTIMATION_THRESHOLD
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: k10DataStoreAdaptiveEstimationThreshold
          - name: K10_DATA_STORE_GENERAL_CONTENT_CACHE_SIZE_MB
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: k10DataStoreGeneralContentCacheSizeMB
          - name: K10_DATA_STORE_GENERAL_METADATA_CACHE_SIZE_MB
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: k10DataStoreGeneralMetadataCacheSizeMB
          - name: K10_DATA_STORE_RESTORE_CONTENT_CACHE_SIZE_MB
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: k10DataStoreRestoreContentCacheSizeMB
          - name: K10_DATA_STORE_RESTORE_METADATA_CACHE_SIZE_MB
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: k10DataStoreRestoreMetadataCacheSizeMB
          - name: K10_LIMITER_GENERIC_VOLUME_BACKUPS_PER_CLUSTER
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10LimiterGenericVolumeBackupsPerCluster
          - name: K10_LIMITER_SNAPSHOT_EXPORTS_PER_CLUSTER
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10LimiterSnapshotExportsPerCluster
          - name: K10_LIMITER_VOLUME_RESTORES_PER_CLUSTER
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10LimiterVolumeRestoresPerCluster
          - name: K10_LIMITER_CSI_SNAPSHOTS_PER_CLUSTER
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10LimiterCsiSnapshotsPerCluster
          - name: K10_LIMITER_DIRECT_SNAPSHOTS_PER_CLUSTER
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10LimiterDirectSnapshotsPerCluster
          - name: K10_LIMITER_IMAGE_COPIES_PER_CLUSTER
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10LimiterImageCopiesPerCluster
          - name: K10_EPHEMERAL_PVC_OVERHEAD
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10EphemeralPVCOverhead
          - name: K10_PERSISTENCE_STORAGE_CLASS
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10PersistenceStorageClass
          - name: AWS_ASSUME_ROLE_DURATION
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: AWSAssumeRoleDuration
{{- if (list "kanister" "executor" "repositories" | has $service) }}
          - name: K10_DATA_STORE_DISABLE_COMPRESSION
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: k10DataStoreDisableCompression

          - name: K10_KANISTER_POD_METRICS_IMAGE
            value: {{ include "get.metricSidecarImage" . }}

          - name: TIMEOUT_WORKER_POD_READY
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10TimeoutWorkerPodReady

          - name: WORKER_POD_METRIC_SIDECAR_ENABLED
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: WorkerPodMetricSidecarEnabled
          - name: WORKER_POD_METRIC_SIDECAR_METRICS_INTERVAL
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: WorkerPodPushgatewayMetricsInterval
        {{- if or (not (quote .Values.workerPodMetricSidecar.resources.requests.memory | empty)) (not (quote .Values.kanisterPodMetricSidecar.resources.requests.memory | empty)) }}
          - name: K10_WORKER_POD_METRIC_SIDECAR_MEMORY_REQUEST
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: WorkerPodMetricSidecarMemoryRequest
        {{- end }}
        {{- if or (not (quote .Values.workerPodMetricSidecar.resources.requests.cpu | empty)) (not (quote .Values.kanisterPodMetricSidecar.resources.requests.cpu | empty)) }}
          - name: K10_WORKER_POD_METRIC_SIDECAR_CPU_REQUEST
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: WorkerPodMetricSidecarCPURequest
        {{- end }}
        {{- if or (not (quote .Values.workerPodMetricSidecar.resources.limits.memory | empty)) (not (quote .Values.kanisterPodMetricSidecar.resources.limits.memory | empty)) }}
          - name: K10_WORKER_POD_METRIC_SIDECAR_MEMORY_LIMIT
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: WorkerPodMetricSidecarMemoryLimit
        {{- end }}
        {{- if or (not (quote .Values.workerPodMetricSidecar.resources.limits.cpu | empty)) (not (quote .Values.kanisterPodMetricSidecar.resources.limits.cpu | empty)) }}
          - name: K10_WORKER_POD_METRIC_SIDECAR_CPU_LIMIT
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: WorkerPodMetricSidecarCPULimit
        {{- end }}
        {{- if .Values.scc.create }}
          - name: {{ include "k10.sccNameEnvVar" . }}
            value: {{ .Release.Name }}-scc
        {{- end }}
        {{- if .Values.workerPodCRDs.enabled }}
          - name: K10_EPHEMERAL_POD_SPECS_CR_ENABLED
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: workerPodResourcesCRDEnabled 
            {{- if .Values.workerPodCRDs.defaultActionPodSpec }}          
          - name: K10_DEFAULT_ACTION_POD_SPEC_NAME
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: workerPodDefaultAPSName
            {{- end }}  
        {{- end }}           
{{- end }}
{{- if (list "kanister" "executor" "repositories" "crypto" "dashboardbff" "aggregatedapis" | has $service) }}
          {{- if .Values.global.podLabels }}
          - name: K10_CUSTOM_POD_LABELS
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10CustomPodLabels
          {{- end }}
          {{- if .Values.global.podAnnotations }}
          - name: K10_CUSTOM_POD_ANNOTATIONS
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10CustomPodAnnotations
          {{- end }}
{{- end }}
{{- if (list "dashboardbff" "catalog" "executor" "crypto" | has $service) }}
    {{- if .Values.metering.mode }}
          - name: K10REPORTMODE
            value: {{ .Values.metering.mode }}
    {{- end }}
{{- end }}
{{- if eq $service "garbagecollector" }}
          - name: K10_GC_DAEMON_PERIOD
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10GCDaemonPeriod
          - name: K10_GC_KEEP_MAX_ACTIONS
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10GCKeepMaxActions
          - name: K10_GC_ACTIONS_ENABLED
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10GCActionsEnabled
{{- end }}
{{- if (eq $service "executor") }}
          - name: K10_LIMITER_EXECUTOR_THREADS
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10LimiterExecutorThreads
          - name: K10_LIMITER_CSI_SNAPSHOT_RESTORES_PER_ACTION
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10LimiterCsiSnapshotRestoresPerAction
          - name: K10_LIMITER_VOLUME_RESTORES_PER_ACTION
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10LimiterVolumeRestoresPerAction
          - name: K10_LIMITER_WORKLOAD_RESTORES_PER_ACTION
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10LimiterWorkloadRestoresPerAction
          - name: K10_TIMEOUT_BLUEPRINT_BACKUP
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10TimeoutBlueprintBackup
          - name: K10_TIMEOUT_BLUEPRINT_RESTORE
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10TimeoutBlueprintRestore
          - name: K10_TIMEOUT_BLUEPRINT_DELETE
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10TimeoutBlueprintDelete
          - name: K10_TIMEOUT_BLUEPRINT_HOOKS
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10TimeoutBlueprintHooks
          - name: K10_TIMEOUT_CHECK_REPO_POD_READY
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10TimeoutCheckRepoPodReady
          - name: K10_TIMEOUT_STATS_POD_READY
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10TimeoutStatsPodReady
          - name: K10_TIMEOUT_EFS_RESTORE_POD_READY
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10TimeoutEFSRestorePodReady
          - name: KANISTER_MANAGED_DATA_SERVICES_BLUEPRINTS_ENABLED
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: KanisterManagedDataServicesBlueprintsEnabled
{{- if or .Values.maxJobWaitDuration .Values.timeout.jobWait }}
          - name: K10_TIMEOUT_JOB_WAIT
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10TimeoutJobWait
{{- end }}
          - name: K10_FORCE_ROOT_IN_BLUEPRINT_ACTIONS
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10ForceRootInBlueprintActions
{{- end }}
{{- if and (eq $service "executor") (.Values.awsConfig.efsBackupVaultName) }}
          - name: EFS_BACKUP_VAULT_NAME
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: efsBackupVaultName
{{- end }}
{{- if and (eq $service "executor") (.Values.genericStorageBackup.token) }}
          - name: K10_GVS_ACTIVATION_TOKEN
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: GVSActivationToken
{{- end }}
{{- if and (eq $service "executor") (.Values.genericStorageBackup.overridepubkey) }}
          - name: OVERRIDE_GVS_TOKEN_VERIFICATION_KEY
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: overridePublicKeyForGVS
{{- end }}
{{- if and (eq $service "executor") (.Values.vmWare.taskTimeoutMin) }}
          - name: VMWARE_GOM_TIMEOUT_MIN
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: vmWareTaskTimeoutMin
{{- end }}
{{- if .Values.useNamespacedAPI }}
          - name: K10_API_DOMAIN
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: apiDomain
{{- end }}
{{- if .Values.jaeger.enabled }}
          - name: JAEGER_AGENT_HOST
            value: {{ .Values.jaeger.agentDNS }}
{{- end }}
{{- if .Values.auth.tokenAuth.enabled }}
          - name: TOKEN_AUTH
            valueFrom:
              secretKeyRef:
                name: k10-token-auth
                key: auth
{{- end }}
          - name: KANISTER_TOOLS
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: KanisterToolsImage
{{- with (include "k10.cacertconfigmapname" .) }}
          - name: CACERT_CONFIGMAP_NAME
            value: {{ . }}
{{- end }}
          - name: K10_RELEASE_NAME
            value: {{ .Release.Name }}
          - name: KANISTER_FUNCTION_VERSION
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: kanisterFunctionVersion
{{- if and (eq $service "controllermanager") (or .Values.injectGenericVolumeBackupSidecar.enabled .Values.injectKanisterSidecar.enabled) }}
          - name: K10_MUTATING_WEBHOOK_ENABLED
            value: "true"
          - name: K10_MUTATING_WEBHOOK_TLS_CERT_DIR
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10MutatingWebhookTLSCertDir
          - name: K10_MUTATING_WEBHOOK_PORT
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10MutatingWebhookPort
{{- end }}
{{- if (list "controllermanager" "kanister" "executor" "dashboardbff" "repositories" | has $service) }}
          - name: K10_DEFAULT_PRIORITY_CLASS_NAME
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10DefaultPriorityClassName
{{- if .Values.genericVolumeSnapshot.resources.requests.memory }}
          - name: KANISTER_TOOLS_MEMORY_REQUESTS
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: KanisterToolsMemoryRequests
{{- end }}
{{- if .Values.genericVolumeSnapshot.resources.requests.cpu }}
          - name: KANISTER_TOOLS_CPU_REQUESTS
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: KanisterToolsCPURequests
{{- end }}
{{- if .Values.genericVolumeSnapshot.resources.limits.memory }}
          - name: KANISTER_TOOLS_MEMORY_LIMITS
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: KanisterToolsMemoryLimits
{{- end }}
{{- if .Values.genericVolumeSnapshot.resources.limits.cpu }}
          - name: KANISTER_TOOLS_CPU_LIMITS
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: KanisterToolsCPULimits
{{- end }}
{{- end }}
{{- if (list "dashboardbff" "controllermanager" "executor" | has $service) }}
    {{- if .Values.prometheus.server.enabled }}
          - name: K10_PROMETHEUS_HOST
            value: {{ include "k10.prometheus.service.name" . }}-exp
          - name: K10_PROMETHEUS_PORT
            value: {{ .Values.prometheus.server.service.servicePort | quote }}
          - name: K10_PROMETHEUS_BASE_URL
            value: {{ .Values.prometheus.server.baseURL }}
    {{- else -}}
        {{- if and .Values.global.prometheus.external.host .Values.global.prometheus.external.port}}
          - name: K10_PROMETHEUS_HOST
            value: {{ .Values.global.prometheus.external.host }}
          - name: K10_PROMETHEUS_PORT
            value: {{ .Values.global.prometheus.external.port | quote }}
          - name: K10_PROMETHEUS_BASE_URL
            value: {{ .Values.global.prometheus.external.baseURL }}
        {{- end -}}
    {{- end }}
        {{- if (.Values.grafana.external.url) }}
          - name: GRAFANA_URL
            value: {{ include "k10.grafanaUrl" . }}
        {{- end }}
{{- end }}
{{- if eq $service "dashboardbff" }}
    {{- if ne .Values.global.persistence.diskSpaceAlertPercent nil }}
          - name: K10_DISK_SPACE_ALERT_PERCENT
            value: {{ .Values.global.persistence.diskSpaceAlertPercent | quote }}
    {{- end -}}
{{- end -}}
{{- if eq $service "controllermanager" }}
    {{- if .Values.multicluster.primary.create }}
        {{- if not .Values.multicluster.enabled }}
            {{- fail "Cannot setup cluster as primary without enabling feature with multicluster.enabled=true" -}}
        {{- end }}
        {{- if not .Values.multicluster.primary.name }}
            {{- fail "Cannot setup cluster as primary without setting cluster name with multicluster.primary.name" -}}
        {{- end }}
        {{- if not .Values.multicluster.primary.ingressURL }}
            {{- fail "Cannot setup cluster as primary without providing an ingress with multicluster.primary.ingressURL" -}}
        {{- end }}
          - name: K10_MC_CREATE_PRIMARY
            value: "true"
          - name: K10_MC_PRIMARY_NAME
            value: {{ .Values.multicluster.primary.name | quote }}
          - name: K10_MC_PRIMARY_INGRESS_URL
            value: {{ .Values.multicluster.primary.ingressURL | quote }}
    {{- end }}
{{- end -}}
{{- if or $.stateful (or (eq (include "check.googleCredsOrSecret" .) "true") (eq $service "auth" "logging")) }}
        volumeMounts:
{{- else if  or (or (eq (include "basicauth.check" .) "true") (or .Values.auth.oidcAuth.enabled (eq (include "check.dexAuth" .) "true"))) .Values.features }}
        volumeMounts:
{{- else if and (eq $service "controllermanager") (or .Values.injectGenericVolumeBackupSidecar.enabled .Values.injectKanisterSidecar.enabled) }}
        volumeMounts:
{{- else if or (eq (include "check.cacertconfigmap" .) "true") (include "k10.ocpcacertsautoextraction" .) }}
        volumeMounts:
{{- else if eq $service "frontend" }}
        volumeMounts:
{{- else if and (list "controllermanager" "executor" | has $pod) (eq (include "check.projectSAToken" .) "true")}}
        volumeMounts:
{{- else if and (eq $service "aggregatedapis") (include "k10.siemEnabled" .) }}
        volumeMounts:
{{- end }}
{{- if $.stateful }}
        - name: {{ $service }}-persistent-storage
          mountPath: {{ .Values.global.persistence.mountPath | quote }}
{{- end }}
{{- if .Values.features }}
        - name: k10-features
          mountPath: "/mnt/k10-features"
{{- end }}
{{- if eq $service "logging" }}
        - name: logging-configmap-storage
          mountPath: "/mnt/conf"
{{- end }}
{{- if eq $service "executor" }}
        - name: datastore-cache-vol
          mountPath: "/tmp"
{{- end }}
{{- if and (eq $service "controllermanager") (or .Values.injectGenericVolumeBackupSidecar.enabled .Values.injectKanisterSidecar.enabled) }}
        - name: mutating-webhook-certs
          mountPath: /etc/ssl/certs/webhook
          readOnly: true
{{- end }}
{{- if list "dashboardbff" "auth" "controllermanager" | has $service}}
{{- if eq (include "basicauth.check" .) "true" }}
        - name: k10-basic-auth
          mountPath: "/var/run/secrets/kasten.io/k10-basic-auth"
          readOnly: true
{{- end }}
{{- if (or .Values.auth.oidcAuth.enabled (eq (include "check.dexAuth" .) "true")) }}
        - name: {{ include "k10.oidcSecretName" .}}
          mountPath: {{ printf "%s/%s" (include "k10.secretsDir" .) (include "k10.oidcSecretName" .) }}
          readOnly: true
{{- if .Values.auth.oidcAuth.clientSecretName }}
        - name: {{ include "k10.oidcCustomerSecretName" .}}
          mountPath: {{ printf "%s/%s" (include "k10.secretsDir" .) (include "k10.oidcCustomerSecretName" .) }}
          readOnly: true
{{- end }}
{{- end }}
{{- end }}
{{- if eq (include "check.googleCredsOrSecret" .) "true"}}
        - name: service-account
          mountPath: {{ include "k10.secretsDir" .}}
{{- end }}
{{- if and (list "controllermanager" "executor" | has $pod) (eq (include "check.projectSAToken" .) "true")}}
        - name: bound-sa-token
          mountPath: "/var/run/secrets/kasten.io/serviceaccount/GWIF"
          readOnly: true
{{- end }}
{{- with (include "k10.cacertconfigmapname" .) }}
        - name: {{ . }}
          mountPath: "/etc/ssl/certs/custom-ca-bundle.pem"
          subPath: custom-ca-bundle.pem
{{- end }}
{{- if eq $service "frontend" }}
        - name: frontend-config
          mountPath: /etc/nginx/nginx.conf
          subPath: nginx.conf
          readOnly: true
        - name: frontend-config
          mountPath: /etc/nginx/conf.d/frontend.conf
          subPath: frontend.conf
          readOnly: true
{{- end}}
{{- if and (eq $service "aggregatedapis") (include "k10.siemEnabled" .) }}
        - name: aggauditpolicy-config
          mountPath: /etc/kubernetes/{{ include "k10.aggAuditPolicyFile" .}}
          subPath: {{ include "k10.aggAuditPolicyFile" .}}
          readOnly: true
{{- end}}
{{- if and (eq $service "catalog") $.stateful }}
      - name: kanister-sidecar
        image: {{ include "get.kanisterToolsImage" .}}
        imagePullPolicy: {{ .Values.kanisterToolsImage.pullPolicy }}
{{- dict "main" . "k10_service_pod_name" $podName "k10_service_container_name" "kanister-sidecar"  | include "k10.resource.request" | indent 8}}
        env:
          {{- with $capabilities := include "k10.capabilities" . }}
          - name: K10_CAPABILITIES
            value: {{ $capabilities | quote }}
          {{- end }}
          {{- with $capabilities_mask := include "k10.capabilities_mask" . }}
          - name: K10_CAPABILITIES_MASK
            value: {{ $capabilities_mask | quote }}
          {{- end }}
{{- if .Values.fips.enabled }}
          {{- include "k10.enforceFIPSEnvironmentVariables" . | nindent 10 }}
{{- end }}
        volumeMounts:
        - name: {{ $service }}-persistent-storage
          mountPath: {{ .Values.global.persistence.mountPath | quote }}
{{- with (include "k10.cacertconfigmapname" .) }}
        - name: {{ . }}
          mountPath: "/etc/ssl/certs/custom-ca-bundle.pem"
          subPath: custom-ca-bundle.pem
{{- end }}
{{- if eq (include "check.projectSAToken" .) "true" }}
        - name: bound-sa-token
          mountPath: "/var/run/secrets/kasten.io/serviceaccount/GWIF"
          readOnly: true
{{- end }}
{{- end }} {{/* and (eq $service "catalog") $.stateful */}}
{{- if and ( eq $service "auth" ) ( eq (include "check.dexAuth" .) "true" ) }}
      - name: dex
        image: {{ include "get.dexImage" . }}
{{- if .Values.auth.ldap.enabled }}
        command: ["/usr/local/bin/dex", "serve", "/dex-config/config.yaml"]
{{- if .Values.fips.enabled }}
        env:
          {{- include "k10.enforceFIPSEnvironmentVariables" . | nindent 10 }}
{{- end }}
{{- else if .Values.auth.openshift.enabled }}
        {{- /*
        In the case of OpenShift, a template config is used instead of a plain config for Dex.
        It requires a different command to be processed correctly.
        */}}
        command: ["/usr/local/bin/docker-entrypoint", "dex", "serve", "/etc/dex/cfg/config.yaml"]
        env:
          - name: {{ include "k10.openShiftClientSecretEnvVar" . }}
{{- if and (not .Values.auth.openshift.clientSecretName) (not .Values.auth.openshift.clientSecret) }}
            valueFrom:
              secretKeyRef:
                name: {{ include "get.openshiftServiceAccountSecretName" . }}
                key: token
{{- else if .Values.auth.openshift.clientSecretName }}
            valueFrom:
              secretKeyRef:
                name: {{ .Values.auth.openshift.clientSecretName }}
                key: token
{{- else }}
            value: {{ .Values.auth.openshift.clientSecret }}
{{- end }}
{{- if .Values.fips.enabled }}
          {{- include "k10.enforceFIPSEnvironmentVariables" . | indent 10 }}
{{- end }}
{{- end }}
        ports:
        - name: http
          containerPort: 8080
        volumeMounts:
{{- if .Values.auth.ldap.enabled }}
        - name: dex-config
          mountPath: /dex-config
        - name: k10-logos-dex
          mountPath: {{ include "k10.dexFrontendDir" . }}/themes/custom/
{{- else }}
        - name: config
          mountPath: /etc/dex/cfg
{{- end }}
{{- with (include "k10.cacertconfigmapname" .) }}
        - name: {{ . }}
          mountPath: "/etc/ssl/certs/custom-ca-bundle.pem"
          subPath: custom-ca-bundle.pem
{{- end }}
{{- end }} {{/* end of dex check */}}
{{- end }}{{/* with .main */}}
{{- end }}{{/* define "k10-container" */}}

{{- define "k10-init-container-header" }}
{{- $pod := .k10_pod }}
{{- with .main }}
{{- $main_context := . }}
{{- $containerList := (dict "main" $main_context "k10_service_pod" $pod | include "get.serviceContainersInPod" | splitList " ") }}
{{- $needsInitContainersHeader := false }}
{{- range $skip, $service := $containerList }}
{{- $serviceStateful := has $service (dict "main" $main_context "k10_service_pod" $pod | include "get.statefulRestServicesInPod" | splitList " ") }}
  {{- if and ( eq $service "auth" ) $main_context.Values.auth.ldap.enabled }}
    {{- $needsInitContainersHeader = true }}
  {{- else if $serviceStateful }}
    {{- $needsInitContainersHeader = true }}
  {{- end }}{{/* initContainers header needed check */}}
{{- end }}{{/* range $skip, $service := $containerList */}}
{{- if $needsInitContainersHeader }}
      initContainers:
{{- end }}
{{- end }}{{/* with .main */}}
{{- end }}{{/* define "k10-init-container-header" */}}

{{- define "k10-init-container" }}
{{- $pod := .k10_pod }}
{{- $podName := (printf "%s-svc" $pod) }}
{{- with .main }}
{{- $main_context := . }}
{{- $containerList := (dict "main" $main_context "k10_service_pod" $pod | include "get.serviceContainersInPod" | splitList " ") }}
{{- range $skip, $service := $containerList }}
{{- $serviceStateful := has $service (dict "main" $main_context "k10_service_pod" $pod | include "get.statefulRestServicesInPod" | splitList " ") }}
{{- if and ( eq $service "auth" ) $main_context.Values.auth.ldap.enabled }}
      - name: dex-init
        command:
        - /dex/dexconfigmerge
        args:
        - --config-path=/etc/dex/cfg/config.yaml
        - --secret-path=/var/run/secrets/kasten.io/bind-secret/bindPW
        - --new-config-path=/dex-config/config.yaml
        - --secret-field=bindPW
        {{- dict "main" $main_context "k10_service" $service | include "serviceImage" | indent 8 }}
        {{- dict "main" $main_context "k10_service_pod_name" $podName "k10_service_container_name" "dex-init" | include "k10.resource.request" | indent 8}}
        volumeMounts:
        - mountPath: /etc/dex/cfg
          name: config
        - mountPath: /dex-config
          name: dex-config
        - name: bind-secret
          mountPath: "/var/run/secrets/kasten.io/bind-secret"
          readOnly: true
{{- else if $serviceStateful }}
      - name: upgrade-init
        securityContext:
            capabilities:
                add:
                - FOWNER
                - CHOWN
            runAsUser: 1000
            allowPrivilegeEscalation: false
        {{- dict "main" $main_context "k10_service" "upgrade" | include "serviceImage" | indent 8 }}
        imagePullPolicy: {{ $main_context.Values.global.image.pullPolicy }}
        {{- dict "main" $main_context "k10_service_pod_name" $podName "k10_service_container_name" "upgrade-init" | include "k10.resource.request" | indent 8}}
        env:
          - name: MODEL_STORE_DIR
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: modelstoredirname
        volumeMounts:
        - name: {{ $service }}-persistent-storage
          mountPath: {{ $main_context.Values.global.persistence.mountPath | quote }}
{{- if eq $service "catalog" }}
      - name: schema-upgrade-check
        {{- dict "main" $main_context "k10_service" $service | include "serviceImage" | indent 8 }}
        imagePullPolicy: {{ $main_context.Values.global.image.pullPolicy }}
        {{- dict "main" $main_context "k10_service_pod_name" $podName "k10_service_container_name" "schema-upgrade-check" | include "k10.resource.request" | indent 8}}
        env:
{{- if $main_context.Values.clusterName }}
          - name: CLUSTER_NAME
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: clustername
{{- end }}
          - name: INIT_CONTAINER
            value: "true"
          - name: K10_RELEASE_NAME
            value: {{ $main_context.Release.Name }}
          - name: LOG_LEVEL
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: loglevel
          - name: MODEL_STORE_DIR
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: modelstoredirname
          - name: POD_NAMESPACE
            valueFrom:
              fieldRef:
                fieldPath: metadata.namespace
          - name: VERSION
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: version
        volumeMounts:
        - name: {{ $service }}-persistent-storage
          mountPath: {{ $main_context.Values.global.persistence.mountPath | quote }}
{{- end }}{{/* eq $service "catalog" */}}
{{- end }}{{/* initContainers definitions */}}
{{- end }}{{/* range $skip, $service := $containerList */}}
{{- end }}{{/* with .main */}}
{{- end }}{{/* define "k10-init-container" */}}
