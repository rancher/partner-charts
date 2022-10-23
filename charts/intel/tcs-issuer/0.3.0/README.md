# Trusted Certificate Issuer Helm chart

Trusted Certificate Service (TCS) is a K8s service to protect signing keys using Intel's SGX technology. Kubernetes certificate signing request (CSR) and cert-manager CertificateRequest APIs are both supported.

This document covers how to install Trusted Certificate Service (TCS) issuer (TCI) by using Helm charts.

To learn more check the documentation [here](https://github.com/intel/trusted-certificate-issuer).

## Prerequisites

- Helm 3.x
- Kubernetes cluster with SGX node
- cert-manager Custom Resource Definitions ([CRDs](https://cert-manager.io/docs/installation/helm/#3-install-customresourcedefinitions))

## Installing the Chart

Use the following command to install TCI (to namespace `intel-system` which will be created).

The Intel's Helm charts repository:

```console
$ helm repo add intel https://intel.github.io/helm-charts
$ helm repo update
```
Install the chart:

> NOTE: This will also install the CRDs.

```console
$ helm install tci intel/tcs-issuer -n intel-system --create-namespace
```

Use the following command to verify the installation status.

```console
$ helm ls -n intel-system
```

## Uninstalling the Chart

In case you want to uninstall TCI, use the following command:

> NOTE: the below command does not uninstall the CRDs. 

```console
$ helm delete tci -n intel-system
```

## Configuration

The following table lists the configurable parameters of the TCS issuer chart and their default values. You can change the default values either via `helm --set <parameter=value>` or editing the `values.yaml` and passing the file to helm via `helm install -f values.yaml ...` option.

| Parameter | Description | Default 
| --- | --- | --- |
| `image.hub`| Image repository | intel |
| `image.name`| Image name | trusted-certificate-issuer |
| `image.tag`| Image tag | Chart's appVersion |
| `image.pullPolicy`| Image pull policy | IfNotPresent |
| `controllerExtraArgs`| List of extra arguments passed to the controller  | <empty> |
| `imagePullSecrets`| Array of secrets pull an image from a private container image registry or repository  | <empty> |
| `pkcs11.sopin`| Create service account | V0lwbUJCybc2Oc6M06Vz |
| `pkcs11.userpin`| Create service account | U3BnbGIyTUl3ZV9lSHUy |
| `serviceAccount.create`| Create service account | true |
| `serviceAccount.annotations`| Dictionary of service account annotations | <empty> |
| `serviceAccount.name`| Name of the service account | Full name of the chart |
| `podAnnotations`| Dictionary of pod annotations | sgx.intel.com/quote-provider: aesmd |
| `podSecurityContext`| Dictionary of pod security context settings | <empty> |
| `service.type`| Service type | ClusterIP |
| `service.port`| Service port | 8443 |
| `resources.limits.cpu`| CPU limit | 500m |
| `resources.limits.memory`| Memory limit | 100Mi |
| `resources.limits.sgx.intel.com/enclave`| SGX enclave limit | 1 |
| `resources.limits.sgx.intel.com/epc`| SGX epc memory limit | 512Ki |
| `resources.requests.cpu`| CPU request | 100m |
| `resources.requests.memory`| Memory request | 20Mi |
| `resources.requests.sgx.intel.com/enclave`| SGX enclave request | 1 |
| `resources.requests.sgx.intel.com/epc`| SGX epc memory request | 512Ki |
| `nodeSelector`| Dictionary of node selector settings | <empty> |
| `tolerations`| Array of tolerations settings | <empty> |
| `affinity`| Dictionary of affinity settings | <empty> |


