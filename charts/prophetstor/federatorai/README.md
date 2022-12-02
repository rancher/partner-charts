# <img src="https://raw.githubusercontent.com/prophetstor-ai/public/master/images/logo.png" width=60/> Federator.ai Operator
Federator.ai helps enterprises optimize cloud resources, maximize application performance, and save significant cost without excessive over-provisioning or under-provisioning of resources, meeting the service-level requirements of their applications.

Enterprises often lack understanding of the resources needed to support their applications. This leads to either excessive over-provisioning or under-provisioning of resources (CPU, memory, storage). Using machine learning, Federator.ai determines the optimal cloud resources needed to support any workload on Kubernetes and helps users find the best-cost instances from cloud providers for their applications.


**Multi-layer workload prediction**

Using machine learning and math-based algorithms, Federator.ai predicts containerized application and cluster node resource usage as the basis for resource recommendations at application level as well as at cluster node level. Federator.ai supports prediction for both physical/virtual CPUs and memories.


**Auto-scaling via resource recommendation**

Federator.ai utilizes the predicted resource usage to recommend the right number and size of pods for applications. Integrated with Datadog's WPA, applications are automatically scaled to meet the predicted resource usage.


**Application-aware recommendation execution**

Optimizing the resource usage and performance goals, Federator.ai uses application specific metrics for workload prediction and pod capacity estimation to auto-scale the right number of pods for best performance without overprovisioning.


**Multi-cloud Cost Analysis**

With resource usage prediction, Federator.ai analyzes potential cost of a cluster on different public cloud providers. It also recommend appropriate cluster nodes and instance types based on resource usage.


**Custom Datadog/Sysdig Dashboards**

Predefined custom Datadog/Sysdig Dashboards for workload prediction/recommendation visualization for cluster nodes and applications.


**SUSE/Rancher Marketplace**

Federator.ai can also be directly installed from SUSE/Rancher Marketplace. Please see the following how-to video for the installation procedure.

https://www.youtube.com/watch?v=mBAPCCAH8kg


**Additional resources**

Want more product information? Explore detailed information about using this product and where to find additional help.

* [Federator.ai Datasheet](https://www.prophetstor.com/wp-content/uploads/datasheets/Federator.ai.pdf)
* [Quick Start Guide](https://prophetstor.com/wp-content/uploads/documentation/Federator.ai/Latest%20Version/ProphetStor%20Federator.ai%20Quick%20Installation%20Guide.pdf)
* [Installation Guide](https://prophetstor.com/wp-content/uploads/2022/05/ProphetStor-Federator.ai-v5.1-Installation-Guide.pdf)
* [User Guide](https://prophetstor.com/wp-content/uploads/2022/05/Federator.ai-5.1-User-Guide.pdf)
* [Release Notes](https://prophetstor.com/wp-content/uploads/2022/05/Federator.ai-5.1-Release-Notes.pdf)
* [Company Information](https://www.prophetstor.com/)

## Prerequisites
-  The [Kubernetes](https://kubernetes.io/) version 1.16 or later.
-  The [Helm](https://helm.sh/) version is 3.x.x or later.

## Add Helm chart repository
```
helm repo add prophetstor https://prophetstor-ai.github.io/federatorai-operator-helm/
```

## Test the Helm chart repository
```
helm search repo federatorai
```

## Installing with the release name `my-name`:
```
helm install `my-name` prophetstor/federatorai --namespace=federatorai --create-namespace
```

## To uninstall/delete the `my-name` deployment:
```
helm ls --all-namespaces
helm delete `my-name` --namespace=federatorai
```

## To delete the Custom Resource Definitions (CRDs):
```
kubectl delete crd alamedaservices.federatorai.containers.ai
```


## Configuration

The following table lists some of the configurable parameters of the chart.
Their default values and other configurable parameters are specified inside values.yaml.

## Parameters

### Global parameters

| Parameter                                                      | Description                                      |
| -------------------------------------------------------------- | ------------------------------------------------ |
| global.imageRegistry                                           | Image registry                                                                                                                     |
| global.imageTag                                                | Image tag of Federator.ai                                                                                                          |
| global.imagePullPolicy                                         | Specify a imagePullPolicy                                                                                                          |
| global.imagePullSecrets                                        | Optionally specify an array of imagePullSecrets.                                                                                   |
| global.storageClassName                                        | Persistent Volume Storage Class                                                                                                    |
| global.commonAnnotations                                       | Common annotations to be added to resources                                                                                        |
| global.commonLabels                                            | Common labels to be added to resources                                                                                             |
| global.podAnnotations                                          | Annotations to be added to pods                                                                                                    |
| global.podLabels                                               | Labels to be added to pods                                                                                                         |
| global.resourcesEnabled                                        | Boolean to specify if you want to apply resources limits/requests settings                                                         |


### alamedaAi Parameters

| Parameter                                                      | Description                                      |
| -------------------------------------------------------------- | ------------------------------------------------ |
| alamedaAi.persistence.dataStorageSize                          | Persistence storage size for data volume                                                                                           |


### alamedaInfluxdb Parameters

| Parameter                                                      | Description                                      |
| -------------------------------------------------------------- | ------------------------------------------------ |
| alamedaInfluxdb.persistence.dataStorageSize                    | Persistence storage size for data volume                                                                                           |


### fedemeterInfluxdb Parameters

| Parameter                                                      | Description                                      |
| -------------------------------------------------------------- | ------------------------------------------------ |
| fedemeterInfluxdb.persistence.dataStorageSize                  | Persistence storage size for data volume                                                                                           |


### federatoraiDashboardFrontend Parameters

| Parameter                                                      | Description                                      |
| -------------------------------------------------------------- | ------------------------------------------------ |
| federatoraiDashboardFrontend.ingress.enabled                   | Enable ingress controller resource                                                                                                 |
| federatoraiDashboardFrontend.ingress.pathType                  | Ingress Path type                                                                                                                  |
| federatoraiDashboardFrontend.ingress.hostname                  | Default host for the ingress resource                                                                                              |
| federatoraiDashboardFrontend.ingress.path                      | The Path to REST. You may need to set this to '/*' in order to use this with ALB ingress controllers                               |
| federatoraiDashboardFrontend.ingress.annotations               | Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations.   |
| federatoraiDashboardFrontend.ingress.ingressClassName          | IngressClass that will be be used to implement the Ingress (Kubernetes 1.18+)                                                      |
| federatoraiDashboardFrontend.ingress.tls                       | Enable TLS configuration for the hostname defined at federatoraiDashboardFrontend.ingress.hostname parameter                       |
| federatoraiDashboardFrontend.ingress.extraHosts                | The list of additional hostnames to be covered with this ingress record.                                                           |
| federatoraiDashboardFrontend.ingress.extraPaths                | Additional arbitrary path/backend objects                                                                                          |
| federatoraiDashboardFrontend.ingress.extraTls                  | The tls configuration for additional hostnames to be covered with this ingress record.                                             |
| federatoraiDashboardFrontend.ingress.secrets                   | If you're providing your own certificates, please use this to add the certificates as secrets                                      |
| federatoraiDashboardFrontend.service.type                      | Kubernetes service type, valid value: LoadBalancer, NodePort                                                                       |
| federatoraiDashboardFrontend.service.port                      | Public service port                                                                                                                |
| federatoraiDashboardFrontend.service.targetPort                | Container port of services, use 9000 for accessing over HTTP and 9001 for accessing over HTTPS                                     |
| federatoraiDashboardFrontend.service.clusterIP                 | Specific cluster IP when service type is cluster IP. Use `None` for headless service                                               |
| federatoraiDashboardFrontend.service.nodePort                  | Kubernetes Service nodePort if service type is `NodePort`                                                                          |
| federatoraiDashboardFrontend.service.loadBalancerIP            | Load Balancer IP Adress if service type is `LoadBalancer`                                                                          |
| federatoraiDashboardFrontend.service.loadBalancerSourceRanges  | Address that are allowed when svc is `LoadBalancer`                                                                                |
| federatoraiDashboardFrontend.service.externalTrafficPolicy     | Enable client source IP preservation                                                                                               |
| federatoraiDashboardFrontend.service.healthCheckNodePort       | Specifies the health check node port (numeric port number) for the service if `externalTrafficPolicy` is set to Local.             |
| federatoraiDashboardFrontend.service.annotations               | Additional annotations for REST service                                                                                            |


### federatoraiPostgresql Parameters

| Parameter                                                        | Description                                      |
| ---------------------------------------------------------------- | ------------------------------------------------ |
| `federatoraiPostgresql.persistence.dataStorageSize`              | Persistent Volume Size for data storage          |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```shell
helm install `my-name` prophetstor/federatorai -f values.yaml --namespace=federatorai --create-namespace
```

> **Tip**: You can use the default [values.yaml](values.yaml)
