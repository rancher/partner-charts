# Nutanix CSI Storage Driver Helm chart

## Introduction

The Container Storage Interface (CSI) Volume Driver for Kubernetes leverages Nutanix Volumes and Nutanix Files to provide scalable and persistent storage for stateful applications.

When Files is used for persistent storage, applications on multiple pods can access the same storage, and also have the benefit of multi-pod read and write access.

## Important notice

Starting with version 2.5 of this chart we separate the Snapshot components to a second independent Chart.
If you plan to update an existing Nutanix CSI Chart version < v2.5.x with this Chart, you need to check below recommendation.

- Once you upgrade to version 2.5+, the snapshot-controler will be removed, but previously installed Snapshot CRD stay in place. You will then need to install the [nutanix-csi-snapshot](https://github.com/nutanix/helm/tree/master/charts/nutanix-csi-snapshot) Helm Chart following the [Important notice](https://github.com/nutanix/helm/tree/master/charts/nutanix-csi-snapshot#upgrading-from-nutanix-csi-storage-helm-chart-deployment) procedure.
- If you create Storageclass automatically with a previous Nutanix CSI Chart version < v2.5.x, take care to remove Storageclass before `Helm upgrade`.

If you previously installed Nutanix CSI Storage Driver with yaml file please follow the [Upgrading from yaml based deployment](#upgrading-from-yaml-based-deployment) section below.

If this is your first deployment and your Kubernetes Distribution does not bundle the snapshot components, you need to install first the [Nutanix CSI Snapshot Controller Helm chart](https://github.com/nutanix/helm/tree/master/charts/nutanix-csi-snapshot).

Please note that starting with v2.2.0, Nutanix CSI driver has changed format of driver name from com.nutanix.csi to csi.nutanix.com. All deployment yamls uses this new driver name format. However, if you initially installed CSI driver in version < v2.2.0 then you should need to continue to use old driver name com.nutanix.csi by setting `legacy` parameter to `true`. If not existing PVC/PV will not work with the new driver name.

## Nutanix CSI driver documentation
https://portal.nutanix.com/page/documents/details?targetId=CSI-Volume-Driver-v2_5:CSI-Volume-Driver-v2_5

## Features list

- Nutanix CSI Driver v2.5.0
- Nutanix Volumes support
- Nutanix Files support
- Volume clone
- Volume snapshot and Restore
- IP Address Whitelisting
- LVM Volume supporting multi vdisks volume group
- NFS Dynamic share provisioning
- PV resize support for Volumes and Dynamic Files mode
- iSCSI Auto CHAP Authentication
- OS independence
- Volume metrics and CSI operations metrics support

## Prerequisites

- Kubernetes 1.17 or later
- Kubernetes worker nodes must have the iSCSI package installed (Nutanix Volumes mode) and/or NFS tools (Nutanix Files mode)
- This chart have been validated on RHEL/CentOS 7/8 and Ubuntu 18.04/20.04/21.04/21.10, but the new architecture enables easy portability to other distributions.
- This Chart is not made to be installed on the local k3s cluster (by default iscsi prerequisite is missing)

## Installing the Chart

To install the chart with the name `nutanix-csi`:

```console
helm repo add nutanix https://nutanix.github.io/helm/

helm install nutanix-csi nutanix/nutanix-csi-storage -n <namespace of your choice>
```

## Upgrade

Upgrades can be done using the normal Helm upgrade mechanism

```
helm repo update
helm upgrade nutanix-csi nutanix/nutanix-csi-storage
```

### Upgrading from yaml based deployment
Starting with CSI driver v2.5.0, yaml based deployment is discontinued. So to upgrade from yaml based deployment, you need to patch your existing CSI deployment with helm annotations. Please follow the following procedure.

```bash
HELM_CHART_NAME="nutanix-csi"
HELM_CHART_NAMESPACE="ntnx-system"
DRIVER_NAME="csi.nutanix.com"

kubectl delete sts csi-provisioner-ntnx-plugin -n ${HELM_CHART_NAMESPACE}
kubectl patch ds csi-node-ntnx-plugin -n ${HELM_CHART_NAMESPACE} -p '{"metadata": {"annotations":{"meta.helm.sh/release-name":"'"${HELM_CHART_NAME}"'","meta.helm.sh/release-namespace":"'"${HELM_CHART_NAMESPACE}"'"}, "labels":{"app.kubernetes.io/managed-by":"Helm"}}}'

kubectl patch csidriver ${DRIVER_NAME} -p '{"metadata": {"annotations":{"meta.helm.sh/release-name":"'"${HELM_CHART_NAME}"'","meta.helm.sh/release-namespace":"'"${HELM_CHART_NAMESPACE}"'"}, "labels":{"app.kubernetes.io/managed-by":"Helm"}}}'

kubectl patch sa csi-provisioner -n ${HELM_CHART_NAMESPACE} -p '{"metadata": {"annotations":{"meta.helm.sh/release-name":"'"${HELM_CHART_NAME}"'","meta.helm.sh/release-namespace":"'"${HELM_CHART_NAMESPACE}"'"}, "labels":{"app.kubernetes.io/managed-by":"Helm"}}}'
kubectl patch sa csi-node-ntnx-plugin -n ${HELM_CHART_NAMESPACE} -p '{"metadata": {"annotations":{"meta.helm.sh/release-name":"'"${HELM_CHART_NAME}"'","meta.helm.sh/release-namespace":"'"${HELM_CHART_NAMESPACE}"'"}, "labels":{"app.kubernetes.io/managed-by":"Helm"}}}'

kubectl patch clusterrole external-provisioner-runner -n ${HELM_CHART_NAMESPACE} -p '{"metadata": {"annotations":{"meta.helm.sh/release-name":"'"${HELM_CHART_NAME}"'","meta.helm.sh/release-namespace":"'"${HELM_CHART_NAMESPACE}"'"}, "labels":{"app.kubernetes.io/managed-by":"Helm"}}}'
kubectl patch clusterrole csi-node-runner -n ${HELM_CHART_NAMESPACE} -p '{"metadata": {"annotations":{"meta.helm.sh/release-name":"'"${HELM_CHART_NAME}"'","meta.helm.sh/release-namespace":"'"${HELM_CHART_NAMESPACE}"'"}, "labels":{"app.kubernetes.io/managed-by":"Helm"}}}'

kubectl patch clusterrolebinding csi-provisioner-role -n ${HELM_CHART_NAMESPACE} -p '{"metadata": {"annotations":{"meta.helm.sh/release-name":"'"${HELM_CHART_NAME}"'","meta.helm.sh/release-namespace":"'"${HELM_CHART_NAMESPACE}"'"}, "labels":{"app.kubernetes.io/managed-by":"Helm"}}}'
kubectl patch clusterrolebinding csi-node-role -n ${HELM_CHART_NAMESPACE} -p '{"metadata": {"annotations":{"meta.helm.sh/release-name":"'"${HELM_CHART_NAME}"'","meta.helm.sh/release-namespace":"'"${HELM_CHART_NAMESPACE}"'"}, "labels":{"app.kubernetes.io/managed-by":"Helm"}}}'

kubectl patch service csi-provisioner-ntnx-plugin -n ${HELM_CHART_NAMESPACE} -p '{"metadata": {"annotations":{"meta.helm.sh/release-name":"'"${HELM_CHART_NAME}"'","meta.helm.sh/release-namespace":"'"${HELM_CHART_NAMESPACE}"'"}, "labels":{"app.kubernetes.io/managed-by":"Helm"}}}'

kubectl patch service csi-metrics-service -n ${HELM_CHART_NAMESPACE} -p '{"metadata": {"annotations":{"meta.helm.sh/release-name":"'"${HELM_CHART_NAME}"'","meta.helm.sh/release-namespace":"'"${HELM_CHART_NAMESPACE}"'"}, "labels":{"app.kubernetes.io/managed-by":"Helm"}}}'

kubectl patch servicemonitor csi-driver -n ${HELM_CHART_NAMESPACE} -p '{"metadata": {"annotations":{"meta.helm.sh/release-name":"'"${HELM_CHART_NAME}"'","meta.helm.sh/release-namespace":"'"${HELM_CHART_NAMESPACE}"'"}, "labels":{"app.kubernetes.io/managed-by":"Helm"}}}' --type=merge
```

Now follow [Installing the Chart](#installing-the-chart) section to finish upgrading the CSI driver.

## Uninstalling the Chart

To uninstall/delete the `nutanix-csi` deployment:

```console
helm delete nutanix-csi -n <namespace of your choice>
```

## Configuration

The following table lists the configurable parameters of the Nutanix-CSI chart and their default values.

| Parameter                     | Description                                                                                 | Default                |
|-------------------------------|---------------------------------------------------------------------------------------------|------------------------|
| `legacy`                      | Use old reverse notation for CSI driver name                                                | `false`                |
| `volumeClass`                 | Activate Nutanix Volumes Storage Class                                                      | `false`                |
| `volumeClassName`             | Name of the Nutanix Volumes Storage Class                                                   | `nutanix-volume`       |
| `volumeClassDescription`      | Description prefix for each created VG                                                      | `volumeClassName`      |
| `volumeClassRetention`        | Retention policy for the Volumes Storage Class (Delete, Retain)                             | `Delete`               |
| `fileClass`                   | Activate Nutanix Files Storage Class                                                        | `false`                |
| `fileClassName`               | Name of the Nutanix Files Storage Class                                                     | `nutanix-file`         |
| `fileClassRetention`          | Retention policy for the Files Storage Class (Delete, Retain)                               | `Delete`               |
| `dynamicFileClass`            | Activate Nutanix Dynamic Files Storage Class                                                | `false`                |
| `dynamicFileClassName`        | Name of the Nutanix Dynamic Files Storage Class                                             | `nutanix-dynamicfile`  |
| `dynamicFileClassDescription` | Description prefix for each created Fileshare                                               | `dynamicFileClassName` |
| `dynamicFileClassRetention`   | Retention policy for the Dynamic Files Storage Class (Delete, Retain)                       | `Delete`               |
| `defaultStorageClass`         | Choose your default Storage Class (none, volume, file, dynfile)                             | `none`                 |
| `prismEndPoint`               | Cluster Virtual IP Address                                                                  | `10.0.0.1`             |
| `username`                    | Name used for the admin role (if created)                                                   | `admin`                |
| `password`                    | Password for the admin role (if created)                                                    | `nutanix/4u`           |
| `secretName`                  | Name of the secret to use for admin role                                                    | `ntnx-secret`          |
| `createSecret`                | Create secret for admin role (if false use existing)                                        | `true`                 |
| `storageContainer`            | Nutanix storage container name                                                              | `default`              |
| `fsType`                      | Type of file system you are using (ext4, xfs)                                               | `xfs`                  |
| `networkSegmentation`         | Activate Volumes Network Segmentation support                                               | `false`                |
| `lvmVolume`                   | Activate LVM to use multiple vdisks by Volume                                               | `false`                |
| `lvmDisks`                    | Number of vdisks by volume if lvm enabled                                                   | `4`                    |
| `fileHost`                    | NFS server IP address                                                                       | `10.0.0.3`             |
| `filePath`                    | Path of the NFS share                                                                       | `share`                |
| `fileServerName`              | Name of the Nutanix FIle Server                                                             | `file`                 |
| `kubeletDir`                  | allows overriding the host location of kubelet's internal state                             | `/var/lib/kubelet`     |
| `nodeSelector`                | Add nodeSelector to all pods                                                                | `{}`                   |
| `tolerations`                 | Add tolerations to all pods                                                                 | `[]`                   |
| `imagePullPolicy`             | Specify imagePullPolicy for all pods                                                        | `IfNotPresent`         |
| `controller.replicas`         | Number of Controllers replicas to deploy.                                                   | `2`                    |
| `controller.nodeSelector`     | Add nodeSelector to provisioner pod                                                         | `{}`                   |
| `controller.tolerations`      | Add tolerations to provisioner pod                                                          | `[]`                   |
| `node.nodeSelector`           | Add nodeSelector to node pods                                                               | `{}`                   |
| `node.tolerations`            | Add tolerations to node pods                                                                | `[]`                   |
| `servicemonitor.enabled`      | Create ServiceMonitor to scrape CSI  metrics                                                | `false`                |
| `servicemonitor.labels`       | Labels to add to the ServiceMonitor (for match the Prometheus serviceMonitorSelector logic) | `k8s-app: csi-driver`  |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install` or provide a a file whit `-f value.yaml`.

### Configuration examples:

Install the driver in the `ntnx-system` namespace:

```console
helm install nutanix-storage nutanix/nutanix-csi-storage -n ntnx-system --create-namespace
```

Install the driver in the `ntnx-system` namespace and create a volume storageclass:

```console
helm install nutanix-storage nutanix/nutanix-csi-storage -n ntnx-system --create-namespace --set volumeClass=true --set prismEndPoint=X.X.X.X --set username=admin --set password=xxxxxxxxx --set storageContainer=container_name --set fsType=xfs
```
In the above command  `prismEndpoint` refers to the Prism Element cluster virtual ip address where storage will be consumed. 


Install the driver in the `ntnx-system` namespace, create a volume and a dynamic file storageclass and set the volume storage class as default:

```console
helm install nutanix-storage nutanix/nutanix-csi-storage -n ntnx-system --create-namespace --set volumeClass=true --set prismEndPoint=X.X.X.X --set username=admin --set password=xxxxxxxxx --set storageContainer=container_name --set fsType=xfs --set defaultStorageClass=volume --set dynamicFileClass=true --set fileServerName=name_of_the_file_server
```
In the above command  `prismEndpoint` refers to the Prism Element cluster virtual ip address where storage will be consumed.

All the options can also be specified in a value.yaml file:

```console
helm install nutanix-storage nutanix/nutanix-csi-storage -n ntnx-system --create-namespace -f value.yaml
```

## Support

The Nutanix CSI Volume Driver is fully supported by Nutanix. Please use the standard support procedure to file a ticket [here](https://www.nutanix.com/support-services/product-support).

## Community

Please file any issues, questions or feature requests you may have [here](https://github.com/nutanix/csi-plugin/issues) for the Nutanix CSI Driver or [here](https://github.com/nutanix/helm/issues) for the Helm chart.

## Contributing

We value all feedback and contributions. If you find any issues or want to contribute, please feel free to open an issue or file a PR.
