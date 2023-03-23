[![New Relic Experimental header](https://github.com/newrelic/opensource-website/raw/master/src/images/categories/Experimental.png)](https://opensource.newrelic.com/oss-category/#new-relic-experimental)

# newrelic-k8s-metrics-adapter

A Helm chart to deploy the New Relic Kubernetes Metrics Adapter.

**Homepage:** <https://hub.docker.com/r/newrelic/newrelic-k8s-metrics-adapter>

## Source Code

* <https://github.com/newrelic/newrelic-k8s-metrics-adapter>
* <https://github.com/newrelic/newrelic-k8s-metrics-adapter/tree/main/charts/newrelic-k8s-metrics-adapter>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://helm-charts.newrelic.com | common-library | 1.1.1 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Node affinity to use for scheduling. |
| apiServicePatchJob.image | object | See `values.yaml`. | Registry, repository, tag, and pull policy for the job container image. |
| apiServicePatchJob.volumeMounts | list | `[]` | Additional Volume mounts for Cert Job, you might want to mount tmp if Pod Security Policies. |
| apiServicePatchJob.volumes | list | `[]` | Additional Volumes for Cert Job. |
| certManager.enabled | bool | `false` | Use cert manager for APIService certs, rather than the built-in patch job. |
| config.accountID | string | `nil` | New Relic [Account ID](https://docs.newrelic.com/docs/accounts/accounts-billing/account-structure/account-id/) where the configured metrics are sourced from. (**Required**) |
| config.cacheTTLSeconds | int | `30` | Period of time in seconds in which a cached value of a metric is consider valid. |
| config.externalMetrics | string | See `values.yaml` | Contains all the external metrics definition of the adapter. Each key of the externalMetric entry represents the metric name and contains the parameters that defines it. |
| config.region | string | Automatically detected from `licenseKey`. | New Relic account region. If not set, it will be automatically derived from the License Key. |
| containerSecurityContext | string | `nil` | Configure containerSecurityContext |
| extraEnv | list | `[]` | Array to add extra environment variables |
| extraEnvFrom | list | `[]` | Array to add extra envFrom |
| extraVolumeMounts | list | `[]` | Add extra volume mounts |
| extraVolumes | list | `[]` | Array to add extra volumes |
| fullnameOverride | string | `""` | To fully override common.naming.fullname |
| image | object | See `values.yaml`. | Registry, repository, tag, and pull policy for the container image. |
| image.pullSecrets | list | `[]` | The image pull secrets. |
| nodeSelector | object | `{}` | Node label to use for scheduling. |
| personalAPIKey | string | `nil` | New Relic [Personal API Key](https://docs.newrelic.com/docs/apis/intro-apis/new-relic-api-keys/#user-api-key) (stored in a secret). Used to connect to NerdGraph in order to fetch the configured metrics. (**Required**) |
| podAnnotations | string | `nil` | Additional annotations to apply to the pod(s). |
| podSecurityContext | string | `nil` | Configure podSecurityContext |
| proxy | string | `nil` | Configure proxy for the metrics-adapter. |
| rbac.pspEnabled | bool | `false` | Whether the chart should create Pod Security Policy objects. |
| replicas | int | `1` | Number of replicas in the deployment. |
| resources | object | See `values.yaml` | Resources you wish to assign to the pod. |
| serviceAccount.create | string | `true` | Specifies whether a ServiceAccount should be created for the job and the deployment. false avoids creation, true or empty will create the ServiceAccount |
| serviceAccount.name | string | Automatically generated. | If `serviceAccount.create` this will be the name of the ServiceAccount to use. If not set and create is true, a name is generated using the fullname template. If create is false, a serviceAccount with the given name must exist |
| tolerations | list | `[]` | List of node taints to tolerate (requires Kubernetes >= 1.6) |
| verboseLog | bool | `false` | Enable metrics adapter verbose logs. |

## Example

Make sure you have [added the New Relic chart repository.](../../README.md#install)

Because of metrics configuration, we recommend to use an external values file to deploy the chart. An example with the required parameters looks like:

```yaml
cluster: ClusterName
personalAPIKey: <Personal API Key>
config:
  accountID: <Account ID>
  externalMetrics:
    nginx_average_requests:
      query: "FROM Metric SELECT average(nginx.server.net.requestsPerSecond) SINCE 2 MINUTES AGO"
```

Then, to install this chart, run the following command:

```sh
helm upgrade --install [release-name] newrelic/newrelic-k8s-metrics-adapter --values [values file path]
```

Once deployed the metric `nginx_average_requests` will be available to use by any HPA. This is and example of an HPA yaml using this metric:

```yaml
kind: HorizontalPodAutoscaler
apiVersion: autoscaling/v2beta2
metadata:
  name: nginx-scaler
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx
  minReplicas: 1
  maxReplicas: 10
  metrics:
    - type: External
      external:
        metric:
          name: nginx_average_requests
          selector:
            matchLabels:
              k8s.namespaceName: nginx
        target:
          type: Value
          value: 10000
```

The NRQL query that will be run to get the `nginx_average_requests` value will be:

```sql
FROM Metric SELECT average(nginx.server.net.requestsPerSecond) WHERE clusterName='ClusterName' AND `k8s.namespaceName`='nginx' SINCE 2 MINUTES AGO
```

## External Metrics

An example of multiple external metrics defined:

```yaml
externalMetrics:
    nginx_average_requests:
      query: "FROM Metric SELECT average(nginx.server.net.requestsPerSecond) SINCE 2 MINUTES AGO"
    container_average_cores_utilization:
      query: "FROM Metric SELECT average(`k8s.container.cpuCoresUtilization`) SINCE 2 MINUTES AGO"
```

## Resources

The default set of resources assigned to the newrelic-k8s-metrics-adapter pods is shown below:

```yaml
resources:
  limits:
    memory: 80M
  requests:
    cpu: 100m
    memory: 30M
```

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
