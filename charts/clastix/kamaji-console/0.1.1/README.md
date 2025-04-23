# kamaji-console

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.2.0](https://img.shields.io/badge/AppVersion-v0.2.0-informational?style=flat-square)

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
  # Project Sveltos data, required for Application Delivery:
  # optional and requires Project Sveltos and its dashboard deployed
  SVELTOS_URL: <projectSveltosDashboardURL>
  SVELTOS_NAMESPACE: <projectSveltosNamespace>
  SVELTOS_SECRET_NAME: <projectSveltosTokenSecretName>
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
| credentialsSecret.email | string | `""` | Username to login into the console |
| credentialsSecret.generate | bool | `false` |  |
| credentialsSecret.jwtSecret | string | `""` | Session-secret used to sign cookies |
| credentialsSecret.name | string | `"kamaji-console"` | Name of the Secret containing sensitive info |
| credentialsSecret.nextAuthUrl | string | `""` | URL where the console is accessible, eg. https://kamaji.labs.clastix.io/ |
| credentialsSecret.password | string | `""` | Password to login into the console |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"ghcr.io/clastix/kamaji-console"` |  |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` |  |
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
| replicaCount | int | `2` |  |
| resources | object | `{}` |  |
| securityContext | object | `{}` |  |
| service.port | int | `80` |  |
| service.targetPort | int | `3000` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| sveltos.namespace | string | `nil` | Namespace where the Project Sveltos is deployed, required for the Application Delivery |
| sveltos.secretName | string | `nil` | Secret containing the access token, required for the Application Delivery |
| sveltos.url | string | `""` | URL of the Project Sveltos Dashboard, required for the Application Delivery |
| tolerations | list | `[]` |  |

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Dario Tranchitella | <dario@tranchitella.eu> |  |
| Adriano Pezzuto | <me@bsctl.io> |  |

## Source Code

* <https://github.com/clastix/kamaji-console>