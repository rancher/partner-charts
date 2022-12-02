# Quickstart

To install s3gw using Helm add the chart to your Helm repos and then run `helm
install`:

```bash
helm add repo s3gw https://aquarist-labs.github.io/s3gw-charts/
helm --namespace s3gw-system install s3gw s3gw/s3gw --create-namespace
```

In order to install s3gw using Helm, from this repository directly, first you
must clone the repo:

```bash
git clone https://github.com/aquarist-labs/s3gw-charts.git
```

Before installing, familiarize yourself with the options, if necessary provide
your own `values.yaml` file.
Then change into the repository and install using Helm:

```bash
cd s3gw-charts
helm install $RELEASE_NAME charts/s3gw \
  --namespace $S3GW_NAMESPACE \
  --create-namespace \
  -f /path/to/your/custom/values.yaml
```

## Rancher

Installing s3gw via the Rancher App Catalog is made easy, the steps are as follows:

- Cluster -> Projects/Namespaces - create the `s3gw` namespace.
- Apps -> Repositories -> Create `s3gw` using the s3gw-charts Git URL
  <https://aquarist-labs.github.io/s3gw-charts/> and the `main` branch.
- Apps -> Charts -> Install `Traefik`.
- Apps -> Charts -> Install `s3gw`. Select the `s3gw` namespace previously created.
  A `pvc` for `s3gw` will be created automatically during installation.

## Documentation

You can access our documentation [here][1].

[1]: https://s3gw-docs.readthedocs.io/en/latest/helm-charts/
