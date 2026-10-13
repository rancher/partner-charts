# Crate Operator CRDs Helm Chart

A Helm chart for installing and upgrading the CRDs for [Crate Operator](https://github.com/crate/crate-operator).
To be able to deploy the custom resource CrateDB to a Kubernetes cluster, the API needs to be extended with a Custom Resource Definition (CRD).

Helm must be installed to use the charts. Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

## Usage

Once Helm is properly set up, install the chart.

### Install from local folder

```
helm install crate-operator-crds crate-operator-crds
```

### Install from repo

```
helm repo add crate-operator https://crate.github.io/crate-operator
helm search repo crate-operator
helm install crate-operator-crds crate-operator/crate-operator-crds
```

### Upgrading the Operator

```
helm upgrade --atomic crate-operator-crds crate-operator-crds
```
