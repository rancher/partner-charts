# CSI Driver for Dell PowerMax Helm chart

The [CSI Driver for Dell PowerMax](https://github.com/dell/csi-powermax) is part of the CSM (Container Storage Modules) open-source suite of Kubernetes storage enablers for Dell EMC products. CSI Driver for PowerMax is a Container Storage Interface (CSI) driver that provides support for provisioning persistent storage using Dell EMC PowerMax storage array.

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
- Install the Volume Snapshot CRDs by referring to [this](https://dell.github.io/csm-docs/docs/csidriver/installation/helm/powermax/#optional-volume-snapshot-requirements) page.

> Refer [this](https://dell.github.io/csm-docs/docs/csidriver/installation/helm/powermax/#prerequisites) for setting up the prerequisites.

## Optional Features
- [Volume Snapshot](https://dell.github.io/csm-docs/docs/csidriver/installation/helm/powermax/#optional-volume-snapshot-requirements)
- [Volume Health Monitoring](https://dell.github.io/csm-docs/docs/csidriver/installation/helm/powermax/#volume-health-monitoring)
- [Replication](https://dell.github.io/csm-docs/docs/csidriver/installation/helm/powermax/#optional-replication-feature-requirements)

## Install the Driver
**Steps**
1. Create a namespace where you want to install the driver (e.g. "csi-powermax"). You can choose any name for the namespace, but make sure to align to the same namespace during the whole installation.
2. Create a secret named "powermax-creds" in the namespace created above. Sample [secret.yaml](https://github.com/dell/csi-powermax/blob/main/samples/secret/secret.yaml).
    >Secret must be of type opaque.
3. Install Cert Manager
    >Create issuer for Cert Manager
    >Create TLS namespace in powermax namespace
4. Create storage classes using ones from [samples](https://github.com/dell/csi-powermax/tree/main/samples/storageclass) folder as an example.
    > If you do not specify `arrayID` parameter in the storage class then the array that was specified as the default would be used for provisioning volumes.
5. Install the chart with the name "powermax". The value.yaml file used during installation can be found [here](https://github.com/dell/csi-powermax/blob/main/helm/csi-powermax/values.yaml)

The table [here](https://dell.github.io/csm-docs/docs/csidriver/installation/helm/powermax/#:~:text=powermax%2Dsettings.yaml-,Parameter,Default,-global) lists the configurable parameters of the chart and their default values. 

*NOTE:* 
- For detailed instructions on how to run the install scripts, see the readme document in the dell-csi-helm-installer folder.
- There are a set of samples provided here to help you configure the driver with reverse proxy
- This script also runs the verify.sh script in the same directory. You will be prompted to enter the credentials for each of the Kubernetes nodes. The verify.sh script needs the credentials to check if the iSCSI initiators have been configured on all nodes. You can also skip the verification step by specifying the --skip-verify-node option
- In order to enable authorization, there should be an authorization proxy server already installed.
- PowerMax Array username must have role as StorageAdmin to be able to perform CRUD operations.
- User should provide all boolean values with double-quotes. This applies only for values.yaml. Example: “true”/“false”.
- controllerCount parameter value should be <= number of nodes in the kubernetes cluster else install script fails.
- Endpoint should not have any special character at the end apart from port number

## Support

The CSI Driver for Dell PowerMax is fully supported by DELL.

For all your support needs or to follow the latest ongoing discussions and updates, join our Slack group. Click [Here](http://del.ly/Slack_request) to request your invite.

You can also interact with us on [GitHub](https://github.com/dell/csm) by creating a [GitHub Issue](https://github.com/dell/csm/issues).

## Contributing

We value all feedback and contributions. If you find any issues or want to contribute, please feel free to open an issue or file a PR. More details in [Contribution Guidelines](https://dell.github.io/csm-docs/docs/references/contributionguidelines/).

## License

This is open source software licensed using the Apache License 2.0. Please see [LICENSE](https://github.com/dell/csi-powermax/blob/main/licenses/Apache.txt) for details.
