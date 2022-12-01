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

* [Federator.ai Datasheet](https://prophetstor.com/wp-content/uploads/datasheets/Federator.ai.pdf)
* [Quick Start Guide](https://prophetstor.com/wp-content/uploads/documentation/Federator.ai/Latest%20Version/ProphetStor%20Federator.ai%20Quick%20Installation%20Guide.pdf)
* [Installation Guide](https://prophetstor.com/wp-content/uploads/2021/08/ProphetStor-Federator.ai-v4.7.0-Installation-Guide-v1.0.pdf)
* [User Guide](https://prophetstor.com/wp-content/uploads/2021/11/Federator.ai-User-Guide-4.7.2.pdf)
* [Release Notes](https://prophetstor.com/wp-content/uploads/2021/11/Federator.ai-4.7.2-Release-Notes.pdf)
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

The following table lists the configurable parameters of the chart and their default values are specfied insde values.yaml.

| Parameter                                                      | Description                                   |
| -------------------------------------------------------------- | --------------------------------------------- |
| `image.pullPolicy`                                             | Container pull policy                         |
| `image.repository`                                             | Image for Federator.ai operator               |
| `image.tag`                                                    | Image Tag for Federator.ai operator           |
| `federatorai.imageLocation`                                    | Image Location for services containers        |
| `federatorai.version`                                          | Image Tag for services containers             |
| `federatorai.persistence.enabled`                              | Enable persistent volumes                     |
| `federatorai.persistence.storageClass`                         | Storage Class Name of persistent volumes      |
| `federatorai.persistence.storages.logStorage.size`             | Log volume size                               |
| `federatorai.persistence.aiCore.dataStorage.size`              | AICore data volume size                       |
| `federatorai.persistence.influxdb.dataStorage.size`            | Influxdb data volume size                     |
| `federatorai.persistence.fedemeterInfluxdb.dataStorage.size`   | Fedemeter influxdb data volume size           |
| `services.dashboardFrontend.nodePort`                          | Port of the Dashboard service                 |
| `services.rest.nodePort`                                       | Port of the REST service                      |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```shell
helm install `my-name` prophetstor/federatorai -f values.yaml --namespace=federatorai --create-namespace
```

> **Tip**: You can use the default [values.yaml](values.yaml)
