# CSI WekaFS Driver
Helm chart for Deployment of WekaIO Container Storage Interface (CSI) plugin for WekaFS - the world fastest filesystem

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/csi-wekafs)](https://artifacthub.io/packages/search?repo=csi-wekafs)
![Version: 2.7.6](https://img.shields.io/badge/Version-2.7.6-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v2.7.6](https://img.shields.io/badge/AppVersion-v2.7.6-informational?style=flat-square)

## Homepage
https://github.com/weka/csi-wekafs

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| WekaIO, Inc. | <csi@weka.io> | <https://weka.io> |

## Pre-requisite
- Kubernetes cluster of version 1.18 and up, 1.19 and up recommended
- Helm v3 must be installed and configured properly
- Weka system pre-configured and Weka client installed and registered in cluster for each Kubernetes node

## Deployment
```shell
helm repo add csi-wekafs https://weka.github.io/csi-wekafs
helm install csi-wekafsplugin csi-wekafs/csi-wekafsplugin --namespace csi-wekafsplugin --create-namespace [--set selinuxSupport=<off | mixed | enforced>]
```

> **NOTE:** Since version 0.8.0, Weka CSI plugin supports installation on SELinux-enabled Kubernetes clusters
> Refer to [SELinux Support & Installation Notes](https://github.com/weka/csi-wekafs/blob/master/selinux/README.md) for additional information

> **NOTE:** Since version 0.7.0, Weka CSI plugin transitions to API-based deployment model which requires API
> connectivity and credentials parameters to be set in Storage Class.
>
> Kubernetes does not allow storage class modification for existing volumes, hence the
> recommended upgrade process is re-deploying new persistent volumes based on new storage class format.
>
> However, for sake of more convenient migration, a `legacySecretName` parameter can be set that will
> bind existing legacy volumes to a Weka cluster API and allow volume expansion.
>
> For further information, refer [Official Weka CSI Plugin documentation](https://docs.weka.io/appendices/weka-csi-plugin)

## Usage
- [Deploy an Example application](https://github.com/weka/csi-wekafs/blob/master/docs/usage.md)
- [SELinux Support & Installation Notes](https://github.com/weka/csi-wekafs/blob/master/selinux/README.md)

## Additional Documentation
- [Official Weka CSI Plugin documentation](https://docs.weka.io/appendices/weka-csi-plugin)

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| dynamicProvisionPath | string | `"csi-volumes"` | Directory in root of file system where dynamic volumes are provisioned |
| csiDriverName | string | `"csi.weka.io"` | Name of the driver (and provisioner) |
| csiDriverVersion | string | `"2.7.6"` | CSI driver version |
| images.livenessprobesidecar | string | `"registry.k8s.io/sig-storage/livenessprobe:v2.16.0"` | CSI liveness probe sidecar image URL |
| images.attachersidecar | string | `"registry.k8s.io/sig-storage/csi-attacher:v4.9.0"` | CSI attacher sidecar image URL |
| images.provisionersidecar | string | `"registry.k8s.io/sig-storage/csi-provisioner:v5.3.0"` | CSI provisioner sidecar image URL |
| images.registrarsidecar | string | `"registry.k8s.io/sig-storage/csi-node-driver-registrar:v2.14.0"` | CSI registrar sidercar |
| images.resizersidecar | string | `"registry.k8s.io/sig-storage/csi-resizer:v1.14.0"` | CSI resizer sidecar image URL |
| images.snapshottersidecar | string | `"registry.k8s.io/sig-storage/csi-snapshotter:v8.3.0"` | CSI snapshotter sidecar image URL |
| images.csidriver | string | `"quay.io/weka.io/csi-wekafs"` | CSI driver main image URL |
| images.csidriverTag | string | `"2.7.6"` | CSI driver tag |
| imagePullSecret | string | `""` | image pull secret required for image download. Must have permissions to access all images above.    Should be used in case of private registry that requires authentication |
| globalPluginTolerations | list | `[{"effect":"NoSchedule","key":"node-role.kubernetes.io/master","operator":"Exists"}]` | Tolerations for all CSI driver components |
| controllerPluginTolerations | list | `[{"effect":"NoSchedule","key":"node-role.kubernetes.io/master","operator":"Exists"}]` | Tolerations for CSI controller component only (by default same as global) |
| nodePluginTolerations | list | `[{"effect":"NoSchedule","key":"node-role.kubernetes.io/master","operator":"Exists"}]` | Tolerations for CSI node component only (by default same as global) |
| nodeSelector | object | `{}` | Optional nodeSelector for CSI plugin deployment on certain Kubernetes nodes only    This nodeselector will be applied to all CSI plugin components |
| affinity | object | `{}` | Optional affinity for CSI plugin deployment    This affinity will be applied to all CSI plugin components |
| machineConfigLabels | list | `["worker","master"]` | Optional setting for OCP platform only, which machineconfig pools to apply the Weka SELinux policy on    NOTE: by default, the policy will be installed both on workers and control plane nodes |
| controller.replicas | int | `2` | Controller number of replicas |
| controller.maxConcurrentRequests | int | `5` | Maximum concurrent requests from sidecars (global) |
| controller.concurrency | object | `{"createSnapshot":5,"createVolume":5,"deleteSnapshot":5,"deleteVolume":5,"expandVolume":5}` | maximum concurrent operations per operation type |
| controller.grpcRequestTimeoutSeconds | int | `30` | Return GRPC Unavailable if request waits in queue for that long time (seconds) |
| controller.configureProvisionerLeaderElection | bool | `true` | Configure provisioner sidecar for leader election |
| controller.configureResizerLeaderElection | bool | `true` | Configure resizer sidecar for leader election |
| controller.configureSnapshotterLeaderElection | bool | `true` | Configure snapshotter sidecar for leader election |
| controller.configureAttacherLeaderElection | bool | `true` | Configure attacher sidecar for leader election |
| controller.nodeSelector | object | `{}` | optional nodeSelector for controller components only |
| controller.affinity | object | `{}` | optional affinity for controller components only |
| controller.labels | object | `{}` | optional labels to add to controller deployment |
| controller.podLabels | object | `{}` | optional labels to add to controller pods |
| controller.terminationGracePeriodSeconds | int | `10` | termination grace period for controller pods |
| node.maxConcurrentRequests | int | `5` | Maximum concurrent requests from sidecars (global) |
| node.concurrency | object | `{"nodePublishVolume":5,"nodeUnpublishVolume":5}` | maximum concurrent operations per operation type (to avoid API starvation) |
| node.grpcRequestTimeoutSeconds | int | `30` | Return GRPC Unavailable if request waits in queue for that long time (seconds) |
| node.nodeSelector | object | `{}` | optional nodeSelector for node components only |
| node.affinity | object | `{}` | optional affinity for node components only |
| node.labels | object | `{}` | optional labels to add to node daemonset |
| node.podLabels | object | `{}` | optional labels to add to node pods |
| node.terminationGracePeriodSeconds | int | `10` | termination grace period for node pods |
| logLevel | int | `5` | Log level of CSI plugin |
| useJsonLogging | bool | `false` | Use JSON structured logging instead of human-readable logging format (for exporting logs to structured log parser) |
| legacyVolumeSecretName | string | `""` | for migration of pre-CSI 0.7.0 volumes only, default API secret. Must reside in same namespace as the plugin |
| priorityClassName | string | `""` | Optional CSI Plugin priorityClassName |
| selinuxSupport | string | `"off"` | Support SELinux labeling for Persistent Volumes, may be either `off`, `mixed`, `enforced` (default off)    In `enforced` mode, CSI node components will only start on nodes having a label `selinuxNodeLabel` below    In `mixed` mode, separate CSI node components will be installed on SELinux-enabled and regular hosts    In `off` mode, only non-SELinux-enabled node components will be run on hosts without label.    WARNING: if SELinux is not enabled, volume provisioning and publishing might fail!    NOTE: SELinux support is enabled automatically on clusters recognized as RedHat OpenShift Container Platform |
| selinuxNodeLabel | string | `"csi.weka.io/selinux_enabled"` | This label must be set to `"true"` on SELinux-enabled Kubernetes nodes,    e.g., to run the node server in secure mode on SELinux-enabled node, the node must have label    `csi.weka.io/selinux_enabled="true"` |
| selinuxOcpRetainMachineConfig | bool | `false` | If true, the SELinux policy machine configuration will not be removed when uninstalling the plugin.    This is useful for OpenShift Container Platform clusters, to not cause machine config pool update on plugin reinstall |
| kubeletPath | string | `"/var/lib/kubelet"` | kubelet path, in cases Kubernetes is installed not in default folder |
| metrics.enabled | bool | `true` | Enable Prometheus Metrics |
| metrics.controllerPort | int | `9090` | Metrics port for Controller Server |
| metrics.provisionerPort | int | `9091` | Provisioner metrics port |
| metrics.resizerPort | int | `9092` | Resizer metrics port |
| metrics.snapshotterPort | int | `9093` | Snapshotter metrics port |
| metrics.nodePort | int | `9094` | Metrics port for Node Serer |
| metrics.attacherPort | int | `9095` | Attacher metrics port |
| hostNetwork | bool | `false` | Set to true to use host networking. Will be always set to true when using NFS mount protocol |
| pluginConfig.fsGroupPolicy | string | `"File"` | WARNING: Changing this value might require uninstall and re-install of the plugin |
| pluginConfig.allowInsecureHttps | bool | `false` | Allow insecure HTTPS (skip TLS certificate verification) |
| pluginConfig.objectNaming.volumePrefix | string | `"csivol-"` | Prefix that will be added to names of Weka cluster filesystems / snapshots assocciated with CSI volume,    must not exceed 7 symbols. |
| pluginConfig.objectNaming.snapshotPrefix | string | `"csisnp-"` | Prefix that will be added to names of Weka cluster snapshots assocciated with CSI snapshot,    must not exceed 7 symbols. |
| pluginConfig.objectNaming.seedSnapshotPrefix | string | `"csisnp-seed-"` | Prefix that will be added to automatically created "seed" snapshot of empty filesytem,    must not exceed 12 symbols. |
| pluginConfig.allowedOperations.autoCreateFilesystems | bool | `true` | Allow automatic provisioning of CSI volumes based on distinct Weka filesystem |
| pluginConfig.allowedOperations.autoExpandFilesystems | bool | `true` | Allow automatic expansion of filesystem on which Weka snapshot-backed CSI volumes,    e.g. in case a required volume capacity exceeds the size of filesystem.    Note: the filesystem is not expanded automatically when a new directory-backed volume is provisioned |
| pluginConfig.allowedOperations.snapshotDirectoryVolumes | bool | `false` | Create snapshots of legacy (dir/v1) volumes. By default disabled.    Note: when enabled, for every legacy volume snapshot, a full filesystem snapshot will be created (wasteful) |
| pluginConfig.allowedOperations.snapshotVolumesWithoutQuotaEnforcement | bool | `false` | Allow creation of snapshot-backed volumes even on unsupported Weka cluster versions, off by default    Note: On versions of Weka < v4.2 snapshot-backed volume capacity cannot be enforced |
| pluginConfig.mutuallyExclusiveMountOptions[0] | string | `"readcache,writecache,coherent,forcedirect"` |  |
| pluginConfig.mutuallyExclusiveMountOptions[1] | string | `"sync,async"` |  |
| pluginConfig.mutuallyExclusiveMountOptions[2] | string | `"ro,rw"` |  |
| pluginConfig.encryption.allowEncryptionWithoutKms | bool | `false` | Allow encryption of Weka filesystems associated with CSI volumes without using external KMS server.    Should never be run in production, only for testing purposes |
| pluginConfig.mountProtocol.useNfs | bool | `false` | Use NFS transport for mounting Weka filesystems, off by default |
| pluginConfig.mountProtocol.allowNfsFailback | bool | `false` | Allow Failback to NFS transport if Weka client fails to mount filesystem using native protocol |
| pluginConfig.mountProtocol.interfaceGroupName | string | `""` | Specify name of NFS interface group to use for mounting Weka filesystems. If not set, first NFS interface group will be used |
| pluginConfig.mountProtocol.clientGroupName | string | `""` | Specify existing client group name for NFS configuration. If not set, "WekaCSIPluginClients" group will be created |
| pluginConfig.mountProtocol.nfsProtocolVersion | string | `"4.1"` | Specify NFS protocol version to use for mounting Weka filesystems. Default is "4.1", consult Weka documentation for supported versions |
| pluginConfig.skipGarbageCollection | bool | `false` | Skip garbage collection of deleted directory-backed volume contents and only move them to trash. Default false |
| pluginConfig.waitForObjectDeletion | bool | `false` | Wait for WEKA filesystem / snapshot deletion before acknowledging the corresponding CSI volume deletion. Default false |
| pluginConfig.manageNodeTopologyLabels | bool | `true` | Allow CSI plugin to manage node topology labels. For Operator-managed clusters, this should be set to false. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
