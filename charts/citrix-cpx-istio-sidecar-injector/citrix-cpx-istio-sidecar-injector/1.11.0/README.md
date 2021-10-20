# Deploy Citrix ADC CPX as a sidecar in Istio environment using Helm charts

Citrix ADC CPX can be deployed as a sidecar proxy in an application pod in the Istio service mesh.


# Table of Contents
1. [TL; DR;](#tldr)
2. [Introduction](#introduction)
3. [Deploy Sidecar Injector for Citrix ADC CPX using Helm chart](#deploy-sidecar-injector-for-citrix-adc-cpx-using-helm-chart)
4. [Observability using Citrix Observability Exporter](#observability-using-coe)
5. [Citrix ADC CPX License Provisioning](#citrix-adc-cpx-license-provisioning)
6. [Service Graph configuration](#configuration-for-servicegraph)
7. [Generate Certificate for Application](#generate-certificate-for-application)
8. [Limitations](#limitations)
9. [Clean Up](#clean-up)
10. [Configuration Parameters](#configuration-parameters)


## <a name="tldr">TL; DR;</a>

    kubectl create namespace citrix-system
    
    helm repo add citrix https://citrix.github.io/citrix-helm-charts/

    helm install cpx-sidecar-injector citrix/citrix-cpx-istio-sidecar-injector --namespace citrix-system --set cpxProxy.EULA=YES


## <a name="introduction">Introduction</a>

Citrix ADC CPX can act as a sidecar proxy to an application container in Istio. You can inject the Citrix ADC CPX manually or automatically using the [Istio sidecar injector](https://istio.io/docs/setup/kubernetes/additional-setup/sidecar-injection/). Automatic sidecar injection requires resources including a Kubernetes [mutating webhook admission](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/) controller, and a service. Using this Helm chart, you can create resources required for automatically deploying Citrix ADC CPX as a sidecar proxy.

In Istio servicemesh, the namespace must be labelled before applying the deployment yaml for [automatic sidecar injection](https://istio.io/docs/setup/kubernetes/additional-setup/sidecar-injection/#automatic-sidecar-injection). Once the namespace is labelled, sidecars (envoy or CPX) will be injected while creating pods.
- For CPX, namespace must be labelled `cpx-injection=enabled`
- For Envoy, namespace must be labelled `istio-injection=enabled`

__Note: If a namespace is labelled with both `istio-injection` and `cpx-injection`, Envoy injection takes a priority! Citrix CPX won't be injected on top of the already injected Envoy sidecar. For using Citrix ADC as sidecar, ensure that `istio-injection` label is removed from the namespace.__

For detailed information on different deployment options, see [Deployment Architecture](https://github.com/citrix/citrix-istio-adaptor/blob/master/docs/istio-integration/architecture.md).

### Compatibility Matrix between Citrix xDS-adaptor and Istio version

Below table provides info about recommended Citrix xDS-Adaptor version to be used for various Istio versions.

| Citrix xDS-Adaptor version | Istio version |
|----------------------------|---------------|
| quay.io/citrix/citrix-xds-adaptor:0.9.9 | Istio v1.10+ |
| quay.io/citrix/citrix-xds-adaptor:0.9.8 | Istio v1.8 to Istio v1.9 |
| quay.io/citrix/citrix-xds-adaptor:0.9.5 | Istio v1.6 |

### Prerequisites

The following prerequisites are required for deploying Citrix ADC as a sidecar to an application pod.

- Ensure that **Istio version 1.8 onwards** is installed
- Ensure that Helm with version 3.x is installed. Follow this [step](https://github.com/citrix/citrix-helm-charts/blob/master/Helm_Installation_version_3.md) to install the same.
- Ensure that your cluster Kubernetes version should be 1.16 onwards and the `admissionregistration.k8s.io/v1`, `admissionregistration.k8s.io/v1beta1` API is enabled

You can verify the API by using the following command:

        kubectl api-versions | grep admissionregistration.k8s.io/v1

The following output indicates that the API is enabled:

        admissionregistration.k8s.io/v1
        admissionregistration.k8s.io/v1beta1

- Create namespace `citrix-system`
        
        kubectl create namespace citrix-system
        
- **Registration of Citrix ADC CPX in ADM**

Create a secret containing ADM username and password in each application namespace.

        kubectl create secret generic admlogin --from-literal=username=<adm-username> --from-literal=password=<adm-password> -n citrix-system

## <a name="deploy-sidecar-injector-for-citrix-adc-cpx-using-helm-chart">Deploy Sidecar Injector for Citrix ADC CPX using Helm chart</a>

**Before you Begin**

To deploy resources for automatic installation of Citrix ADC CPX as a sidecar in Istio, perform the following step. In this example, release name is specified as `cpx-sidecar-injector`  and namespace is used as `citrix-system`.


    helm repo add citrix https://citrix.github.io/citrix-helm-charts/

    helm install cpx-sidecar-injector citrix/citrix-cpx-istio-sidecar-injector --namespace citrix-system --set cpxProxy.EULA=YES

This step installs a mutating webhook and a service resource to application pods in the namespace labeled as `cpx-injection=enabled`.

*"Note:" The `cpx-injection=enabled` label is mandatory for injecting sidecars.*

An example to deploy application along with Citrix ADC CPX sidecar is provided [here](https://github.com/citrix/citrix-helm-charts/tree/master/examples/citrix-adc-in-istio).


# <a name="observability-using-coe"> Observability using Citrix Observability Exporter </a>

### Pre-requisites

1. Citrix Observability Exporter (COE) should be deployed in the cluster.

2. Citrix ADC CPX should be running with versions 13.0-48+ or 12.1-56+.

Citrix ADC CPXes serving East West traffic send its metrics and transaction data to COE which has a support for Prometheus and Zipkin. 

Metrics data can be visualized in Prometheus dashboard. 

Zipkin enables users to analyze tracing for East-West service to service communication.

*Note*: Istio should be [installed](https://istio.io/docs/tasks/observability/distributed-tracing/zipkin/#before-you-begin) with Zipkin as tracing endpoint.

```
helm repo add citrix https://citrix.github.io/citrix-helm-charts/

helm install cpx-sidecar-injector citrix/citrix-cpx-istio-sidecar-injector --namespace citrix-system --set cpxProxy.EULA=YES,coe.coeURL=<coe-service-name>.<namespace>
```

By default, COE is primarily used for Prometheus integration. Servicegraph and tracing is handled by Citrix ADM appliance. To enable Zipkin tracing, set argument `coe.coeTracing=true` in helm command. Default value of coeTracing is set to false.

```
helm repo add citrix https://citrix.github.io/citrix-helm-charts/

helm install cpx-sidecar-injector citrix/citrix-cpx-istio-sidecar-injector --namespace citrix-system --set cpxProxy.EULA=YES,coe.coeURL=<coe-service-name>.<namespace>,coe.coeTracing=true

```

For example, if COE is deployed as `coe` in `citrix-system` namespace, then below helm command will deploy sidecar injector webhook which will be deploying Citrix ADC CPX sidecar proxies in application pods, and these sidecar proxies will be configured to establish communication channels with COE.

```
helm repo add citrix https://citrix.github.io/citrix-helm-charts/

helm install cpx-sidecar-injector citrix/citrix-cpx-istio-sidecar-injector --namespace citrix-system --set cpxProxy.EULA=YES,coe.coeURL=coe.citrix-system
```

*Important*: Apply below mentioned annotations on COE deployment so that Prometheus can scrape data from COE.
```
        prometheus.io/scrape: "true"
        prometheus.io/port: "5563" # Prometheus port
```
## <a name="citrix-adc-cpx-license-provisioning">**Citrix ADC CPX License Provisioning**</a>
By default, CPX runs with 20 Mbps bandwidth called as [CPX Express](https://www.citrix.com/en-in/products/citrix-adc/cpx-express.html) however for better performance and production deployment customer needs licensed CPX instances. [Citrix ADM](https://www.citrix.com/en-in/products/citrix-application-delivery-management/) is used to check out licenses for Citrix ADC CPX.

**Bandwidth based licensing**
For provisioning licensing on Citrix ADC CPX, it is mandatory to provide License Server information to CPX. This can be done by setting **ADMSettings.licenseServerIP** as License Server IP. In addition to this, **ADMSettings.bandWidthLicense** needs to be set true and desired bandwidth capacity in Mbps should be set **ADMSettings.bandWidth**.
For example, to set 2Gbps as bandwidth capacity, below command can be used.

```
helm repo add citrix https://citrix.github.io/citrix-helm-charts/

helm install cpx-sidecar-injector citrix/citrix-cpx-istio-sidecar-injector --namespace citrix-system --set cpxProxy.EULA=YES --set ADMSettings.licenseServerIP=<licenseServer_IP>,ADMSettings.bandWidthLicense=True --set ADMSettings.bandWidth=2000

```

## <a name="configuration-for-servicegraph">**Service Graph configuration**</a>
   Citrix ADM Service graph is an observability tool that allows user to analyse service to service communication. The service graph is generated by ADM post collection of transactional data from registered Citrix ADC instances. More details about it can be found [here](https://docs.citrix.com/en-us/citrix-application-delivery-management-service/application-analytics-and-management/service-graph.html).
   Citrix ADC needs to be provided with ADM details for registration and data export. This section lists the steps needed to deploy Citrix ADC and register it with ADM.

   1. Create secret using Citrix ADM Agent credentials, which will be used by Citrix ADC as CPX to communicate with Citrix ADM Agent:

	kubectl create secret generic admlogin --from-literal=username=<adm-agent-username> --from-literal=password=<adm-agent-password>

   2. Deploy Citrix ADC CPX sidecar injector using helm command with `ADM` details:

	helm install cpx-sidecar-injector citrix/citrix-cpx-istio-sidecar-injector --namespace citrix-system --set cpxProxy.EULA=YES --set ADMSettings.ADMIP=<ADM-Agent-IP>

> **Note:**
> If container agent is being used here for Citrix ADM, specify `PodIP` of container agent in the `ADMSettings.ADMIP` parameter.

## <a name="generate-certificate-for-application">Generate Certificate for Application </a>

Application needs TLS certificate-key pair for establishing secure communication channel with other applications. Earlier these certificates were issued by Istio Citadel and bundled in Kubernetes secret. Certificate was loaded in the application pod by doing volume mount of secret. Now `xDS-Adaptor` can generate its own certificate and get it signed by the Istio Citadel (Istiod). This eliminates the need of secret and associated [risks](https://kubernetes.io/docs/concepts/configuration/secret/#risks). 

xDS-Adaptor needs to be provided with details Certificate Authority (CA) for successful signing of Certificate Signing Request (CSR). By default, CA is `istiod.istio-system.svc` which accepts CSRs on port 15012. 
To skip this process, don't provide any value (empty string) to `certProvider.caAddr`.
```
	helm repo add citrix https://citrix.github.io/citrix-helm-charts/

        helm install cpx-sidecar-injector citrix/citrix-cpx-istio-sidecar-injector --namespace citrix-system --set cpxProxy.EULA=YES --set certProvider.caAddr=""
```

### <a name="using-third-party-service-account-tokens">Configure Third Party Service Account Tokens</a>

In order to generate certificate for application workload, xDS-Adaptor needs to send valid service account token along with Certificate Signing Request (CSR) to the Istio control plane (Citadel CA). Istio control plane authenticates the xDS-Adaptor using this JWT. 
Kubernetes supports two forms of these tokens:

* Third party tokens, which have a scoped audience and expiration.
* First party tokens, which have no expiration and are mounted into all pods.
 
 If Kubernetes cluster is installed with third party tokens, then the same information needs to be provided for automatic sidecar injection by passing `--set certProvider.jwtPolicy="third-party-jwt"`. By default, it is `first-party-jwt`.

```
        helm repo add citrix https://citrix.github.io/citrix-helm-charts/

        helm install cpx-sidecar-injector citrix/citrix-cpx-istio-sidecar-injector --namespace citrix-system --set cpxProxy.EULA=YES --set certProvider.caAddr="istiod.istio-system.svc" --set certProvider.jwtPolicy="third-party-jwt"

```

To determine if your cluster supports third party tokens, look for the TokenRequest API using below command. If there is no output, then it is `first-party-jwt`. In case of `third-party-jwt`, output will be like below.

```
# kubectl get --raw /api/v1 | jq '.resources[] | select(.name | index("serviceaccounts/token"))'

{
    "name": "serviceaccounts/token",
    "singularName": "",
    "namespaced": true,
    "group": "authentication.k8s.io",
    "version": "v1",
    "kind": "TokenRequest",
    "verbs": [
        "create"
    ]
}

```

## <a name="limitations">Limitations</a>

Citrix ADC CPX occupies certain ports for internal usage. This makes application service running on one of these restricted ports incompatible with the Citrix ADC CPX.
The list of ports is mentioned below. Citrix is working on delisting some of the major ports from the given list, and same shall be available in future releases.

#### Restricted Ports

| Sr No |Port Number|
|-------|-----------|
| 1 | 80 |
| 2 | 3010 |
| 3 | 5555 |
| 4 | 8080 |

## <a name="clean-up">Clean Up</a>

To delete the resources created for automatic injection with the release name  `cpx-sidecar-injector`, perform the following step.

    helm delete cpx-sidecar-injector

## <a name="configuration-parameters">Configuration parameters</a>

The following table lists the configurable parameters and their default values in the Helm chart.


| Parameter                      | Description                   | Default                   |
|--------------------------------|-------------------------------|---------------------------|
| `xDSAdaptor.image`                    | Image of the Citrix xDS Adaptor container                    |  quay.io/citrix/citrix-xds-adaptor:0.9.9   |
| `xDSAdaptor.imagePullPolicy`   | Image pull policy for xDS-adaptor | IfNotPresent        |
| `xDSAdaptor.secureConnect`     | If this value is set to true, xDS-adaptor establishes secure gRPC channel with Istio Pilot   | TRUE                       |
| `xDSAdaptor.logLevel`   | Log level to be set for xDS-adaptor log messages. Possible values: TRACE (most verbose), DEBUG, INFO, WARN, ERROR (least verbose) | DEBUG       | Optional|
| `xDSAdaptor.jsonLog`   | Set this argument to true if log messages are required in JSON format | false       | Optional|
| `coe.coeURL`          | Name of [Citrix Observability Exporter](https://github.com/citrix/citrix-observability-exporter) Service in the form of _servicename.namespace_  | NIL            | Optional|
| `coe.coeTracing`          | Use COE to send appflow transactions to Zipkin endpoint. If it is set to true, ADM servicegraph (if configured) can be impacted.  | false           | Optional|
| `ADMSettings.ADMIP`     | Provide the Citrix Application Delivery Management (ADM) IP address | NIL                       |
| `ADMSettings.licenseServerIP `          | Citrix License Server IP address  | NIL            | Optional |
| `ADMSettings.licenseServerPort`   | Citrix ADM port if a non-default port is used                                                                                      | 27000                                                          |
| `ADMSettings.bandWidth`          | Desired bandwidth capacity to be set for Citrix ADC CPX in Mbps  | NIL            | Optional |
| `ADMSettings.bandWidthLicense`          | To specify bandwidth based licensing  | false            | Optional |
| `istioPilot.name`                 | Name of the Istio Pilot service     | istio-pilot                                                           |
| `istioPilot.namespace`     | Namespace where Istio Pilot is running       | istio-system                                                          |
| `istioPilot.secureGrpcPort`       | Secure GRPC port where Istio Pilot is listening (Default setting)                                                                  | 15011                                                                 |
| `istioPilot.insecureGrpcPort`      | Insecure GRPC port where Istio Pilot is listening                                                                                  | 15010                                                                 |
| `istioPilot.proxyType`      | Type of Citrix ADC associated with the xDS-adaptor. Possible values are: sidecar and router.                                                                              |   sidecar|
| `istioPilot.SAN`                 | Subject alternative name for Istio Pilot which is the Secure Production Identity Framework For Everyone (SPIFFE) ID of Istio Pilot.                                   | NIL |
| `cpxProxy.netscalerUrl`   |    URL or IP address of the Citrix ADC which will be configured by Istio-adaptor.                                                            | http://127.0.0.1 |
| `cpxProxy.image`          | Citrix ADC CPX image used as sidecar proxy                                                                                                    | quay.io/citrix/citrix-k8s-cpx-ingress:13.0-79.64 |
| `cpxProxy.imagePullPolicy`           | Image pull policy for Citrix ADC                                                                                  | IfNotPresent                                                               |
| `cpxProxy.EULA`              |  End User License Agreement(EULA) terms and conditions. If yes, then user agrees to EULA terms and conditions.                                                     | NO |
| `cpxProxy.cpxSidecarMode`            | Environment variable for Citrix ADC CPX. It indicates that Citrix ADC CPX is running as sidecar mode or not.                                                                                               | YES                                                                    |
| `cpxProxy.cpxDisableProbe`            | Environment variable for Citrix ADC CPX. It indicates that Citrix ADC CPX will disable probing dynamic services. It should be enabled for multicluster setup.                                                                                               | YES                                                                    |
| `sidecarWebHook.webhookImage`   | Mutating webhook associated with the sidecar injector. It invokes a service `cpx-sidecar-injector` to inject sidecar proxies in the application pod.                                                                                      | quay.io/citrix/cpx-istio-sidecar-injector:1.0.0 |
| `sidecarWebHook.imagePullPolicy`   | Image pull policy                                                                          |IfNotPresent|
| `sidecarCertsGenerator.image`   | Certificate genrator image associated with sidecar injector. This image generates certificate and key needed for CPX sidecar injection.                                                                                      | quay.io/citrix/cpx-sidecar-injector-certgen:1.1.0 |
| `sidecarCertsGenerator.imagePullPolicy`   | Image pull policy                                                                          |IfNotPresent|
| `webhook.injectionLabelName` |  Label of namespace where automatic Citrix ADC CPX sidecar injection is required. | cpx-injection |
| `certProvider.caAddr`   | Certificate Authority (CA) address issuing certificate to application                           | istiod.istio-system.svc                          | Optional |
| `certProvider.caPort`   | Certificate Authority (CA) port issuing certificate to application                              | 15012 | Optional |
| `certProvider.trustDomain`   | SPIFFE Trust Domain                         | cluster.local | Optional |
| `certProvider.certTTLinHours`   | Validity of certificate generated by xds-adaptor and signed by Istiod (Istio Citadel) in hours. Default is 30 days validity              | 720 | Optional |
| `certProvider.clusterId`   | clusterId is the ID of the cluster where Istiod CA instance resides (default Kubernetes). It can be different value on some cloud platforms or in multicluster environments. For example, in Anthos servicemesh, it might be of the format of `cn<project-name>-<region>-<cluster_name>`. In multiCluster environments, it is the value of global.multiCluster.clusterName provided during servicemesh control plane installation              | Kubernetes | Optional |
| `certProvider.jwtPolicy`   | Service Account token type. Kubernetes platform supports First party tokens and Third party tokens.  | first-party-jwt | Optional |
| `certProvider.jwtPolicy`   | Service Account token type. Kubernetes platform supports First party tokens and Third party tokens. Usually public cloud based Kubernetes has third-party-jwt | null | Optional |

**Note:** You can use the `values.yaml` file packaged in the chart. This file contains the default configuration values for the chart.
