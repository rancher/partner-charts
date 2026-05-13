The [CSI Driver for Unity XT](https://github.com/dell/csi-unity) is part of the CSM (Container Storage Modules) open-source suite of Kubernetes storage enablers for Dell products. CSI Driver for Unity XT is a Container Storage Interface (CSI) driver that provides support for provisioning persistent storage using Dell Unity XT storage array.


## Pre-Requisites
- Install Kubernetes (see [supported versions](https://dell.github.io/csm-docs/docs/csidriver/#features-and-capabilities))
- Install Helm v3 (follow [steps](https://dell.github.io/csm-docs/docs/csidriver/installation/helm/unity/#install-helm-30))
- Install sshpass
- Configure the pre-installation steps according to the protocols you are using: 
    - To use FC protocol, the host must be zoned with Unity XT array and Multipath needs to be configured
    - To use iSCSI protocol, iSCSI initiator utils packages need to be installed and Multipath needs to be configured
    - To use NFS protocol, NFS utility packages needs to be installed
- Enable mount propagation on container runtime that is being used
- In order to use the Kubernetes Volume Snapshot feature, ensure to deploy `Volume Snapshot CRDs` and `Volume Snapshot Controller` in the kubernetes cluster as a pre-requisite. Refer [here](https://dell.github.io/csm-docs/docs/csidriver/installation/helm/unity/#installation-example) for installation example of CRD's and default snapshot controller

For more information, refer to the [documentation](https://dell.github.io/csm-docs/docs/csidriver/installation/helm/unity/#prerequisites)

## Install CSI Driver for Unity XT

1. Clone the [git repository](https://github.com/dell/csi-unity) that has the helm charts and install scripts
2. Create a namespace called `unity`
3. Collect information from the Unity XT Systems like Unique ArrayId, IP address, username, and password. Using the information, prepare `secrets.yaml`. Create the secrets. Samples available [here](https://github.com/dell/csi-unity/blob/main/samples/secret/secret.yaml)
>NOTE: For certificate validation of Unisphere REST API calls refer [here](https://dell.github.io/csm-docs/docs/csidriver/installation/helm/unity/#certificate-validation-for-unisphere-rest-api-calls). Otherwise, create an empty secret. Samples available [here](https://github.com/dell/csi-unity/tree/main/samples/secret/emptysecret.yaml)
4. Copy the `helm/csi-unity/values.yaml` into a file named `myvalues.yaml` in the same directory of csi-install.sh, to customize settings for installation
5. Edit `myvalues.yaml` to set the following parameters for your installation:
   
    The following table lists the primary configurable parameters of the Unity XT driver chart and their default values. More detailed information can be found in the [`values.yaml`](https://github.com/dell/csi-unity/blob/master/helm/csi-unity/values.yaml) file in this repository.
    
    | Parameter | Description | Required | Default |
    | --------- | ----------- | -------- |-------- |
    | version | helm version | true | - |
    | logLevel | LogLevel is used to set the logging level of the driver | true | info |
    | allowRWOMultiPodAccess | Flag to enable multiple pods to use the same PVC on the same node with RWO access mode. | false | false |
    | kubeletConfigDir | Specify kubelet config dir path | Yes | /var/lib/kubelet |
    | syncNodeInfoInterval | Time interval to add node info to the array. Default 15 minutes. The minimum value should be 1 minute. | false | 15 |
    | maxUnityVolumesPerNode | Maximum number of volumes that controller can publish to the node. | false | 0 |
    | certSecretCount | Represents the number of certificate secrets, which the user is going to create for SSL authentication. (unity-cert-0..unity-cert-n). The minimum value should be 1. | false | 1 |
    | imagePullPolicy |  The default pull policy is IfNotPresent which causes the Kubelet to skip pulling an image if it already exists. | Yes | IfNotPresent |
    | podmon.enabled | service to monitor failing jobs and notify | false | - |
    | podmon.image| pod man image name | false | - |
    | tenantName | Tenant name added while adding host entry to the array | No |  |
    | fsGroupPolicy | Defines which FS Group policy mode to be used, Supported modes `None, File and ReadWriteOnceWithFSType` | No | "ReadWriteOnceWithFSType" |
    | **controller** | Allows configuration of the controller-specific parameters.| - | - |
    | controllerCount | Defines the number of csi-unity controller pods to deploy to the Kubernetes release| Yes | 2 |
    | volumeNamePrefix | Defines a string prefix for the names of PersistentVolumes created | Yes | "k8s" |
    | snapshot.enabled | Enable/Disable volume snapshot feature | Yes | true |
    | snapshot.snapNamePrefix | Defines a string prefix for the names of the Snapshots created | Yes | "snapshot" |
    | resizer.enabled | Enable/Disable volume expansion feature | Yes | true |
    | nodeSelector | Define node selection constraints for pods of controller deployment | No | |
    | tolerations | Define tolerations for the controller deployment, if required | No | |
    | healthMonitor.enabled | Enable/Disable deployment of external health monitor sidecar for controller side volume health monitoring. | No | false |
    | healthMonitor.interval | Interval of monitoring volume health condition. Allowed values: Number followed by unit (s,m,h) | No | 60s |
    | ***node*** | Allows configuration of the node-specific parameters.| - | - |
    | dnsPolicy | Define the DNS Policy of the Node service | Yes | ClusterFirstWithHostNet |
    | healthMonitor.enabled | Enable/Disable health monitor of CSI volumes- volume usage, volume condition | No | false |
    | nodeSelector | Define node selection constraints for pods of node deployment | No | |
    | tolerations | Define tolerations for the node deployment, if required | No | |


    **Note**: 
    
      * User should provide all boolean values with double-quotes. This applies only for `myvalues.yaml`. Example: "true"/"false"  
      * controllerCount parameter value should be <= number of nodes in the kubernetes cluster else install script fails

6. Run the `./csi-install.sh --namespace unity --values ./myvalues.yaml` command to proceed with the installation using bash script or you can also install the driver using standalone helm chart by running helm install command `helm install --dry-run --values <myvalues.yaml-location> --namespace <namespace> <name-of-secret> <helmPath>` <br/>
   `<namespace>` - namespace of the driver installation  <br/>
   `<name of secret>` - unity in case of unity-creds and unity-certs-0 secrets <br/>
   `<helmPath>` - Path of the helm directory <br/>

7. Create storage classes from [samples](https://github.com/dell/csi-unity/tree/main/samples/storageclass)
    
    **Note**:

    * At least one storage class is required for one array
    * In case you want to make updates to an existing storage class, ensure to delete it using the `kubectl delete storageclass <storageclass-name>` command. Deleting a storage class has no impact on a running Pod with mounted PVCs. You cannot provision new PVCs until at least one storage class is newly created

For full-length documentation, please visit Container Storage Modules documentation [page](https://dell.github.io/csm-docs/).

## Support

The CSI Driver for Dell Unity XT is fully supported by DELL.

For all your support needs or to follow the latest ongoing discussions and updates, join our Slack group. Click [Here](http://del.ly/Slack_request) to request your invite.

You can also interact with us on [GitHub](https://github.com/dell/csm) by creating a [GitHub Issue](https://github.com/dell/csm/issues).

## Contributing

We value all feedback and contributions. If you find any issues or want to contribute, please feel free to open an issue or file a PR. More details in [Contribution Guidelines](https://dell.github.io/csm-docs/docs/references/contributionguidelines/).

## License

This is open source software licensed using the Apache License 2.0. Please see [LICENSE](https://github.com/dell/csi-powerstore/blob/main/licenses/Apache.txt) for details.

