# K8s-TrilioVault-Operator
This operator is to manage the lifecycle of TrilioVault Backup/Recovery solution. This operator install, updates and manage the TrilioVault application.

## Introduction

## Prerequisites

- Kubernetes 1.13+
- Alpha feature gates should be enabled
- PV provisioner support
- CSI driver should be installed

## Installation

To install the chart with the operator name `trilio`:

```bash
# For helm version 2
helm install --name trilio k8s-triliovault-operator

# For helm version 3
helm install --name-template trilio k8s-triliovault-operator
```

The command deploys the K8s-triliovault-operator with the default configuration.

## Uninstall

To uninstall/delete the chart `trilio` :

```bash
# For helm version 2
helm delete trilio --purge

# For helm version 3
helm uninstall trilio
```

## Configuration

TODO: Add possible configuration in helm chart.
