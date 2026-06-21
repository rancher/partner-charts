# kubemq-crds

`kubemq-crds` is the Helm chart that installs the Custom Resources Definition
required by the KubeMQ stack. It should be installed before installing
`kubemq-controller`, `kubemq-cluster` and `kubemq-connector` charts.

## Installing

For example:
```console
$ helm repo add kubemq-charts  https://kubemq-io.github.io/charts
$ helm install --create-namespace -n kubemq kubemq-crds kubemq-charts/kubemq-crds
```

For a more comprehensive documentation about how to install the whole KubeMQ
stack, check the `kubemq-controller` ,`kubemq-cluster` and `kubemq-connector` charts documentation out.

## Upgrading the charts

Please refer to the release notes of each version of the helm charts.
These can be found [here](https://github.com/kubemq/helm-charts/releases).

## Uninstalling the charts

To uninstall/delete kubemq-crds use the following command:

```console
$ helm uninstall -n kubemq kubemq-crds
```

The commands remove all the Kubernetes components associated with the chart.
Keep in mind that the chart is required by the `kubemq-controller`, `kubemq-cluster` and `kubemq-connector` charts.

If you want to keep the history use `--keep-history` flag.
