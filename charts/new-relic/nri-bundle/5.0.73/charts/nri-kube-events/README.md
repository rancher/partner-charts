# nri-kube-events

![Version: 3.9.4](https://img.shields.io/badge/Version-3.9.4-informational?style=flat-square) ![AppVersion: 2.9.4](https://img.shields.io/badge/AppVersion-2.9.4-informational?style=flat-square)

A Helm chart to deploy the New Relic Kube Events router

**Homepage:** <https://docs.newrelic.com/docs/integrations/kubernetes-integration/kubernetes-events/install-kubernetes-events-integration>

# Helm installation

You can install this chart using [`nri-bundle`](https://github.com/newrelic/helm-charts/tree/master/charts/nri-bundle) located in the
[helm-charts repository](https://github.com/newrelic/helm-charts) or directly from this repository by adding this Helm repository:

```shell
helm repo add nri-kube-events https://newrelic.github.io/nri-kube-events
helm upgrade --install nri-kube-events/nri-kube-events -f your-custom-values.yaml
```

## Source Code

* <https://github.com/newrelic/nri-kube-events/>
* <https://github.com/newrelic/nri-kube-events/tree/main/charts/nri-kube-events>
* <https://github.com/newrelic/infrastructure-agent/>

## Values managed globally

This chart implements the [New Relic's common Helm library](https://github.com/newrelic/helm-charts/tree/master/library/common-library) which
means that it honors a wide range of defaults and globals common to most New Relic Helm charts.

Options that can be defined globally include `affinity`, `nodeSelector`, `tolerations`, `proxy` and others. The full list can be found at
[user's guide of the common library](https://github.com/newrelic/helm-charts/blob/master/library/common-library/README.md).

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Sets pod/node affinities. Can be configured also with `global.affinity` |
| agentHTTPTimeout | string | `"30s"` | Amount of time to wait until timeout to send metrics to the metric forwarder |
| cluster | string | `""` | Name of the Kubernetes cluster monitored. Mandatory. Can be configured also with `global.cluster` |
| containerSecurityContext | object | `{}` | Sets security context (at container level). Can be configured also with `global.containerSecurityContext` |
| customAttributes | object | `{}` | Adds extra attributes to the cluster and all the metrics emitted to the backend. Can be configured also with `global.customAttributes` |
| customSecretLicenseKey | string | `""` | In case you don't want to have the license key in you values, this allows you to point to which secret key is the license key located. Can be configured also with `global.customSecretLicenseKey` |
| customSecretName | string | `""` | In case you don't want to have the license key in you values, this allows you to point to a user created secret to get the key from there. Can be configured also with `global.customSecretName` |
| deployment.annotations | object | `{}` | Annotations to add to the Deployment. |
| dnsConfig | object | `{}` | Sets pod's dnsConfig. Can be configured also with `global.dnsConfig` |
| fedramp.enabled | bool | `false` | Enables FedRAMP. Can be configured also with `global.fedramp.enabled` |
| forwarder | object | `{"resources":{}}` | Resources for the forwarder sidecar container |
| fullnameOverride | string | `""` | Override the full name of the release |
| hostNetwork | bool | `false` | Sets pod's hostNetwork. Can be configured also with `global.hostNetwork` |
| images | object | See `values.yaml` | Images used by the chart for the integration and agents |
| images.agent | object | See `values.yaml` | Image for the New Relic Infrastructure Agent sidecar |
| images.integration | object | See `values.yaml` | Image for the New Relic Kubernetes integration |
| images.pullSecrets | list | `[]` | The secrets that are needed to pull images from a custom registry. |
| labels | object | `{}` | Additional labels for chart objects |
| licenseKey | string | `""` | This set this license key to use. Can be configured also with `global.licenseKey` |
| nameOverride | string | `""` | Override the name of the chart |
| nodeSelector | object | `{}` | Sets pod's node selector. Can be configured also with `global.nodeSelector` |
| nrStaging | bool | `false` | Send the metrics to the staging backend. Requires a valid staging license key. Can be configured also with `global.nrStaging` |
| podAnnotations | object | `{}` | Annotations to add to the pod. |
| podLabels | object | `{}` | Additional labels for chart pods |
| podSecurityContext | object | `{}` | Sets security context (at pod level). Can be configured also with `global.podSecurityContext` |
| priorityClassName | string | `""` | Sets pod's priorityClassName. Can be configured also with `global.priorityClassName` |
| proxy | string | `""` | Configures the integration to send all HTTP/HTTPS request through the proxy in that URL. The URL should have a standard format like `https://user:password@hostname:port`. Can be configured also with `global.proxy` |
| rbac.create | bool | `true` | Specifies whether RBAC resources should be created |
| resources | object | `{}` | Resources for the integration container |
| scrapers | object | See `values.yaml` | Configure the various kinds of scrapers that should be run. |
| serviceAccount | object | See `values.yaml` | Settings controlling ServiceAccount creation |
| serviceAccount.create | bool | `true` | Specifies whether a ServiceAccount should be created |
| sinks | object | See `values.yaml` | Configure where will the metrics be written. Mostly for debugging purposes. |
| sinks.newRelicInfra | bool | `true` | The newRelicInfra sink sends all events to New Relic. |
| sinks.stdout | bool | `false` | Enable the stdout sink to also see all events in the logs. |
| tolerations | list | `[]` | Sets pod's tolerations to node taints. Can be configured also with `global.tolerations` |
| verboseLog | bool | `false` | Sets the debug logs to this integration or all integrations if it is set globally. Can be configured also with `global.verboseLog` |

## Maintainers

* [juanjjaramillo](https://github.com/juanjjaramillo)
* [csongnr](https://github.com/csongnr)
* [dbudziwojskiNR](https://github.com/dbudziwojskiNR)
