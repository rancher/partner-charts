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


## Deploy TrilioVault Cluster

- The TrilioVault custom resource name is TrilioVaultManager
- TrilioVault Operator defines this Custom Resource (CR)

For Helm v2

```bash
apiVersion: triliovault.trilio.io/v1
kind: TrilioVaultManager
metadata:
  labels:
    triliovault: triliovault
  name: triliovault-manager
  namespace: default
spec:
  trilioVaultAppVersion: v2.0.0
  helmVersion:
    version: v2
    tillerNamespace: kube-system
  applicationScope: Cluster
  #restoreNamespaces: ["kube-system", "default", "restore-ns"]
  #resources:
    #requests:
      #memory: 400Mi

```

For Helm v3

```bash
apiVersion: triliovault.trilio.io/v1
kind: TrilioVaultManager
metadata:
  labels:
    triliovault: triliovault
  name: triliovault-manager
  namespace: default
spec:
  trilioVaultAppVersion: v2.0.0
  helmVersion:
    version: v3
  applicationScope: Cluster
  #restoreNamespaces: ["kube-system", "default", "restore-ns"]
  #resources:
    #requests:
      #memory: 400Mi
```

Create 

```bash
$ kubectl create -f triliovault-manager.yaml
```

List CR of TrilioVaultManager

```bash
kubectl get triliovaultmanager
NAME                  TRILIOVAULT-VERSION   SCOPE     STATUS     RESTORE-NAMESPACES
triliovault-manager   v2.0.0                Cluster   Deployed   [kube-system default restore-ns]
```

List pods created by TrilioVaultManager CR are running

```bash
$ kubectl get pods
k8s-triliovault-admission-webhook-544b566979-4lw7q                1/1     Running     0          7d2h
k8s-triliovault-backend-5b79996f48-djzd4                          1/1     Running     0          7d2h
k8s-triliovault-control-plane-78c7d589fb-d2829                    1/1     Running     0          7d2h
k8s-triliovault-exporter-789c785968-vn7hf                         1/1     Running     0          7d2h
k8s-triliovault-ingress-controller-54c55b58cf-vw7s7               1/1     Running     0          7d2h
k8s-triliovault-web-85d58df67b-jqnln                              1/1     Running     0          7d2h
```

TrilioVault is now successfully installed on your cluster.
