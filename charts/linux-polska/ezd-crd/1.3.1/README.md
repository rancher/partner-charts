<!--- app-name: ezd-crd -->
# CRDs for EZD backend Helm Chart

Helm chart necessary for installtion of EZD backend chart.
For more detailed information for EZD-CRD chart please check [README](https://github.com/linuxpolska/ezd-rp/blob/main/README.md)

## TL;DR

```console
helm repo add lp-ezd https://linuxpolska.github.io/ezd-rp
helm upgrade --install --create-namespace ezd-crd -n default lp-ezd/ezd-crd
```

## Introduction

This chart bootstraps a set of operatos and CRDs on a [Kubernetes](https://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

Linux Polska charts can be served by [Rancher Apps & Marketplace](https://ranchermanager.docs.rancher.com/pages-for-subheaders/helm-charts-in-rancher) for deployment and management of Helm Charts in clusters.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure

## Installing the Chart

Add repository necessary for installation:

```console
helm repo add lp-ezd https://linuxpolska.github.io/ezd-rp
helm repo update
```

To install the chart with the release name `my-release`:

```console
helm upgrade --install --create-namespace ezd-crd -n default lp-ezd/ezd-crd
```

The command deploys operators on the Kubernetes cluster in the default configuration. For more detailed information regarding parameters please check our [README](https://github.com/linuxpolska/ezd-rp/blob/main/README.md).

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
helm uninstall ezd-crd
```

The command removes all the Kubernetes components but no CRDs

To delete the CRDs  associated with `my-release`:

```console

kubectl get crd -o name | grep -E "(postgresql.cnpg.io|rabbitmqclusters.rabbitmq.com)" | xargs kubectl delete 

```

> **Note**: Deleting the CRDs will delete all data as well. Please be cautious before doing it.

For more detailed information regarding installation of ezd-crd please refer to [INSTALLATION](https://github.com/linuxpolska/ezd-rp/blob/main/INSTALLATION.md)

## Compability with NASK ezdrp version

Chart ezd-crd was tested with chart version up to 19.4.15 (application version up to 1.2024-19.4).

## Configuration and parameters

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments:

```console
helm search repo lp-ezd
helm show values lp-ezd/ezd-crd
```

## Components version
- redis_operator: 0.15.0-golang-1.17-r1
- cluster_operator: 2.6.0-golang-1.20-r1
- cloudnative-pg: 1.22.0-debian-11-r1

