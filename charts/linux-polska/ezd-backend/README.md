<!--- app-name: ezd-backend -->
# LP backend for EZD RP 

Services necessary to run EZD RP application provided by NASK. 
For more detailed information for EZD-BACKEND chart please check [README](https://github.com/linuxpolska/ezd-rp/blob/main/README.md)

## TL;DR

```console
helm repo add lp-ezd https://linuxpolska.github.io/ezd-rp
helm upgrade --install --create-namespace ezd-backend -n ezd-rp lp-ezd/ezd-backend
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
helm repo add lp-ezd https://github.com/linuxpolska/ezd-rp
helm repo update
```

To install the chart with the release name `my-release`:

```console
helm upgrade --install --create-namespace ezd-backend -n ezd-rp le-ezd/ezd-backend
```

The command deploys postgresql, rabbitmq, redis on the Kubernetes cluster in the default configuration. For more detailed information regarding parameters please check our [README](https://github.com/linuxpolska/ezd-rp/blob/main/README.md).

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `ezd-backend` deployment:

```console
helm -n default uninstall ezd-backed
```

> **Note**: Deleting the helm chart will delete all data as well. Please be cautious before doing it.

> **Note**: Remove helm chart before remove CRDs for LP Backend.

For more detailed information regarding installation of ezd-backend please refer to [INSTALLATION](https://github.com/linuxpolska/ezd-rp/blob/main/INSTALLATION.md)

## Compability with NASK ezdrp version

Chart ezd-crd was tested with chart version up to 19.4.15 (application version up to 1.2024-19.4).

## Configuration and parameters

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments:

```console
helm search repo lp-ezd
helm show values lp-ezd/ezd-backend
```

## Components version
- mongodb: 5.0.23-debian-11-r1
- redis: 7.0.12-alpine-3.15-r1
- rabbitmq: 3.12.12-management-ubuntu-22.04-r1
- postgresql: 15.5-postgres-15.5-bullseye-r1
