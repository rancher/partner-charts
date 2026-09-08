# Crate Operator Helm Chart

A Helm chart for installing and upgrading the [Crate Operator](https://github.com/crate/crate-operator).
The **CrateDB Kubernetes Operator** provides convenient way to run [CrateDB](https://github.com/crate/crate)
clusters inside Kubernetes.

Helm must be installed to use the charts. Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

## Prerequisites

The Crate Operator requires the CrateDB [CRD](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/#customresourcedefinitions).
It can be installed separately by installing the [Helm Chart](../cratedb-crds/) or as a dependency of this Chart.

If the CRD is already installed (via the `crate-operator-crds` Helm chart or manually), you need to pass `--set crate-operator-crds.enabled=false` when installing the Operator.

If the RBAC resources are already installed, you need to pass `--set rbac.create=false` when installing the Operator.

## Usage

Once Helm is properly set up, install the chart.

### Install from local folder

```
helm install crate-operator crate-operator
```

### Install from repo

```
helm repo add crate-operator https://crate.github.io/crate-operator
helm search repo crate-operator
helm install crate-operator crate-operator/crate-operator
```

#### Namespace

The operator is installed in the namespace `crate-operator`.
The namespace needs either to be created first:

```shell
kubectl create namespace crate-operator
```

or it will be created automatically by adding `--namespace=crate-operator --create-namespace` to the Helm command:

```shell
helm upgrade --install --atomic crate-operator crate-operator \
    --namespace=crate-operator \
    --create-namespace
```

#### Configuration

Please refer to the [configuration documentation](https://github.com/crate/crate-operator/blob/master/docs/source/configuration.rst) for further details.

### Upgrading the Operator

```
helm upgrade --atomic crate-operator crate-operator
```
