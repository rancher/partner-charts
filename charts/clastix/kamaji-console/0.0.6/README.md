# kamaji-console

![Version: 0.0.6](https://img.shields.io/badge/Version-0.0.6-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.0.3](https://img.shields.io/badge/AppVersion-v0.0.3-informational?style=flat-square)

Kamaji deploys and operates Kubernetes at scale with a fraction of the operational burden. This chart install a console for Kamaji.

## Install the console

This chart requires a Secret in your Kubernetes cluster that contains the configuration and credentials to access the console. You can have the chart generate it for you, or create it yourself and provide the name of the Secret during installation.

Replace placeholders with actual values, and execute the following:

```bash
# The secret is required, otherwise the installation will fail
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: <secret-name>
  namespace: <charts-namespace>
data:
  # Credentials to login into console
  ADMIN_EMAIL: <email>
  ADMIN_PASSWORD: <password>
  # Secret used to sign the browser session
  JWT_SECRET: <jwtSecret>
  # URL where the console is accessible: https://<hostname>/ui
  NEXTAUTH_URL: <nextAuthUrl>
EOF
```

Make sure you set `credentialsSecret.name` value to the name of the secret <secret-name>.

To install the Chart with the release name `kamaji-console` in the `kamaji-system` namespace:

        helm repo add clastix https://clastix.github.io/charts
        helm repo update
        helm install console clastix/kamaji-console -n kamaji-system --create-namespace

Show the status:

        helm status console -n kamaji-system

Upgrade the Chart

        helm upgrade console -n kamaji-system clastix/kamaji-console

Uninstall the Chart

        helm uninstall console -n kamaji-system

## Customize the installation

Here the values you can override:

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| credentialsSecret.email | string | `""` |  |
| credentialsSecret.generate | bool | `false` |  |
| credentialsSecret.jwtSecret | string | `""` |  |
| credentialsSecret.name | string | `"kamaji-console"` |  |
| credentialsSecret.nextAuthUrl | string | `""` |  |
| credentialsSecret.password | string | `""` |  |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"clastix/kamaji-console"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` | type=kubernetes.io/dockerconfigjson |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"kamaji.localhost"` |  |
| ingress.hosts[0].paths[0].path | string | `"/ui"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| ingress.tls | list | `[]` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| securityContext | object | `{}` |  |
| service.port | int | `80` |  |
| service.targetPort | int | `3000` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| tolerations | list | `[]` |  |

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Dario Tranchitella | <dario@tranchitella.eu> |  |
| Adriano Pezzuto | <me@bsctl.io> |  |

## Source Code

* <https://github.com/clastix/kamaji-console>