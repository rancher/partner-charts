# TrilioVault for Kubernetes

[K8s-TrilioVault-Operator](https://trilio.io) is an operator designed to manage
the K8s-TrilioVault Application Lifecycle.

This operator is to manage the lifecycle of TrilioVault Backup/Recovery solution. This operator install, updates and manage the TrilioVault application.

Introduction:

Prerequisites:

Kubernetes 1.17+
Alpha feature gates should be enabled
PV provisioner support
CSI driver should be installed

Installation:

To install the chart with the operator name trilio:

helm install k8s-triliovault-operator triliovault-operator/k8s-triliovault-operator

# For helm version 3

helm install triliovault-operator triliovault-operator/k8s-triliovault-operator

The command deploys the Triliovault for Kubernetes Operator with the default configuration.

Uninstall:

To uninstall/delete the chart trilio :

# For helm version 3
helm uninstall k8s-triliovault-operator

For more information around TVM manager installation, please follow below link:
https://docs.trilio.io/kubernetes/use-triliovault/installing-triliovault
