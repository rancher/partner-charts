# Asserts

[Asserts](http://www.asserts.ai) is a metrics intelligence platform built on Prometheus’s open ecosystem. Asserts scans your metrics to build a dependency graph and then analyzes them using Asserts's [SAAFE](https://docs.asserts.ai/understanding-saafe-model) model.

## Introduction

This chart bootstraps an [Asserts](https://www.asserts.ai) deployment on a [Kubernetes](https://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.17+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure
- A Prometheus compatible endpoint to query
- [kube-state-metrics](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-state-metrics) (metrics from the Prometheus endpoint)
- [node-exporter](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-node-exporter) (metrics from the Prometheus endpoint)

## Installing the Chart

### You ARE running Prometheus-Operator in the same cluster you are installing Asserts

```bash
helm repo add asserts https://asserts.github.io/helm-charts
helm repo update
helm install asserts asserts/asserts -n asserts --create-namespace
```

### You ARE NOT running Prometheus-Operator in the same cluster as where Asserts is installed

Create a values file, here we will call it `values.yaml`:

```yaml
## Asserts cluster env and site
##
## IGNORE IF RUNNING Promtheus-Operator!!!
##
## This is required in order for Asserts to scrape a
## and monitor itself. This should be set to the env and site
## of the cluster asserts is being installed in.
## This means that the env and site of the datasource
## for this cluster (set in the Asserts UI after installing)
assertsClusterEnv: <your-env>
# optional (e.g. us-west-2)
assertsClusterSite: ""

# Set since not running Prometheus-Operator (default is true)
serviceMonitor:
  enabled: false
```

```bash
helm repo add asserts https://asserts.github.io/helm-charts
helm repo update
helm install asserts asserts/asserts -n asserts -f values.yaml --create-namespace
```

## Verify and Access

Once all containers are initialized and running:

```bash
kubectl get pods -l app.kubernetes.io/instance=asserts
```

You can then login to the asserts-ui by running:

```bash
kubectl port-forward svc/asserts-ui 8080
```

And opening your browser to [http://localhost:8080](http://localhost:8080)
you will be directed to the Asserts Registration page. There you can acquire
a license as seen [here](https://docs.asserts.ai/getting-started/self-hosted/helm-chart#see-the-data)

## Configuring Promethueus DataSources

Configure your Prometheus DataSource which Asserts will connect to
and query by following [these instructions](https://docs.asserts.ai/integrations/data-source/prometheus)

## Uninstalling the Chart

To uninstall/delete the `asserts` deployment:

```console
helm delete asserts
```

The command removes all the Kubernetes components but PVC's associated with the chart and deletes the release.

To delete the PVC's associated with `asserts`:

```bash
kubectl delete pvc -l app.kubernetes.io/instance=asserts
```

> **Note**: Deleting the PVC's will delete all asserts related data as well.
