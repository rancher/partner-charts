# nri-metadata-injection

A Helm chart to deploy the New Relic metadata injection webhook.

**Homepage:** <https://hub.docker.com/r/newrelic/k8s-metadata-injection>

# Helm installation

You can install this chart using [`nri-bundle`](https://github.com/newrelic/helm-charts/tree/master/charts/nri-bundle) located in the
[helm-charts repository](https://github.com/newrelic/helm-charts) or directly from this repository by adding this Helm repository:

```shell
helm repo add nri-metadata-injection https://newrelic.github.io/k8s-metadata-injection
helm upgrade --install nri-metadata-injection/nri-metadata-injection -f your-custom-values.yaml
```

## Source Code

* <https://github.com/newrelic/k8s-metadata-injection>
* <https://github.com/newrelic/k8s-metadata-injection/tree/master/charts/nri-metadata-injection>

## Values managed globally

This chart implements the [New Relic's common Helm library](https://github.com/newrelic/helm-charts/tree/master/library/common-library) which
means that it honors a wide range of defaults and globals common to most New Relic Helm charts.

Options that can be defined globally include `affinity`, `nodeSelector`, `tolerations`, `proxy` and others. The full list can be found at
[user's guide of the common library](https://github.com/newrelic/helm-charts/blob/master/library/common-library/README.md).

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Sets pod/node affinities. Can be configured also with `global.affinity` |
| certManager.enabled | bool | `false` | Use cert manager for webhook certs |
| cluster | string | `""` | Name of the Kubernetes cluster monitored. Can be configured also with `global.cluster` |
| containerSecurityContext | object | `{}` | Sets security context (at container level). Can be configured also with `global.containerSecurityContext` |
| customTLSCertificate | bool | `false` | Use custom tls certificates for the webhook, or let the chart handle it automatically. Ref: https://docs.newrelic.com/docs/integrations/kubernetes-integration/link-your-applications/link-your-applications-kubernetes#configure-injection |
| dnsConfig | object | `{}` | Sets pod's dnsConfig. Can be configured also with `global.dnsConfig` |
| fullnameOverride | string | `""` | Override the full name of the release |
| hostNetwork | bool | false | Sets pod's hostNetwork. Can be configured also with `global.hostNetwork` |
| image | object | See `values.yaml` | Image for the New Relic Metadata Injector |
| image.pullSecrets | list | `[]` | The secrets that are needed to pull images from a custom registry. |
| injectOnlyLabeledNamespaces | bool | `false` | Enable the metadata decoration only for pods living in namespaces labeled with 'newrelic-metadata-injection=enabled'. |
| jobImage | object | See `values.yaml` | Image for creating the needed certificates of this webhook to work |
| jobImage.pullSecrets | list | `[]` | The secrets that are needed to pull images from a custom registry. |
| jobImage.volumeMounts | list | `[]` | Volume mounts to add to the job, you might want to mount tmp if Pod Security Policies Enforce a read-only root. |
| jobImage.volumes | list | `[]` | Volumes to add to the job container |
| labels | object | `{}` | Additional labels for chart objects. Can be configured also with `global.labels` |
| nameOverride | string | `""` | Override the name of the chart |
| nodeSelector | object | `{}` | Sets pod's node selector. Can be configured also with `global.nodeSelector` |
| podAnnotations | object | `{}` | Annotations to be added to all pods created by the integration. |
| podLabels | object | `{}` | Additional labels for chart pods. Can be configured also with `global.podLabels` |
| podSecurityContext | object | `{}` | Sets security context (at pod level). Can be configured also with `global.podSecurityContext` |
| priorityClassName | string | `""` | Sets pod's priorityClassName. Can be configured also with `global.priorityClassName` |
| rbac.pspEnabled | bool | `false` | Whether the chart should create Pod Security Policy objects. |
| replicas | int | `1` |  |
| resources | object | 100m/30M -/80M | Image for creating the needed certificates of this webhook to work |
| timeoutSeconds | int | `28` | Webhook timeout Ref: https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/#timeouts |
| tolerations | list | `[]` | Sets pod's tolerations to node taints. Can be configured also with `global.tolerations` |

## Maintainers

* [nserrino](https://github.com/nserrino)
* [philkuz](https://github.com/philkuz)
* [htroisi](https://github.com/htroisi)
* [juanjjaramillo](https://github.com/juanjjaramillo)
* [svetlanabrennan](https://github.com/svetlanabrennan)
* [nrepai](https://github.com/nrepai)
* [csongnr](https://github.com/csongnr)
* [vuqtran88](https://github.com/vuqtran88)
* [xqi-nr](https://github.com/xqi-nr)
