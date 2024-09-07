# KubeMQ Charts
KubeMQ is a Cloud Native, enterprise grade message queue broker for distributed services architecture.

KubeMQ is delivered as a small, lightweight Docker container, designed for any type of workload and architecture running in Kubernetes or any other containers orchestration system which support Docker.

## HELM
KubeMQ Helm charts required Helm v3. Please download/upgrade from [https://github.com/helm/helm](https://github.com/helm/helm)

## Add KubeMQ Helm Repository

``` 
$ helm repo add kubemq-charts  https://kubemq-io.github.io/charts
```

Verify KubeMQ helm repository charts is properly configured by:

## Update KubeMQ Helm Repository
``` 
$ helm repo update
```

## Install KubeMQ Cluster Chart

``` console 
$ helm install kubemq-crds kubemq-charts/kubemq-crds
$ helm install --wait --create-namespace -n kubemq kubemq-controller kubemq-charts/kubemq-controller
$ helm install --wait -n kubemq kubemq-cluster --set key={your-license-key} kubemq-charts/kubemq-cluster
```

## Uninstall KubeMQ Cluster Chart

To uninstall/delete the kubemq-release deployment:

``` console
$ helm uninstall -n kubemq kubemq-cluster
$ helm uninstall -n kubemq kubemq-controller
$ helm uninstall kubemq-crds
```

```

## Documentation
Please visit [https://docs.kubemq.io](https://docs.kubemq.io) for more information about KubeMQ.
