## General

> **Note:**
> Chart ezd-backend was tested with chart version up to 21.11.11 (application version up to 1.2025.21.11).

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
>
> Copy, write down or memorize notes from helm installation output. It will be necessary for EZD RP frontend installation.
>
> OR
>
> Use `/tmp/ezd-pass.sh` file as prepared in *CLI installation - Preparation section*

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

## CLI installation

### Preparation

```bash
RELEASE_NAMESPACE=example
CHART_VERSION=1.8.0

cat <<EOF > /tmp/ezd-pass.sh
# These passwords are necessary for ezdrp backend AND frontend deployments.
# Following passwords will be a random alphanumeric by default.
# You can change it to Your alphanumeric password.

PSQL_PASSWD=$(openssl rand -hex 10)
PSQL_APP_PASSWD=$(openssl rand -hex 10)
RABBITMQ_PASSWD=$(openssl rand -hex 10)
RABBITMQ_USER=ezdrpadmin
REDIS_PASSWD=$(openssl rand -hex 10)

BACKEND_NAMESPACE=$RELEASE_NAMESPACE
EOF
source /tmp/ezd-pass.sh
```

### Go go helm

```bash
cat << EOF > /tmp/values.yaml
postgresqlConfig:
  auth:
    admPassword:  ${PSQL_PASSWD}
    appPassword:  ${PSQL_APP_PASSWD}
rabbitmqConfig:
  auth:
    password:  ${RABBITMQ_PASSWD}
    username:  ${RABBITMQ_USER}
redisConfig:
  auth:
    password:  ${REDIS_PASSWD}
EOF

helm -n ${RELEASE_NAMESPACE} upgrade --install ezd-backend-release \
--repo https://linuxpolska.github.io/ezd-rp \
ezd-backend \
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
helm -n ${RELEASE_NAMESPACE} uninstall ezd-backend-release
```

## GUI Installation
If You want to install ezd-backend via GUI, please follow [this instruction](https://github.com/linuxpolska/ezd-rp/blob/main/INSTALL_VIA_GUI.md).
