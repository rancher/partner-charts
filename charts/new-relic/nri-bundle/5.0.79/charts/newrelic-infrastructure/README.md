# newrelic-infrastructure

A Helm chart to deploy the New Relic Kubernetes monitoring solution

**Homepage:** <https://docs.newrelic.com/docs/kubernetes-pixie/kubernetes-integration/get-started/introduction-kubernetes-integration/>

# Helm installation

You can install this chart using [`nri-bundle`](https://github.com/newrelic/helm-charts/tree/master/charts/nri-bundle) located in the
[helm-charts repository](https://github.com/newrelic/helm-charts) or directly from this repository by adding this Helm repository:

```shell
helm repo add nri-kubernetes https://newrelic.github.io/nri-kubernetes
helm upgrade --install newrelic-infrastructure nri-kubernetes/newrelic-infrastructure -f your-custom-values.yaml
```

## Source Code

* <https://github.com/newrelic/nri-kubernetes/>
* <https://github.com/newrelic/nri-kubernetes/tree/main/charts/newrelic-infrastructure>
* <https://github.com/newrelic/infrastructure-agent/>

## Values managed globally

This chart implements the [New Relic's common Helm library](https://github.com/newrelic/helm-charts/tree/master/library/common-library) which
means that it honors a wide range of defaults and globals common to most New Relic Helm charts.

Options that can be defined globally include `affinity`, `nodeSelector`, `tolerations`, `proxy` and others. The full list can be found at
[user's guide of the common library](https://github.com/newrelic/helm-charts/blob/master/library/common-library/README.md).

## Chart particularities

### Low data mode
There are two mechanisms to reduce the amount of data that this integration sends to New Relic. See this snippet from the `values.yaml` file:
```yaml
common:
  config:
    interval: 15s

lowDataMode: false
```

The `lowDataMode` toggle is the simplest way to reduce data send to Newrelic. Setting it to `true` changes the default scrape interval from 15 seconds
(the default) to 30 seconds.

If you need for some reason to fine-tune the number of seconds you can use `common.config.interval` directly. If you take a look at the `values.yaml`
file, the value there is `nil`. If any value is set there, the `lowDataMode` toggle is ignored as this value takes precedence.

Setting this interval above 40 seconds can make you experience issues with the Kubernetes Cluster Explorer so this chart limits setting the interval
inside the range of 10 to 40 seconds.

### Affinities and tolerations

The New Relic common library allows to set affinities, tolerations, and node selectors globally using e.g. `.global.affinity` to ease the configuration
when you use this chart using `nri-bundle`. This chart has an extra level of granularity to the components that it deploys:
control plane, ksm, and kubelet.

Take this snippet as an example:
```yaml
global:
  affinity: {}
affinity: {}

kubelet:
  affinity: {}
ksm:
  affinity: {}
controlPlane:
  affinity: {}
```

The order to set an affinity is to set first any `kubelet.affinity`, `ksm.affinity`, or `controlPlane.affinity`. If these values are empty the chart
fallbacks to `affinity` (at root level), and if that value is empty, the chart fallbacks to `global.affinity`.

The same procedure applies to `nodeSelector` and `tolerations`.

On the other hand, some components have affinities and tolerations predefined e.g. to be able to run kubelet pods on nodes that are tainted as master
nodes or to schedule the KSM scraper on the same node of KSM to reduce the inter-node traffic.

If you are having problems assigning pods to nodes it may be because of this. Take a look at the [`values.yaml`](values.yaml) to see if the pod that is
not having your expected behavior has any predefined value.

### `hostNetwork` toggle

In versions below v3, changing the `privileged` mode affected the `hostNetwork`. We changed this behavior and now you can set pods to use `hostNetwork`
using the corresponding [flags from the common library](https://github.com/newrelic/helm-charts/blob/master/library/common-library/README.md)
(`.global.hostNetwork` and `.hostNetwork`) but the component that scrapes data from the control plane has always set `hostNetwork` enabled by default
(Look in the [`values.yaml`](values.yaml) for `controlPlane.hostNetwork: true`)

This is because the most common configuration of the control plane components is to be configured to listen only to `localhost`.

If your cluster security policy does not allow to use `hostNetwork`, you can disable it control plane monitoring by setting `controlPlane.enabled` to
`false.`

### `privileged` toggle

The default value for `privileged` [from the common library](https://github.com/newrelic/helm-charts/blob/master/library/common-library/README.md) is
`false` but in this particular this chart it is set to `true` (Look in the [`values.yaml`](values.yaml) for `privileged: true`)

This is because when `kubelet` pods need to run in privileged mode to fetch cpu, memory, process, and network metrics of your nodes.

If your cluster security policy does not allow to have `privileged` in your pod' security context, you can disable it by setting `privileged` to
`false` taking into account that you will lose all the metrics from the host and some metadata from the host that are added to the metrics of the
integrations that you have configured.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Sets pod/node affinities set almost globally. (See [Affinities and tolerations](README.md#affinities-and-tolerations)) |
| cluster | string | `""` | Name of the Kubernetes cluster monitored. Can be configured also with `global.cluster` |
| common | object | See `values.yaml` | Config that applies to all instances of the solution: kubelet, ksm, control plane and sidecars. |
| common.agentConfig | object | `{}` | Config for the Infrastructure agent. Will be used by the forwarder sidecars and the agent running integrations. See: https://docs.newrelic.com/docs/infrastructure/install-infrastructure-agent/configuration/infrastructure-agent-configuration-settings/ |
| common.config.interval | duration | `15s` (See [Low data mode](README.md#low-data-mode)) | Intervals larger than 40s are not supported and will cause the NR UI to not behave properly. Any non-nil value will override the `lowDataMode` default. |
| common.config.namespaceSelector | object | `{}` | Config for filtering ksm and kubelet metrics by namespace. |
| containerSecurityContext | object | `{}` | Sets security context (at container level). Can be configured also with `global.containerSecurityContext` |
| controlPlane | object | See `values.yaml` | Configuration for the control plane scraper. |
| controlPlane.affinity | object | Deployed only in master nodes. | Affinity for the control plane DaemonSet. |
| controlPlane.agentConfig | object | `{}` | Config for the Infrastructure agent that will forward the metrics to the backend. It will be merged with the configuration in `.common.agentConfig` See: https://docs.newrelic.com/docs/infrastructure/install-infrastructure-agent/configuration/infrastructure-agent-configuration-settings/ |
| controlPlane.config.apiServer | object | Common settings for most K8s distributions. | API Server monitoring configuration |
| controlPlane.config.apiServer.enabled | bool | `true` | Enable API Server monitoring |
| controlPlane.config.controllerManager | object | Common settings for most K8s distributions. | Controller manager monitoring configuration |
| controlPlane.config.controllerManager.enabled | bool | `true` | Enable controller manager monitoring. |
| controlPlane.config.etcd | object | Common settings for most K8s distributions. | etcd monitoring configuration |
| controlPlane.config.etcd.enabled | bool | `true` | Enable etcd monitoring. Might require manual configuration in some environments. |
| controlPlane.config.retries | int | `3` | Number of retries after timeout expired |
| controlPlane.config.scheduler | object | Common settings for most K8s distributions. | Scheduler monitoring configuration |
| controlPlane.config.scheduler.enabled | bool | `true` | Enable scheduler monitoring. |
| controlPlane.config.timeout | string | `"10s"` | Timeout for the Kubernetes APIs contacted by the integration |
| controlPlane.enabled | bool | `true` | Deploy control plane monitoring component. |
| controlPlane.hostNetwork | bool | `true` | Run Control Plane scraper with `hostNetwork`. `hostNetwork` is required for most control plane configurations, as they only accept connections from localhost. |
| controlPlane.kind | string | `"DaemonSet"` | How to deploy the control plane scraper. If autodiscovery is in use, it should be `DaemonSet`. Advanced users using static endpoints set this to `Deployment` to avoid reporting metrics twice. |
| controlPlane.tolerations | list | Schedules in all tainted nodes | Tolerations for the control plane DaemonSet. |
| customAttributes | object | `{}` | Adds extra attributes to the cluster and all the metrics emitted to the backend. Can be configured also with `global.customAttributes` |
| customSecretLicenseKey | string | `""` | In case you don't want to have the license key in you values, this allows you to point to which secret key is the license key located. Can be configured also with `global.customSecretLicenseKey` |
| customSecretName | string | `""` | In case you don't want to have the license key in you values, this allows you to point to a user created secret to get the key from there. Can be configured also with `global.customSecretName` |
| dnsConfig | object | `{}` | Sets pod's dnsConfig. Can be configured also with `global.dnsConfig` |
| enableProcessMetrics | bool | `false` | Collect detailed metrics from processes running in the host. This defaults to true for accounts created before July 20, 2020. ref: https://docs.newrelic.com/docs/release-notes/infrastructure-release-notes/infrastructure-agent-release-notes/new-relic-infrastructure-agent-1120 |
| fedramp.enabled | bool | `false` | Enables FedRAMP. Can be configured also with `global.fedramp.enabled` |
| fullnameOverride | string | `""` | Override the full name of the release |
| hostNetwork | bool | `false` | Sets pod's hostNetwork. Can be configured also with `global.hostNetwork` |
| images | object | See `values.yaml` | Images used by the chart for the integration and agents. |
| images.agent | object | See `values.yaml` | Image for the New Relic Infrastructure Agent plus integrations. |
| images.forwarder | object | See `values.yaml` | Image for the New Relic Infrastructure Agent sidecar. |
| images.integration | object | See `values.yaml` | Image for the New Relic Kubernetes integration. |
| images.pullSecrets | list | `[]` | The secrets that are needed to pull images from a custom registry. |
| integrations | object | `{}` | Config files for other New Relic integrations that should run in this cluster. |
| ksm | object | See `values.yaml` | Configuration for the Deployment that collects state metrics from KSM (kube-state-metrics). |
| ksm.affinity | object | Deployed in the same node as KSM | Affinity for the KSM Deployment. |
| ksm.agentConfig | object | `{}` | Config for the Infrastructure agent that will forward the metrics to the backend. It will be merged with the configuration in `.common.agentConfig` See: https://docs.newrelic.com/docs/infrastructure/install-infrastructure-agent/configuration/infrastructure-agent-configuration-settings/ |
| ksm.config.retries | int | `3` | Number of retries after timeout expired |
| ksm.config.scheme | string | `"http"` | Scheme to use to connect to kube-state-metrics. Supported values are `http` and `https`. |
| ksm.config.selector | string | `"app.kubernetes.io/name=kube-state-metrics"` | Label selector that will be used to automatically discover an instance of kube-state-metrics running in the cluster. |
| ksm.config.timeout | string | `"10s"` | Timeout for the ksm API contacted by the integration |
| ksm.enabled | bool | `true` | Enable cluster state monitoring. Advanced users only. Setting this to `false` is not supported and will break the New Relic experience. |
| ksm.hostNetwork | bool | Not set | Sets pod's hostNetwork. When set bypasses global/common variable |
| ksm.resources | object | 100m/150M -/850M | Resources for the KSM scraper pod. Keep in mind that sharding is not supported at the moment, so memory usage for this component ramps up quickly on large clusters. |
| ksm.tolerations | list | Schedules in all tainted nodes | Tolerations for the KSM Deployment. |
| kubelet | object | See `values.yaml` | Configuration for the DaemonSet that collects metrics from the Kubelet. |
| kubelet.agentConfig | object | `{}` | Config for the Infrastructure agent that will forward the metrics to the backend and will run the integrations in this cluster. It will be merged with the configuration in `.common.agentConfig`. You can see all the agent configurations in [New Relic docs](https://docs.newrelic.com/docs/infrastructure/install-infrastructure-agent/configuration/infrastructure-agent-configuration-settings/) e.g. you can set `passthrough_environment` int the [config file](https://docs.newrelic.com/docs/infrastructure/install-infrastructure-agent/configuration/configure-infrastructure-agent/#config-file) so the agent let use that environment variables to the integrations. |
| kubelet.config.retries | int | `3` | Number of retries after timeout expired |
| kubelet.config.scraperMaxReruns | int | `4` | Max number of scraper rerun when scraper runtime error happens |
| kubelet.config.timeout | string | `"10s"` | Timeout for the kubelet APIs contacted by the integration |
| kubelet.enabled | bool | `true` | Enable kubelet monitoring. Advanced users only. Setting this to `false` is not supported and will break the New Relic experience. |
| kubelet.extraEnv | list | `[]` | Add user environment variables to the agent |
| kubelet.extraEnvFrom | list | `[]` | Add user environment from configMaps or secrets as variables to the agent |
| kubelet.extraVolumeMounts | list | `[]` | Defines where to mount volumes specified with `extraVolumes` |
| kubelet.extraVolumes | list | `[]` | Volumes to mount in the containers |
| kubelet.hostNetwork | bool | Not set | Sets pod's hostNetwork. When set bypasses global/common variable |
| kubelet.tolerations | list | Schedules in all tainted nodes | Tolerations for the control plane DaemonSet. |
| labels | object | `{}` | Additional labels for chart objects. Can be configured also with `global.labels` |
| licenseKey | string | `""` | This set this license key to use. Can be configured also with `global.licenseKey` |
| lowDataMode | bool | `false` (See [Low data mode](README.md#low-data-mode)) | Send less data by incrementing the interval from `15s` (the default when `lowDataMode` is `false` or `nil`) to `30s`. Non-nil values of `common.config.interval` will override this value. |
| nameOverride | string | `""` | Override the name of the chart |
| nodeSelector | object | `{}` | Sets pod's node selector almost globally. (See [Affinities and tolerations](README.md#affinities-and-tolerations)) |
| nrStaging | bool | `false` | Send the metrics to the staging backend. Requires a valid staging license key. Can be configured also with `global.nrStaging` |
| podAnnotations | object | `{}` | Annotations to be added to all pods created by the integration. |
| podLabels | object | `{}` | Additional labels for chart pods. Can be configured also with `global.podLabels` |
| podSecurityContext | object | `{}` | Sets security context (at pod level). Can be configured also with `global.podSecurityContext` |
| priorityClassName | string | `""` | Sets pod's priorityClassName. Can be configured also with `global.priorityClassName` |
| privileged | bool | `true` | Run the integration with full access to the host filesystem and network. Running in this mode allows reporting fine-grained cpu, memory, process and network metrics for your nodes. |
| proxy | string | `""` | Configures the integration to send all HTTP/HTTPS request through the proxy in that URL. The URL should have a standard format like `https://user:password@hostname:port`. Can be configured also with `global.proxy` |
| rbac.create | bool | `true` | Whether the chart should automatically create the RBAC objects required to run. |
| rbac.pspEnabled | bool | `false` | Whether the chart should create Pod Security Policy objects. |
| selfMonitoring.pixie.enabled | bool | `false` | Enables the Pixie Health Check nri-flex config. This Flex config performs periodic checks of the Pixie /healthz and /statusz endpoints exposed by the Pixie Cloud Connector. A status for each endpoint is sent to New Relic in a pixieHealthCheck event. |
| serviceAccount | object | See `values.yaml` | Settings controlling ServiceAccount creation. |
| serviceAccount.create | bool | `true` | Whether the chart should automatically create the ServiceAccount objects required to run. |
| sink.http.probeBackoff | string | `"5s"` | The amount of time the scraper container to backoff when it fails to probe infra agent sidecar. |
| sink.http.probeTimeout | string | `"90s"` | The amount of time the scraper container to probe infra agent sidecar container before giving up and restarting during pod starts. |
| strategy | object | `type: Recreate` | Update strategy for the deployed Deployments. |
| tolerations | list | `[]` | Sets pod's tolerations to node taints almost globally. (See [Affinities and tolerations](README.md#affinities-and-tolerations)) |
| updateStrategy | object | See `values.yaml` | Update strategy for the deployed DaemonSets. |
| verboseLog | bool | `false` | Sets the debug logs to this integration or all integrations if it is set globally. Can be configured also with `global.verboseLog` |

## Maintainers

* [juanjjaramillo](https://github.com/juanjjaramillo)
* [csongnr](https://github.com/csongnr)
* [dbudziwojskiNR](https://github.com/dbudziwojskiNR)

## Past Contributors

Previous iterations of this chart started as a community project in the [stable Helm chart repository](github.com/helm/charts/). New Relic is very thankful for all the 15+ community members that contributed and helped maintain the chart there over the years:

* coreypobrien
* sstarcher
* jmccarty3
* slayerjain
* ryanhope2
* rk295
* michaelajr
* isindir
* idirouhab
* ismferd
* enver
* diclophis
* jeffdesc
* costimuraru
* verwilst
* ezelenka
