# NetScaler IPAM controller.

NetScaler provides a controller called IPAM controller for IP address management. When you create a service of type LoadBalancer, you can use the [NetScaler IPAM controller](https://docs.netscaler.com/en-us/citrix-k8s-ingress-controller/network/type-loadbalancer/) to automatically allocate an IP address to the service. Once the IPAM controller is deployed, it allocates IP address to services of type LoadBalancer from predefined IP address ranges. The [NetScaler ingress controller](https://docs.netscaler.com/en-us/citrix-k8s-ingress-controller/) configures the IP address allocated to the service as virtual IP (VIP) in NetScaler MPX or VPX.

## TL;DR;

   ```
   helm repo add netscaler https://netscaler.github.io/netscaler-helm-charts/

   helm install ipam netscaler/netscaler-ipam-controller --set vipRange=<IP-address-range>
   ```

## Introduction
This Helm chart deploys a NetScaler IPAM controller in the [Kubernetes](https://kubernetes.io/) or in the [Openshift](https://www.openshift.com) cluster using the [Helm](https://helm.sh/) package manager.

IPAM controller has the ability to either allocate the same IP for all ingresses (default behaviour) or it can allocate unique IP until the IP range is exhausted. This behaviour can be controlled using the `reuseIngressVip` parameter of the helm chart.
Please note that for services of type LoadBalancer, distinct IPs are allocated from the specified IP range until all available addresses are exhausted.

### Prerequisites

-  The [Kubernetes](https://kubernetes.io/) version is 1.24 or later if using Kubernetes environment.
-  The [Openshift](https://www.openshift.com) version 4.8 or later if using OpenShift platform.
-  The [Helm](https://helm.sh/) version 3.x or later. You can follow instruction given [here](https://github.com/netscaler/netscaler-helm-charts/blob/master/Helm_Installation_version_3.md) to install the same.
-  For Infoblox integration, ensure that you create a user role in Infoblox with the following permissions:
   - Allocate and manage IP addresses.
   - Create, update, and delete host records.
   - Create, update, and delete extensible attributes.
   - Create, update, and delete Network Views.
- Create generic secret in Kubernetes for the Infoblox User:
  ```
  kubectl create secret generic infobloxsecret --from-literal=username=<Infoblox Username> --from-literal=password=<Infoblox Password> -n <namespace>
  ```

## Installing the Chart
Add the NetScaler IPAM Controller helm chart repository using command:

   ```
   helm repo add netscaler https://netscaler.github.io/netscaler-helm-charts/
   ```

   To install the chart with the release name ``` my-release```:

   ```
   helm install my-release netscaler/netscaler-ipam-controller --set vipRange=<IP-address-range>
   ```

> **Note:**
>
> By default the chart installs the recommended [RBAC](https://kubernetes.io/docs/admin/authorization/rbac/) roles and role bindings.

### Installed components

The following components are installed:

-  [NetScaler IPAM Controller](https://docs.netscaler.com/en-us/citrix-k8s-ingress-controller/network/type-loadbalancer/)

## Configuration
The following table lists the configurable parameters of the NetScaler CPX with NetScaler ingress controller as side car chart and their default values.

| Parameters | Mandatory or Optional | Default value | Description |
| ---------- | --------------------- | ------------- | ----------- |
| imageRegistry                   | Mandatory  |  `quay.io`               |  The NetScaler IPAM Controller image registry             |  
| imageRepository                 | Mandatory  |  `netscaler/netscaler-ipam-controller`              |   The NetScaler IPAM Controller image repository             | 
| imageTag                  | Mandatory  |  `2.1.2`               |  The NetScaler IPAM Controller image tag            |
| pullPolicy | Mandatory | `IfNotPresent` | The NetScaler IPAM Controller image pull policy. |
| vipRange | Mandatory | N/A | This variable allows you to define the IP address range. You can either define IP address range or an IP address range associated with a unique name. NetScaler IPAM controller assigns the IP address from this IP address range to the service of type LoadBalancer. |
| reuseIngressVip| Optional | True | This variable allows you to use same IP for all ingresses using the same vipRange. |
| cluster| Mandatory if  infoblox.enabled is true| N/A | This variable allows you to provide cluster name thatis used to identify the cluster in which the IPAM controller is deployed. |
| infoblox.enabled| Optional | false | Boolean value that allows you to enable/disable infoblox IPAM. |
| infoblox.gridHost| Mandatory if  infoblox.enabled is true| N/A | Infoblox grid host IP or FQDN. Should be reachable from Cluster. |
| infoblox.credentialSecret| Mandatory if  infoblox.enabled is true| N/A | Kubernetes Secret in the same namespace having infoblox username and password with desired access privileges as listed in prerequisites. |
| infoblox.httpTimeout| Optional | 10 | This variable allows you to provide infoblox client HTTP Timeout in seconds. |
| infoblox.maxRetries| Optional | 3 | This variable allows you to provide infoblox client max retries in case of failure. |
| infoblox.netView| Optional | default | This variable allows you to provide infoblox Network View. If the Network View is not present it will be created. |
| infoblox.vipRange| Mandatory if  infoblox.enabled is true | N/A | Infoblox IPAM VIP Range that will be managed by the controller. All IPs in this range will be managed in Infoblox by the controller and should not be conflicting for any other processes. IP range should be in CIDR format a.b.c.d/n. Example: "[{"infoblox-range": ["1.1.1.0/24"]}]" |
| serviceAccount.create | Mandatory | true | Create serviceAccount for NetScaler IPAM Controller |
| serviceAccount.tokenExpirationSeconds | Mandatory | 31536000 | Time in seconds when the token of serviceAccount get expired |
| serviceAccount.name | Optional | "" | Name of the ServiceAccount for the IPAM Controller. If you want to use a ServiceAccount that you have already created and manage yourself, specify its name here and set serviceAccount.create to false. |
| createClusterRoleAndBinding | Mandatory | true | If you want to use a ClusterRole and Cluster Role Binding that you have already created and manage yourself then set to false. Please make sure you have bound the serviceaccount with the cluster role properly.  |
| podAnnotations | Optional | N/A | Map of annotations to add to the pods. |
| affinity | Optional | N/A | Affinity labels for pod assignment. |
| nodeSelector.key | Optional | N/A | Node label key to be used for nodeSelector option in IPAM controller deployment. |
| nodeSelector.value | Optional | N/A | Node label value to be used for nodeSelector option in IPAM controller deployment. |
| tolerations | Optional | N/A | Specify the tolerations for the IPAM Controller deployment. |
Alternatively, you can define a YAML file with the values for the parameters and pass the values while installing the chart.
| resources | Optional | {} |	CPU/Memory resource requests/limits for NetScaler IPAM Controller container |
For example:
   ```
   helm install my-release netscaler/netscaler-ipam-controller -f values.yaml
   ```

> **Tip:**
>
> The [values.yaml](https://github.com/netscaler/netscaler-helm-charts/blob/master/netscaler-ipam-controller/values.yaml) contains the default values of the parameters.

## Uninstalling the Chart
To uninstall/delete the ```my-release``` deployment:
   ```
   helm delete my-release
   ```

## Related documentation

- [Service Type LoadBalancer Documentation](https://docs.netscaler.com/en-us/citrix-k8s-ingress-controller/network/type-loadbalancer/)
- [NetScaler ingress controller Documentation](https://docs.netscaler.com/en-us/citrix-k8s-ingress-controller/)
- [NetScaler ingress controller GitHub](https://github.com/netscaler/netscaler-k8s-ingress-controller)
