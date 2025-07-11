{{/* Code generated automatically. DO NOT EDIT. */}}
{{/* K10 services can be disabled by customers via helm value based feature flags.
Therefore, fetching of a list or yaml with service names should be done with the get.enabled* helper functions.
For example, the k10.restServices list can be fetched with get.enabledRestServices */}}
{{- define "k10.additionalServices" -}}frontend kanister{{- end -}}
{{- define "k10.restServices" -}}auth bloblifecyclemanager catalog controllermanager crypto dashboardbff events executor garbagecollector jobs logging metering repositories state vbrintegrationapi{{- end -}}
{{- define "k10.services" -}}aggregatedapis gateway{{- end -}}
{{- define "k10.exposedServices" -}}auth dashboardbff vbrintegrationapi{{- end -}}
{{- define "k10.statelessServices" -}}aggregatedapis auth bloblifecyclemanager controllermanager crypto dashboardbff events executor garbagecollector repositories gateway state vbrintegrationapi{{- end -}}
{{- define "k10.colocatedServices" -}}
bloblifecyclemanager:
  port: 8001
  primary: crypto
events:
  port: 8001
  primary: state
garbagecollector:
  port: 8002
  primary: crypto
repositories:
  port: 8003
  primary: crypto
vbrintegrationapi:
  port: 8001
  primary: dashboardbff
{{- end -}}
{{- define "k10.colocatedServiceLookup" -}}
crypto:
- repositories
- bloblifecyclemanager
- garbagecollector
dashboardbff:
- vbrintegrationapi
state:
- events
{{- end -}}
{{- define "k10.aggregatedAPIs" -}}actions apps repositories vault dr{{- end -}}
{{- define "k10.configAPIs" -}}config{{- end -}}
{{- define "k10.profiles" -}}profiles{{- end -}}
{{- define "k10.policies" -}}policies{{- end -}}
{{- define "k10.policypresets" -}}policypresets{{- end -}}
{{- define "k10.transformsets" -}}transformsets{{- end -}}
{{- define "k10.blueprintbindings" -}}blueprintbindings{{- end -}}
{{- define "k10.auditconfigs" -}}auditconfigs{{- end -}}
{{- define "k10.storagesecuritycontexts" -}}storagesecuritycontexts{{- end -}}
{{- define "k10.storagesecuritycontextbindings" -}}storagesecuritycontextbindings{{- end -}}
{{- define "k10.reportingAPIs" -}}reporting{{- end -}}
{{- define "k10.distAPIs" -}}dist{{- end -}}
{{- define "k10.actionsAPIs" -}}actions{{- end -}}
{{- define "k10.backupActions" -}}backupactions{{- end -}}
{{- define "k10.backupActionsDetails" -}}backupactions/details{{- end -}}
{{- define "k10.reportActions" -}}reportactions{{- end -}}
{{- define "k10.reportActionsDetails" -}}reportactions/details{{- end -}}
{{- define "k10.storageRepositories" -}}storagerepositories{{- end -}}
{{- define "k10.restoreActions" -}}restoreactions{{- end -}}
{{- define "k10.restoreActionsDetails" -}}restoreactions/details{{- end -}}
{{- define "k10.validateActions" -}}validateactions{{- end -}}
{{- define "k10.validateActionsDetails" -}}validateactions/details{{- end -}}
{{- define "k10.importActions" -}}importactions{{- end -}}
{{- define "k10.importActionsDetails" -}}importactions/details{{- end -}}
{{- define "k10.exportActions" -}}exportactions{{- end -}}
{{- define "k10.exportActionsDetails" -}}exportactions/details{{- end -}}
{{- define "k10.retireActions" -}}retireactions{{- end -}}
{{- define "k10.runActions" -}}runactions{{- end -}}
{{- define "k10.runActionsDetails" -}}runactions/details{{- end -}}
{{- define "k10.backupClusterActions" -}}backupclusteractions{{- end -}}
{{- define "k10.backupClusterActionsDetails" -}}backupclusteractions/details{{- end -}}
{{- define "k10.restoreClusterActions" -}}restoreclusteractions{{- end -}}
{{- define "k10.restoreClusterActionsDetails" -}}restoreclusteractions/details{{- end -}}
{{- define "k10.cancelActions" -}}cancelactions{{- end -}}
{{- define "k10.upgradeActions" -}}upgradeactions{{- end -}}
{{- define "k10.defaultCACertKey" -}}custom-ca-bundle.pem{{- end -}}
{{- define "k10.appsAPIs" -}}apps{{- end -}}
{{- define "k10.restorePoints" -}}restorepoints{{- end -}}
{{- define "k10.restorePointsDetails" -}}restorepoints/details{{- end -}}
{{- define "k10.clusterRestorePoints" -}}clusterrestorepoints{{- end -}}
{{- define "k10.clusterRestorePointsDetails" -}}clusterrestorepoints/details{{- end -}}
{{- define "k10.applications" -}}applications{{- end -}}
{{- define "k10.applicationsDetails" -}}applications/details{{- end -}}
{{- define "k10.vaultAPIs" -}}vault{{- end -}}
{{- define "k10.passkey" -}}passkeys{{- end -}}
{{- define "k10.authAPIs" -}}auth{{- end -}}
{{- define "k10.defaultK10LimiterSnapshotExportsPerAction" -}}3{{- end -}}
{{- define "k10.defaultK10LimiterWorkloadSnapshotsPerAction" -}}5{{- end -}}
{{- define "k10.defaultK10DataStoreParallelUpload" -}}8{{- end -}}
{{- define "k10.defaultK10DataStoreGeneralContentCacheSizeMB" -}}500{{- end -}}
{{- define "k10.defaultK10DataStoreGeneralMetadataCacheSizeMB" -}}500{{- end -}}
{{- define "k10.defaultK10DataStoreTotalCacheSizeLimitMB" -}}3000{{- end -}}
{{- define "k10.defaultK10DataStoreRestoreContentCacheSizeMB" -}}500{{- end -}}
{{- define "k10.defaultK10DataStoreRestoreMetadataCacheSizeMB" -}}500{{- end -}}
{{- define "k10.defaultK10BackupBufferFileHeadroomFactor" -}}1.1{{- end -}}
{{- define "k10.defaultK10LimiterGenericVolumeBackupsPerCluster" -}}10{{- end -}}
{{- define "k10.defaultK10LimiterSnapshotExportsPerCluster" -}}10{{- end -}}
{{- define "k10.defaultK10LimiterVolumeRestoresPerCluster" -}}10{{- end -}}
{{- define "k10.defaultK10LimiterCsiSnapshotsPerCluster" -}}10{{- end -}}
{{- define "k10.defaultK10LimiterImageCopiesPerCluster" -}}10{{- end -}}
{{- define "k10.defaultK10LimiterDirectSnapshotsPerCluster" -}}10{{- end -}}
{{- define "k10.defaultK10GCDaemonPeriod" -}}21600{{- end -}}
{{- define "k10.defaultK10GCKeepMaxActions" -}}1000{{- end -}}
{{- define "k10.defaultK10GCActionsEnabled" -}}false{{- end -}}
{{- define "k10.defaultK10LimiterExecutorThreads" -}}8{{- end -}}
{{- define "k10.defaultK10LimiterCsiSnapshotRestoresPerAction" -}}3{{- end -}}
{{- define "k10.defaultK10LimiterVolumeRestoresPerAction" -}}3{{- end -}}
{{- define "k10.defaultK10LimiterWorkloadRestoresPerAction" -}}3{{- end -}}
{{- define "k10.defaultAssumeRoleDuration" -}}60m{{- end -}}
{{- define "k10.defaultK10TimeoutBlueprintBackup" -}}45{{- end -}}
{{- define "k10.defaultK10TimeoutBlueprintRestore" -}}600{{- end -}}
{{- define "k10.defaultK10TimeoutBlueprintDelete" -}}45{{- end -}}
{{- define "k10.defaultK10TimeoutBlueprintHooks" -}}20{{- end -}}
{{- define "k10.defaultK10TimeoutCheckRepoPodReady" -}}20{{- end -}}
{{- define "k10.defaultK10TimeoutStatsPodReady" -}}20{{- end -}}
{{- define "k10.defaultK10TimeoutEFSRestorePodReady" -}}45{{- end -}}
{{- define "k10.cloudProviders" -}}aws google azure{{- end -}}
{{- define "k10.serviceResources" -}}
aggregatedapis-svc:
  aggregatedapis-svc:
    requests:
      cpu: 90m
      memory: 180Mi
auth-svc:
  auth-svc:
    requests:
      cpu: 3m
      memory: 120Mi
catalog-svc:
  catalog-svc:
    requests:
      cpu: 6m
      memory: 150Mi
  kanister-sidecar:
    limits:
      cpu: 1200m
      memory: 800Mi
    requests:
      cpu: 100m
      memory: 800Mi
  schema-upgrade-check:
    requests:
      cpu: 6m
      memory: 150Mi
  upgrade-init:
    requests:
      cpu: 5m
      memory: 20Mi
controllermanager-svc:
  controllermanager-svc:
    requests:
      cpu: 9m
      memory: 160Mi
crypto-svc:
  bloblifecyclemanager-svc:
    requests:
      cpu: 3m
      memory: 120Mi
  crypto-svc:
    requests:
      cpu: 3m
      memory: 120Mi
  garbagecollector-svc:
    requests:
      cpu: 3m
      memory: 130Mi
  repositories-svc:
    requests:
      cpu: 3m
      memory: 130Mi
dashboardbff-svc:
  dashboardbff-svc:
    requests:
      cpu: 9m
      memory: 170Mi
  vbrintegrationapi-svc:
    requests:
      cpu: 3m
      memory: 120Mi
executor-svc:
  executor-svc:
    requests:
      cpu: 3m
      memory: 160Mi
  tools:
    requests:
      cpu: 1m
      memory: 2Mi
frontend-svc:
  frontend-svc:
    requests:
      cpu: 1m
      memory: 40Mi
jobs-svc:
  jobs-svc:
    requests:
      cpu: 3m
      memory: 120Mi
  upgrade-init:
    requests:
      cpu: 5m
      memory: 20Mi
kanister-svc:
  kanister-svc:
    requests:
      cpu: 3m
      memory: 100Mi
logging-svc:
  logging-svc:
    requests:
      cpu: 3m
      memory: 120Mi
  upgrade-init:
    requests:
      cpu: 5m
      memory: 20Mi
metering-svc:
  metering-svc:
    requests:
      cpu: 12m
      memory: 170Mi
  upgrade-init:
    requests:
      cpu: 5m
      memory: 20Mi
state-svc:
  events-svc:
    requests:
      cpu: 3m
      memory: 120Mi
  state-svc:
    requests:
      cpu: 3m
      memory: 130Mi
{{- end -}}
{{- define "k10.multiClusterVersion" -}}2.5{{- end -}}
{{- define "k10.mcExternalPort" -}}18000{{- end -}}
{{- define "k10.defaultKubeVirtVMsUnfreezeTimeout" -}}5m{{- end -}}
{{- define "k10.aggAuditPolicyFile" -}}agg-audit-policy.yaml{{- end -}}
{{- define "k10.siemAuditLogFilePath" -}}-{{- end -}}
{{- define "k10.siemAuditLogFileSize" -}}100{{- end -}}
{{- define "k10.kanisterToolsImageTag" -}}0.114.0{{- end -}}
{{- define "k10.disabledServicesEnvVar" -}}K10_DISABLED_SERVICES{{- end -}}
{{- define "k10.openShiftClientSecretEnvVar" -}}K10_OPENSHIFT_CLIENT_SECRET{{- end -}}
{{- define "k10.defaultK10DefaultPriorityClassName" -}}{{- end -}}
{{- define "k10.dexServiceAccountName" -}}k10-dex-k10-sa{{- end -}}
{{- define "k10.defaultCACertConfigMapName" -}}custom-ca-bundle-store{{- end -}}
{{- define "k10.openShiftConsolePluginName" -}}console-plugin{{- end -}}
{{- define "k10.openShiftConsolePluginCRName" -}}veeam-kasten-console-plugin{{- end -}}
{{- define "k10.openShiftConsolePluginImageName" -}}ocpconsoleplugin{{- end -}}
{{- define "k10.gatewayPrefixVarName" -}}PREFIX_PATH{{- end -}}
{{- define "k10.gatewayGrafanaSvcVarName" -}}GRAFANA_SVC_NAME{{- end -}}
{{- define "k10.gatewayRequestHeadersVarName" -}}EXTAUTH_REQUEST_HEADERS{{- end -}}
{{- define "k10.gatewayAuthHeadersVarName" -}}EXTAUTH_AUTH_HEADERS{{- end -}}
{{- define "k10.gatewayPortVarName" -}}PORT{{- end -}}
{{- define "k10.gatewayEnableDex" -}}ENABLE_DEX{{- end -}}
{{- define "k10.gatewayTLSCertFile" -}}TLS_CRT_FILE{{- end -}}
{{- define "k10.gatewayTLSKeyFile" -}}TLS_KEY_FILE{{- end -}}
{{- define "k10.azureClientIDEnvVar" -}}AZURE_CLIENT_ID{{- end -}}
{{- define "k10.azureTenantIDEnvVar" -}}AZURE_TENANT_ID{{- end -}}
{{- define "k10.azureClientSecretEnvVar" -}}AZURE_CLIENT_SECRET{{- end -}}
{{- define "k10.oidcSecretName" -}}k10-oidc-auth{{- end -}}
{{- define "k10.oidcCustomerSecretName" -}}k10-oidc-auth-creds{{- end -}}
{{- define "k10.secretsDir" -}}/var/run/secrets/kasten.io{{- end -}}
{{- define "k10.sccNameEnvVar" -}}K10_SCC_NAME{{- end -}}
{{- define "k10.fluentbitEndpointEnvVar" -}}FLUENTBIT_ENDPOINT{{- end -}}
