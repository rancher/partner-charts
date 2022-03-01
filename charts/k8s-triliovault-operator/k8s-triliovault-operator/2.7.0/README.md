# K8s-TrilioVault-Operator
This operator is to manage the lifecycle of TrilioVault Backup/Recovery solution. This operator install, updates and manage the TrilioVault application.

## Introduction

## Prerequisites

- Kubernetes 1.18+
- PV provisioner support
- CSI driver should be installed

### One Click Installation

In one click install for upstream operator, a cluster scope TVM custom resource `triliovault-manager` is created.

```shell script
helm repo add trilio-vault-operator https://charts.k8strilio.net/trilio-stable/k8s-triliovault-operator
helm install tvm trilio-vault-operator/k8s-triliovault-operator
```

#### One click install Configuration

The following table lists the configuration parameter of the upstream operator one click install feature and their
default values.

| Parameter                                                          | Description                                  | Default
| ---------                                                          | -----------                                  | -------
| `installTVK.enabled`                                               | 1 click install feature is enabled           | true
| `installTVK.applicationScope`                                      | scope of TVK application created             | Cluster
| `installTVK.ingressConfig.host`                                    | host of the ingress resource created         | ""
| `installTVK.ingressConfig.tlsSecretName`                           | tls secret name which contains ingress certs | ""
| `installTVK.ingressConfig.annotations`                             | annotations to be added on ingress resource  | ""
| `installTVK.ingressConfig.ingressClass`                            | ingress class name for the ingress resource  | ""
| `installTVK.ComponentConfiguration.ingressController.enabled`      | TVK ingress controller should be deployed    | true
| `installTVK.ComponentConfiguration.ingressController.service.type` | TVK ingress controller service type          | "LoadBalancer"

Check the TVM CR configuration by running following command:

```
kubectl get triliovaultmanagers.triliovault.trilio.io triliovault-manager -o yaml
```

Once the operator pod is in running state, the TVK pods getting spawned. Confirm the [TVK pods are up](#Check-TVK-Install).

## Manual Installation

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
  trilioVaultAppVersion: latest
  applicationScope: Cluster
  # User can configure the ingress hosts, annotations and TLS secret through the ingressConfig section
  ingressConfig:
    host: "trilio.co.in"
    tlsSecretName: "secret-name"
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
      enabled: true
      service:
        type: LoadBalancer
```

### Apply the Custom Resource

Apply `TVM.yaml`:

```shell
kubectl create -f TVM.yaml
```

### Check TVK Install

Check that the pods were created:

```
kubectl get pods
```

```
NAME                                                        READY   STATUS    RESTARTS   AGE
k8s-triliovault-admission-webhook-6ff5f98c8-qwmfc           1/1     Running   0          81s
k8s-triliovault-backend-6f66b6b8d5-gxtmz                    1/1     Running   0          81s
k8s-triliovault-control-plane-6c464c5d78-ftk6g              1/1     Running   0          81s
k8s-triliovault-exporter-59566f97dd-gs4xc                   1/1     Running   0          81s
k8s-triliovault-ingress-nginx-controller-867c764cd5-qhpx6   1/1     Running   0          18s
k8s-triliovault-web-967c8475-m7pc6                          1/1     Running   0          81s
tvm-k8s-triliovault-operator-66bd7d86d5-dvhzb               1/1     Running   0          6m48s
```

Check that ingress controller service is of type LoadBalancer:
```
NAME                                                 TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                      AGE
k8s-triliovault-admission-webhook                    ClusterIP      10.7.243.24    <none>           443/TCP                      129m
k8s-triliovault-ingress-nginx-controller             LoadBalancer   10.7.246.193   35.203.155.148   80:30362/TCP,443:32327/TCP   129m
k8s-triliovault-ingress-nginx-controller-admission   ClusterIP      10.7.250.31    <none>           443/TCP                      129m
k8s-triliovault-web                                  ClusterIP      10.7.254.41    <none>           80/TCP                       129m
k8s-triliovault-web-backend                          ClusterIP      10.7.252.146   <none>           80/TCP                       129m
tvm-k8s-triliovault-operator-webhook-service         ClusterIP      10.7.248.163   <none>           443/TCP                      130m                  123m
```

Check that ingress resources has the host defined by the user:
```
NAME              CLASS                           HOSTS   ADDRESS          PORTS   AGE
k8s-triliovault   k8s-triliovault-default-nginx   *       35.203.155.148   80      129m
```

You can access the TVK UI by hitting this address in your browser: https://35.203.155.148

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
