# kyverno-notation-aws

![Version: 2.0.0](https://img.shields.io/badge/Version-2.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v2.0.0](https://img.shields.io/badge/AppVersion-v2.0.0-informational?style=flat-square)

Kyverno extension service for Notation and the AWS signer

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Nirmata | <support@nirmata.com> | <https://nirmata.com/> |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| region | string | `"us-west-2"` |  |
| nameOverride | string | `nil` | Override the name of the chart |
| fullnameOverride | string | `nil` | Override the expanded name of the chart |
| namespaceOverride | string | `nil` | Override the namespace the chart deploys to |
| image.defaultRegistry | string | `"ghcr.io"` | Image registry |
| image.registry | string | `nil` |  |
| image.repository | string | `"nirmata/enterprise-kyverno-notation-aws"` | Image repository |
| image.tag | string | `nil` | Image tag Defaults to appVersion in Chart.yaml if omitted |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| crds.install | bool | `true` | Whether to have Helm install the Kyverno Notation AWS CRDs. |
| deployment.updateStrategy | object | See [values.yaml](values.yaml) | Deployment update strategy. Ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy |
| deployment.imagePullSecrets | object | `{}` | Image pull secrets in case IRSA isn't configured, this will define the `--imagePullSecrets` argument |
| deployment.allowInsecureRegistry | bool | `false` | Allow insecure registry specifies whether to allow insecure connections to registries. Not recommended. |
| deployment.maxSignatureAttempts | int | `30` | Max signature attempts specifies the maximum number of signature envelopes that will be processed for verification |
| deployment.tokenAudiences | string | `"kyverno-svc.kyverno.io"` | Comma-separated audiences a caller's token must be intended for, passed to TokenReview. Must match the audience the caller mints its token with. Kyverno 1.18-n4k projects `apiCallToken` with a custom audience so the token cannot be replayed against the Kubernetes API server — which also means the API server rejects it, so leaving this empty makes every request fail with "Token is not authorized". The default matches that chart's `apiCallToken.audience` default; change both together if you change either. |
| serviceAccount.enabled | bool | `true` |  |
| serviceAccount.name | string | `nil` | The ServiceAccount name |
| serviceAccount.annotations | object | `{}` | Annotations for the ServiceAccount |
| configMap.name | string | `"notation-plugin-config"` | The notation-plugin-config configmap name |
| license.create | bool | `false` | Create a license Secret from license.value |
| license.name | string | `nil` | Name of the license Secret to create when license.create is true. Defaults to "<fullname>-license" if omitted |
| license.existingSecret | string | `nil` | Name of a pre-existing license Secret to mount when license.create is false |
| license.key | string | `"license"` | Key inside the license Secret holding the license file contents |
| license.value | string | `nil` | License file contents, used only when license.create is true |
| nodeSelector | object | `{}` |  |
| tolerations | list | `[]` |  |
| affinity | object | `{}` |  |
| customLabels | object | `{}` | user supplied labels to apply to all resources excluding label selectors |
| startupProbe | object | See [values.yaml](values.yaml) | Startup probe. The block is directly forwarded into the deployment, so you can use whatever startupProbes configuration you want. ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/ |
| livenessProbe | object | See [values.yaml](values.yaml) | Liveness probe. The block is directly forwarded into the deployment, so you can use whatever livenessProbe configuration you want. ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/ |
| readinessProbe | object | See [values.yaml](values.yaml) | Readiness Probe. The block is directly forwarded into the deployment, so you can use whatever readinessProbe configuration you want. ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/ |
| test.sleep | int | `50` | Sleep time before running test |
| test.image.registry | string | `nil` | Image registry |
| test.image.repository | string | `"busybox"` | Image repository |
| test.image.tag | string | `"1.35"` | Image tag Defaults to `latest` if omitted |
| test.image.pullPolicy | string | `nil` | Image pull policy Defaults to image.pullPolicy if omitted |
| test.resources.limits | object | `{"cpu":"100m","memory":"256Mi"}` | Pod resource limits |
| test.resources.requests | object | `{"cpu":"10m","memory":"64Mi"}` | Pod resource requests |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
