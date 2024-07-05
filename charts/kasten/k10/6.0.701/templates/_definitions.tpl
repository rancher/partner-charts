{{/* Code generated automatically. DO NOT EDIT. */}}
{{/* K10 services can be disabled by customers via helm value based feature flags.
Therefore, fetching of a list or yaml with service names should be done with the get.enabled* helper functions.
For example, the k10.restServices list can be fetched with get.enabledRestServices */}}
{{- define "k10.additionalServices" -}}frontend kanister{{- end -}}
{{- define "k10.restServices" -}}admin auth bloblifecyclemanager catalog controllermanager crypto dashboardbff events executor garbagecollector jobs logging metering state vbrintegrationapi{{- end -}}
{{- define "k10.services" -}}aggregatedapis{{- end -}}
{{- define "k10.exposedServices" -}}auth dashboardbff vbrintegrationapi{{- end -}}
{{- define "k10.statelessServices" -}}admin aggregatedapis auth bloblifecyclemanager controllermanager crypto dashboardbff events executor garbagecollector state vbrintegrationapi{{- end -}}
{{- define "k10.colocatedServices" -}}
admin:
  isExposed: false
  port: 8001
  primary: state
bloblifecyclemanager:
  isExposed: true
  port: 8001
  primary: crypto
events:
  isExposed: true
  port: 8002
  primary: crypto
garbagecollector:
  isExposed: true
  port: 8003
  primary: crypto
vbrintegrationapi:
  isExposed: true
  port: 8001
  primary: dashboardbff
{{- end -}}
{{- define "k10.colocatedServiceLookup" -}}
crypto:
- bloblifecyclemanager
- events
- garbagecollector
dashboardbff:
- vbrintegrationapi
state:
- admin
{{- end -}}
{{- define "k10.aggregatedAPIs" -}}actions apps repositories vault{{- end -}}
{{- define "k10.configAPIs" -}}config{{- end -}}
{{- define "k10.profiles" -}}profiles{{- end -}}
{{- define "k10.policies" -}}policies{{- end -}}
{{- define "k10.policypresets" -}}policypresets{{- end -}}
{{- define "k10.transformsets" -}}transformsets{{- end -}}
{{- define "k10.blueprintbindings" -}}blueprintbindings{{- end -}}
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
{{- define "k10.importActions" -}}importactions{{- end -}}
{{- define "k10.exportActions" -}}exportactions{{- end -}}
{{- define "k10.exportActionsDetails" -}}exportactions/details{{- end -}}
{{- define "k10.retireActions" -}}retireactions{{- end -}}
{{- define "k10.runActions" -}}runactions{{- end -}}
{{- define "k10.backupClusterActions" -}}backupclusteractions{{- end -}}
{{- define "k10.backupClusterActionsDetails" -}}backupclusteractions/details{{- end -}}
{{- define "k10.restoreClusterActions" -}}restoreclusteractions{{- end -}}
{{- define "k10.restoreClusterActionsDetails" -}}restoreclusteractions/details{{- end -}}
{{- define "k10.cancelActions" -}}cancelactions{{- end -}}
{{- define "k10.upgradeActions" -}}upgradeactions{{- end -}}
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
{{- define "k10.defaultConcurrentSnapshotConversions" -}}3{{- end -}}
{{- define "k10.defaultConcurrentWorkloadSnapshots" -}}5{{- end -}}
{{- define "k10.defaultK10DataStoreParallelUpload" -}}8{{- end -}}
{{- define "k10.defaultK10DataStoreGeneralContentCacheSizeMB" -}}0{{- end -}}
{{- define "k10.defaultK10DataStoreGeneralMetadataCacheSizeMB" -}}500{{- end -}}
{{- define "k10.defaultK10DataStoreRestoreContentCacheSizeMB" -}}500{{- end -}}
{{- define "k10.defaultK10DataStoreRestoreMetadataCacheSizeMB" -}}500{{- end -}}
{{- define "k10.defaultK10BackupBufferFileHeadroomFactor" -}}1.1{{- end -}}
{{- define "k10.defaultK10LimiterGenericVolumeSnapshots" -}}10{{- end -}}
{{- define "k10.defaultK10LimiterGenericVolumeCopies" -}}10{{- end -}}
{{- define "k10.defaultK10LimiterGenericVolumeRestores" -}}10{{- end -}}
{{- define "k10.defaultK10LimiterCsiSnapshots" -}}10{{- end -}}
{{- define "k10.defaultK10LimiterProviderSnapshots" -}}10{{- end -}}
{{- define "k10.defaultK10GCDaemonPeriod" -}}21600{{- end -}}
{{- define "k10.defaultK10GCKeepMaxActions" -}}1000{{- end -}}
{{- define "k10.defaultK10GCImportRunActionsEnabled" -}}false{{- end -}}
{{- define "k10.defaultK10GCRetireActionsEnabled" -}}false{{- end -}}
{{- define "k10.defaultK10ExecutorWorkerCount" -}}8{{- end -}}
{{- define "k10.defaultK10ExecutorMaxConcurrentRestoreCsiSnapshots" -}}3{{- end -}}
{{- define "k10.defaultK10ExecutorMaxConcurrentRestoreGenericVolumeSnapshots" -}}3{{- end -}}
{{- define "k10.defaultK10ExecutorMaxConcurrentRestoreWorkloads" -}}3{{- end -}}
{{- define "k10.defaultAssumeRoleDuration" -}}60m{{- end -}}
{{- define "k10.defaultKanisterBackupTimeout" -}}45{{- end -}}
{{- define "k10.defaultKanisterRestoreTimeout" -}}600{{- end -}}
{{- define "k10.defaultKanisterDeleteTimeout" -}}45{{- end -}}
{{- define "k10.defaultKanisterHookTimeout" -}}20{{- end -}}
{{- define "k10.defaultKanisterCheckRepoTimeout" -}}20{{- end -}}
{{- define "k10.defaultKanisterStatsTimeout" -}}20{{- end -}}
{{- define "k10.defaultKanisterEFSPostRestoreTimeout" -}}45{{- end -}}
{{- define "k10.cloudProviders" -}}aws google azure{{- end -}}
{{- define "k10.serviceResources" -}}
admin-svc:
  admin-svc:
    requests:
      cpu: 2m
      memory: 160Mi
aggregatedapis-svc:
  aggregatedapis-svc:
    requests:
      cpu: 90m
      memory: 180Mi
auth-svc:
  auth-svc:
    requests:
      cpu: 2m
      memory: 30Mi
bloblifecyclemanager-svc:
  bloblifecyclemanager-svc:
    requests:
      cpu: 10m
      memory: 40Mi
catalog-svc:
  catalog-svc:
    requests:
      cpu: 200m
      memory: 780Mi
  kanister-sidecar:
    limits:
      cpu: 1200m
      memory: 800Mi
    requests:
      cpu: 100m
      memory: 800Mi
controllermanager-svc:
  controllermanager-svc:
    requests:
      cpu: 5m
      memory: 30Mi
crypto-svc:
  crypto-svc:
    requests:
      cpu: 1m
      memory: 30Mi
dashboardbff-svc:
  dashboardbff-svc:
    requests:
      cpu: 8m
      memory: 40Mi
events-svc:
  events-svc:
    requests:
      cpu: 3m
      memory: 500Mi
executor-svc:
  executor-svc:
    requests:
      cpu: 3m
      memory: 50Mi
  tools:
    requests:
      cpu: 1m
      memory: 2Mi
frontend-svc:
  frontend-svc:
    requests:
      cpu: 1m
      memory: 40Mi
garbagecollector-svc:
  garbagecollector-svc:
    requests:
      cpu: 3m
      memory: 100Mi
jobs-svc:
  jobs-svc:
    requests:
      cpu: 30m
      memory: 380Mi
kanister-svc:
  kanister-svc:
    requests:
      cpu: 1m
      memory: 30Mi
logging-svc:
  logging-svc:
    requests:
      cpu: 2m
      memory: 40Mi
metering-svc:
  metering-svc:
    requests:
      cpu: 2m
      memory: 30Mi
state-svc:
  state-svc:
    requests:
      cpu: 2m
      memory: 30Mi
{{- end -}}
{{- define "k10.multiClusterVersion" -}}2{{- end -}}
{{- define "k10.mcExternalPort" -}}18000{{- end -}}
{{- define "k10.defaultKubeVirtVMsUnfreezeTimeout" -}}5m{{- end -}}
{{- define "k10.kanisterToolsImageTag" -}}0.95.0{{- end -}}
{{- define "k10.disabledServicesEnvVar" -}}K10_DISABLED_SERVICES{{- end -}}
