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
https://portal.nutanix.com/page/documents/details?targetId=CSI-Volume-Driver-v3_0:CSI-Volume-Driver-v3_0

## Features list

- Nutanix CSI Driver v3.6.0
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
- Squash type support for Dynamic File mode

## Prerequisites

- Kubernetes 1.20 or later
- Kubernetes worker nodes must have the iSCSI package installed (Nutanix Volumes mode) and/or NFS tools (Nutanix Files mode)
- This chart have been validated on RHEL/CentOS/Rocky 8/9 and Ubuntu 18.04/20.04/21.04/21.10/22.05, but the new architecture enables easy portability to other distributions.

## Installing the Chart

To install the chart with the name `nutanix-csi`:

```console
wget https://github.com/nutanix/helm-releases/releases/download/nutanix-csi-storage-3.6.0/nutanix-csi-storage-3.6.0.tgz
```

After downloading the chart you can directly set the values and install:

```console
helm install nutanix-csi nutanix-csi-storage-3.6.0.tgz --set <key>=<value> -n <namespace of your choice>
```

Or you can unzip, set values and then install:

```console
tar -xvf nutanix-csi-storage-3.6.0.tgz

helm install nutanix-csi nutanix-csi-storage-3.6.0 -n <namespace of your choice>
```

## Upgrade

To upgrade the chart with the name `nutanix-csi`:

```console
wget https://github.com/nutanix/helm-releases/releases/download/nutanix-csi-storage-3.6.0/nutanix-csi-storage-3.6.0.tgz
```

After downloading the chart you can directly set the values and upgrade:

```console
helm upgrade nutanix-csi nutanix-csi-storage-3.6.0.tgz --set <key>=<value> -n <namespace of your choice>
```

Or you can unzip, set values and then upgrade:

```console
tar -xvf nutanix-csi-storage-3.6.0.tgz

helm upgrade nutanix-csi nutanix-csi-storage -n <namespace of your choice>
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

| Parameter                        | Description                                                                                 | Default                  |
|----------------------------------|---------------------------------------------------------------------------------------------|--------------------------|
| `legacy`                         | Use old reverse notation for CSI driver name                                                | `false`                  |
| `createVolumeSnapshotClass`      | Volumesnapshotclass will be created as part of the deployment                               | `true`                   |
| `volumeSnapshotClassName`        | Name of the volumesnapshotclass                                                             | `nutanix-snapshot-class` |
| `volumeSnapshotClassAnnotations` | Annotations to add to the volumesnapshotclass                                               | {}                       |
| `volumeSnapshotClassLabels`      | Labels to add to the volumesnapshotclass                                                    | {}                       |
| `volumeSnapshotClassRetention`   | Retention policy for the volumesnapshotclass (Delete, Retain)                               | `Retain`                 |
| `createPrismCentralSecret`       | Create secret for PC account (if false use existing)                                        |  `true`                        |
| `prismCentralEndPoint`           | Prism Central (PC) cluster Virtual IP Address or fully qualified domain name (FQDN)         |                          |
| `pcUsername`                     | Username of a Prism Central (PC) cluster admin (if created)                                 |                          |
| `pcPassword`                     | Password for the Prism Central (PC) cluster admin (if created)                              |                          |
| `pcSecretName`                   | Secret name that stores Prism Central (PC) cluster credentials                              |                          |
| `createSecret`                   | Create secret for PE account (if false use existing)                                        | `true`                  |
| `prismEndPoint`                  | Prism Element (PE) cluster Virtual IP Address or fully qualified domain name (FQDN)         |                          |
| `username`                       | Username of a Prism Element (PE) cluster admin (if created)                                 |                          |
| `password`                       | Password for the Prism Element (PE) cluster admin (if created)                              |                          |
| `secretName`                     | Secret name that stores Prism Element (PE) cluster credentials                              | `ntnx-secret`            |
| `filesKey.endpoint`              | FileServer FQDN or FileServer IP (used for snapshot feature)                                |                          |
| `filesKey.username`              | FileServer REST API Username (used for snapshot feature)                                    |                          |
| `filesKey.password`              | FileServer REST API Password (used for snapshot feature)                                    |
| `ntnxInitConfigMap.associateCategoriesToVolume`          | set it to true if categories should be associated to the volume, When using PE as the management plane, associateCategoriesToVolume won't have any effect. | `true`    |                          |
| `ntnxInitConfigMap.usePC`        | set it to true if CSI should be deployed in PC mode, set it to false if CSI should be deployed in PE mode | `true`       |
| `kubeletDir`                     | allows overriding the host location of kubelet's internal state                             | `/var/lib/kubelet`       |
| `nodeSelector`                   | Add nodeSelector to all pods                                                                | `{}`                     |
| `tolerations`                    | Add tolerations to all pods                                                                 | `[]`                     |
| `imagePullPolicy`                | Specify imagePullPolicy for all pods                                                        | `IfNotPresent`           |
| `maxVolumesPerNode`                | maximum volumes allowed per node                                                        | `64`           |
| `controller.replicas`            | Number of Controllers replicas to deploy.                                                   | `2`                      |
| `controller.nodeSelector`        | Add nodeSelector to provisioner pod                                                         | `{}`                     |
| `controller.tolerations`         | Add tolerations to provisioner pod                                                          | `[]`                     |
| `node.nodeSelector`              | Add nodeSelector to node pods                                                               | `{}`                     |
| `node.tolerations`               | Add tolerations to node pods                                                                | `[]`                     |
| `servicemonitor.enabled`         | Create ServiceMonitor to scrape CSI  metrics                                                | `false`                  |
| `servicemonitor.labels`          | Labels to add to the ServiceMonitor (for match the Prometheus serviceMonitorSelector logic) | `k8s-app: csi-driver`    |
| `kubernetesClusterDeploymentType`          | Takes values in ["non-bare-metal", "bare-metal"] depending on the type of deployment | `non-bare-metal`    |
| `fsGroupPolicy` | Controls how Kubernetes manages file system group ownership for volumes provisioned by the CSI driver.<br/><br/>**Options:**<br/>- `"File"`<br/>- `"ReadWriteOnceWithFSType"`<br/>- `"None"`<br/><br/>**Default:**<br/>- `"ReadWriteOnceWithFSType"` (if not set in `values.yaml`)<br/>- `"File"` (if set in `values.yaml` for CSI version 3.5.0 onwards)<br/><br/>**Important:**<br/>- This field is immutable after the `CSIDriver` resource is created.<br/>- For upgrades, the existing value is retained and cannot be changed by updating the Helm value.<br/>- To change `fsGroupPolicy`, you must delete the `CSIDriver` resource and modify the helm chart by adding desired fsGroupPolicy value and reinstall the csi driver. | `"ReadWriteOnceWithFSType"`<br/>(if not set in values.yaml)<br/>`"File"` (if set in values.yaml for CSI version 3.5.0 onwards) |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install` or provide a a file whit `-f value.yaml`.

### Configuration examples:

Install the driver in the `ntnx-system` namespace:

```console
helm install nutanix-storage nutanix/nutanix-csi-storage -n ntnx-system --create-namespace
```

Install the driver in the `ntnx-system` namespace and create a volume storageclass:

```console
helm install nutanix-storage nutanix/nutanix-csi-storage -n ntnx-system --create-namespace --set prismEndPoint=X.X.X.X --set username=admin --set password=xxxxxxxxx
```
In the above command  `prismEndpoint` refers to the Prism Element cluster virtual ip address where storage will be consumed. 


Install the driver in the `ntnx-system` namespace, create a volume and a dynamic file storageclass and set the volume storage class as default:

```console
helm install nutanix-storage nutanix/nutanix-csi-storage -n ntnx-system --create-namespace --set prismEndPoint=X.X.X.X --set username=admin --set password=xxxxxxxxx
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
