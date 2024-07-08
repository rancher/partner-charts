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
helm upgrade asserts asserts/asserts \
    --install \
    --namespace asserts \
    --create-namespace
```

Asserts uses metric label informaton to build the Entity Graph, it will use labels from service meshes (Istio, Linkerd) or from the Asserts eBPF Probe. By default the probe is not enabled, it can be enabled via a values file or from the Helm command line.

```bash
helm upgrade asserts asserts/asserts \
    --upgrade \
    --namespace asserts \
    --create-namespace \
    --set ebpfProbe.enabled=true
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

## Sizing Values

The default Helm chart values in the [values.yaml](https://github.com/asserts/helm-charts/blob/master/charts/asserts/values.yaml) file are configured to allow you to quickly get Asserts up and running. Here are some sample values files for sizing resources according to the total number of raw metrics
at the source Prometheus endpoints:

[small](https://github.com/asserts/helm-charts/blob/master/charts/asserts/small.yaml): Up to 1 million metrics

[medium](https://github.com/asserts/helm-charts/blob/master/charts/asserts/medium.yaml): 1 to 5 million metrics

[large](https://github.com/asserts/helm-charts/blob/master/charts/asserts/large.yaml): Over 5 million metrics

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
