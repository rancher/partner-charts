# newrelic-infra-operator

A Helm chart to deploy the New Relic Infrastructure Kubernetes Operator.

**Homepage:** <https://hub.docker.com/r/newrelic/newrelic-infra-operator>

## Helm installation

You can install this chart using [`nri-bundle`](https://github.com/newrelic/helm-charts/tree/master/charts/nri-bundle) located in the
[helm-charts repository](https://github.com/newrelic/helm-charts) or directly from this repository by adding this Helm repository:

```shell
helm repo add newrelic-infra-operator https://newrelic.github.io/newrelic-infra-operator
helm upgrade --install newrelic-infra-operator/newrelic-infra-operator -f your-custom-values.yaml
```

## Source Code

* <https://github.com/newrelic/newrelic-infra-operator>
* <https://github.com/newrelic/newrelic-infra-operator/tree/main/charts/newrelic-infra-operator>

## Usage example

Make sure you have [added the New Relic chart repository.](../../README.md#install)

Then, to install this chart, run the following command:

```sh
helm upgrade --install [release-name] newrelic-infra-operator/newrelic-infra-operator --set cluster=my_cluster_name --set licenseKey [your-license-key]
```

When installing on Fargate add as well `--set fargate=true`

### Configure in which pods the sidecar should be injected

Policies are available in order to configure in which pods the sidecar should be injected.
Each policy is evaluated independently and if at least one policy matches the operator will inject the sidecar.

Policies are composed by `namespaceSelector` checking the labels of the Pod namespace, `podSelector` checking
the labels of the Pod and `namespace` checking the namespace name. Each of those, if specified, are ANDed.

By default, the policies are configured in order to inject the sidecar in each pod belonging to a Fargate profile.

> Moreover, it is possible to add the label `infra-operator.newrelic.com/disable-injection` to Pods to exclude injection
for a single Pod that otherwise would be selected by the policies.

Please make sure to configure policies correctly to avoid injecting sidecar for pods running on EC2 nodes
already monitored by the infrastructure DaemonSet.

### Configure the sidecar with labelsSelectors

It is also possible to configure `resourceRequirements` and `extraEnvVars` based on the labels of the mutating Pod.

The current configuration increases the resource requirements for sidecar injected on `KSM` instances. Moreover,
injectes disable the `DISABLE_KUBE_STATE_METRICS` environment variable for Pods not running on `KSM` instances
to decrease the load on the API server.

## Values managed globally

This chart implements the [New Relic's common Helm library](https://github.com/newrelic/helm-charts/tree/master/library/common-library) which
means that it honors a wide range of defaults and globals common to most New Relic Helm charts.

Options that can be defined globally include `affinity`, `nodeSelector`, `tolerations`, `proxy` and others. The full list can be found at
[user's guide of the common library](https://github.com/newrelic/helm-charts/blob/master/library/common-library/README.md).

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| admissionWebhooksPatchJob | object | See `values.yaml` | Image used to create certificates and inject them to the admission webhook |
| admissionWebhooksPatchJob.image.pullSecrets | list | `[]` | The secrets that are needed to pull images from a custom registry. |
| admissionWebhooksPatchJob.volumeMounts | list | `[]` | Volume mounts to add to the job, you might want to mount tmp if Pod Security Policies. Enforce a read-only root. |
| admissionWebhooksPatchJob.volumes | list | `[]` | Volumes to add to the job container. |
| affinity | object | `{}` | Sets pod/node affinities. Can be configured also with `global.affinity` |
| certManager.enabled | bool | `false` | Use cert manager for webhook certs |
| cluster | string | `""` | Name of the Kubernetes cluster monitored. Mandatory. Can be configured also with `global.cluster` |
| config | object | See `values.yaml` | Operator configuration |
| config.ignoreMutationErrors | bool | `true` | IgnoreMutationErrors instruments the operator to ignore injection error instead of failing. If set to false errors of the injection could block the creation of pods. |
| config.infraAgentInjection | object | See `values.yaml` | configuration of the sidecar injection webhook |
| config.infraAgentInjection.agentConfig | object | See `values.yaml` | agentConfig contains the configuration for the container agent injected |
| config.infraAgentInjection.agentConfig.configSelectors | list | See `values.yaml` | configSelectors is the way to configure resource requirements and extra envVars of the injected sidecar container. When mutating it will be applied the first configuration having the labelSelector matching with the mutating pod. |
| config.infraAgentInjection.agentConfig.image | object | See `values.yaml` | Image of the infrastructure agent to be injected. |
| containerSecurityContext | object | `{}` | Sets security context (at container level). Can be configured also with `global.containerSecurityContext` |
| customSecretLicenseKey | string | `""` | In case you don't want to have the license key in you values, this allows you to point to which secret key is the license key located. Can be configured also with `global.customSecretLicenseKey` |
| customSecretName | string | `""` | In case you don't want to have the license key in you values, this allows you to point to a user created secret to get the key from there. Can be configured also with `global.customSecretName` |
| dnsConfig | object | `{}` | Sets pod's dnsConfig. Can be configured also with `global.dnsConfig` |
| fullnameOverride | string | `""` | Override the full name of the release |
| hostNetwork | bool | `false` | Sets pod's hostNetwork. Can be configured also with `global.hostNetwork` |
| image | object | See `values.yaml` | Image for the New Relic Infrastructure Operator |
| image.pullSecrets | list | `[]` | The secrets that are needed to pull images from a custom registry. |
| licenseKey | string | `""` | This set this license key to use. Can be configured also with `global.licenseKey` |
| nameOverride | string | `""` | Override the name of the chart |
| nodeSelector | object | `{}` | Sets pod's node selector. Can be configured also with `global.nodeSelector` |
| podAnnotations | object | `{}` | Annotations to add to the pod. |
| podSecurityContext | object | `{"fsGroup":1001,"runAsGroup":1001,"runAsUser":1001}` | Sets security context (at pod level). Can be configured also with `global.podSecurityContext` |
| priorityClassName | string | `""` | Sets pod's priorityClassName. Can be configured also with `global.priorityClassName` |
| rbac.pspEnabled | bool | `false` | Whether the chart should create Pod Security Policy objects. |
| replicas | int | `1` |  |
| resources | object | `{"limits":{"memory":"80M"},"requests":{"cpu":"100m","memory":"30M"}}` | Resources available for this pod |
| serviceAccount | object | See `values.yaml` | Settings controlling ServiceAccount creation |
| serviceAccount.create | bool | `true` | Specifies whether a ServiceAccount should be created |
| timeoutSeconds | int | `28` | Webhook timeout Ref: https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/#timeouts |
| tolerations | list | `[]` | Sets pod's tolerations to node taints. Can be configured also with `global.tolerations` |

## Maintainers

* [alvarocabanas](https://github.com/alvarocabanas)
* [carlossscastro](https://github.com/carlossscastro)
* [sigilioso](https://github.com/sigilioso)
* [gsanchezgavier](https://github.com/gsanchezgavier)
* [kang-makes](https://github.com/kang-makes)
* [marcsanmi](https://github.com/marcsanmi)
* [paologallinaharbur](https://github.com/paologallinaharbur)
* [roobre](https://github.com/roobre)
