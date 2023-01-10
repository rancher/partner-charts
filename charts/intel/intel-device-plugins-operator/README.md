# Intel Device Plugins Operator Helm Chart

[Intel Device Plugins for Kubernetes](https://github.com/intel/intel-device-plugins-for-kubernetes) Helm charts for installing the operator. Operator installation is manadtory after which each device plugin can be installed via its own Helm chart.
## Prerequisites
- [cert-manager](https://cert-manager.io/docs/installation/helm)
- [Node Feature Discovery NFD](https://kubernetes-sigs.github.io/node-feature-discovery/master/get-started/deployment-and-usage.html) [optional]

## Get Helm Repository Info
```
helm repo add intel https://intel.github.io/helm-charts/
helm repo update
```

You can execute `helm search repo intel` command to see pulled charts [optional].

## Install Helm Chart
CRDs of the device plugin operator are installed as part of the chart.

```
helm install device-plugin-operator intel/intel-device-plugins-operator [flags]
```

## Upgrade Chart
```
helm upgrade device-plugin-operator intel/intel-device-plugins-operator [flags]
```

## Uninstall Chart
```
helm uninstall device-plugin-operator
```
CRDs are not uninstalled.

## Configuration
See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments:

```console
helm show values intel/intel-device-plugins-operator
```

You may also run `helm show values` on this chart's dependencies for additional options.

|parameter| value |
|---------|-----------|
| `hub` | `intel` |
| `tag` | `` |
| `pullPolicy` | `IfNotPresent` |