# nri-prometheus

A Helm chart to deploy the New Relic Prometheus OpenMetrics integration

**Homepage:** <https://docs.newrelic.com/docs/infrastructure/prometheus-integrations/install-configure-openmetrics/configure-prometheus-openmetrics-integrations/>

# Helm installation

You can install this chart using [`nri-bundle`](https://github.com/newrelic/helm-charts/tree/master/charts/nri-bundle) located in the
[helm-charts repository](https://github.com/newrelic/helm-charts) or directly from this repository by adding this Helm repository:

```shell
helm repo add nri-prometheus https://newrelic.github.io/nri-prometheus
helm upgrade --install newrelic-prometheus nri-prometheus/nri-prometheus -f your-custom-values.yaml
```

## Source Code

* <https://github.com/newrelic/nri-prometheus>
* <https://github.com/newrelic/nri-prometheus/tree/main/charts/nri-prometheus>

## Scraping services and endpoints

When a service is labeled or annotated with `scrape_enabled_label` (defaults to `prometheus.io/scrape`),
`nri-prometheus` will attempt to hit the service directly, rather than the endpoints behind it.

This is the default behavior for compatibility reasons, but is known to cause issues if more than one endpoint
is behind the service, as metric queries will be load-balanced as well leading to inaccurate histograms.

In order to change this behaviour set `scrape_endpoints` to `true` and `scrape_services` to `false`.
This will instruct `nri-prometheus` to scrape the underlying endpoints, as Prometheus server does.

Existing users that are switching to this behavior should note that, depending on the number of endpoints
behind the services in the cluster the load and the metrics reported by those, data ingestion might see
an increase when flipping this option. Resource requirements might also be impacted, again depending on the number of new targets.

While it is technically possible to set both `scrape_services` and `scrape_endpoints` to true, we do no recommend
doing so as it will lead to redundant metrics being processed,

## Values managed globally

This chart implements the [New Relic's common Helm library](https://github.com/newrelic/helm-charts/tree/master/library/common-library) which
means that it honors a wide range of defaults and globals common to most New Relic Helm charts.

Options that can be defined globally include `affinity`, `nodeSelector`, `tolerations`, `proxy` and others. The full list can be found at
[user's guide of the common library](https://github.com/newrelic/helm-charts/blob/master/library/common-library/README.md).

## Chart particularities

### Low data mode
See this snippet from the `values.yaml` file:
```yaml
global:
  lowDataMode: false
lowDataMode: false
```

To reduce the amount ot metrics we send to New Relic, enabling the `lowDataMode` will add [these transformations](static/lowdatamodedefaults.yaml):
```yaml
transformations:
  - description: "Low data mode defaults"
    ignore_metrics:
      # Ignore the following metrics.
      # These metrics are already collected by the New Relic Kubernetes Integration.
      - prefixes:
        - kube_
        - container_
        - machine_
        - cadvisor_
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Sets pod/node affinities. Can be configured also with `global.affinity` |
| cluster | string | `""` | Name of the Kubernetes cluster monitored. Can be configured also with `global.cluster` |
| config | object | See `values.yaml` | Provides your own `config.yaml` for this integration. Ref: https://docs.newrelic.com/docs/infrastructure/prometheus-integrations/install-configure-openmetrics/configure-prometheus-openmetrics-integrations/#example-configuration-file |
| containerSecurityContext | object | `{}` | Sets security context (at container level). Can be configured also with `global.containerSecurityContext` |
| customSecretLicenseKey | string | `""` | In case you don't want to have the license key in you values, this allows you to point to which secret key is the license key located. Can be configured also with `global.customSecretLicenseKey` |
| customSecretName | string | `""` | In case you don't want to have the license key in you values, this allows you to point to a user created secret to get the key from there. Can be configured also with `global.customSecretName` |
| dnsConfig | object | `{}` | Sets pod's dnsConfig. Can be configured also with `global.dnsConfig` |
| fedramp.enabled | bool | false | Enables FedRAMP. Can be configured also with `global.fedramp.enabled` |
| fullnameOverride | string | `""` | Override the full name of the release |
| hostNetwork | bool | `false` | Sets pod's hostNetwork. Can be configured also with `global.hostNetwork` |
| image | object | See `values.yaml` | Image for the New Relic Kubernetes integration |
| image.pullSecrets | list | `[]` | The secrets that are needed to pull images from a custom registry. |
| labels | object | `{}` | Additional labels for chart objects. Can be configured also with `global.labels` |
| licenseKey | string | `""` | This set this license key to use. Can be configured also with `global.licenseKey` |
| lowDataMode | bool | false | Reduces number of metrics sent in order to reduce costs. Can be configured also with `global.lowDataMode` |
| nameOverride | string | `""` | Override the name of the chart |
| nodeSelector | object | `{}` | Sets pod's node selector. Can be configured also with `global.nodeSelector` |
| nrStaging | bool | false | Send the metrics to the staging backend. Requires a valid staging license key. Can be configured also with `global.nrStaging` |
| podAnnotations | object | `{}` | Annotations to be added to all pods created by the integration. |
| podLabels | object | `{}` | Additional labels for chart pods. Can be configured also with `global.podLabels` |
| podSecurityContext | object | `{}` | Sets security context (at pod level). Can be configured also with `global.podSecurityContext` |
| priorityClassName | string | `""` | Sets pod's priorityClassName. Can be configured also with `global.priorityClassName` |
| proxy | string | `""` | Configures the integration to send all HTTP/HTTPS request through the proxy in that URL. The URL should have a standard format like `https://user:password@hostname:port`. Can be configured also with `global.proxy` |
| rbac.create | bool | `true` | Specifies whether RBAC resources should be created |
| resources | object | `{}` |  |
| serviceAccount.annotations | object | `{}` | Add these annotations to the service account we create. Can be configured also with `global.serviceAccount.annotations` |
| serviceAccount.create | bool | `true` | Configures if the service account should be created or not. Can be configured also with `global.serviceAccount.create` |
| serviceAccount.name | string | `nil` | Change the name of the service account. This is honored if you disable on this cahrt the creation of the service account so you can use your own. Can be configured also with `global.serviceAccount.name` |
| tolerations | list | `[]` | Sets pod's tolerations to node taints. Can be configured also with `global.tolerations` |
| verboseLog | bool | false | Sets the debug logs to this integration or all integrations if it is set globally. Can be configured also with `global.verboseLog` |

## Maintainers

* [alvarocabanas](https://github.com/alvarocabanas)
* [carlossscastro](https://github.com/carlossscastro)
* [sigilioso](https://github.com/sigilioso)
* [gsanchezgavier](https://github.com/gsanchezgavier)
* [kang-makes](https://github.com/kang-makes)
* [marcsanmi](https://github.com/marcsanmi)
* [paologallinaharbur](https://github.com/paologallinaharbur)
* [roobre](https://github.com/roobre)
