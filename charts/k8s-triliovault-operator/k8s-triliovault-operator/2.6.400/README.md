# K8s-TrilioVault-Operator
This operator is to manage the lifecycle of TrilioVault Backup/Recovery solution. This operator install, updates and manage the TrilioVault application.

## Introduction

## Prerequisites

- Kubernetes 1.18+
- Alpha feature gates should be enabled
- PV provisioner support
- CSI driver should be installed

## Installation

To install the operator on local setup just run the latest helm charts inside this repo

```shell script
helm repo add trilio-vault-operator https://charts.k8strilio.net/trilio-stable/k8s-triliovault-operator
helm install tvm trilio-vault-operator/k8s-triliovault-operator
```

Now, create a TrilioVaultManager CR to install the TrilioVault for Kubernetes. You can provide the custom configurations for the TVK resources as follows:

```
apiVersion: triliovault.trilio.io/v1
kind: TrilioVaultManager
metadata:
  labels:
    triliovault: k8s
  name: tvk
spec:
  trilioVaultAppVersion: 2.5.0
  applicationScope: Cluster
  # TVK components configuration, currently supports control-plane, web, exporter, web-backend, ingress-controller, admission-webhook.
  # User can configure resources for all componentes and can configure service type and host for the ingress-controller
  componentConfiguration:
    web-backend:
      resources:
        requests:
          memory: "400Mi"
          cpu: "200m"
        limits:
          memory: "2584Mi"
          cpu: "1000m"
    ingress-controller:
      service:
        type: LoadBalancer
      host: "trilio.co.in"
```

### Apply the Custom Resource

Apply `TVM.yaml`:

```shell
kubectl create -f TVM.yaml
```

Check that the pods were created:

```
kubectl get pods
```

```
NAME                                                 READY   STATUS    RESTARTS   AGE
k8s-triliovault-admission-webhook-6ff5f98c8-qwmfc    1/1     Running   0          81s
k8s-triliovault-backend-6f66b6b8d5-gxtmz             1/1     Running   0          81s
k8s-triliovault-control-plane-6c464c5d78-ftk6g       1/1     Running   0          81s
k8s-triliovault-exporter-59566f97dd-gs4xc            1/1     Running   0          81s
k8s-triliovault-ingress-controller-84cf46848-tkcdz   1/1     Running   0          18s
k8s-triliovault-web-967c8475-m7pc6                   1/1     Running   0          81s
tvm-k8s-triliovault-operator-66bd7d86d5-dvhzb        1/1     Running   0          6m48s
```

Check that ingress controller service is of type LoadBalancer:
```
k8s-triliovault-admission-webhook              ClusterIP      10.255.241.108   <none>          443/TCP                      2m7s
k8s-triliovault-ingress-gateway                LoadBalancer   10.255.254.153   34.75.176.146   80:30737/TCP,443:30769/TCP   2m7s
k8s-triliovault-web                            ClusterIP      10.255.245.52    <none>          80/TCP                       2m7s
k8s-triliovault-web-backend                    ClusterIP      10.255.250.166   <none>          80/TCP                       2m7s
kubernetes                                     ClusterIP      10.255.240.1     <none>          443/TCP                      6m9s
tvm-k8s-triliovault-operator-webhook-service   ClusterIP      10.255.249.77    <none>          443/TCP                      3m22s
```

Check that ingress resources has the host defined by the user:
```
NAME                             CLASS   HOSTS          ADDRESS   PORTS   AGE
k8s-triliovault-ingress-master   nginx   trilio.co.in             80      98s
k8s-triliovault-ingress-minion   nginx   trilio.co.in             80      98s

```

## Delete

```shell
kubectl delete -f TVM.yaml
```

## Uninstall

To uninstall/delete the operator helm chart :

```bash
helm uninstall tvm
```

## TrilioVaultManager compatibility

The following table captures the compatibility matrix of the TrilioVault Manager against TVK:

| TVM Version | TVK 2.5.2 | TVK 2.5.1 | TVK 2.5.0 | TVK 2.1.0 | TVK 2.0.5 | TVK 2.0.4 | TVK 2.0.3 | TVK 2.0.2 | TVK 2.0.1 |
|-------------|-----------|-----------|-----------|-----------|-----------|-----------|-----------|-----------|-----------|
| 2.5.2       |    yes    |    yes    |    yes    |    yes    |    yes    |    yes    |    yes    |    yes    |    yes    |
| 2.5.0       |    no     |    yes    |    yes    |    yes    |    yes    |    yes    |    yes    |    yes    |    yes    |
| v2.1.0      |    no     |    no     |    no     |    yes    |    yes    |    yes    |    yes    |    yes    |    yes    |
| v2.0.5      |    no     |    no     |    no     |    yes    |    yes    |    yes    |    yes    |    yes    |    yes    |
| v2.0.2      |    no     |    no     |    no     |    yes    |    yes    |    yes    |    yes    |    yes    |    yes    |
| v2.0.1      |    no     |    no     |    no     |    yes    |    yes    |    yes    |    yes    |    yes    |    yes    |
| v2.0.0      |    no     |    no     |    no     |    yes    |    yes    |    yes    |    yes    |    yes    |    yes    |
