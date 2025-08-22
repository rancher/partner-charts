## General

> **Note:**
> Chart ezd-crd was tested with chart version up to 21.18.7 (application version up to 1.2025.21.18).

### Are you looking for more information?

1. Based on: https://github.com/linuxpolska/ezd-rp
2. Documentation: https://github.com/linuxpolska/ezd-rp/blob/main/README.md
3. Chart Source: https://linuxpolska.github.io/ezd-rp


## Before Installation

#### Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure

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
> List all releases using `helm list`

## Known Issues

> **Note:**
> Notify us: https://github.com/linuxpolska/ezd-rp/issues

#### Mismatch release name or namespace for a CRD installation

```
Error: Unable to continue with install: CustomResourceDefinition "backups.postgresql.cnpg.io" in namespace "" exists and cannot be imported into the current release: invalid ownership metadata; annotation validation error: key "meta.helm.sh/release-name" must equal "ezd-crd": current value is "wrong-crd-release"; annotation validation error: key "meta.helm.sh/release-namespace" must equal "lp-system": current value is "wrong-namespace"
```

Release name and namespace must match for CRD upgrade. To work around the error like above, uninstall old CRDs or change release-name/namespace to matching values.

## CLI installation

### Preparation

```bash
RELEASE_NAMESPACE=lp-system
CHART_VERSION=2.0.0
```

### Go go helm

```bash
cat << EOF > /tmp/values.yaml
global:
  rabbitmq:
    deploy: true
  postgresql:
    deploy: true
  redis:
    deploy: true
  certManager:
    deploy: true

cert-manager-operator:
  cert-manager:
    replicaCount: 1

cnpg-operator:
  cloudnative-pg:
    image:
      repository: ghcr.io/cloudnative-pg/cloudnative-pg
      tag: "1.27.0"
      pullPolicy: Always

rabbitmq-operator:
  rke2rabbitmqope:
    clusterOperator:
      replicaCount: 1

redis-operator:
  redis-operator:
    replicas: 1
EOF

helm -n ${RELEASE_NAMESPACE} upgrade --install ezd-crd \
--repo https://linuxpolska.github.io/ezd-rp \
ezd-crd \
-f /tmp/values.yaml \
--version ${CHART_VERSION} \
--create-namespace
```

### Validation and Testing

```bash
kubectl -n ${RELEASE_NAMESPACE} get po
helm -n ${RELEASE_NAMESPACE} list
```

## CLI removing

```bash
helm -n ${RELEASE_NAMESPACE} uninstall ezd-crd
kubectl get crd -o name | grep -E "(postgresql.cnpg.io|rabbitmqclusters.rabbitmq.com|redis.opstreelabs.in|cert-manager.io)" | xargs kubectl delete
```

> **Note**: Deleting the CRDs will delete all data as well. Please be cautious before doing it.
