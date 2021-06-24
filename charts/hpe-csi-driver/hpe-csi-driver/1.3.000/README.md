# HPE CSI Driver for Kubernetes Helm chart

The [HPE CSI Driver for Kubernetes](https://scod.hpedev.io/csi_driver/index.html) leverages HPE storage platforms to provide scalable and persistent storage for stateful applications.

## Prerequisites

- Upstream Kubernetes version >= 1.15
- Most Kubernetes distributions are supported
- Recent Ubuntu, SLES, CentOS or RHEL compute nodes connected to their respective official package repositories
- Helm 3 (Version >= 3.2.0 required)

Depending on which [Container Storage Provider](https://scod.hpedev.io/container_storage_provider/index.html) (CSP) is being used, other prerequisites and requirements may apply, such as storage platform OS and features.

- [HPE Nimble Storage](https://scod.hpedev.io/container_storage_provider/hpe_nimble_storage/index.html)
- [HPE 3PAR and Primera](https://scod.hpedev.io/container_storage_provider/hpe_3par_primera/index.html)

## Configuration and installation

The following table lists the configurable parameters of the HPE-CSI chart and their default values.

|  Parameter                |  Description                                                           |  Default     |
|---------------------------|------------------------------------------------------------------------|--------------|
| logLevel                  | Log level. Can be one of `info`, `debug`, `trace`, `warn` and `error`. | info         |
| imagePullPolicy           | Image pull policy (`Always`, `IfNotPresent`, `Never`).                 | IfNotPresent |
| disableNodeConformance    | Disable automatic installation of iSCSI/Multipath Packages.            | false        |
| iscsi.chapUser            | Username for iSCSI CHAP authentication.                                | ""           |
| iscsi.chapPassword        | Password for iSCSI CHAP authentication.                                | ""           |

It's recommended to create a [values.yaml](https://github.com/hpe-storage/co-deployments/blob/master/helm/values/csi-driver) file from the corresponding release of the chart and edit it to fit the environment the chart is being deployed to. Download and edit [a sample file](https://github.com/hpe-storage/co-deployments/blob/master/helm/values/csi-driver).

These are the bare minimum required parameters for a successful deployment to an iSCSI environment if CHAP authentication is required.

```
iscsi:
  chapUser: <username>
  chapPassword: <password>
```

Tweak any additional parameters to suit the environment or as prescribed by HPE.

### Installing the chart

To install the chart with the name `hpe-csi`:

Add HPE helm repo:

```
helm repo add hpe https://hpe-storage.github.io/co-deployments
helm repo update
```

Install the latest chart:

```
helm install hpe-csi hpe/hpe-csi-driver --namespace kube-system -f myvalues.yaml
```

**Note**: values.yaml is optional if no parameters are overridden from defaults.

### Upgrading the Chart

To upgrade the chart, specify the version you want to upgrade to as below. Please do NOT re-use a full blown `values.yaml` from prior versions to upgrade to later versions. Always use `values.yaml` from corresponding release from [values.yaml](https://github.com/hpe-storage/co-deployments/blob/master/helm/values/csi-driver)

List the avaiable version of the plugin:

```
helm repo update
helm search repo hpe-csi-driver -l
```

Select the target version to upgrade as below:

```
helm upgrade hpe-csi hpe/hpe-csi-driver --namespace kube-system --version=x.x.x.x -f myvalues.yaml
```

### Uninstalling the Chart

To uninstall the `hpe-csi` chart:

```
helm uninstall hpe-csi --namespace kube-system
```

**Note**: Due to a limitation in Helm, CRDs are not deleted as part of the chart uninstall.

### Alternative install method

In some cases it's more practical to provide the local configuration via the `helm` CLI directly. Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. These will take precedence over entries in [values.yaml](https://github.com/hpe-storage/co-deployments/blob/master/helm/values/csi-driver). For example:

```
helm install hpe-csi hpe/hpe-csi-driver --namespace kube-system --set iscsi.chapUsername=admin \
--set iscsi.chapPassword=xxxxxxxx
```

## Using persistent storage with Kubernetes

Enable dynamic provisioning of persistent storage by creating a `StorageClass` API object that references a `Secret` which maps to a supported HPE primary storage backend. Refer to the [HPE CSI Driver for Kubernetes](https://scod.hpedev.io/csi_driver/using.html) documentation on [HPE Storage Container Orchestration Documentation](https://scod.hpedev.io/). Also, it's helpful to be familiar with [persistent storage concepts](https://kubernetes.io/docs/concepts/storage/volumes/) in Kubernetes prior to deploying stateful workloads.

## Support

The HPE CSI Driver for Kubernetes Helm chart is covered by your HPE support contract. Please file any issues, questions or feature requests [here](https://github.com/hpe-storage/co-deployments/issues) or contact HPE through the regular support channels. You may also join our Slack community to chat with HPE folks close to this project. We hang out in `#NimbleStorage`, `#3par-primera` and `#Kubernetes` at [hpedev.slack.com](https://hpedev.slack.com), sign up here: [slack.hpedev.io](https://slack.hpedev.io/).

## Contributing

We value all feedback and contributions. If you find any issues or want to contribute, please feel free to open an issue or file a PR. More details in [CONTRIBUTING.md](https://github.com/hpe-storage/co-deployments/blob/master/CONTRIBUTING.md)

## License

This is open source software licensed using the Apache License 2.0. Please see [LICENSE](https://github.com/hpe-storage/co-deployments/blob/master/LICENSE) for details.
