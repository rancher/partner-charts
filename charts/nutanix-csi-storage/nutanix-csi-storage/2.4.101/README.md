# Nutanix CSI Volume Driver Helm chart

## Introduction

The Container Storage Interface (CSI) Volume Driver for Kubernetes leverages Nutanix Volumes and Nutanix Files to provide scalable and persistent storage for stateful applications.

When Files is used for persistent storage, applications on multiple pods can access the same storage, and also have the benefit of multi-pod read and write access.

## Important notice

If you plan to update an existing Nutanix CSI deployement from 1.x to 2.x with this Chart, you need first deploy manually the CRD present here https://github.com/nutanix/csi-plugin/tree/master/deploy/Centos/crd.

Please note that starting with v2.2.0, Nutanix CSI driver has changed format of driver name from com.nutanix.csi to csi.nutanix.com. All deployment yamls uses this new driver name format. However, if you are upgrading the CSI driver then you should continue to use old driver name com.nutanix.csi by setting `legacy` parameter to `true`. If not existing PVC/PV will not work with the new driver name.

## Nutanix CSI driver documentation
https://portal.nutanix.com/page/documents/details?targetId=CSI-Volume-Driver-v2_4_1:CSI-Volume-Driver-v2_4_1

## Features list

- Nutanix CSI Driver v2.4.1
- Nutanix Volumes support
- Nutanix Files support
- Volume resize support ( beta in Kubernetes >= 1.16.0 )
- Volume clone ( beta Kubernetes >= 1.16.0 )
- Volume snapshot and Restore ( beta Kubernetes >= 1.17.0 )
- IP Address Whitelisting
- LVM Volume supporting multi vdisks volume group
- NFS dynamic share provisioning
- iSCSI Auto CHAP Authentication
- OS independence
- Volume metrics and CSI operations metrics support

## Prerequisites

- Kubernetes 1.17 or later
- Kubernetes worker nodes must have the iSCSI package installed (Nutanix Volumes only)
- This chart have been validated on CentOS 7 and Ubuntu 18.04/20.04, but the new architecture enables easy portability to other distributions.

## Installing the Chart

To install the chart with the name `nutanix-csi`:

```console
helm repo add nutanix https://nutanix.github.io/helm/

helm install nutanix-csi nutanix/nutanix-csi-storage -n <namespace of your choice>
```

## Uninstalling the Chart

To uninstall/delete the `nutanix-csi` deployment:

```console
helm delete nutanix-csi -n <namespace of your choice>
```

## Configuration

The following table lists the configurable parameters of the Nutanix-CSI chart and their default values.

|              Parameter           |                Description             |             Default            |
|----------------------------------|----------------------------------------|--------------------------------|
| `legacy`                         | Use old reverse notation for CSI driver name | `false` |
| `volumeClass`                    | Activate Nutanix Volumes Storage Class | `true` |
| `volumeClassName`                | Name of the Nutanix Volumes Storage Class | `nutanix-volume` |
| `fileClass`                      | Activate Nutanix Files Storage Class | `false` |
| `fileClassName`                  | Name of the Nutanix Files Storage Class | `nutanix-file` |
| `dynamicFileClass`               | Activate Nutanix Dynamic Files Storage Class | `false` |
| `dynamicFileClassName`           | Name of the Nutanix Dynamic Files Storage Class | `nutanix-dynamicfile` |
| `defaultStorageClass`            | Choose your default Storage Class (none, volume, file, dynfile) | `none`|
| `prismEndPoint`                  | Cluster Virtual IP Address |`10.0.0.1`|
| `dataServiceEndPoint`            | Prism data service IP |`10.0.0.2`|
| `username`                       | Name used for the admin role (if created) |`admin`|
| `password`                       | Password for the admin role (if created) |`nutanix/4u`|
| `secretName`                     | Name of the secret to use for admin role| `ntnx-secret`|
| `createSecret`                   | Create secret for admin role (if false use existing)| `true`|
| `storageContainer`               | Nutanix storage container name     | `default`|
| `fsType`                         | Type of file system you are using (ext4, xfs)  |`xfs`|
| `lvmVolume`                      | Activate LVM to use multiple vdisks by Volume    |`false`|
| `lvmDisks`                       | Number of vdisks by volume if lvm enabled | `4`|
| `fileHost`                       | NFS server IP address | `10.0.0.3`|
| `filePath`                       | Path of the NFS share |`share`|
| `fileServerName`                 | Name of the Nutanix FIle Server | `file`|
| `kubeletDir`                     | allows overriding the host location of kubelet's internal state | `/var/lib/kubelet`|
| `nodeSelector`                   | Add nodeSelector to all pods | `{}` |
| `tolerations`                    | Add tolerations to all pods | `[]` |
| `imagePullPolicy`                | Specify imagePullPolicy for all pods| `IfNotPresent`|
| `provisioner.nodeSelector`       | Add nodeSelector to provisioner pod | `{}` |
| `provisioner.tolerations`        | Add tolerations to provisioner pod | `[]`  |
| `node.nodeSelector`              | Add nodeSelector to node pods | `{}` |
| `node.tolerations`               | Add tolerations to node pods | `[]` |
| `snapshotController.nodeSelector`| Add nodeSelector to snapshotController pod | `{}` |
| `snapshotController.tolerations` | Add tolerations to snapshotController pod | `[]` |
| `servicemonitor.enabled`         | Create ServiceMonitor to scrape CSI  metrics | `false` |
| `servicemonitor.labels`          | Labels to add to the ServiceMonitor (for match the Prometheus serviceMonitorSelector logic) | `k8s-app: csi-driver`|

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install` or provide a a file whit `-f value.yaml`.

Example:

```console
helm install nutanix-csi nutanix/nutanix-csi-storage --set prismEndPoint=X.X.X.X --set dataServiceEndPoint=Y.Y.Y.Y --set username=admin --set password=xxxxxxxxx --set storageContainer=container_name --set fsType=xfs --set defaultStorageClass=volume
```

or

```console
helm install nutanix-csi nutanix/nutanix-csi-storage -f value.yaml
```

## Support

The Nutanix CSI Volume Driver is fully supported by Nutanix. Please use the standard support procedure to file a ticket [here](https://www.nutanix.com/support-services/product-support).

## Community

Please file any issues, questions or feature requests you may have [here](https://github.com/nutanix/csi-plugin/issues) for the Nutanix CSI Driver or [here](https://github.com/nutanix/helm/issues) for the Helm chart.

## Contributing

We value all feedback and contributions. If you find any issues or want to contribute, please feel free to open an issue or file a PR.
