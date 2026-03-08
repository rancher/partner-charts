# ACE User Roles

[ACE User Roles by AppsCode](https://github.com/kubeops/ui-server) - ACE User Roles for ByteBuilders

## TL;DR;

```bash
$ helm repo add appscode https://charts.appscode.com/stable/
$ helm repo update
$ helm search repo appscode/ace-user-roles --version=v2026.2.16
$ helm upgrade -i ace-user-roles appscode/ace-user-roles -n kubeops --create-namespace --version=v2026.2.16
```

## Introduction

This chart deploys ACE User Roles on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.21+

## Installing the Chart

To install/upgrade the chart with the release name `ace-user-roles`:

```bash
$ helm upgrade -i ace-user-roles appscode/ace-user-roles -n kubeops --create-namespace --version=v2026.2.16
```

The command deploys ACE User Roles on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall the `ace-user-roles`:

```bash
$ helm uninstall ace-user-roles -n kubeops
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the `ace-user-roles` chart and their default values.

|               Parameter                |         Description         |               Default                |
|----------------------------------------|-----------------------------|--------------------------------------|
| nameOverride                           | Overrides name template     | <code>""</code>                      |
| fullnameOverride                       | Overrides fullname template | <code>""</code>                      |
| enableClusterRoles.ace                 |                             | <code>false</code>                   |
| enableClusterRoles.appcatalog          |                             | <code>false</code>                   |
| enableClusterRoles.catalog             |                             | <code>false</code>                   |
| enableClusterRoles.cert-manager        |                             | <code>false</code>                   |
| enableClusterRoles.kubedb-ui           |                             | <code>false</code>                   |
| enableClusterRoles.kubedb              |                             | <code>false</code>                   |
| enableClusterRoles.kubestash           |                             | <code>false</code>                   |
| enableClusterRoles.kubevault           |                             | <code>false</code>                   |
| enableClusterRoles.license-proxyserver |                             | <code>false</code>                   |
| enableClusterRoles.metrics             |                             | <code>false</code>                   |
| enableClusterRoles.prometheus          |                             | <code>false</code>                   |
| enableClusterRoles.secrets-store       |                             | <code>false</code>                   |
| enableClusterRoles.stash               |                             | <code>false</code>                   |
| enableClusterRoles.virtual-secrets     |                             | <code>false</code>                   |
| annotations.helm.sh/hook               |                             | <code>pre-install,pre-upgrade</code> |
| annotations.helm.sh/hook-delete-policy |                             | <code>before-hook-creation</code>    |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm upgrade -i`. For example:

```bash
$ helm upgrade -i ace-user-roles appscode/ace-user-roles -n kubeops --create-namespace --version=v2026.2.16 --set annotations.helm.sh/hook=pre-install,pre-upgrade
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while
installing the chart. For example:

```bash
$ helm upgrade -i ace-user-roles appscode/ace-user-roles -n kubeops --create-namespace --version=v2026.2.16 --values values.yaml
```
