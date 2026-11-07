# CSI Driver for Dell PowerStore Helm chart

The [CSI Driver for Dell PowerStore](https://github.com/dell/csi-powerstore) is part of the CSM (Container Storage Modules) open-source suite of Kubernetes storage enablers for Dell EMC products. CSI Driver for PowerStore is a Container Storage Interface (CSI) driver that provides support for provisioning persistent storage using Dell EMC PowerStore storage array.

## Prerequisites

- Kubernetes version >= 1.23 (see [supported version](https://dell.github.io/csm-docs/docs/csidriver/#features-and-capabilities))
- Helm 3
- If you plan to use either the Fibre Channel or iSCSI or NVMe/TCP or NVMe/FC protocol, refer to either _Fibre Channel requirements_ or _Set up the iSCSI Initiator_ or _Set up the NVMe Initiator_ sections below. You can use NFS volumes without FC or iSCSI or NVMe/TCP or NVMe/FC configuration.
> You can use either the Fibre Channel or iSCSI or NVMe/TCP or NVMe/FC protocol, but you do not need all the four.

> If you want to use preconfigured iSCSI/FC hosts be sure to check that they are not part of any host group
- Linux native multipathing requirements
- Mount propagation is enabled on container runtime that is being used
- If using Snapshot feature, satisfy all Volume Snapshot requirements
- Nonsecure registries are defined in Docker or other container runtimes, for CSI drivers that are hosted in a non-secure location.
- You can access your cluster with kubectl and helm.
- Ensure that your nodes support mounting NFS volumes.
- Install the Volume Snapshot CRDs by referring to [this](https://dell.github.io/csm-docs/docs/csidriver/installation/helm/powerstore/#optional-volume-snapshot-requirements) page.

> Refer [this](https://dell.github.io/csm-docs/docs/csidriver/installation/helm/powerstore/#prerequisites) for setting up the prerequisites.

## Optional Features
- [Volume Snapshot](https://dell.github.io/csm-docs/docs/csidriver/installation/helm/powerstore/#optional-volume-snapshot-requirements)
- [Volume Health Monitoring](https://dell.github.io/csm-docs/docs/csidriver/installation/helm/powerstore/#volume-health-monitoring)
- [Replication](https://dell.github.io/csm-docs/docs/csidriver/installation/helm/powerstore/#optional-replication-feature-requirements)

## Install the Driver
**Steps**
1. Create a namespace where you want to install the driver (e.g. "csi-powerstore"). You can choose any name for the namespace, but make sure to align to the same namespace during the whole installation.
2. Create a secret named "powerstore-config" in the namespace created above. Sample [secret.yaml](https://github.com/dell/csi-powerstore/blob/main/samples/secret/secret.yaml).
    >Secret must be of type opaque.
3. Create storage classes using ones from [samples](https://github.com/dell/csi-powerstore/tree/main/samples/storageclass) folder as an example.
    > If you do not specify `arrayID` parameter in the storage class then the array that was specified as the default would be used for provisioning volumes.
4. Install the chart with the name "powerstore". The value.yaml file used during installation can be found [here](https://github.com/dell/csi-powerstore/blob/main/helm/csi-powerstore/values.yaml)

The following table lists the configurable parameters of the chart and their default values.

| Parameter                           | Description                                                                                               | Required | Default                    |
|-------------------------------------|-----------------------------------------------------------------------------------------------------------|----------|----------------------------|
| logLevel                            | Defines CSI driver log level                                                                              | No       | "debug"                    |
| logFormat                           | Defines CSI driver log format                                                                             | No       | "JSON"                     |
| externalAccess                      | Defines additional entries for hostAccess of NFS volumes, single IP address and subnet are valid entries  | No       | " "                        |
| kubeletConfigDir                    | Defines kubelet config path for cluster                                                                   | Yes      | "/var/lib/kubelet"         |
| imagePullPolicy                     | Policy to determine if the image should be pulled prior to starting the container.                        | Yes      | "IfNotPresent"             |
| nfsAcls                             | Defines permissions - POSIX mode bits or NFSv4 ACLs, to be set on NFS target mount directory.             | No       | "0777"                     |
| connection.enableCHAP               | Defines whether the driver should use CHAP for iSCSI connections or not                                   | No       | False                      |
| controller.controllerCount          | Defines number of replicas of controller deployment                                                       | Yes      | 2                          |
| controller.volumeNamePrefix         | Defines the string added to each volume that the CSI driver creates                                       | No       | "csivol"                   |         
| controller.snapshot.enabled         | Allows to enable/disable snapshotter sidecar with driver installation for snapshot feature                | No       | "true"                     |
| controller.snapshot.snapNamePrefix  | Defines prefix to apply to the names of a created snapshots                                               | No       | "csisnap"                  |
| controller.resizer.enabled          | Allows to enable/disable resizer sidecar with driver installation for volume expansion feature            | No       | "true"                     |
| controller.healthMonitor.enabled    | Allows to enable/disable volume health monitor                                                            | No       | false                      |
| controller.healthMonitor.interval   | Interval of monitoring volume health condition                                                            | No       | 60s                        |
| controller.nodeSelector             | Defines what nodes would be selected for pods of controller deployment                                    | Yes      | " "                        |
| controller.tolerations              | Defines toleration that would be applied to controller deployment                                        | Yes      | " "                        |
| node.nodeNamePrefix                 | Defines the string added to each node that the CSI driver registers                                       | No       | "csi-node"                 |
| node.nodeIDPath                     | Defines a path to file with a unique identifier identifying the node in the Kubernetes cluster            | No       | "/etc/machine-id"          |
| node.healthMonitor.enabled          | Allows to enable/disable volume health monitor                                                            | No       | false                      |
| node.nodeSelector                   | Defines what nodes would be selected for pods of node daemonset                                           | Yes      | " "                        |
| node.tolerations                    | Defines toleration that would be applied to node daemonset                                               | Yes      | " "                        |
| fsGroupPolicy                       | Defines which FS Group policy mode to be used, Supported modes `None, File and ReadWriteOnceWithFSType`   | No       | "ReadWriteOnceWithFSType"  |
| controller.vgsnapshot.enabled       | To enable or disable the volume group snapshot feature                                                    | No       | "true"                     |
| images.driverRepository             | To use an image from custom repository                                                                    | No       | dockerhub                  |
| version                             | To use any driver version                                                                                 | No       | Latest driver version      |
| allowAutoRoundOffFilesystemSize     | Allows the controller to round off filesystem to 3Gi which is the minimum supported value                 | No       | false                      |
| storageCapacity.enabled             | Enable/Disable storage capacity tracking                                                                  | No       | true                       |
| storageCapacity.pollInterval        | Configure how often the driver checks for changed capacity                                                | No       | 5m                         |

*NOTE:* 
- By default, the driver scans available SCSI adapters and tries to register them with the storage array under the SCSI hostname using `node.nodeNamePrefix` and the ID read from the file pointed to by `node.nodeIDPath`. If an adapter is already registered with the storage under a different hostname, the adapter is not used by the driver.
- A hostname the driver uses for registration of adapters is in the form `<nodeNamePrefix>-<nodeID>-<nodeIP>`. By default, these are csi-node and the machine ID read from the file `/etc/machine-id`. 
- To customize the hostname, for example if you want to make them more user friendly, adjust nodeIDPath and nodeNamePrefix accordingly. For example, you can set `nodeNamePrefix` to `k8s` and `nodeIDPath` to `/etc/hostname` to produce names such as `k8s-worker1-192.168.1.2`.
- (Optional) Enable additional Mount Options - A user is able to specify additional mount options as needed for the driver. 
   - Mount options are specified in storageclass yaml under _mountOptions_. 
   - *WARNING*: Before utilizing mount options, you must first be fully aware of the potential impact and understand your environment's requirements for the specified option.

## Support

The CSI Driver for Dell PowerStore is fully supported by DELL.

For all your support needs or to follow the latest ongoing discussions and updates, join our Slack group. Click [Here](http://del.ly/Slack_request) to request your invite.

You can also interact with us on [GitHub](https://github.com/dell/csm) by creating a [GitHub Issue](https://github.com/dell/csm/issues).

## Contributing

We value all feedback and contributions. If you find any issues or want to contribute, please feel free to open an issue or file a PR. More details in [Contribution Guidelines](https://dell.github.io/csm-docs/docs/references/contributionguidelines/).

## License

This is open source software licensed using the Apache License 2.0. Please see [LICENSE](https://github.com/dell/csi-powerstore/blob/main/licenses/Apache.txt) for details.
