# kubemq-controller

`kubemq-controller` is the Helm chart that installs the KubeMQ Operator and
required by the KubeMQ stack. It should be installed before installing
`kubemq-cluster` and `kubemq-connector` charts.

## Installing

For example:
```console
$ helm repo add kubemq-charts  https://kubemq-io.github.io/charts
$ helm install -n kubemq kubemq-controller kubemq-charts/kubemq-controller
```

For a more comprehensive documentation about how to install the KubeMQ Cluster and KubeMQ Connector, check the `kubemq-cluster` and `kubemq-connector` charts documentation out.

## Upgrading the charts

Please refer to the release notes of each version of the helm charts.
These can be found [here](https://github.com/kubemq/helm-charts/releases).

## Uninstalling the charts

To uninstall/delete kubemq-controller use the following command:

```console
$ helm uninstall -n kubemq kubemq-controller
```

The commands remove all the Kubernetes components associated with the chart.
Keep in mind that the chart is required by the `kubemq-cluster` and `kubemq-connector` charts.

If you want to keep the history use `--keep-history` flag.
