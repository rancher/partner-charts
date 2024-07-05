# HPE Storage Array Exporter for Prometheus Helm chart

The [HPE Storage Array Exporter for Prometheus](https://hpe-storage.github.io/array-exporter) provides storage system information in the form of [Prometheus](https://prometheus.io/) metrics.  It can be used in combination with [HPE CSI Info Metrics Provider for Prometheus](https://scod.hpedev.io/csi_driver/metrics.html) metrics to focus on storage resources used within a Kubernetes cluster.

## Prerequisites

- Kubernetes 1.18+ (most distributions)
- Helm 3 (3.2.0+)

## Configuration

The chart has these configurable parameters and default values.

| Parameter | Description | Default |
|---------------------------|------------------------------------------------------------------------|------------------|
| acceptEula | Confirm your acceptance of the HPE End User License Agreement at https://www.hpe.com/us/en/software/licensing.html by setting this value to `true`. | `false` |
| arraySecret | The name of a Secret in the same namespace as the Helm chart installation providing storage array access information: `address` (or `backend`), `username`, and `password`. | hpe-backend |
| image.registry | The registry from which to pull container images. | `quay.io` |
| image.pullPolicy | Container image pull policy (`Always`, `IfNotPresent`, `Never`). | `IfNotPresent` |
| logLevel | Minimum severity of messages to output (`info`, `debug`, `trace`, `warn`, `error`). | `info` |
| metrics.disableIntrospection | Exclude metrics about the metrics provider itself, with prefixes such as `promhttp`, `process`, and `go`. | `false` |
| service.type | The type of Service to create, ClusterIP for access solely from within the cluster or NodePort to provide access from outside the cluster (`ClusterIP`, `NodePort`). | `ClusterIP` |
| service.port | The TCP port at which to expose access to storage array metrics within the cluster. | `9090` |
| service.nodePort | The TCP port at which to expose access to storage array metrics externally at each cluster node, if the Service type is NodePort and automatic assignment is not desired. | *none* |
| service.labels | Labels to add to the Service, for example to include target labels in a ServiceMonitor scrape configuration. | `{}` |
| service.annotations | Annotations to add to the Service, for example to configure it as a scrape target when using the Prometheus Helm chart's default configuration. | `{}` |
| serviceMonitor.enable | Create a ServiceMonitor custom resource (used with the Prometheus Operator). | `false` |
| serviceMonitor.targetLabels | List of labels on the service to add to the scraped metric. | `[]` |

The `arraySecret` parameter is required and has no default value.  A Secret used by the [HPE CSI Driver for Kubernetes](https://scod.hpedev.io/csi_driver/index.html) can be reused without modification.  Otherwise, use [this example](https://github.com/hpe-storage/co-deployments/blob/master/yaml/array-exporter/edge/hpe-array-exporter-secret.yaml) to create a new one.

The `acceptEula` value must be set to `true`, confirming your acceptance of the [HPE End User License Agreement](https://www.hpe.com/us/en/software/licensing.html).

## Installation

It's beneficial to understand how certain `Service` annotations and labels affect the deployment of the HPE Storage Array Exporter. Visit the [official documentation](https://hpe-storage.github.io/array-exporter) to learn more.

### Add the HPE Storage Helm Repo

```
helm repo add hpe-storage https://hpe-storage.github.io/co-deployments/
helm repo update
```

### Customize Settings

Use of a values.yaml file is recommended.  Retrieve the values.yaml file for the [latest version](https://github.com/hpe-storage/co-deployments/blob/master/helm/charts/hpe-array-exporter/values.yaml) or for the specific version you will install:

```
helm show values hpe-storage/hpe-array-exporter --version X.Y.Z > myvalues.yaml
```

Edit the values according to the deployment environment, including identifying (or creating) an `arraySecret` and setting `acceptEula` to confirm your acceptance of the [HPE End User License Agreement](https://www.hpe.com/us/en/software/licensing.html).

### Install

The latest release is installed by default.  Add a `--version` or `--devel` option to install a specific version or the latest pre-release chart.

Use a customized values.yaml file:

```
kubectl create ns hpe-storage
helm install [RELEASE_NAME] hpe-storage/hpe-array-exporter -n hpe-storage -f myvalues.yaml
```

Or use command line options:

```
helm install [RELEASE_NAME] hpe-storage/hpe-array-exporter -n hpe-storage \
  --set acceptEula=xxxx,arraySecret=my-array-secret
```

## Uninstallation

```
helm uninstall [RELEASE_NAME] -n hpe-storage
```

## Using the HPE Storage Array Exporter

Visit the official documentation for guidance on usage.

- [HPE Storage Array Exporter for Prometheus](https://hpe-storage.github.io/array-exporter)

## Support

The HPE Storage Array Exporter for Prometheus Helm chart is fully supported by HPE. A formal support facility for HPE storage products can be found at [SCOD](https://scod.hpedev.io/legal/support).

## Community

Submit issues, questions, and feature requests [here](https://github.com/hpe-storage/co-deployments/issues). However, see [SCOD](https://scod.hpedev.io/legal/support) for support inquiries related to your HPE storage product. You may also join our Slack community to chat with HPE folks close to this project. We hang out in `#Alletra`, `#NimbleStorage`, `#3par-primera`, and `#Kubernetes`. Sign up at [slack.hpedev.io](https://slack.hpedev.io/) and login at [hpedev.slack.com](https://hpedev.slack.com/).

## Contributing

We value feedback and contributions. If you find an issue or want to contribute, please open an issue or file a PR as described in [CONTRIBUTING.md](https://github.com/hpe-storage/co-deployments/blob/master/CONTRIBUTING.md).

## License

This chart is open source software licensed using the Apache License 2.0. See the [LICENSE](https://github.com/hpe-storage/co-deployments/blob/master/LICENSE) for details.
