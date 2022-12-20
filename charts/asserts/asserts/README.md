# Asserts

[Asserts](http://www.asserts.ai) is a metrics intelligence platform built on Prometheus’s open ecosystem. Asserts scans your metrics to build a dependency graph and then analyzes them using Asserts's [SAAFE](https://docs.asserts.ai/understanding-saafe-model) model.

## Introduction

This chart bootstraps an [Asserts](https://www.asserts.ai) deployment on a [Kubernetes](https://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.17+
- Helm 3.2.0+
- PV provisioner support for the underlying infrastructure
- A Prometheus compatible endpoint with [kube-state-metrics](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-state-metrics) and [node-exporter](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-node-exporter)

## Installing the Chart

```bash
helm repo add asserts https://asserts.github.io/helm-charts
helm repo update
helm upgrade --install asserts asserts/asserts -n asserts --create-namespace
```

There any many configuration options such as PagerDuty and Slack integrations. These can be configured with a values file.
View all install configuration options [here](https://github.com/asserts/helm-charts/blob/master/charts/asserts/values.yaml).

## Verify and Access

When Asserts is spinning up for the first time, it usually takes about 3-4 minutes
but could take longer depending on the hardware resources allocated (e.g. a kind/k3d cluster).

Once all containers are initialized and running:

```bash
kubectl get pods -l app.kubernetes.io/instance=asserts -n asserts
```

You can then login to the asserts-ui by running:

```bash
kubectl port-forward svc/asserts-ui 8080 -n asserts
```

And opening your browser to [http://localhost:8080](http://localhost:8080), where you will be directed to the Asserts Registration page. There you can acquire a license.

## Acquire a License

Acquire a trial license by following [these steps](https://docs.asserts.ai/getting-started/self-hosted/helm-chart#acquire-a-license)

## Configuring a Prometheus DataSource

Configure your Prometheus DataSource which Asserts will connect to and query by following [these instructions](https://docs.asserts.ai/integrations/data-source/prometheus). Once you're connected, you can see the data and start observing!

## Upgrading the Chart

```bash
helm repo update
helm upgrade --install asserts asserts/asserts -n asserts
```
## Uninstalling the Chart

To uninstall/delete the `asserts` deployment:

```console
helm delete asserts -n asserts
```

The command removes all the Kubernetes components but PVC's associated with the chart and deletes the release.

To delete the PVC's associated with `asserts`:

```bash
kubectl delete pvc -l app.kubernetes.io/instance=asserts -n asserts
```

> **Note**: Deleting the PVC's will delete all asserts related data as well.
