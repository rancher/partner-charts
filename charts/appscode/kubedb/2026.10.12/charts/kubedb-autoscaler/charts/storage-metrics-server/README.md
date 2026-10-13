# Storage Metrics API Server

[Kubernetes Storage Metrics API Server by AppsCode](https://github.com/kubeops/storage-metrics-server) - Kubernetes Storage Metrics API server by AppsCode

## TL;DR;

```bash
$ helm repo add appscode https://charts.appscode.com/stable/
$ helm repo update
$ helm search repo appscode/storage-metrics-server --version=v0.1.0
$ helm upgrade -i storage-metrics-server appscode/storage-metrics-server -n kubeops --create-namespace --version=v0.1.0
```

## Introduction

This chart deploys Storage Metrics API server on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.26+

## Installing the Chart

To install/upgrade the chart with the release name `storage-metrics-server`:

```bash
$ helm upgrade -i storage-metrics-server appscode/storage-metrics-server -n kubeops --create-namespace --version=v0.1.0
```

The command deploys Storage Metrics API server on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall the `storage-metrics-server`:

```bash
$ helm uninstall storage-metrics-server -n kubeops
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the `storage-metrics-server` chart and their default values.

|                Parameter                 |                                                                     Description                                                                      |               Default                |
|------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------|
| nameOverride                             | nameOverride / fullnameOverride let users keep the chart-generated names but override one or both ends.                                              | <code>""</code>                      |
| fullnameOverride                         |                                                                                                                                                      | <code>""</code>                      |
| registryFQDN                             | Docker registry FQDN used to pull the storage-metrics-server image. Set this to use a docker registry hosted at ${registryFQDN}/${registry}/${image} | <code>ghcr.io</code>                 |
| image.registry                           | Docker registry used to pull the image                                                                                                               | <code>appscode</code>                |
| image.repository                         | Name of the container image                                                                                                                          | <code>storage-metrics-server</code>  |
| image.tag                                | Container image tag; defaults to the chart appVersion when empty                                                                                     | <code>""</code>                      |
| imagePullSecrets                         | Specify an array of imagePullSecrets. Secrets must be manually created in the namespace.                                                             | <code>[]</code>                      |
| imagePullPolicy                          | Container image pull policy                                                                                                                          | <code>IfNotPresent</code>            |
| distro.openshift                         | Set true, if installed in OpenShift                                                                                                                  | <code>false</code>                   |
| distro.ubi                               | Set operator or all to use ubi images                                                                                                                | <code>""</code>                      |
| replicaCount                             |                                                                                                                                                      | <code>1</code>                       |
| extraEnv                                 | Extra environment variables.                                                                                                                         | <code>[]</code>                      |
| resources.requests.cpu                   |                                                                                                                                                      | <code>100m</code>                    |
| resources.requests.memory                |                                                                                                                                                      | <code>200Mi</code>                   |
| resources.limits.cpu                     |                                                                                                                                                      | <code>500m</code>                    |
| resources.limits.memory                  |                                                                                                                                                      | <code>500Mi</code>                   |
| securityContext.runAsNonRoot             |                                                                                                                                                      | <code>true</code>                    |
| securityContext.runAsUser                |                                                                                                                                                      | <code>65534</code>                   |
| securityContext.readOnlyRootFilesystem   |                                                                                                                                                      | <code>true</code>                    |
| securityContext.allowPrivilegeEscalation |                                                                                                                                                      | <code>false</code>                   |
| securityContext.seccompProfile.type      |                                                                                                                                                      | <code>RuntimeDefault</code>          |
| service.type                             |                                                                                                                                                      | <code>ClusterIP</code>               |
| service.port                             |                                                                                                                                                      | <code>443</code>                     |
| service.targetPort                       |                                                                                                                                                      | <code>6443</code>                    |
| apiService.create                        | Set to false if you register the APIService out-of-band (e.g. via cert-manager + apiservice-registrar).                                              | <code>true</code>                    |
| apiService.insecureSkipTLSVerify         |                                                                                                                                                      | <code>true</code>                    |
| apiService.groupPriorityMinimum          |                                                                                                                                                      | <code>100</code>                     |
| apiService.versionPriority               |                                                                                                                                                      | <code>100</code>                     |
| priorityClassName                        |                                                                                                                                                      | <code>system-cluster-critical</code> |
| nodeSelector                             |                                                                                                                                                      | <code>{}</code>                      |
| tolerations                              |                                                                                                                                                      | <code>[]</code>                      |
| affinity                                 |                                                                                                                                                      | <code>{}</code>                      |
| podDisruptionBudget.enabled              |                                                                                                                                                      | <code>false</code>                   |
| podDisruptionBudget.minAvailable         |                                                                                                                                                      | <code>1</code>                       |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm upgrade -i`. For example:

```bash
$ helm upgrade -i storage-metrics-server appscode/storage-metrics-server -n kubeops --create-namespace --version=v0.1.0 --set registryFQDN=ghcr.io
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while
installing the chart. For example:

```bash
$ helm upgrade -i storage-metrics-server appscode/storage-metrics-server -n kubeops --create-namespace --version=v0.1.0 --values values.yaml
```
