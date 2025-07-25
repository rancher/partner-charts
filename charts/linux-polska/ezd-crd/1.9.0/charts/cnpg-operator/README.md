## General

### Are you looking for more information?

1. Based on: https://github.com/cloudnative-pg/cloudnative-pg.git
2. Documentation: https://cloudnative-pg.io/docs/
3. Chart Source: https://github.com/cloudnative-pg/charts.git


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
#### Error: Unable to continue with install: ConfigMap "cnpg-controller-manager-config" in namespace "lp-system" exists and cannot be imported into the current release: invalid ownership metadata; annotation validation error: key "meta.helm.sh/release-name" must equal "aaaa": current value is "bbbb"

Reason: Helm is trying to install a release named 'aaaa', but there’s already a resource (ConfigMap cnpg-controller-manager-config) in the lp-system namespace that belongs to another Helm release called 'bbbb'.

Soloution:

1. Use the same release name as before (bbbb)

```bash
helm upgrade --install bbbb -n lp-system ...
```

2. Delete the old Helm release (if you don’t need it)

```bash
helm uninstall bbbb -n lp-system
```

## CLI installation

### Preparation

```bash
export RELEASE_NAME=cnpg-operator
export CHART_NAME=cnpg-operator
export RELEASE_NAMESPACE=lp-system
export CHART_VERSION=0.2.3

kubectl create ns ${RELEASE_NAMESPACE}
kubectl config set-context --current --namespace ${RELEASE_NAMESPACE}
```

### Go go helm

``` bash
helm -n ${RELEASE_NAMESPACE} upgrade --install ${RELEASE_NAME} \
${CHART_NAME} --repo https://charts.sourcemation.com/ \
-f /tmp/values.yaml \
--version ${CHART_VERSION}
```

### Validation and Testing

```bash
kubectl -n ${RELEASE_NAMESPACE} get po
helm -n ${RELEASE_NAMESPACE} test ${RELEASE_NAME}
```

## CLI removing

```bash
helm -n ${RELEASE_NAMESPACE} uninstall ${RELEASE_NAME}
kubectl get crd -o name|grep 'cnpg.io'|xargs kubectl delete
kubectl delete MutatingWebhookConfiguration/cnpg-mutating-webhook-configuration
kubectl delete ValidatingWebhookConfiguration/cnpg-validating-webhook-configuration
```
