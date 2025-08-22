## General

### Are you looking for more information?

1. Documentation: https://www.rabbitmq.com/kubernetes/operator/install-operator
2. Chart Source: https://github.com/bitnami/charts/tree/main/bitnami/rabbitmq-cluster-operator

## Before Installation

> **Note:**
> no action required

## After Installation

> **Note:**
> no action required

## Before Upgrade

> **Note:**
> no action required

## After Upgrade

> **Note:**
> no action required

## Tips and Tricks

> **Note:**
> no tips and tricks

## Known Issues

> **Note:**
> Notify us: https://github.com/SourceMation/charts/issues

## CLI installation

### Preparation

```bash
export RELEASE_NAME=rabbitmq-ope
export CHART_NAME=rabbitmq-operator
export CHART_VERSION=0.1.14
export RELEASE_NAMESPACE=lp-system

kubectl create ns ${RELEASE_NAMESPACE}
kubectl config set-context --current --namespace ${RELEASE_NAMESPACE}
```

### Go go helm

```bash
helm -n ${RELEASE_NAMESPACE} upgrade --install ${RELEASE_NAME} \
${CHART_NAME} --repo https://charts.sourcemation.com/ \
--version ${CHART_VERSION}
```

### Validation and Testing

```bash
kubectl -n ${RELEASE_NAMESPACE} get all
helm -n ${RELEASE_NAMESPACE} test ${RELEASE_NAME}
```

## CLI removing

```bash
helm -n ${RELEASE_NAMESPACE} uninstall ${RELEASE_NAME}
kubectl get crd -o name | grep 'rabbitmq.com' | xargs kubectl delete
```
