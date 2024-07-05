# kubemq-cluster

`kubemq-cluster` is the Helm chart that installs the KubeMQ Cluster.

## Installing

For example:
```console
$ helm repo add kubemq-charts  https://kubemq-io.github.io/charts
$ helm install --create-namespace -n kubemq kubemq-cluster kubemq-charts/kubemq-cluster
```
## Upgrading the charts

Please refer to the release notes of each version of the helm charts.
These can be found [here](https://github.com/kubemq/helm-charts/releases).

## Uninstalling the charts

To uninstall/delete kubemq-cluster use the following command:

```console
$ helm uninstall -n kubemq kubemq-cluster
```
The commands remove all the Kubernetes components associated with the chart.

If you want to keep the history use `--keep-history` flag.
