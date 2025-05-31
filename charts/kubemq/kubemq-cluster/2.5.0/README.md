# kubemq-cluster

`kubemq-cluster` is the Helm chart that installs the KubeMQ Cluster.

## Installing

For example:
```console
$ helm repo add kubemq-charts  https://kubemq-io.github.io/charts
$ helm install --create-namespace -n kubemq kubemq-cluster kubemq-charts/kubemq-cluster
```

## Using Private Container Registries

KubeMQ Cluster supports pulling images from private container registries. To use private registries:

1. **Create a registry secret:**

```console
$ kubectl create secret docker-registry my-registry-secret \
  --docker-server=my-private-registry.com \
  --docker-username=myuser \
  --docker-password=mypassword \
  --docker-email=myemail@example.com \
  --namespace=kubemq
```

2. **Install the cluster with the registry secret:**

```console
$ helm install --create-namespace -n kubemq kubemq-cluster kubemq-charts/kubemq-cluster \
  --set key={your-license-key} \
  --set imagePullSecrets[0].name=my-registry-secret
```

3. **Using values file:**

Create a `values.yaml` file:
```yaml
key: your-license-key
imagePullSecrets:
  - name: my-registry-secret
```

Then install:
```console
$ helm install --create-namespace -n kubemq kubemq-cluster kubemq-charts/kubemq-cluster -f values.yaml
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
