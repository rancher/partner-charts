# Quickstart

In order to install s3gw using Helm, from this repository directly, first you
must clone the repo:

    git clone https://github.com/aquarist-labs/s3gw-charts.git

Before installing, familiarize yourself with the options, if necessary provide
your own `values.yaml` file.
Then change into the repository and install using Helm:

    cd s3gw-charts
    helm install $RELEASE_NAME charts/s3gw --namespace $S3GW_NAMESPACE --create-namespace -f /path/to/your/custom/values.yaml

## Rancher

Installing s3gw via the Rancher App Catalog is made easy, the steps are as follow

- Cluster -> Projects/Namespaces - create the `s3gw` namespace.
- Storage -> PersistentVolumeClaim -> Create -> choose the `s3gw` namespace -> provide a size and name it `s3gw-pvc`.
- Apps -> Repositories -> Create `s3gw` using the s3gw-charts Git URL <https://github.com/aquarist-labs/s3gw-charts> and the main branch.
- Apps -> Charts -> Install Traefik.
- Apps -> Charts -> Install `s3gw` -> Storage -> Storage Type: `pvc` -> PVC Name: `s3gw-pvc`.

## Documentation

You can access our documentation [here](https://s3gw-docs.readthedocs.io/en/latest/helm-charts/).
