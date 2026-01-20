# NetScaler Kubernetes Gateway Controller.

[NetScaler](https://www.netscaler.com/) provides Kubernetes Gateway Controller and load balancing solution which globally monitors applications, collects, and shares metrics across different clusters, and provides intelligent load balancing decisions. It ensures better performance and reliability for your Kubernetes applications.

## TL;DR;

### For Kubernetes
   ```
   helm repo add netscaler https://netscaler.github.io/netscaler-helm-charts/

   helm install gateway-controller netscaler/netscaler-kubernetes-gateway-controller --set gatewayController.gatewayControllerName=citrix.com/nsgc-controller,license.accept=yes,gatewayController.entityPrefix=gwy
   ```

### For OpenShift

   ```
   helm repo add netscaler https://netscaler.github.io/netscaler-helm-charts/

   helm install gateway-controller netscaler/netscaler-kubernetes-gateway-controller --set gatewayController.gatewayControllerName=citrix.com/nsgc-controller,license.accept=yes,gatewayController.openshift=true,gatewayController.entityPrefix=gwy
   ```

> **Important:**
>
> The `license.accept` argument is mandatory. Ensure that you set the value as `yes` to accept the terms and conditions of the NetScaler license.

> **NOTE:**
>
> The CRDs supported by NetScaler will be installed automatically with the installation of the Helm Charts if CRDs are not already available in the cluster.

## Introduction
This Helm chart deploys NetScaler Kubernetes Gateway Controller in the [Kubernetes](https://kubernetes.io) or in the [Openshift](https://www.openshift.com) cluster using [Helm](https://helm.sh) package manager.

### Prerequisites

-  The [Kubernetes](https://kubernetes.io/) version 1.24 or later if using Kubernetes environment.
-  The [Openshift](https://www.openshift.com) version 4.8 or later if using OpenShift platform.
-  The [Helm](https://helm.sh/) version 3.x or later. You can follow instruction given [here](https://github.com/netscaler/netscaler-helm-charts/blob/master/Helm_Installation_version_3.md) to install the same.

-  The user name and password of the NetScaler VPX or MPX appliance. The NetScaler appliance needs to have system user account (non-default) with certain privileges so that NetScaler Kubernetes Gateway Controller can configure the NetScaler VPX or MPX appliance. For instructions to create the system user account on NetScaler, see [Create System User Account for NSIC in NetScaler](#create-system-user-account-for-nsic-in-netscaler).

    You can pass user name and password using Kubernetes secrets. Create a Kubernetes secret for the user name and password using the following command:

    ```
       kubectl create secret generic nslogin --from-literal=username='nsic' --from-literal=password='mypassword'
    ```
    - The secrets with credentials need to be created for all the NetScaler Nodes.

## Installing the Chart
Add the NetScaler Kubernetes Gateway Controller helm chart repository using command:

```
   helm repo add netscaler https://netscaler.github.io/netscaler-helm-charts/
```

### For Kubernetes:
#### 1. NetScaler Kubernetes Gateway Controller
To install the chart with the release name, `my-release`, use the following command:
   ```
   helm install my-release netscaler/netscaler-kubernetes-gateway-controller --set gatewayController.gatewayControllerName=citrix.com/nsgc-controller,license.accept=yes,gatewayController.entityPrefix=gwy
   ```

> **Note:**
>
> By default, the chart installs the recommended [RBAC](https://kubernetes.io/docs/admin/authorization/rbac/) roles and role bindings.

The command deploys NetScaler Kubernetes Gateway Controller on Kubernetes cluster with the default configuration. The [configuration](#configuration) section lists the mandatory and optional parameters that you can configure during installation.

### For Openshift:
#### 1. NetScaler Kubernetes Gateway Controller
Add the service account named "mcingress-k8s-role" to the privileged Security Context Constraints of OpenShift:

   ```
   oc adm policy add-scc-to-user privileged system:serviceaccount:<namespace>:mcingress-k8s-role
   ```

To install the chart with the release name, `my-release`, use the following command:
   ```
   helm install my-release netscaler/netscaler-kubernetes-gateway-controller --set gatewayController.gatewayControllerName=citrix.com/nsgc-controller,license.accept=yes,gatewayController.openshift=true,gatewayController.entityPrefix=gwy
   ```

The command deploys NetScaler Kubernetes Gateway Controller on your Openshift cluster in the default configuration. The [configuration](#configuration) section lists the mandatory and optional parameters that you can configure during installation.

### Installed components

The following components are installed:

-  NetScaler Kubernetes Gateway Controller

## CRDs configuration

Kubernetes Gateway CRDs are expected to be installed, its prerequisite. Refer [Install Kubernetes Gateway CRD](https://gateway-api.sigs.k8s.io/guides/#install-standard-channel)

Netscaler CRDs will be installed when we install NetScaler Kubernetes Gateway controller via Helm automatically if CRDs are not installed in cluster already. If you wish to skip the CRD installation step, you can pass the --skip-crds flag. For more information about this option in Helm please see [this](https://helm.sh/docs/chart_best_practices/custom_resource_definitions/).

### Resource Quotas
There are various use-cases when resource quotas are configured on the Kubernetes cluster. If quota is enabled in a namespace for compute resources like CPU and memory, users must specify requests or limits for those values; otherwise, the quota system may reject pod creation. The resource quotas for the Gateway Controller containers can be provided explicitly in the helm chart.

To set requests and limits for the Gateway Controller container, use the variables `resources.requests` and `resources.limits` respectively.

Below is an example of the helm command that configures
- For Gateway Controller container:
```
  CPU request for 500 milli CPUs
  CPU limit at 1000m
  Memory request for 512M
  Memory limit at 1000M
```
```
helm install my-release netscaler/netscaler-kubernetes-gateway-controller --set gatewayController.gatewayControllerName=citrix.com/nsgc-controller,license.accept=yes --set resources.requests.cpu=500m,resources.requests.memory=512Mi --set resources.limits.cpu=1000m,resources.limits.memory=1000Mi,gatewayController.entityPrefix=gwy
```

### Configuration

The following table lists the mandatory and optional parameters that you can configure during installation:

| Parameters | Mandatory or Optional | Default value | Description |
| --------- | --------------------- | ------------- | ----------- |
| license.accept | Mandatory | no | Set `yes` to accept the NSIC end user license agreement. |
| imageRegistry                   | Optional  |  `quay.io`               |  The NetScaler Kubernetes Gateway Controller image registry             |  
| imageRepository                 | Optional  |  `netscaler/netscaler-k8s-ingress-controller`              |   The NetScaler ingress controller image repository             |
| imageTag                  | Optional  |  `3.4.4`               |   The NetScaler Kubernetes Gateway Controller image tag            |
| pullPolicy | Optional | Always | The NSIC image pull policy. |
| imagePullSecrets | Optional | N/A | Provide list of Kubernetes secrets to be used for pulling the images from a private Docker registry or repository. For more information on how to create this secret please see [Pull an Image from a Private Registry](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/). |
| nameOverride | Optional | N/A | String to partially override deployment fullname template with a string (will prepend the release name) |
| fullNameOverride | Optional | N/A | String to fully override deployment fullname template with a string |
| podAnnotations | Optional | N/A | Map of annotations to add to the pods. |
| nodeSelector.key | Optional | N/A | Node label key to be used for nodeSelector option in NSIC deployment. |
| nodeSelector.value | Optional | N/A | Node label value to be used for nodeSelector option in NSIC deployment. |
| affinity | Optional | N/A | Affinity labels for pod assignment. |
| tolerations | Optional | N/A | Specify the tolerations for the NSICC deployment. |
| netscaler.nsIP | Optional | N/A | The IP address of the NetScaler device. For details, see [Prerequisites](#prerequistes). |
| netscaler.nsPort | Optional | 443 | The port used by NSIC to communicate with NetScaler. You can use port 80 for HTTP. |
| netscaler.nsProtocol | Optional | HTTPS | The protocol used by NSIC to communicate with NetScaler. You can also use HTTP on port 80. |
| netscaler.nitroReadTimeout | Optional | 20 | The nitro Read timeout in seconds, defaults to 20 |
| netscaler.adcCredentialSecret | Mandatory | N/A | The Kubernetes secret containing login credentials for the NetScaler VPX or MPX. For information on how to create the secret keys, see [Prerequisites](#prerequistes). |
| netscaler.nsSNIPS | Optional | N/A | The list of subnet IPAddresses on the NetScaler device, which will be used to create PBR Routes instead of Static Routes [PBR support](https://github.com/netscaler/netscaler-k8s-ingress-controller/tree/master/docs/how-to/pbr.md) |
| netscaler.nsVIP | Optional | N/A | The Virtual IP address on the NetScaler device. |
| netscaler.netscalernsValidateCert | Optional | false | Set to true if NetScaler Certificate validation is required. Please refer [this](https://docs.netscaler.com/en-us/netscaler-k8s-ingress-controller/certificate-management/adc-certificate-validation) for more info.  |
| netscaler.podIPsforServiceGroupMembers | Optional | False |  By default NetScaler Ingress Controller will add NodeIP and NodePort as service group members while configuring type LoadBalancer Services and NodePort services. This variable if set to `True` will change the behaviour to add pod IP and Pod port instead of nodeIP and nodePort. Users can set this to `True` if there is a route between NetScaler and K8s clusters internal pods either using feature-node-watch argument or using NetScaler Node Controller. |
| netscaler.nsCertSecret | Optional | "" | Kubernetes Secret created for the CA certificate of NetScaler. Please refer [this](https://docs.netscaler.com/en-us/netscaler-k8s-ingress-controller/certificate-management/adc-certificate-validation) for more info.  |
| netscaler.hostAlias.ip | Optional | "" | Management IP of NetScaler. Please refer [this](https://docs.netscaler.com/en-us/netscaler-k8s-ingress-controller/certificate-management/adc-certificate-validation) for more info.  |
| netscaler.hostAlias.hostName | Optional | "" | HostName set on the NetScaler. Please refer [this](https://docs.netscaler.com/en-us/netscaler-k8s-ingress-controller/certificate-management/adc-certificate-validation) for more info.  |
| netscaler.secretStore.enabled | Optional | False | Set to "True" for deploying other Secret Provider classes  |
| netscaler.secretStore.username | Optional | N/A | if `secretStore.enabled`, `username` of NetScaler will be fetched from the Secret Provider  |
| netscaler.secretStore.password | Optional | N/A | if `secretStore.enabled`, `password` of NetScaler will be fetched from the Secret Provider  |
| netscaler.certBundle | Optional | false |When set to true this will bind certificate key bundle in frontend vservers. Please refer [this](https://docs.netscaler.com/en-us/citrix-adc/current-release/ssl/ssl-certificates/install-link-and-update-certificates.html#support-for-ssl-certificate-key-bundle).
| gatewayController.logLevel | Optional | INFO | The log level to control the logs generated by NSIC. The supported log levels are: CRITICAL, ERROR, WARNING, INFO, DEBUG, TRACE, and NONE. For more information, see [Logging](https://github.com/netscaler/netscaler-kubernetes-gateway-controller/blob/master/docs/configure/log-levels.md).|
| gatewayController.disableAPIServerCertVerify | Optional | False | Set this parameter to True for disabling API Server certificate verification. |
| gatewayController.kubernetesURL | Optional | N/A | The kube-apiserver URL that NSIC uses to register the events. If the value is not specified, NSIC uses the [internal kube-apiserver IP address](https://kubernetes.io/docs/tasks/access-application-cluster/access-cluster/#accessing-the-api-from-a-pod). |
| gatewayController.entityPrefix | Mandatory | N/A | The prefix for the resources on the NetScaler VPX/MPX. |
| gatewayController.openshift | Optional | false | Set this argument if OpenShift environment is being used. |
| gatewayController.gatewayControllerName | Mandatory | N/A | Name of Gateway Controller . |
| gatewayController.serviceAccount.create | Mandatory | true | Create serviceAccount for NetScaler Kubernetes Gateway Controller |
| gatewayController.serviceAccount.tokenExpirationSeconds | Mandatory | 31536000 | Time in seconds when the token of serviceAccount gets expired |
| gatewayController.serviceAccount.name | Optional | "" | Name of the ServiceAccount for the Gateway Controller. If you want to use a ServiceAccount that you have already created and manage yourself, specify its name here and set gatewayController.serviceAccount.create to false. |
| gatewayController.createClusterRoleAndBinding | Mandatory | true | If you want to use a ClusterRole and Cluster Role Binding that you have already created and manage yourself then set to false. Please make sure you have bound the serviceaccount with the cluster role properly.  |
| gatewayController.enableLivenessProbe| Optional | True | Enable liveness probe settings for NetScaler Ingress Controller |
| gatewayController.enableReadinessProbe| Optional | True | Enable Readineess probe settings for NetScaler Ingress Controller |
| gatewayController.jsonLog | Optional | false | Set this argument to true if log messages are required in JSON format | 
| gatewayController.kubernetesURL | Optional | N/A | The kube-apiserver url that NSIC uses to register the events. If the value is not specified, NSIC uses the [internal kube-apiserver IP address](https://kubernetes.io/docs/tasks/access-application-cluster/access-cluster/#accessing-the-api-from-a-pod). |
| gatewayController.livenessProbe | Optional | N/A | Set livenessProbe settings for NSIC |
| gatewayController.readinessProbe | Optional | N/A | Set readinessProbe settings|
| gatewayController.nodeWatch | Optional | false | Use the argument if you want to automatically configure network route from the NetScaler VPX or MPX to the pods in the Kubernetes cluster. For more information, see [Automatically configure route on the NetScaler instance](https://docs.netscaler.com/en-us/netscaler-k8s-ingress-controller/network/staticrouting/#automatically-configure-route-on-the-netscaler-adc-instance). |
| gatewayController.nsncPbr | Optional | False | Use this argument to inform NetScaler kubernetes gateway Controller about configuring Policy Based Routes(PBR) on the NetScaler. For more information, see [NSNC-PBR-SUPPORT](https://github.com/netscaler/netscaler-k8s-ingress-controller/blob/master/docs/network/pbr.md#configure-pbr-using-the-netscaler-node-controller) |
| gatewayController.optimizeEndpointBinding | Optional | false | To enable/disable binding of backend endpoints to servicegroup in a single API-call. Recommended when endpoints(pods) per application are large in number. Applicable only for NetScaler Version >=13.0-45.7  |
| gatewayController.pullPolicy | Mandatory | IfNotPresent | The NSIC image pull policy. |
| gatewayController.extraVolumeMounts  |  Optional |  [] |  Specify the Additional VolumeMounts to be mounted in Exporter container. Specify the volumes in `extraVolumes`  |
| gatewayController.extraVolumes  |  Optional |  [] |  Specify the Additional Volumes for additional volumeMounts  |
| gatewayController.eresources | Optional | {} |	CPU/Memory resource requests/limits for NetScaler Ingress Controller container |

Alternatively, you can define a YAML file with the values for the parameters and pass the values while installing the chart.

For example:
   ```
   helm install my-release netscaler/netscaler-kubernetes-gateway-controller -f values.yaml
   ```

Your values.yaml should look something like this:
   ```
   license:
   accept: yes

   gatewayControllerName: "citrix.com/nsgc-controller"

   entityPrefix: "k8sgwy"
   ```

## Uninstalling the Chart
To uninstall/delete the ```my-release``` deployment:

   ```
   helm delete my-release
   ```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Related documentation

- [NetScaler Kubernetes Gateway Controller Documentation](https://docs.netscaler.com/en-us/netscaler-kubernetes-gateway-controller/gateway/gateway.html)
