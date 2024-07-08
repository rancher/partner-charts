# Asserts eBPF Probe

[Asserts](http://www.asserts.ai) uses metric label informaton to build an Entity Graph, it will use labels from service meshes (Istio, Linkerd) or from the Asserts eBPF Probe which we cover here.

## Introduction

This chart bootstraps an Asserts eBPF Probe Daemonset on a [Kubernetes](https://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.17+
- Helm 3.2.0+
- Linux kernel version >= 4.16

## Installing the Chart

```bash
helm repo add asserts https://asserts.github.io/helm-charts
helm repo update
helm upgrade ebpf-probe asserts/ebpf-probe \
    --install \
    --namespace asserts \
    --create-namespace
```

Note that the podMonitor is enabled by default. This will allow a Prometheus instance installed using Prometheus-Operator to scrape the metrics emitted by the service. You may need to set `podMonitor.extraLabels` as shown in `values.yaml` depending on your Prometheus-Operator setup.

## Upgrading the Chart

```bash
helm repo update
helm upgrade --install ebpf-probe asserts/ebpf-probe -n asserts
```

## Uninstalling the Chart

To uninstall/delete the `ebpf-probe` deployment:

```console
helm delete ebpf-probe -n asserts
```