# NetScaler CPX with NetScaler Gateway Controller running as sidecar.


## TL;DR;

### For Kubernetes
   ```
   helm repo add netscaler https://netscaler.github.io/netscaler-helm-charts/

   helm install netscaler-cpx-with-gateway-controller netscaler/netscaler-cpx-with-gateway-controller --set license.accept=yes,gatewayController.gatewayControllerName=<controllerName>
   ```

### For OpenShift

   ```
   helm repo add netscaler https://netscaler.github.io/netscaler-helm-charts/

   helm install netscaler-cpx-with-gateway-controller netscaler/netscaler-cpx-with-gateway-controller --set license.accept=yes,gatewayController.openshift=true,gatewayController.gatewayControllerName=<controllerName>
   ```

> **Important:**
>
> The "license.accept" is a mandatory argument and should be set to "yes" to accept the terms of the NetScaler license.

## Introduction
This Helm chart deploys a NetScaler CPX with NetScaler gateway controller as a sidecar in the [Kubernetes](https://kubernetes.io/) or in the [Openshift](https://www.openshift.com) cluster using the [Helm](https://helm.sh/) package manager.

### Prerequisites

-  The [Kubernetes](https://kubernetes.io/) version should be 1.24 and above if using Kubernetes environment.
-  The [Openshift](https://www.openshift.com) version 4.8 or later if using OpenShift platform.
-  The [Helm](https://helm.sh/) version 3.x or later. You can follow instruction given [here](https://github.com/netscaler/netscaler-helm-charts/blob/master/Helm_Installation_version_3.md) to install the same.
-  You have installed [Prometheus Operator](https://github.com/coreos/prometheus-operator), if you want to view the metrics of the NetScaler CPX collected by the [metrics exporter](https://github.com/netscaler/netscaler-k8s-gateway-controller/tree/master/metrics-visualizer#visualization-of-metrics).
- Registration of NetScaler CPX in ADM: You may want to register your CPX in ADM for licensing or to obtain [servicegraph](https://docs.netscaler.com/en-us/citrix-application-delivery-management-service/application-analytics-and-management/service-graph.html). For this you will have to create a Kubernetes secret using ADM credentials and provide it while install the chart. Create a Kubernetes secret for the user name and password using the following command:

  ```
  kubectl create secret generic admlogin --from-literal=username=<adm-username> --from-literal=password=<adm-password>
  ```

## Installing the Chart
Add the NetScaler Gateway Controller helm chart repository using command:

   ```
   helm repo add netscaler https://netscaler.github.io/netscaler-helm-charts/
   ```

### For Kubernetes:
#### 1. NetScaler CPX with NetScaler Gateway Controller running as side car.
To install the chart with the release name ``` my-release```:

   ```
   helm install my-release netscaler/netscaler-cpx-with-gateway-controller --set license.accept=yes,gatewayController.gatewayControllerName=<controllerName>
   ```

> **Note:**
>
> By default the chart installs the recommended [RBAC](https://kubernetes.io/docs/admin/authorization/rbac/) roles and role bindings.

The command deploys NetScaler CPX with NetScaler gateway controller as a sidecar on the Kubernetes cluster with the default configuration. The [configuration](#configuration) section lists the mandatory and optional parameters that you can configure during installation.


### For OpenShift:
Add the name of the service account created when the chart is deployed to the privileged Security Context Constraints of OpenShift:

   ```
   oc adm policy add-scc-to-user privileged system:serviceaccount:<namespace>:<service-account-name>
   ```

#### 1. NetScaler CPX with NetScaler Gateway Controller running as side car.
To install the chart with the release name, `my-release`, use the following command:
   ```
   helm install my-release netscaler/netscaler-cpx-with-gateway-controller --set license.accept=yes,gatewayController.openshift=true,gatewayController.gatewayControllerName=<controllerName>
   ```

### Installed components

The following components are installed:

-  [NetScaler CPX](https://docs.netscaler.com/en-us/citrix-adc-cpx/current-release/about)
-  [NetScaler gateway controller](https://github.com/netscaler/netscaler-k8s-gateway-controller)

### NetScaler CPX Service Annotations:

The parameter serviceAnnotations can be used to annotate CPX service while installing NetScaler CPX using this helm chart. For example, if CPX is getting deployed in Azure and an Azure Internal Load Balancer is required before CPX then the annotation service.beta.kubernetes.io/azure-load-balancer-internal:True can be set in CPX service as:

```
service:
  annotations:
     service.beta.kubernetes.io/azure-load-balancer-internal:True
```

### NetScaler CPX Service Ports:

   By default, port 80 and 443 of CPX service will exposed when CPX is installed using this helm chart.To expose the CPX service as a NodePort, specify the service type as NodePort:
  service:
    
```
service:
  annotations: {}
  spec:
    type: NodePort
    ports:
      - port: 80
        targetPort: 80
        protocol: TCP
        name: http
      - port: 443
        targetPort: 443
        protocol: TCP
        name: https
```

   

## CRDs configuration

CRDs will be installed when we install NetScaler gateway controller via Helm automatically if CRDs are not installed in cluster already. If you wish to skip the CRD installation step, you can pass the --skip-crds flag. For more information about this option in Helm please see [this](https://helm.sh/docs/chart_best_practices/custom_resource_definitions/).

### Tolerations

Taints are applied on cluster nodes whereas tolerations are applied on pods. Tolerations enable pods to be scheduled on node with matching taints. For more information see [Taints and Tolerations in Kubernetes](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/).

Toleration can be applied to pod running NetScaler CPX and gateway controller containers using `tolerations` argument while deploying CPX+NSGWC using helm chart. This argument takes list of tolerations that user need to apply on the CPX+NSGWC pods.

For example, following command can be used to apply toleration on the CPX+NSGWC pod:

```
helm install my-release netscaler/netscaler-cpx-with-gateway-controller --set license.accept=yes,tolerations[0].key=<toleration-key>,tolerations[0].value=<toleration-value>,tolerations[0].operator=<toleration-operator>,tolerations[0].effect=<toleration-effect>,gatewayController.gatewayControllerName=<controllerName>
```

Here tolerations[0].key, tolerations[0].value and tolerations[0].effect are the key, value and effect that was used while tainting the node.
Effect represents what should happen to the pod if the pod don't have any matching toleration. It can have values `NoSchedule`, `NoExecute` and `PreferNoSchedule`.
Operator represents the operation to be used for key and value comparison between taint and tolerations. It can have values `Exists` and `Equal`. The default value for operator is `Equal`.

### Resource Quotas
There are various use-cases when resource quotas are configured on the Kubernetes cluster. If quota is enabled in a namespace for compute resources like cpu and memory, users must specify requests or limits for those values; otherwise, the quota system may reject pod creation. The resource quotas for the NSGWC and CPX containers can be provided explicitly in the helm chart.

To set requests and limits for the NSGWC container, use the variables `gatewayController.resources.requests` and `gatewayController.resources.limits` respectively.
Similarly, to set requests and limits for the CPX container, use the variable `netscalerCpx.resources.requests` and `netscalerCpx.resources.limits` respectively.

Below is an example of the helm command that configures

A) For NSGWC container:

  CPU request for 500milli CPUs

  CPU limit at 1000m

  Memory request for 512M

  Memory limit at 1000M

B) For CPX container:

  CPU request for 250milli CPUs

  CPU limit at 500m

  Memory request for 256M

  Memory limit at 512M

```
helm install my-release netscaler/netscaler-cpx-with-gateway-controller --set license.accept=yes --set gatewayController.resources.requests.cpu=500m,gatewayController.resources.requests.memory=512Mi,gatewayController.resources.limits.cpu=1000m,gatewayController.resources.limits.memory=1000Mi --set netscalerCpx.resources.limits.cpu=500m,netscalerCpx.resources.limits.memory=512Mi,netscalerCpx.resources.requests.cpu=250m,netscalerCpx.resources.requests.memory=256Mi --set gatewayController.gatewayControllerName="netscaler.com/gateway-controller"
```

## Configuration
The following table lists the configurable parameters of the NetScaler CPX with NetScaler gateway controller as side car chart and their default values.

| Parameters | Mandatory or Optional | Default value | Description |
| ---------- | --------------------- | ------------- | ----------- |
| license.accept | Mandatory | no | Set `yes` to accept the NetScaler gateway controller end user license agreement. |
| gatewayController.gatewayControllerName | Mandatory | N/A | Name of Gateway Controller . |
| gatewayController.imageRegistry                   | Mandatory  |  `quay.io`               |  The NetScaler gateway controller image registry             |  
| gatewayController.imageRepository                 | Mandatory  |  `netscaler/netscaler-k8s-ingress-controller`              |   The NetScaler gateway controller image repository             | 
| gatewayController.imageTag                  | Mandatory  |  `3.2.22`               |   The NetScaler gateway controller image tag            |
| gatewayController.pullPolicy | Mandatory | IfNotPresent | The NetScaler gateway controller image pull policy. |
| gatewayController.required | Mandatory | true | NSGWC to be run as sidecar with NetScaler CPX |
| gatewayController.enableLivenessProbe| Optional | False | Enable liveness probe settings for NetScaler Gateway Controller |
| gatewayController.enableReadinessProbe| Optional | False | Enable Readineess probe settings for NetScaler Gateway Controller |
| gatewayController.livenessProbe | Optional | N/A | Set livenessProbe settings for NSGWC |
| gatewayController.readinessProbe | Optional | N/A | Set readinessProbe settings|
| gatewayController.resources | Optional | {} |	CPU/Memory resource requests/limits for NetScaler Gateway Controller container |
| gatewayController.rbacRole  | Optional |  false  |  To deploy NSGWC with RBAC Role set rbacRole=true; by default NSGWC gets installed with RBAC ClusterRole(rbacRole=false) |
| imagePullSecrets | Optional | N/A | Provide list of Kubernetes secrets to be used for pulling the images from a private Docker registry or repository. For more information on how to create this secret please see [Pull an Image from a Private Registry](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/). |
| nameOverride | Optional | N/A | String to partially override deployment fullname template with a string (will prepend the release name) |
| fullNameOverride | Optional | N/A | String to fully override deployment fullname template with a string |
| netscalerCpx.resources | Optional | {} |	CPU/Memory resource requests/limits for NetScaler CPX container |
| gatewayController.nitroReadTimeout | Optional | 20 | The nitro Read timeout in seconds, defaults to 20 | 
| gatewayController.logLevel | Optional | INFO | The loglevel to control the logs generated by gatewayController. The supported loglevels are: CRITICAL, ERROR, WARNING, INFO, DEBUG, TRACE and NONE. For more information, see [Logging](https://github.com/netscaler/netscaler-k8s-gateway-controller/blob/master/docs/configure/log-levels.md).|
| gatewayController.jsonLog | Optional | false | Set this argument to true if log messages are required in JSON format | 
| gatewayController.nsConfigDnsRec | Optional | false | To enable/disable DNS address Record addition in NetScaler through Gateway |
| gatewayController.nsSvcLbDnsRec | Optional | false | To enable/disable DNS address Record addition in NetScaler through Type Load Balancer Service |
| gatewayController.nsDnsNameserver | Optional | N/A | To add DNS Nameservers in NetScaler |
| gatewayController.optimizeEndpointBinding | Optional | false | To enable/disable binding of backend endpoints to servicegroup in a single API-call. Recommended when endpoints(pods) per application are large in number. Applicable only for NetScaler Version >=13.0-45.7  |
| gatewayController.nsHTTP2ServerSide | Optional | OFF | Set this argument to `ON` for enabling HTTP2 for NetScaler service group configurations. |
| gatewayController.nsCookieVersion | Optional | 0 | Specify the persistence cookie version (0 or 1). |
| gatewayController.logProxy | Optional | N/A | Provide Elasticsearch or Kafka or Zipkin endpoint for NetScaler observability exporter. |
| netscalerCpx.nsProtocol | Optional | http | Protocol http or https used for the communication between NetScaler Gateway Controller and CPX |
| gatewayController.entityPrefix | Optional | k8s | The prefix for the resources on the NetScaler CPX. |
| gatewayController.disableAPIServerCertVerify | Optional | False | Set this parameter to True for disabling API Server certificate verification. |
| gatewayController.openshift | Optional | false | Set this argument if OpenShift environment is being used. |
| gatewayController.disableOpenshiftRoutes | false | By default Openshift routes are processed in openshift environment, this variable can be used to disable Gateway controller processing the openshift routes. |
| gatewayController.routeLabels | Optional | proxy in (<Release name of helm chart>) | You can use this parameter to provide the route labels selectors to be used by NetScaler Gateway Controller for routeSharding in OpenShift cluster. |
| gatewayController.namespaceLabels | Optional | N/A | You can use this parameter to provide the namespace labels selectors to be used by NetScaler Gateway Controller for routeSharding in OpenShift cluster. |
| gatewayController.certBundle | Optional | False | When set to true this will bind certificate key bundle in frontend vservers. Please refer [this](https://docs.netscaler.com/en-us/citrix-adc/current-release/ssl/ssl-certificates/install-link-and-update-certificates.html#support-for-ssl-certificate-key-bundle) |
| nodeSelector.key | Optional | N/A | Node label key to be used for nodeSelector option for CPX-NSGWC deployment. |
| nodeSelector.value | Optional | N/A | Node label value to be used for nodeSelector option in CPX-NSGWC deployment. |
| podAnnotations | Optional | N/A | Map of annotations to add to the pods. |
| affinity | Optional | N/A | Affinity labels for pod assignment. |
| tolerations | Optional | N/A | Specify the tolerations for the CPX-NSGWC deployment. |
| serviceType.loadBalancer.enabled | Optional | False | Set this argument if you want servicetype of CPX service to be LoadBalancer. |
| serviceType.nodePort.enabled | Optional | False | Set this argument if you want servicetype of CPX service to be NodePort. |
| serviceType.nodePort.httpPort | Optional | N/A | Specify the HTTP nodeport to be used for NodePort CPX service. |
| serviceType.nodePort.httpsPort | Optional | N/A | Specify the HTTPS nodeport to be used for NodePort CPX service. |
| service.annotaion | Optional | N/A | Dictionary of annotations to be used in CPX service. Key in this dictionary is the name of the annotation and Value is the required value of that annotation. For example, [see this](#netscaler-cpx-service-annotations). |
| service.spec | Optional | N/A | Specification settings of NetScaler CPX. To expose the CPX service as a NodePort, specify service.spec.type as NodePort. For example, [see this](#netscaler-cpx-service-ports). |
| serviceAccount.create | Mandatory | true | Create serviceAccount for the pod. |
| serviceAccount.tokenExpirationSeconds | Mandatory | 31536000 | Time in seconds when the token of serviceAccount get expired |
| serviceAccount.name | Optional | "" | Name of the ServiceAccount for the NetScaler CPX with Gateway Controller. If you want to use a ServiceAccount that you have already created and manage yourself, specify its name here and set serviceAccount.create to false. |
| createClusterRoleAndBinding | Mandatory | true | If you want to use a ClusterRole and Cluster Role Binding that you have already created and manage yourself then set to false. Please make sure you have bound the serviceaccount with the cluster role properly.  |
| netscalerCpx.imageRegistry                   | Mandatory  |  `quay.io`               |  The NetScaler CPX image registry             |  
| netscalerCpx.imageRepository                 | Mandatory  |  `netscaler/netscaler-cpx`              |   The NetScaler CPX image repository             | 
| netscalerCpx.imageTag                  | Mandatory  |  `14.1-47.48`               |   The NetScaler CPX image tag            |
| netscalerCpx.pullPolicy | Mandatory | IfNotPresent | The NetScaler CPX image pull policy. |
| netscalerCpx.hostName | Optional | N/A | This entity will be used to set Hostname of the CPX |
| netscalerCpx.nsLbHashAlgo.required | Optional | false | Set this value to set the LB consistent hashing Algorithm |
| netscalerCpx.nsLbHashAlgo.hashFingers | Optional |256 | Specifies the number of fingers to be used for hashing algorithm. Possible values are from 1 to 1024, Default value is 256 |
| netscalerCpx.nsLbHashAlgo.hashAlgorithm | Optional | 'default' | Specifies the supported algorithm. Supported algorithms are "default", "jarh", "prac", Default value is 'default' |
| netscalerCpx.commands| Optional | N/A | This argument accepts user-provided NetScaler bootup config that is applied as soon as the CPX is instantiated. Please note that this is not a dynamic config, and any subsequent changes to the configmap don't reflect in the CPX config unless the pod is restarted. For more info, please refer the [documentation](https://docs.netscaler.com/en-us/citrix-adc-cpx/current-release/configure-cpx-kubernetes-using-configmaps.html).  |
| netscalerCpx.shellCommands| Optional | N/A | This argument accepts user-provided bootup config that is applied as soon as the CPX is instantiated. Please note that this is not a dynamic config, and any subsequent changes to the configmap don't reflect in the CPX config unless the pod is restarted. For more info, please refer the [documentation](https://docs.netscaler.com/en-us/citrix-adc-cpx/current-release/configure-cpx-kubernetes-using-configmaps.html). |
| netscalerCpx.enableStartupProbe | Optional | True | Enable startupProbe settings for CPX |
| netscalerCpx.enableLivenessProbe | Optional | True  | Enable livenessProbe settings for CPX |
| netscalerCpx.startupProbe | Optional | N/A | Set startupProbe settings for CPX |
| netscalerCpx.livenessProbe | Optional | N/A  | Set livenessProbe settings for CPX |
| netscalerCpx.cpxLicenseAggregator | Optional | N/A | IP/FQDN of the CPX License Aggregator if it is being used to license the CPX. |
| netscalerCpx.ADMSettings.licenseServerIP | Optional | N/A | Provide the NetScaler Application Delivery Management (ADM) IP address to license NetScaler CPX. For more information, see [Licensing]( https://docs.netscaler.com/en-us/citrix-k8s-ingress-controller/licensing/). |
| netscalerCpx.ADMSettings.licenseServerPort | Optional | 27000 | NetScaler ADM port if non-default port is used. |
| netscalerCpx.ADMSettings.ADMIP | Optional | N/A |  NetScaler Application Delivery Management (ADM) IP address. |
| netscalerCpx.ADMSettings.loginSecret | Optional | N/A | The secret key to login to the ADM. For information on how to create the secret keys, see [Prerequisites](#prerequistes). |
| netscalerCpx.ADMSettings.bandWidthLicense | Optional | False | Set to true if you want to use bandwidth based licensing for NetScaler CPX. |
| netscalerCpx.ADMSettings.bandWidth | Optional | 1000 | Desired bandwidth capacity to be set for NetScaler CPX in Mbps. |
| netscalerCpx.ADMSettings.vCPULicense | Optional | N/A | Set to true if you want to use vCPU based licensing for NetScaler CPX. |
| netscalerCpx.ADMSettings.licenseEdition| Optional | PLATINUM | License edition that can be Standard, Platinum and Enterprise . By default, Platinum is selected.|
| netscalerCpx.ADMSettings.cpxCores | Optional | 1 | Desired number of vCPU to be set for NetScaler CPX. |
| netscalerCpx.ADMSettings.licensingMode | Optional | "" | Set the licensing mode as `pool` or `las`. For licensingMode `las`, set the netscalerCpx.ADMSettings.ADMIP, netscalerCpx.ADMSettings.loginSecret, netscalerCpx.ADMSettings.bandWidth and netscalerCpx.ADMSettings.licenseEdition. For `pool` licensing, set the netscalerCpx.ADMSettings.licenseServerIP and set either netscalerCpx.ADMSettings.bandWidthLicense or netscalerCpx.ADMSettings.vCPULicense. |
| exporter.required | Optional | false | Use the argument if you want to run the [Exporter for NetScaler Stats](https://github.com/netscaler/netscaler-adc-metrics-exporter) along with NetScaler ingress controller to pull metrics for the NetScaler CPX|
| exporter.imageRegistry                   | Optional  |  `quay.io`               |  The Exporter for NetScaler Stats image registry             |  
| exporter.imageRepository                 | Optional  |  `netscaler/netscaler-adc-metrics-exporter`              |   The Exporter for NetScaler Stats image repository             | 
| exporter.imageTag                  | Optional  |  `1.5.0`               |  The Exporter for NetScaler Stats image tag            | 
| exporter.pullPolicy | Optional | IfNotPresent | The Exporter for NetScaler Stats image pull policy. |
| exporter.resources | Optional | {} |	CPU/Memory resource requests/limits for Metrics exporter container |
| exporter.ports.containerPort | Optional | 8888 | The Exporter for NetScaler Stats container port. |
| exporter.serviceMonitorExtraLabels | Optional |  | Extra labels for service monitor whem NetScaler-adc-metrics-exporter is enabled. |
Alternatively, you can define a YAML file with the values for the parameters and pass the values while installing the chart.

For example:
   ```
   helm install netscaler-cpx-with-gateway-controller netscaler/netscaler-cpx-with-gateway-controller -f values.yaml
   ```

## Uninstalling the Chart
To uninstall/delete the ```my-release``` deployment:
   ```
   helm delete my-release
   ```

## Related documentation

- [NetScaler CPX Documentation](https://docs.netscaler.com/en-us/citrix-adc-cpx/current-release/cpx-architecture-and-traffic-flow)
- [NetScaler gateway controller Documentation](https://docs.netscaler.com/en-us/netscaler-kubernetes-gateway-controller/)
