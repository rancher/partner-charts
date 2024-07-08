# Citrix ADC CPX with Citrix Ingress Controller running as sidecar.

In a [Kubernetes](https://kubernetes.io/) or [OpenShift](https://www.openshift.com) cluster, you can deploy [Citrix ADC CPX](https://docs.citrix.com/en-us/citrix-adc-cpx) with Citrix ingress controller as a [sidecar](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/). The Citrix ADC CPX instance is used for load balancing the North-South traffic to the microservices in your cluster. And, the sidecar Citrix ingress controller configures the Citrix ADC CPX.

## TL;DR;

### For Kubernetes
   ```
   helm repo add citrix https://citrix.github.io/citrix-helm-charts/

   helm install citrix-cpx-with-ingress-controller citrix/citrix-cpx-with-ingress-controller --set license.accept=yes
   ```

   To install Citrix Provided Custom Resource Definition(CRDs) along with Citrix Ingress Controller
   ```
   helm install citrix-cpx-with-ingress-controller citrix/citrix-cpx-with-ingress-controller --set license.accept=yes,crds.install=true
   ```

### For OpenShift

   ```
   helm repo add citrix https://citrix.github.io/citrix-helm-charts/

   helm install citrix-cpx-with-ingress-controller citrix/citrix-cpx-with-ingress-controller --set license.accept=yes,openshift=true
   ```

   To install Citrix Provided Custom Resource Definition(CRDs) along with Citrix Ingress Controller
   ```
   helm install citrix-cpx-with-ingress-controller citrix/citrix-cpx-with-ingress-controller --set license.accept=yes,openshift=true,crds.install=true
   ```

> **Important:**
>
> The "license.accept" is a mandatory argument and should be set to "yes" to accept the terms of the Citrix license.


## Introduction
This Helm chart deploys a Citrix ADC CPX with Citrix ingress controller as a sidecar in the [Kubernetes](https://kubernetes.io/) or in the [Openshift](https://www.openshift.com) cluster using the [Helm](https://helm.sh/) package manager.

### Prerequisites

-  The [Kubernetes](https://kubernetes.io/) version should be 1.16 and above if using Kubernetes environment.
-  The [Openshift](https://www.openshift.com) version 4.8 or later if using OpenShift platform.
-  The [Helm](https://helm.sh/) version 3.x or later. You can follow instruction given [here](https://github.com/citrix/citrix-helm-charts/blob/master/Helm_Installation_version_3.md) to install the same.
-  You have installed [Prometheus Operator](https://github.com/coreos/prometheus-operator), if you want to view the metrics of the Citrix ADC CPX collected by the [metrics exporter](https://github.com/citrix/citrix-k8s-ingress-controller/tree/master/metrics-visualizer#visualization-of-metrics).
- Registration of Citrix ADC CPX in ADM: You may want to register your CPX in ADM for licensing or to obtain [servicegraph](https://docs.citrix.com/en-us/citrix-application-delivery-management-service/application-analytics-and-management/service-graph.html). For this you will have to create a Kubernetes secret using ADM credentials and provide it while install the chart. Create a Kubernetes secret for the user name and password using the following command:

  ```
  kubectl create secret generic admlogin --from-literal=username=<adm-username> --from-literal=password=<adm-password> -n citrix-system
  ```

## Installing the Chart
Add the Citrix Ingress Controller helm chart repository using command:

   ```
   helm repo add citrix https://citrix.github.io/citrix-helm-charts/
   ```

### For Kubernetes:
#### 1. Citrix ADC CPX with Citrix Ingress Controller running as side car.
To install the chart with the release name ``` my-release```:

   ```
   helm install my-release citrix/citrix-cpx-with-ingress-controller --set license.accept=yes,ingressClass[0]=<ingressClassName>
   ```

> **Note:**
>
> By default the chart installs the recommended [RBAC](https://kubernetes.io/docs/admin/authorization/rbac/) roles and role bindings.

The command deploys Citrix ADC CPX with Citrix ingress controller as a sidecar on the Kubernetes cluster with the default configuration. The [configuration](#configuration) section lists the mandatory and optional parameters that you can configure during installation.

#### 2. Citrix ADC CPX with Citrix Ingress Controller and Exporter running as side car.
[Metrics exporter](https://github.com/citrix/citrix-k8s-ingress-controller/tree/master/metrics-visualizer#visualization-of-metrics) can be deployed as sidecar to the Citrix ADC CPX and collects metrics from the Citrix ADC CPX instance. You can then [visualize these metrics](https://developer-docs.citrix.com/projects/citrix-k8s-ingress-controller/en/latest/metrics/promotheus-grafana/) using Prometheus Operator and Grafana.
> **Note:**
>
> Ensure that you have installed [Prometheus Operator](https://github.com/coreos/prometheus-operator).

Use the following command for this:
   ```
   helm install my-release citrix/citrix-cpx-with-ingress-controller --set license.accept=yes,ingressClass[0]=<ingressClassName>,exporter.required=true
   ```

### For OpenShift:
Add the name of the service account created when the chart is deployed to the privileged Security Context Constraints of OpenShift:

   ```
   oc adm policy add-scc-to-user privileged system:serviceaccount:<namespace>:<service-account-name>
   ```

#### 1. Citrix ADC CPX with Citrix Ingress Controller running as side car.
To install the chart with the release name, `my-release`, use the following command:
   ```
   helm install my-release citrix/citrix-cpx-with-ingress-controller --set license.accept=yes,openshift=true
   ```

#### 2. Citrix ADC CPX with Citrix Ingress Controller and Exporter running as side car.
[Metrics exporter](https://github.com/citrix/citrix-k8s-ingress-controller/tree/master/metrics-visualizer#visualization-of-metrics) can be deployed as sidecar to the Citrix ADC CPX and collects metrics from the Citrix ADC CPX instance. You can then [visualize these metrics](https://developer-docs.citrix.com/projects/citrix-k8s-ingress-controller/en/latest/metrics/promotheus-grafana/) using Prometheus Operator and Grafana.
> **Note:**
>
> Ensure that you have installed [Prometheus Operator](https://github.com/coreos/prometheus-operator).

Use the following command for this:
   ```
   helm install my-release citrix/citrix-cpx-with-ingress-controller --set license.accept=yes,openshift=true,exporter.required=true
   ```

### Installed components

The following components are installed:

-  [Citrix ADC CPX](https://docs.citrix.com/en-us/citrix-adc-cpx/netscaler-cpx.html)
-  [Citrix ingress controller](https://github.com/citrix/citrix-k8s-ingress-controller) (if enabled)
-  [Exporter](https://github.com/citrix/citrix-adc-metrics-exporter) (if enabled)


### Citrix ADC CPX Service Annotations:

   The parameter `serviceAnnotations` can be used to annotate CPX service while installing Citrix ADC CPX using this helm chart.
   For example, if CPX is getting deployed in Azure and an Azure Internal Load Balancer is required before CPX then the annotation `service.beta.kubernetes.io/azure-load-balancer-internal:True` can be set in CPX service using Helm command:

   ```
   helm install my-release citrix/citrix-cpx-with-ingress-controller --set license.accept=yes,serviceAnnotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal=True
   ```

   or the same can be provided in [values.yaml](https://github.com/citrix/citrix-helm-charts/blob/master/citrix-cpx-with-ingress-controller/values.yaml):

   ```
   license:
     accept: yes
   serviceAnnotations:
     service.beta.kubernetes.io/azure-load-balancer-internal: True
   ```

   which can be used to install Citrix ADC CPX using Helm command:

   ```
   helm install my-release citrix/citrix-cpx-with-ingress-controller -f values.yaml
   ```

   To know more about service annotations supported by Kubernetes on various platforms please see [this](https://kubernetes.io/docs/concepts/services-networking/service/).

### Citrix ADC CPX Service Ports:

   By default, port 80 and 443 of CPX service will exposed when CPX is installed using this helm chart. If it is required to expose any other ports in CPX service then the parameter `servicePorts` can be used for it.
   For example, if port 9999 is required to be exposed then below helm command can be used for installing Citrix ADC CPX:

   ```
   helm install my-release citrix/citrix-cpx-with-ingress-controller --set license.accept=yes,servicePorts[0].port=9999,servicePorts[0].protocol=TCP,servicePorts[0].name=https
   ```

   or the same can be provided in [values.yaml](https://github.com/citrix/citrix-helm-charts/blob/master/citrix-cpx-with-ingress-controller/values.yaml):

   ```
   license:
     accept: yes
   servicePorts:
     - port: 9090
       protocol: TCP
       name: https
   ```

   which can be used to install Citrix ADC using Helm command:

   ```
   helm install my-release citrix/citrix-cpx-with-ingress-controller -f values.yaml
   ```

> **Note:** If `servicePorts` parameters is used, only ports provided in this parameter will be exposed in CPX service.
> If you want to expose default ports 80 or 443, then you will need to explicity mention these also in this parameter.

### Configuration for ServiceGraph:
   If Citrix ADC CPX need to send data to the Citrix ADM to bring up the servicegraph, then the below steps can be followed to install Citrix ADC CPX with ingress controller. Citrix ingress controller configures Citrix ADC CPX with the configuration required for servicegraph.

   1. Create secret using Citrix ADC Agent credentials, which will be used by Citrix ADC CPX to communicate with Citrix ADM Agent:

	kubectl create secret generic admlogin --from-literal=username=<adm-agent-username> --from-literal=password=<adm-agent-password>

   2. Deploy Citrix ADC CPX with Citrix ingress controller using helm command:

	helm install my-release citrix/citrix-cpx-with-ingress-controller --set license.accept=yes,analyticsConfig.required=true,analyticsConfig.timeseries.metrics.enable=true,analyticsConfig.distributedTracing.enable=true,analyticsConfig.endpoint.server=<ADM-Agent-IP>,ADMSettings.ADMIP=<ADM-Agent-IP>,ADMSettings.loginSecret=<Secret-for-ADM-Agent-credentials>

> **Note:**
> If container agent is being used here for Citrix ADM, please provide `svcIP` of container agent in the `analyticsConfig.endpoint.server` parameter.

## Citrix ADC CPX DaemonSet with Citrix Ingress Controller as sidecar for BGP Advertisement

   The previous section of deploying CPX as a Deployment  requires a Tier-1 Loadbalancer such as Citrix VPX or cloud loadbalancers to route the traffic to CPX instances running in Kubernetes cluster, but you can also leverage  BGP network fabric in your on-prem environemnt to route the traffic to CPX instances in a Kubernetes or Openshift cluster. you need to deploy CPX with Citrix Ingress Controller as Daemonset to advertise the ExternalIPs of the K8s services of type LoadBalancer to your BGP Fabric. Citrix ADC CPX establishes a BGP peering session with your network routers, and uses that peering session to advertise the IP addresses of external cluster services. If your routers have ECMP capability, the traffic is load-balanced to multiple CPX instances by the upstream router, which in turn load-balances to actual application pods. When you deploy the Citrix ADC CPX with this mode, Citrix ADC CPX adds iptables rules for each service of type LoadBalancer on Kubernetes nodes. The traffic destined to the external IP address is routed to Citrix ADC CPX pods. You can also set the 'ingressIP' variable to an IP Address to advertise the External IP address for Ingress resources. Refer [documentation](https://github.com/citrix/citrix-k8s-ingress-controller/blob/master/docs/network/cpx-bgp-router.md) for complete details about BGP advertisement with CPX.

### Download the chart
You can download the chart usimg `helm pull` command.
```
helm repo add citrix https://citrix.github.io/citrix-helm-charts/
helm pull citrix/citrix-cpx-with-ingress-controller
tar -zxvf citrix-cpx-with-ingress-controller-x.y.z.tgz
```

### Edit the BGP configuration in values.yaml
BGP configurations enables CPX to peer with neighbor routers for advertisting the routes for Service of Type LoadBalancer. Citrix Ingress Controllers uses static IPs given in Service YAML or using an IPAM controller to allocate an External IP address, and same is advertisted to the neighbour router with the Gateway as Node IP. An example BGP configurations is given below.

```
# BGP configurations: local AS, remote AS and remote address is mandatory to provide.
bgpSettings:
  required: true
  bgpConfig:
  - bgpRouter:
      # Local AS number for BGP advertisement
      localAS:
      neighbor:
        # Address of the nighbor router for BGP advertisement
      - address: xx.xx.xx.xx
        # Remote AS number
        remoteAS:
        advertisementInterval: 10
        ASOriginationInterval: 10
```
If the cluster spawns across multiple networks, you can also specify the NodeSelector to give different neighbors for different Cluster Nodes as shown below.

```
bgpSettings:
  required: true
  bgpConfig:
  - nodeSelector: datacenter=ds1
    bgpRouter:
      localAS:
      neighbor:
      - address: xx.xx.xx.xx
        remoteAS:
        advertisementInterval: 10
        ASOriginationInterval: 10
  - nodeSelector: datacenter=ds2
    bgpRouter:
      localAS:
      neighbor:
      - address: yy.yy.yy.yy
        remoteAS:
        advertisementInterval: 10
        ASOriginationInterval: 10
```

### Deploy the chart
#### For Kubernetes:
#### 1. Citrix ADC CPX DaemonSet with Citrix Ingress Controller running as side car for BGP Advertisement.


To install the chart with the release name ``` my-release```:

   ```
   helm install my-release ./citrix-cpx-with-ingress-controller --set license.accept=yes,cpxBgpRouter=true
   ```
If you are running Citrix IPAM for auto allocation of IPs for Service of type LoadBalancer, you must enable the IPAM configurations in Citrix Ingress Controller as show below:

   ```
   helm install my-release ./citrix-cpx-with-ingress-controller --set license.accept=yes,cpxBgpRouter=true,ipam=true
   ```
If you are using ingress resources, you must set the `ingressIP` to a valid IP Address which will enable the BGP route advertisement for this IP when ingress resource is deployed.

   ```
   helm install my-release ./citrix-cpx-with-ingress-controller --set license.accept=yes,cpxBgpRouter=true,ingressIP=<Ingress External IP Address>
   ```

> **Note:**
>
> By default the chart installs the recommended [RBAC](https://kubernetes.io/docs/admin/authorization/rbac/) roles and role bindings.

The command deploys Citrix ADC CPX Daemonset with Citrix ingress controller as a sidecar on the Kubernetes cluster with the default configuration. The [configuration](#configuration) section lists the mandatory and optional parameters that you can configure during installation.

#### 2. Citrix ADC CPX with Citrix Ingress Controller and Exporter running as side car for BGP Advertisement.
[Metrics exporter](https://github.com/citrix/citrix-k8s-ingress-controller/tree/master/metrics-visualizer#visualization-of-metrics) can be deployed as sidecar to the Citrix ADC CPX and collects metrics from the Citrix ADC CPX instance. You can then [visualize these metrics](https://developer-docs.citrix.com/projects/citrix-k8s-ingress-controller/en/latest/metrics/promotheus-grafana/) using Prometheus Operator and Grafana.
> **Note:**
>
> Ensure that you have installed [Prometheus Operator](https://github.com/coreos/prometheus-operator).

Use the following command for this:
   ```
   helm install my-release ./citrix-cpx-with-ingress-controller --set license.accept=yes,cpxBgpRouter=true,exporter.required=true
   ```
If you are running Citrix IPAM controller for auto allocation of IPs for Service of type LoadBalancer, you must enable the IPAM configurations in Citrix Ingress Controller as show below:

   ```
   helm install my-release ./citrix-cpx-with-ingress-controller --set license.accept=yes,cpxBgpRouter=true,ipam=true,exporter.required=true
   ```
If you are using ingress resources, you must set the `ingressIP` to a valid IP Address which will enable the BGP route advertisement for this IP when ingress resource is deployed.

   ```
   helm install my-release ./citrix-cpx-with-ingress-controller --set license.accept=yes,cpxBgpRouter=true,ingressIP=<Ingress external IP>, exporter.required=true
   ```

#### For OpenShift:
Add the name of the service account created when the chart is deployed to the privileged Security Context Constraints of OpenShift:

   ```
   oc adm policy add-scc-to-user privileged system:serviceaccount:<namespace>:<service-account-name>
   ```

#### 1. Citrix ADC CPX DaemonSet with Citrix Ingress Controller running as side car for BGP Advertisement.
To install the chart with the release name, `my-release`, use the following command:
   ```
   helm install my-release ./citrix-cpx-with-ingress-controller --set license.accept=yes,cpxBgpRouter=true,openshift=true
   ```
If you are running Citrix IPAM controller for auto allocation of IPs for Service of type LoadBalancer, you must enable the IPAM configurations in Citrix Ingress Controller as show below:

   ```
   helm install my-release ./citrix-cpx-with-ingress-controller --set license.accept=yes,cpxBgpRouter=true,ipam=true,openshift=true
   ```

   If you are using ingress or Route resources, you must set the `ingressIP` to a valid IP Address which will enable the BGP route advertisement for this IP when ingress resource is deployed.

   ```
   helm install my-release ./citrix-cpx-with-ingress-controller --set license.accept=yes,cpxBgpRouter=true,ingressIP=<Ingress External IP Address>,openshift=true
   ```

#### 2. Citrix ADC CPX with Citrix Ingress Controller and Exporter running as side car for BGP Advertisement.
[Metrics exporter](https://github.com/citrix/citrix-k8s-ingress-controller/tree/master/metrics-visualizer#visualization-of-metrics) can be deployed as sidecar to the Citrix ADC CPX and collects metrics from the Citrix ADC CPX instance. You can then [visualize these metrics](https://developer-docs.citrix.com/projects/citrix-k8s-ingress-controller/en/latest/metrics/promotheus-grafana/) using Prometheus Operator and Grafana.
> **Note:**
>
> Ensure that you have installed [Prometheus Operator](https://github.com/coreos/prometheus-operator).

Use the following command for this:
   ```
   helm install my-release ./citrix-cpx-with-ingress-controller --set license.accept=yes,openshift=true,openshift=true,exporter.required=true
   ```
If you are running Citrix IPAM controller for auto allocation of IPs for Service of type LoadBalancer, you must enable the IPAM configurations in Citrix Ingress Controller as show below:

   ```
   helm install my-release ./citrix-cpx-with-ingress-controller --set license.accept=yes,cpxBgpRouter=true,ipam=true,openshift=true,exporter.required=true
   ```

If you are using ingress or Route resources, you must set the `ingressIP` to a valid IP Address which will enable the BGP route advertisement for this IP when ingress resource is deployed.

   ```
   helm install my-release ./citrix-cpx-with-ingress-controller --set license.accept=yes,cpxBgpRouter=true,ingressIP=<Ingress External IP Address>,openshift=true,exporter.required=true
   ```

## CRDs configuration

CRDs can be installed/upgraded when we install/upgrade Citrix ADC CPX with Citrix ingress controller using `crds.install=true` parameter in Helm. If you do not want to install CRDs, then set the option `crds.install` to `false`. By default, CRDs too get deleted if you uninstall through Helm. This means, even the CustomResource objects created by the customer will get deleted. If you want to avoid this data loss set `crds.retainOnDelete` to `true`.

> **Note:**
> Installing again may fail due to the presence of CRDs. Make sure that you back up all CustomResource objects and clean up CRDs before re-installing Citrix ADC CPX with Citrix ingress controller.

There are a few examples of how to use these CRDs, which are placed in the folder: [Example-CRDs](https://github.com/citrix/citrix-helm-charts/tree/master/example-crds). Refer to them and install as needed, using the following command:
```kubectl create -f <crd-example.yaml>```

### Details of the supported CRDs:

#### authpolicies CRD:

Authentication policies are used to enforce access restrictions to resources hosted by an application or an API server.

Citrix provides a Kubernetes CustomResourceDefinitions (CRDs) called the [Auth CRD](https://github.com/citrix/citrix-k8s-ingress-controller/tree/master/crd/auth) that you can use with the Citrix ingress controller to define authentication policies on the ingress Citrix ADC.

Example file: [auth_example.yaml](https://github.com/citrix/citrix-helm-charts/tree/master/example-crds/auth_example.yaml)

#### continuousdeployments CRD  for canary:

Canary release is a technique to reduce the risk of introducing a new software version in production by first rolling out the change to a small subset of users. After user validation, the application is rolled out to the larger set of users. Citrix ADC-Integrated [Canary Deployment solution](https://github.com/citrix/citrix-k8s-ingress-controller/tree/master/crd/canary) stitches together all components of continuous delivery (CD) and makes canary deployment easier for the application developers.

#### httproutes and listeners CRDs for contentrouting:

[Content Routing (CR)](https://github.com/citrix/citrix-k8s-ingress-controller/tree/master/crd/contentrouting) is the execution of defined rules that determine the placement and configuration of network traffic between users and web applications, based on the content being sent. For example, a pattern in the URL or header fields of the request.

Example files: [HTTPRoute_crd.yaml](https://github.com/citrix/citrix-helm-charts/tree/master/example-crds/HTTPRoute_crd.yaml), [Listener_crd.yaml](https://github.com/citrix/citrix-helm-charts/tree/master/example-crds/Listener_crd.yaml)

#### ratelimits CRD:

In a Kubernetes deployment, you can [rate limit the requests](https://github.com/citrix/citrix-k8s-ingress-controller/tree/master/crd/ratelimit) to the resources on the back end server or services using rate limiting feature provided by the ingress Citrix ADC.

Example files: [ratelimit-example1.yaml](https://github.com/citrix/citrix-helm-charts/tree/master/example-crds/ratelimit-example1.yaml), [ratelimit-example2.yaml](https://github.com/citrix/citrix-helm-charts/tree/master/example-crds/ratelimit-example2.yaml)

#### vips CRD:

Citrix provides a CustomResourceDefinitions (CRD) called [VIP](https://github.com/citrix/citrix-k8s-ingress-controller/tree/master/crd/vip) for asynchronous communication between the IPAM controller and Citrix ingress controller.

The IPAM controller is provided by Citrix for IP address management. It allocates IP address to the service from a defined IP address range. The Citrix ingress controller configures the IP address allocated to the service as virtual IP (VIP) in Citrix ADX VPX. And, the service is exposed using the IP address.

When a new service is created, the Citrix ingress controller creates a CRD object for the service with an empty IP address field. The IPAM Controller listens to addition, deletion, or modification of the CRD and updates it with an IP address to the CRD. Once the CRD object is updated, the Citrix ingress controller automatically configures Citrix ADC-specfic configuration in the tier-1 Citrix ADC VPX.

#### rewritepolicies CRD:

In kubernetes environment, to deploy specific layer 7 policies to handle scenarios such as, redirecting HTTP traffic to a specific URL, blocking a set of IP addresses to mitigate DDoS attacks, imposing HTTP to HTTPS and so on, requires you to add appropriate libraries within the microservices and manually configure the policies. Instead, you can use the [Rewrite and Responder features](https://github.com/citrix/citrix-k8s-ingress-controller/blob/master/crd/rewrite-responder-policies-deployment.yaml) provided by the Ingress Citrix ADC device to deploy these policies.

Example files: [target-url-rewrite.yaml](https://github.com/citrix/citrix-helm-charts/tree/master/example-crds/target-url-rewrite.yaml)

#### wafs CRD:

[WAF CRD](https://github.com/citrix/citrix-k8s-ingress-controller/blob/master/docs/crds/waf.md) can be used to configure the web application firewall policies with the Citrix ingress controller on the Citrix ADC VPX, MPX, SDX, and CPX. The WAF CRD enables communication between the Citrix ingress controller and Citrix ADC for enforcing web application firewall policies.

In a Kubernetes deployment, you can enforce a web application firewall policy to protect the server using the WAF CRD. For more information about web application firewall, see [Web application security](https://docs.citrix.com/en-us/citrix-adc/13/application-firewall/introduction/web-application-security.html).

Example files: [wafhtmlxsssql.yaml](https://github.com/citrix/citrix-helm-charts/tree/master/example-crds/wafhtmlxsssql.yaml)

#### CORS CRD:

[CORS CRD](https://github.com/citrix/citrix-k8s-ingress-controller/blob/master/docs/crds/cors.md) Cross-origin resource sharing (CORS) is a mechanism allows a web application running under one domain to securely access resources in another domain. You can configure CORS policies on Citrix ADC using Citrix ingress controller to allow one domain (the origin domain) to call APIs in another domain. For more information, see the [cross-origin resource sharing CRD](https://github.com/citrix/citrix-k8s-ingress-controller/blob/master/docs/crds/cors.md) documentation.

Example files: [cors-crd.yaml](https://github.com/citrix/citrix-helm-charts/tree/master/example-crds/corspolicy-example.yaml)

#### APPQOE CRD:

[APPQOE CRD](https://github.com/citrix/citrix-k8s-ingress-controller/blob/master/docs/crds/appqoe.md) When a Citrix ADC appliance receives an HTTP request and forwards it to a back-end server, sometimes there may be connection failures with the back-end server. You can configure the request-retry feature on Citrix ADC to forward the request to the next available server, instead of sending the reset to the client. Hence, the client saves round trip time when Citrix ADC initiates the same request to the next available service.
For more information, see the AppQoE support documentation. [Appqoe resource sharing CRD](https://github.com/citrix/citrix-k8s-ingress-controller/blob/master/docs/crds/appqoe.md) documentation.

Example files: [appqoe-crd.yaml](https://github.com/citrix/citrix-helm-charts/tree/master/example-crds/appqoe_example.yaml)

#### WILDCARDDNS CRD:

[WILDCARDDNS CRD](https://github.com/citrix/citrix-k8s-ingress-controller/blob/master/docs/crds/wildcarddns.md) Wildcard DNS domains are used to handle requests for nonexistent domains and subdomains. In a zone, use wildcard domains to redirect queries for all nonexistent domains or subdomains to a particular server, instead of creating a separate Resource Record (RR) for each domain. The most common use of a wildcard DNS domain is to create a zone that can be used to forward mail from the internet to some other mail system.
For more information, see the Wild card DNS domains support documentation. [Wildcard DNS Entry CRD](https://github.com/citrix/citrix-k8s-ingress-controller/blob/master/docs/crds/wildcarddns.md) documentation.

Example files: [wildcarddns-crd.yaml](https://github.com/citrix/citrix-helm-charts/tree/master/example-crds/wildcarddns-example.yaml)

## Citrix ADC CPX servicetype LoadBalancer
Citrix ADC CPX can be installed with service having servicetype LoadBalancer. Following arguments can be used in the `helm install` command for the same:

```
helm install citrix-cpx-with-ingress-controller citrix/citrix-cpx-with-ingress-controller --set license.accept=yes,serviceType.loadBalancer.enabled=True
```

## Citrix ADC CPX servicetype NodePort
Citrix ADC CPX can be installed with service having servicetype Nodeport. Following arguments can be used in the `helm install` command for the same:

```
helm install citrix-cpx-with-ingress-controller citrix/citrix-cpx-with-ingress-controller --set license.accept=yes,serviceType.nodePort.enabled=True
```

Additionally, `serviceType.nodePort.httpPort` and `serviceType.nodePort.httpsPort` arguments can be used to select the nodePort for the CPX service for HTTP and HTTPS ports.

### Tolerations

Taints are applied on cluster nodes whereas tolerations are applied on pods. Tolerations enable pods to be scheduled on node with matching taints. For more information see [Taints and Tolerations in Kubernetes](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/).

Toleration can be applied to pod running Citrix ADC CPX and ingress controller containers using `tolerations` argument while deploying CPX+CIC using helm chart. This argument takes list of tolerations that user need to apply on the CPX+CIC pods.

For example, following command can be used to apply toleration on the CPX+CIC pod:

```
helm install my-release citrix/citrix-cpx-with-ingress-controller --set license.accept=yes,tolerations[0].key=<toleration-key>,tolerations[0].value=<toleration-value>,tolerations[0].operator=<toleration-operator>,tolerations[0].effect=<toleration-effect>
```

Here tolerations[0].key, tolerations[0].value and tolerations[0].effect are the key, value and effect that was used while tainting the node.
Effect represents what should happen to the pod if the pod don't have any matching toleration. It can have values `NoSchedule`, `NoExecute` and `PreferNoSchedule`.
Operator represents the operation to be used for key and value comparison between taint and tolerations. It can have values `Exists` and `Equal`. The default value for operator is `Equal`.

## Configuration
The following table lists the configurable parameters of the Citrix ADC CPX with Citrix ingress controller as side car chart and their default values.

| Parameters | Mandatory or Optional | Default value | Description |
| ---------- | --------------------- | ------------- | ----------- |
| license.accept | Mandatory | no | Set `yes` to accept the Citrix ingress controller end user license agreement. |
| imageRegistry                   | Mandatory  |  `quay.io`               |  The Citrix ADC CPX image registry             |  
| imageRepository                 | Mandatory  |  `citrix/citrix-k8s-cpx-ingress`              |   The Citrix ADC CPX image repository             | 
| imageTag                  | Mandatory  |  `13.1-30.52`               |   The Citrix ADC CPX image tag            | 
| pullPolicy | Mandatory | IfNotPresent | The Citrix ADC CPX image pull policy. |
| daemonSet | Optional | False | Set this to true if Citrix ADC CPX needs to be deployed as DaemonSet. |
| cic.imageRegistry                   | Mandatory  |  `quay.io`               |  The Citrix ingress controller image registry             |  
| cic.imageRepository                 | Mandatory  |  `citrix/citrix-k8s-ingress-controller`              |   The Citrix ingress controller image repository             | 
| cic.imageTag                  | Mandatory  |  `1.32.7`               |   The Citrix ingress controller image tag            | 
| cic.pullPolicy | Mandatory | IfNotPresent | The Citrix ingress controller image pull policy. |
| cic.required | Mandatory | true | CIC to be run as sidecar with Citrix ADC CPX |
| cic.resources | Optional | {} |	CPU/Memory resource requests/limits for Citrix Ingress Controller container |
| cic.rbacRole  | Optional |  false  |  To deploy CIC with RBAC Role set rbacRole=true; by default CIC gets installed with RBAC ClusterRole(rbacRole=false)) |
| imagePullSecrets | Optional | N/A | Provide list of Kubernetes secrets to be used for pulling the images from a private Docker registry or repository. For more information on how to create this secret please see [Pull an Image from a Private Registry](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/). |
| nameOverride | Optional | N/A | String to partially override deployment fullname template with a string (will prepend the release name) |
| fullNameOverride | Optional | N/A | String to fully override deployment fullname template with a string |
| resources | Optional | {} |	CPU/Memory resource requests/limits for Citrix CPX container |
| nitroReadTimeout | Optional | 20 | The nitro Read timeout in seconds, defaults to 20 | 
| logLevel | Optional | DEBUG | The loglevel to control the logs generated by CIC. The supported loglevels are: CRITICAL, ERROR, WARNING, INFO, DEBUG and TRACE. For more information, see [Logging](https://github.com/citrix/citrix-k8s-ingress-controller/blob/master/docs/configure/log-levels.md).|
| jsonLog | Optional | false | Set this argument to true if log messages are required in JSON format | 
| nsConfigDnsRec | Optional | false | To enable/disable DNS address Record addition in ADC through Ingress |
| nsSvcLbDnsRec | Optional | false | To enable/disable DNS address Record addition in ADC through Type Load Balancer Service |
| nsDnsNameserver | Optional | N/A | To add DNS Nameservers in ADC |
| optimizeEndpointBinding | Optional | false | To enable/disable binding of backend endpoints to servicegroup in a single API-call. Recommended when endpoints(pods) per application are large in number. Applicable only for Citrix ADC Version >=13.0-45.7  |
| defaultSSLCertSecret | Optional | N/A | Provide Kubernetes secret name that needs to be used as a default non-SNI certificate in Citrix ADC. |
| nsHTTP2ServerSide | Optional | OFF | Set this argument to `ON` for enabling HTTP2 for Citrix ADC service group configurations. |
| cpxLicenseAggregator | Optional | N/A | IP/FQDN of the CPX License Aggregator if it is being used to license the CPX. |
| nsCookieVersion | Optional | 0 | Specify the persistence cookie version (0 or 1). |
| profileSslFrontend | Optional | N/A | Specify the frontend SSL profile. For Details see [Configuration using FRONTEND_SSL_PROFILE](https://docs.citrix.com/en-us/citrix-k8s-ingress-controller/configure/profiles.html#global-front-end-profile-configuration-using-configmap-variables) |
| profileTcpFrontend | Optional | N/A | Specify the frontend TCP profile. For Details see [Configuration using FRONTEND_TCP_PROFILE](https://docs.citrix.com/en-us/citrix-k8s-ingress-controller/configure/profiles.html#global-front-end-profile-configuration-using-configmap-variables) |
| profileHttpFrontend | Optional | N/A | Specify the frontend HTTP profile. For Details see [Configuration using FRONTEND_HTTP_PROFILE](https://docs.citrix.com/en-us/citrix-k8s-ingress-controller/configure/profiles.html#global-front-end-profile-configuration-using-configmap-variables) |
| logProxy | Optional | N/A | Provide Elasticsearch or Kafka or Zipkin endpoint for Citrix observability exporter. |
| nsProtocol | Optional | http | Protocol http or https used for the communication between Citrix Ingress Controller and CPX |
| cpxBgpRouter | Optional | false| If set to true, this CPX is deployed as daemonset in BGP controller mode wherein BGP advertisements are done for attracting external traffic to Kubernetes clusters |
| replicaCount  | Optional  | 1 | Number of CPX-CIC pods to be deployed. With `cpxBgpRouter : true`, replicaCount is 1 since CPX will be deployed as DaemonSet |
| nsIP | Optional | 192.168.1.2 | NSIP used by CPX for internal communication when run in Host mode, i.e when cpxBgpRouter is set to true. A /24 internal network is created in this IP range which is used for internal communications withing the network namespace. |
| nsGateway | Optional | 192.168.1.1 | Gateway used by CPX for internal communication when run in Host mode, i.e when cpxBgpRouter is set to true. If not specified, first IP in the nsIP network is used as gateway. It must be in same network as nsIP |
| bgpPort | Optional | 179 | BGP port used by CPX for BGP advertisement if cpxBgpRouter is set to true|
| ingressIP | Optional | N/A | External IP address to be used by ingress resources if not overriden by ingress.com/frontend-ip annotation in Ingress resources. This is also advertised to external routers when pxBgpRouter is set to true|
| entityPrefix | Optional | k8s | The prefix for the resources on the Citrix ADC CPX. |
| ingressClass | Optional | N/A | If multiple ingress load balancers are used to load balance different ingress resources. You can use this parameter to specify Citrix ingress controller to configure Citrix ADC associated with specific ingress class. For more information on Ingress class, see [Ingress class support](https://developer-docs.citrix.com/projects/citrix-k8s-ingress-controller/en/latest/configure/ingress-classes/). For Kubernetes version >= 1.19, this will create an IngressClass object with the name specified here  |
| setAsDefaultIngressClass | Optional | False | Set the IngressClass object as default. New Ingresses without an "ingressClassName" field specified will be assigned the class specified in ingressClass. Applicable only for kubernetes versions >= 1.19 |
| updateIngressStatus | Optional | False | Set this argument if you want to update ingress status of the ingress resources exposed via CPX. This is only applicable if servicetype of CPX service is LoadBalancer. |
| disableAPIServerCertVerify | Optional | False | Set this parameter to True for disabling API Server certificate verification. |
| openshift | Optional | false | Set this argument if OpenShift environment is being used. |
| disableOpenshiftRoutes | false | By default Openshift routes are processed in openshift environment, this variable can be used to disable Ingress controller processing the openshift routes. |
| routeLabels | Optional | N/A | You can use this parameter to provide the route labels selectors to be used by Citrix Ingress Controller for routeSharding in OpenShift cluster. |
| namespaceLabels | Optional | N/A | You can use this parameter to provide the namespace labels selectors to be used by Citrix Ingress Controller for routeSharding in OpenShift cluster. |
| sslCertManagedByAWS | Optional | False | Set this argument if SSL certs used is managed by AWS while deploying Citrix ADC CPX in AWS. |
| nodeSelector.key | Optional | N/A | Node label key to be used for nodeSelector option for CPX-CIC deployment. |
| nodeSelector.value | Optional | N/A | Node label value to be used for nodeSelector option in CPX-CIC deployment. |
| podAnnotations | Optional | N/A | Map of annotations to add to the pods. |
| affinity | Optional | N/A | Affinity labels for pod assignment. |
| tolerations | Optional | N/A | Specify the tolerations for the CPX-CIC deployment. |
| serviceType.loadBalancer.enabled | Optional | False | Set this argument if you want servicetype of CPX service to be LoadBalancer. |
| serviceType.nodePort.enabled | Optional | False | Set this argument if you want servicetype of CPX service to be NodePort. |
| serviceType.nodePort.httpPort | Optional | N/A | Specify the HTTP nodeport to be used for NodePort CPX service. |
| serviceType.nodePort.httpsPort | Optional | N/A | Specify the HTTPS nodeport to be used for NodePort CPX service. |
| serviceAnnotations | Optional | N/A | Dictionary of annotations to be used in CPX service. Key in this dictionary is the name of the annotation and Value is the required value of that annotation. For example, [see this](#citrix-adc-cpx-service-annotations). |
| serviceSpec.externalTrafficPolicy | Optional | Cluster | Use this parameter to provide externalTrafficPolicy for CPX service of type LoadBalancer or NodePort. `serviceType.loadBalancer.enabled` or `serviceType.nodePort.enabled` should be set to `true` according to your use case for using this parameter. |
| serviceSpec.loadBalancerIP | Optional | N/A | Use this parameter to provide LoadBalancer IP to CPX service of type LoadBalancer. `serviceType.loadBalancer.enabled` should be set to `true` for using this parameter. |
| serviceSpec.loadBalancerSourceRanges | Optional | N/A | Provide the list of IP Address or range which should be allowed to access the Network Load Balancer. `serviceType.loadBalancer.enabled` should be set to `true` for using this parameter. For details, see [Network Load Balancer support on AWS](https://kubernetes.io/docs/concepts/services-networking/service/#aws-nlb-support). |
| servicePorts | Optional | N/A | List of port. Each element in this list is a dictionary that contains information about the port. For example, [see this](#citrix-adc-cpx-service-ports). |
| ADMSettings.licenseServerIP | Optional | N/A | Provide the Citrix Application Delivery Management (ADM) IP address to license Citrix ADC CPX. For more information, see [Licensing](https://developer-docs.citrix.com/projects/citrix-k8s-ingress-controller/en/latest/licensing/). |
| ADMSettings.licenseServerPort | Optional | 27000 | Citrix ADM port if non-default port is used. |
| ADMSettings.ADMIP | Optional | N/A |  Citrix Application Delivery Management (ADM) IP address. |
| ADMSettings.loginSecret | Optional | N/A | The secret key to login to the ADM. For information on how to create the secret keys, see [Prerequisites](#prerequistes). |
| ADMSettings.bandWidthLicense | Optional | False | Set to true if you want to use bandwidth based licensing for Citrix ADC CPX. |
| ADMSettings.bandWidth | Optional | 1000 | Desired bandwidth capacity to be set for Citrix ADC CPX in Mbps. |
| ADMSettings.vCPULicense | Optional | N/A | Set to true if you want to use vCPU based licensing for Citrix ADC CPX. |
| ADMSettings.licenseEdition| Optional | PLATINUM | License edition that can be Standard, Platinum and Enterprise . By default, Platinum is selected.|
| ADMSettings.cpxCores | Optional | 1 | Desired number of vCPU to be set for Citrix ADC CPX. |
| ADMSettings.analyticsServerPort | Optional | 5557 | Port used for Analytics by ADM. Required to plot ServiceGraph. |
| exporter.required | Optional | false | Use the argument if you want to run the [Exporter for Citrix ADC Stats](https://github.com/citrix/citrix-adc-metrics-exporter) along with Citrix ingress controller to pull metrics for the Citrix ADC CPX|
| exporter.imageRegistry                   | Optional  |  `quay.io`               |  The Exporter for Citrix ADC Stats image registry             |  
| exporter.imageRepository                 | Optional  |  `citrix/citrix-adc-metrics-exporter`              |   The Exporter for Citrix ADC Stats image repository             | 
| exporter.imageTag                  | Optional  |  `1.4.9`               |  The Exporter for Citrix ADC Stats image tag            | 
| exporter.pullPolicy | Optional | IfNotPresent | The Exporter for Citrix ADC Stats image pull policy. |
| exporter.resources | Optional | {} |	CPU/Memory resource requests/limits for Metrics exporter container |
| exporter.ports.containerPort | Optional | 8888 | The Exporter for Citrix ADC Stats container port. |
| analyticsConfig.required | Mandatory | false | Set this to true if you want to configure Citrix ADC to send metrics and transaction records to analytics service. |
| analyticsConfig.distributedTracing.enable | Optional | false | Set this value to true to enable OpenTracing in Citrix ADC. |
| analyticsConfig.distributedTracing.samplingrate | Optional | 100 | Specifies the OpenTracing sampling rate in percentage. |
| analyticsConfig.endpoint.server | Optional | N/A | Set this value as the IP address or DNS address of the  analytics server. |
| analyticsConfig.endpoint.service | Optional | N/A | Set this value as the IP address or service name with namespace of the analytics service deployed in Kuberenetes. Format: namespace/servicename|
| analyticsConfig.timeseries.port | Optional | 5563 | Specify the port used to expose analytics service for timeseries endpoint. |
| analyticsConfig.timeseries.metrics.enable | Optional | Set this value to true to enable sending metrics from Citrix ADC. |
| analyticsConfig.timeseries.metrics.mode | Optional | avro |  Specifies the mode of metric endpoint. |
| analyticsConfig.timeseries.auditlogs.enable | Optional | false | Set this value to true to export audit log data from Citrix ADC. |
| analyticsConfig.timeseries.events.enable | Optional | false | Set this value to true to export events from the Citrix ADC. |
| analyticsConfig.transactions.enable | Optional | false | Set this value to true to export transactions from Citrix ADC. |
| analyticsConfig.transactions.port | Optional | 5557 | Specify the port used to expose analytics service for transaction endpoint. |
| crds.install | Optional | False | Unset this argument if you don't want to install CustomResourceDefinitions which are consumed by CIC. |
| crds.retainOnDelete | Optional | false | Set this argument if you want to retain CustomResourceDefinitions even after uninstalling CIC. This will avoid data-loss of Custom Resource Objects created before uninstallation. |
| bgpSettings.required | Optional | false | Set this argument if you want to enable BGP configurations for exposing service of Type Loadbalancer through BGP fabric|
| bgpSettings.bgpConfig | Optional| N/A| This represents BGP configurations in YAML format. For the description about individual fields, please refer the [documentation](https://github.com/citrix/citrix-k8s-ingress-controller/blob/master/docs/network/cpx-bgp-router.md) |
| nsLbHashAlgo.required | Optional | false | Set this value to set the LB consistent hashing Algorithm |
| nsLbHashAlgo.hashFingers | Optional |256 | Specifies the number of fingers to be used for hashing algorithm. Possible values are from 1 to 1024, Default value is 256 |
| nsLbHashAlgo.hashAlgorithm | Optional | 'default' | Specifies the supported algorithm. Supported algorithms are "default", "jarh", "prac", Default value is 'default' |

> **Note:**
>
> If Citrix ADM related information is not provided during installation, Citrix ADC CPX will come up with the default license.

Alternatively, you can define a YAML file with the values for the parameters and pass the values while installing the chart.

For example:
   ```
   helm install citrix-cpx-with-ingress-controller citrix/citrix-cpx-with-ingress-controller -f values.yaml
   ```

> **Tip:**
>
> The [values.yaml](https://github.com/citrix/citrix-helm-charts/blob/master/citrix-cpx-with-ingress-controller/values.yaml) contains the default values of the parameters.

## Uninstalling the Chart
To uninstall/delete the ```my-release``` deployment:
   ```
   helm delete my-release
   ```

## Related documentation

- [Citrix ADC CPX Documentation](https://docs.citrix.com/en-us/citrix-adc-cpx/12-1/cpx-architecture-and-traffic-flow.html)
- [Citrix ingress controller Documentation](https://developer-docs.citrix.com/projects/citrix-k8s-ingress-controller/en/latest/)
- [Citrix ingress controller GitHub](https://github.com/citrix/citrix-k8s-ingress-controller)
- [BGP advertisement for External IPs with CPX](https://github.com/citrix/citrix-k8s-ingress-controller/blob/master/docs/network/cpx-bgp-router.md)
