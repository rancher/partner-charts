# Instana

Instana is an [APM solution](https://www.instana.com/) built for microservices that enables IT Ops to build applications faster and deliver higher quality services by automating monitoring, tracing and root cause analysis.
This solution is optimized for [Kubernetes](https://www.instana.com/automatic-kubernetes-monitoring/).

This chart adds the Instana Agent to all schedulable nodes in your cluster via a privileged `DaemonSet` and accompanying resources like `ConfigurationMap`s, `Secret`s and RBAC settings.

## Prerequisites

* Kubernetes 1.21+ OR OpenShift 4.8+
* Helm 3

## Installation

To configure the installation you can either specify the options on the command line using the **--set** switch, or you can edit **values.yaml**.

First, create a namespace for the instana-agent

```bash
$ kubectl create namespace instana-agent
```

**OpenShift:** When targetting an OpenShift 4.x cluster, ensure proper permission before installing the helm chart, otherwise the agent pods will not be scheduled correctly.

```bash
$ oc adm policy add-scc-to-user privileged -z instana-agent
$ oc adm policy add-scc-to-user anyuid -z instana-agent-remote -n instana-agent
```

To install the chart with the release name `instana-agent` and set the values on the command line run:

```bash
$ helm install instana-agent \
--namespace instana-agent \
--repo https://agents.instana.io/helm \
--set agent.key=INSTANA_AGENT_KEY \
--set agent.endpointHost=HOST \
--set zone.name=ZONE_NAME \
--set cluster.name="CLUSTER_NAME" \
instana-agent
```

## Upgrade

The helm chart deploys a Kubernetes Operator internally that reconciles the agent resources based on an agent CustomResource (CR) that is created based on the helm values. As the Operator pattern requires a CustomResourceDefinition (CRD) to be present in the cluster before defining any CRs, the CRD definition is included in the helm chart. On initial installations the chart deploys the CRD before submitting the rest of the artifacts.

Helm has known limitations around handling the CRD lifecycle as outlined in their [documentation](https://helm.sh/docs/chart_best_practices/custom_resource_definitions/).

This leads to the problem, that CRD updates are only submitted to the Cluster on **initial installation**, but **NOT applied automatically during upgrades**.

It is also worth noting, that CRDs must be removed manually if the chart should be removed completly, see more details in the [uninstall](#uninstallation) section.

To ensure a proper update, apply the CRD updates before running the upgrade:

```
helm pull --repo https://agents.instana.io/helm --untar instana-agent; kubectl apply -f instana-agent/crds; helm upgrade instana-agent instana-agent \
  --namespace instana-agent \
  --repo https://agents.instana.io/helm \
  --reuse-values
```

This is especially important when migrating from helm charts v1 to v2, as the upgrade will fail otherwise as the CR artifact cannot be created.

In case the instana-agent configmap was manually changed (not via helm values), the script [convert-agent-configmap-to-custom-values.sh](./convert-agent-configmap-to-custom-values.sh) can be used to convert the configmap to a custom-values.yaml file.

```bash
# helm v1 chart was installed in the Kubernetes cluster and the configmap was manually changed
# convert the configmap to a custom-values.yaml file
./convert-agent-configmap-to-custom-values.sh

# apply the custom-values.yaml file during the upgrade by specifying `-f custom-values.yaml`
```

### Required Settings

#### Configuring the Instana Backend

In order to report the data it collects to the Instana backend for analysis, the Instana agent must know which backend to report to, and which credentials to use to authenticate, known as "agent key".

As described by the [Install Using the Helm Chart](https://www.instana.com/docs/setup_and_manage/host_agent/on/kubernetes#install-using-the-helm-chart) documentation, you will find the right values for the following fields inside Instana itself:

* `agent.endpointHost`
* `agent.endpointPort`
* `agent.key`

_Note:_ You can find the options mentioned in the [configuration section below](#configuration-reference)

If your agents report into a self-managed Instana unit (also known as "on-prem"), you will also need to configure a "download key", which allows the agent to fetch its components from the Instana repository.
The download key is set via the following value:

* `agent.downloadKey`

#### Zone and Cluster

Instana needs to know how to name your Kubernetes cluster and, optionally, how to group your Instana agents in [Custom zones](https://www.instana.com/docs/setup_and_manage/host_agent/configuration/#custom-zones) using the following fields:

* `zone.name`
* `cluster.name`

Either `zone.name` or `cluster.name` are required.
If you omit `cluster.name`, the value of `zone.name` will be used as cluster name as well.
If you omit `zone.name`, the host zone will be automatically determined by the availability zone information provided by the [supported Cloud providers](https://www.instana.com/docs/setup_and_manage/cloud_service_agents).

## Uninstallation

To uninstall/delete the `instana-agent` release:

```bash
helm uninstall instana-agent -n instana-agent && kubectl patch agent instana-agent -n instana-agent -p '{"metadata":{"finalizers":null}}' --type=merge &&
kubectl delete crd/agents.instana.io
```

## Configuration Reference

The following table lists the configurable parameters of the Instana chart and their default values.

| Parameter                                           | Description                                                                                                                                                                                                                                                                                                            | Default                                                                                                                                 |
| --------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| `agent.configuration_yaml`                          | Custom content for the agent configuration.yaml file                                                                                                                                                                                                                                                                   | `nil` See [below](#agent-configuration) for more details                                                                                |
| `agent.endpointHost`                                | Instana Agent backend endpoint host                                                                                                                                                                                                                                                                                    | `ingress-red-saas.instana.io` (US and ROW). If in Europe, please override with `ingress-blue-saas.instana.io`                           |
| `agent.endpointPort`                                | Instana Agent backend endpoint port                                                                                                                                                                                                                                                                                    | `443`                                                                                                                                   |
| `agent.key`                                         | Your Instana Agent key                                                                                                                                                                                                                                                                                                 | `nil` You must provide your own key unless `agent.keysSecret` is specified                                                              |
| `agent.downloadKey`                                 | Your Instana Download key                                                                                                                                                                                                                                                                                              | `nil` Usually not required                                                                                                              |
| `agent.keysSecret`                                  | As an alternative to specifying `agent.key` and, optionally, `agent.downloadKey`, you can instead specify the name of the secret in the namespace in which you install the Instana agent that carries the agent key and download key                                                                                   | `nil` Usually not required, see [Bring your own Keys secret](#bring-your-own-keys-secret) for more details                              |
| `agent.additionalBackends`                          | List of additional backends to report to; it must specify the `endpointHost` and `key` fields, and optionally `endpointPort`                                                                                                                                                                                           | `[]` Usually not required; see [Configuring Additional Backends](#configuring-additional-backends) for more info and examples           |
| `agent.tls.secretName`                              | The name of the secret of type `kubernetes.io/tls` which contains the TLS relevant data. If the name is provided, `agent.tls.certificate` and `agent.tls.key` will be ignored.                                                                                                                                         | `nil`                                                                                                                                   |
| `agent.tls.certificate`                             | The certificate data encoded as base64. Which will be used to create a new secret of type `kubernetes.io/tls`.                                                                                                                                                                                                         | `nil`                                                                                                                                   |
| `agent.tls.key`                                     | The private key data encoded as base64. Which will be used to create a new secret of type `kubernetes.io/tls`.                                                                                                                                                                                                         | `nil`                                                                                                                                   |
| `agent.image.name`                                  | The image name to pull                                                                                                                                                                                                                                                                                                 | `instana/agent`                                                                                                                         |
| `agent.image.digest`                                | The image digest to pull; if specified, it causes `agent.image.tag` to be ignored                                                                                                                                                                                                                                      | `nil`                                                                                                                                   |
| `agent.image.tag`                                   | The image tag to pull; this property is ignored if `agent.image.digest` is specified                                                                                                                                                                                                                                   | `latest`                                                                                                                                |
| `agent.image.pullPolicy`                            | Image pull policy                                                                                                                                                                                                                                                                                                      | `Always`                                                                                                                                |
| `agent.image.pullSecrets`                           | Image pull secrets; if not specified (default) _and_ `agent.image.name` starts with `containers.instana.io`, it will be automatically set to `[{ "name": "containers-instana-io" }]` to match the default secret created in this case.                                                                                 | `nil`                                                                                                                                   |
| `agent.listenAddress`                               | List of addresses to listen on, or "*" for all interfaces                                                                                                                                                                                                                                                              | `nil`                                                                                                                                   |
| `agent.mode`                                        | Agent mode. Supported values are `APM`, `INFRASTRUCTURE`, `AWS`                                                                                                                                                                                                                                                        | `APM`                                                                                                                                   |
| `agent.instanaMvnRepoUrl`                           | Override for the Maven repository URL when the Agent needs to connect to a locally provided Maven repository 'proxy'                                                                                                                                                                                                   | `nil` Usually not required                                                                                                              |
| `agent.instanaMvnRepoFeaturesPath`                  | Override for the Maven repository features path the Agent needs to connect to a locally provided Maven repository 'proxy'                                                                                                                                                                                              | `nil` Usually not required                                                                                                              |
| `agent.instanaMvnRepoSharedPath`                    | Override for the Maven repository shared path when the Agent needs to connect to a locally provided Maven repository 'proxy'                                                                                                                                                                                           | `nil` Usually not required                                                                                                              |
| `agent.agentReleaseRepoMirrorUrl`                    | The URL of the agent features repository mirror. For more information, see [Configuring the agent repository as the mirror](https://www.ibm.com/docs/en/instana-observability/current?topic=agents-setting-up-agent-repositories-dynamic-host#configuring-the-agent-repository-as-the-mirror).                                                                                                                                                                                           | `nil`                                                                                                              |
| `agent.agentReleaseRepoMirrorUsername`                    | The username for authentication for the agent features repository mirror. For more information, see [Configuring the agent repository as the mirror](https://www.ibm.com/docs/en/instana-observability/current?topic=agents-setting-up-agent-repositories-dynamic-host#configuring-the-agent-repository-as-the-mirror).                                                                                                                                                                                           | `nil`                                                                                                              |
| `agent.agentReleaseRepoMirrorPassword`                    | The password for authentication for the agent features repository mirror. For more information, see [Configuring the agent repository as the mirror](https://www.ibm.com/docs/en/instana-observability/current?topic=agents-setting-up-agent-repositories-dynamic-host#configuring-the-agent-repository-as-the-mirror).                                                                                                                                                                                           | `nil`                                                                                                              |
| `agent.instanaSharedRepoMirrorUrl`                    | The URL of the agent shared repository mirror. For more information, see [Configuring the agent repository as the mirror](https://www.ibm.com/docs/en/instana-observability/current?topic=agents-setting-up-agent-repositories-dynamic-host#configuring-the-agent-repository-as-the-mirror).                                                                                                                                                                                           | `nil`                                                                                                              |
| `agent.instanaSharedRepoMirrorUsername`                    | The username for authentication for the for the agent shared repository mirror. For more information, see [Configuring the agent repository as the mirror](https://www.ibm.com/docs/en/instana-observability/current?topic=agents-setting-up-agent-repositories-dynamic-host#configuring-the-agent-repository-as-the-mirror).                                                                                                                                                                                           | `nil`                                                                                                              |
| `agent.instanaSharedRepoMirrorPassword`                    | The password for authentication for the for the agent shared repository mirror. For more information, see [Configuring the agent repository as the mirror](https://www.ibm.com/docs/en/instana-observability/current?topic=agents-setting-up-agent-repositories-dynamic-host#configuring-the-agent-repository-as-the-mirror).                                                                                                                                                                                           | `nil`                                                                                                              |
| `agent.updateStrategy.type`                         | [DaemonSet update strategy type](https://kubernetes.io/docs/tasks/manage-daemon/update-daemon-set/); valid values are `OnDelete` and `RollingUpdate`                                                                                                                                                                   | `RollingUpdate`                                                                                                                         |
| `agent.updateStrategy.rollingUpdate.maxUnavailable` | How many agent pods can be updated at once; this value is ignored if `agent.updateStrategy.type` is different than `RollingUpdate`                                                                                                                                                                                     | `1`                                                                                                                                     |
| `agent.minReadySeconds`                             | The minimum number of seconds for which a newly created Pod should be ready without any of its containers crashing, for it to be considered available                                                                                                                                                                  | `0`                                                                                                                                     |
| `agent.pod.annotations`                             | Additional annotations to apply to the pod                                                                                                                                                                                                                                                                             | `{}`                                                                                                                                    |
| `agent.pod.labels`                                  | Additional labels to apply to the Agent pod                                                                                                                                                                                                                                                                            | `{}`                                                                                                                                    |
| `agent.pod.priorityClassName`                       | Name of an _existing_ PriorityClass that should be set on the agent pods                                                                                                                                                                                                                                               | `nil`                                                                                                                                   |
| `agent.proxyHost`                                   | Hostname/address of a proxy                                                                                                                                                                                                                                                                                            | `nil`                                                                                                                                   |
| `agent.proxyPort`                                   | Port of a proxy                                                                                                                                                                                                                                                                                                        | `nil`                                                                                                                                   |
| `agent.proxyProtocol`                               | Proxy protocol. Supported proxy types are `http` (for both HTTP and HTTPS proxies), `socks4`, `socks5`.                                                                                                                                                                                                                | `nil`                                                                                                                                   |
| `agent.proxyUser`                                   | Username of the proxy auth                                                                                                                                                                                                                                                                                             | `nil`                                                                                                                                   |
| `agent.proxyPassword`                               | Password of the proxy auth                                                                                                                                                                                                                                                                                             | `nil`                                                                                                                                   |
| `agent.proxyUseDNS`                                 | Boolean if proxy also does DNS                                                                                                                                                                                                                                                                                         | `nil`                                                                                                                                   |
| `agent.pod.limits.cpu`                              | Container cpu limits in cpu cores                                                                                                                                                                                                                                                                                      | `1.5`                                                                                                                                   |
| `agent.pod.limits.memory`                           | Container memory limits in MiB                                                                                                                                                                                                                                                                                         | `768Mi`                                                                                                                                 |
| `agent.pod.requests.cpu`                            | Container cpu requests in cpu cores                                                                                                                                                                                                                                                                                    | `0.5`                                                                                                                                   |
| `agent.pod.requests.memory`                         | Container memory requests in MiB                                                                                                                                                                                                                                                                                       | `768Mi`                                                                                                                                 |
| `agent.pod.tolerations`                             | Tolerations for pod assignment                                                                                                                                                                                                                                                                                         | `[]`                                                                                                                                    |
| `agent.pod.affinity`                                | Affinity for pod assignment                                                                                                                                                                                                                                                                                            | `{}`                                                                                                                                    |
| `agent.pod.volumes`                                | Custom volumes of the agent pod, see https://kubernetes.io/docs/concepts/storage/volumes/                                                                                                                                                                                                                                                                                            | `[]`                                                                                                                                    |
| `agent.pod.volumeMounts`                           | Custom volume mounts of the agent pod, see https://kubernetes.io/docs/concepts/storage/volumes/                                                                                                                                                                                                                                                                                            | `[]`                                                                                                                                    |
| `agent.pod.env`                                         | Additional environment variables for the agent using the Kubernetes syntax. See example below.                                                                                                                                                                                                                                                                         | `{}`                                                                                                                                    |
| `agent.pod.livenessProbe`                               | Override the default liveness probe settings for the agent container. Allows customization of `initialDelaySeconds`, `timeoutSeconds`, `periodSeconds`, and `failureThreshold`. See [Liveness Probe Configuration](#liveness-probe-configuration) for more details.                                                                                                      | Default: `initialDelaySeconds: 600`, `timeoutSeconds: 5`, `periodSeconds: 10`, `failureThreshold: 6`                                   |
| `agent.serviceMesh.enabled`                         | Activate Instana Agent JVM monitoring service mesh support for Istio or OpenShift ServiceMesh                                                                                                                                                                                                                          | `true`                                                                                                                                  |
| `agent.env`                                         | Additional environment variables for the agent                                                                                                                                                                                                                                                                         | `{}`                                                                                                                                    |
| `agent.redactKubernetesSecrets`                     | Enable additional secrets redaction for selected Kubernetes resources                                                                                                                                                                                                                                                  | `nil` See [Kubernetes secrets](https://docs.instana.io/setup_and_manage/host_agent/on/kubernetes/#secrets) for more details.            |
| `cluster.name`                                      | Display name of the monitored cluster                                                                                                                                                                                                                                                                                  | Value of `zone.name`                                                                                                                    |
| `k8s_sensor.deployment.enabled`                     | Isolate k8sensor with a deployment                                                                                                                                                                                                                                                                                     |
| `k8s_sensor.deployment.minReadySeconds`             | The minimum number of seconds for which a newly created Pod should be ready without any of its containers crashing, for it to be considered available                                                                                                                                                                  | `0`                                                                                                                                     | `true` |
| `k8s_sensor.image.name`                             | The k8sensor image name to pull                                                                                                                                                                                                                                                                                        | `gcr.io/instana/k8sensor`                                                                                                               |
| `k8s_sensor.image.digest`                           | The image digest to pull; if specified, it causes `k8s_sensor.image.tag` to be ignored                                                                                                                                                                                                                                 | `nil`                                                                                                                                   |
| `k8s_sensor.image.tag`                              | The image tag to pull; this property is ignored if `k8s_sensor.image.digest` is specified                                                                                                                                                                                                                              | `latest`                                                                                                                                |
| `k8s_sensor.deployment.pod.limits.cpu`              | CPU request for the `k8sensor` pods                                                                                                                                                                                                                                                                                    | `4`                                                                                                                                     |
| `k8s_sensor.deployment.pod.limits.memory`           | Memory request limits for the `k8sensor` pods                                                                                                                                                                                                                                                                          | `6144Mi`                                                                                                                                |
| `k8s_sensor.deployment.pod.requests.cpu`            | CPU limit for the `k8sensor` pods                                                                                                                                                                                                                                                                                      | `1.5`                                                                                                                                   |
| `k8s_sensor.deployment.pod.requests.memory`         | Memory limit for the `k8sensor` pods                                                                                                                                                                                                                                                                                   | `1024Mi`                                                                                                                                |
| `k8s_sensor.etcd.insecure`                          | Whether to use insecure connection to ETCD                                                                                                                                                                                                                                                                             | `false`                                                                                                                                 |
| `k8s_sensor.etcd.ca.mountPath`                      | Path where the CA should be mounted for ETCD                                                                                                                                                                                                                                                                           | `nil`                                                                                                                                   |
| `k8s_sensor.etcd.ca.secretName`                     | Kubernetes Secret name containing the CA certificate for ETCD                                                                                                                                                                                                                                                          | `nil`                                                                                                                                   |
| `k8s_sensor.etcd.ca.filename`                       | Name of the file containing the CA Certificate for ETCD (key in the Kubernetes Secret)                                                                                                                                                                                                                                 | `nil`                                                                                                                                   |
| `k8s_sensor.etcd.targets`                           | Optional ETCD targets for vanilla clusters                                                                                                                                                                                                                                                                             | `nil`                                                                                                                                   |
| `k8s_sensor.featureFlags.crdMonitoring`             | Enable or disable Custom Resource Definition (CRD) monitoring in the k8sensor. When enabled, the k8sensor will monitor and report on CRDs in the cluster.                                                                                                                                                              | `false`                                                                                                                                 |
| `k8s_sensor.restClient.hostAllowlist`               | List of hosts allowed for REST client connections                                                                                                                                                                                                                                                                      | `nil`                                                                                                                                   |
| `k8s_sensor.restClient.ca.mountPath`                | Path where the CA should be mounted for REST client                                                                                                                                                                                                                                                                    | `nil`                                                                                                                                   |
| `k8s_sensor.restClient.ca.secretName`               | Kubernetes Secret name containing the CA certificate for REST client                                                                                                                                                                                                                                                   | `nil`                                                                                                                                   |
| `k8s_sensor.restClient.ca.filename`                 | Name of the file containing the CA Certificate for REST client (key in the Kubernetes Secret)                                                                                                                                                                                                                          | `nil`                                                                                                                                   |
| `podSecurityPolicy.enable`                          | Whether a PodSecurityPolicy should be authorized for the Instana Agent pods. Requires `rbac.create` to be `true` as well and it is available until Kubernetes version v1.25.                                                                                                                                           | `false` See [PodSecurityPolicy](https://docs.instana.io/setup_and_manage/host_agent/on/kubernetes/#podsecuritypolicy) for more details. |
| `podSecurityPolicy.name`                            | Name of an _existing_ PodSecurityPolicy to authorize for the Instana Agent pods. If not provided and `podSecurityPolicy.enable` is `true`, a PodSecurityPolicy will be created for you.                                                                                                                                | `nil`                                                                                                                                   |
| `rbac.create`                                       | Whether RBAC resources should be created                                                                                                                                                                                                                                                                               | `true`                                                                                                                                  |
| `opentelemetry.grpc.enabled`                        | Whether to configure the agent to accept telemetry from OpenTelemetry applications via gRPC. This option also implies `service.create=true`, and requires Kubernetes 1.21+, as it relies on `internalTrafficPolicy`.                                                                                                   | `true`                                                                                                                                  |
| `opentelemetry.grpc.port`                        | Port to be used for the OpenTelemetry GRPC endpoint.                                                                                                   | `4317`                                                                                                                                  |
| `opentelemetry.http.enabled`                        | Whether to configure the agent to accept telemetry from OpenTelemetry applications via HTTP. This option also implies `service.create=true`, and requires Kubernetes 1.21+, as it relies on `internalTrafficPolicy`.                                                                                                   | `true`                                                                                                                                  |
| `opentelemetry.http.port`                        | Port to be used for the OpenTelemetry HTTP endpoint.                                                                                                   | `4318`                                                                                                                                  |
| `prometheus.remoteWrite.enabled`                    | Whether to configure the agent to accept metrics over its implementation of the `remote_write` Prometheus endpoint. This option also implies `service.create=true`, and requires Kubernetes 1.21+, as it relies on `internalTrafficPolicy`.                                                                            | `false`                                                                                                                                 |
| `service.create`                                    | Whether to create a service that exposes the agents' Prometheus, OpenTelemetry and other APIs inside the cluster. Requires Kubernetes 1.21+, as it relies on `internalTrafficPolicy`. The `ServiceInternalTrafficPolicy` feature gate needs to be enabled (default: enabled).                                          | `true`                                                                                                                                  |
| `serviceAccount.create`                             | Whether a ServiceAccount should be created                                                                                                                                                                                                                                                                             | `true`                                                                                                                                  |
| `serviceAccount.name`                               | Name of the ServiceAccount to use                                                                                                                                                                                                                                                                                      | `instana-agent`                                                                                                                         |
| `serviceAccount.annotations`                        | Annotations to add to the service account                                                                                                                                                                                                                                                                              | `{}`                                                                                                                                    |
| `useSecretMounts`                                   | Controls whether sensitive information is mounted as files instead of environment variables. Improves security by preventing credentials from being visible in process listings.                                                                                                                                         | `true`                                                                                                                                  |
| `zone.name`                                         | Zone that detected technologies will be assigned to                                                                                                                                                                                                                                                                    | `nil` You must provide either `zone.name` or `cluster.name`, see [above](#installation) for details                                     |
| `zones`                                             | Multi-zone daemonset configuration.                                                                                                                                                                                                                                                                                    | `nil` see [below](#multiple-zones) for details                                                                                          |
| `k8s_sensor.podDisruptionBudget.enabled`            | Whether to create DisruptionBudget for k8sensor to limit the number of concurrent disruptions                                                                                                                                                                                                                          | `false`                                                                                                                                 |
| `k8s_sensor.deployment.pod.affinity`                | `k8sensor` deployment affinity format                                                                                                                                                                                                                                                                                  | `podAntiAffinity` defined in `values.yaml`                                                                                              |
| `controllerManager.image.name`                                  | The image name to pull                                                                                                                                                                                                                                                                                                 | `instana/agent`                                                                                                                         |
| `controllerManager.image.digest`                                | The image digest to pull; if specified, it causes `controllerManager.image.tag` to be ignored                                                                                                                                                                                                                                      | `nil`                                                                                                                                   |
| `controllerManager.image.tag`                                   | The image tag to pull; this property is ignored if `controllerManager.image.digest` is specified                                                                                                                                                                                                                                   | `latest`                                                                                                                                |
| `controllerManager.image.pullPolicy`                            | Image pull policy                                                                                                                                                                                                                                                                                                      | `Always`                                                                                                                                |
| `controllerManager.image.pullSecrets`                           | Image pull secrets                                                                                | `nil`                                                                                                                                   |
| `controllerManager.resources`                           | limits.cpu, limits.memory, requests.cpu and requests.memory can be defined                                                                              | `nil`                                                                                                                                   |


### Agent Modes

Agent can have either `APM` or `INFRASTRUCTURE`.
Default is APM and if you want to override that, ensure you set value:

* `agent.mode`

For more information on agent modes, refer to the [Host Agent Modes](https://www.instana.com/docs/setup_and_manage/host_agent#host-agent-modes) documentation.

### Agent Configuration

Besides the settings listed above, there are many more settings that can be applied to the agent via the so-called "Agent Configuration File", often also referred to as `configuration.yaml` file.
An overview of the settings that can be applied is provided in the [Agent Configuration File](https://www.instana.com/docs/setup_and_manage/host_agent/configuration#agent-configuration-file) documentation.
To configure the agent, you need to provide the configuration via the `agent.configuration_yaml` parameter in [values.yaml](values.yaml). As all other settings, the Agent configuration is handled by the Operator and stored in Kubernetes Secret resources internally. This way, even plain text passwords are not exposed in any configmap after deployment.

This configuration will be used for all Instana Agents on all nodes. Visit the [agent configuration documentation](https://docs.instana.io/setup_and_manage/host_agent/#agent-configuration-file) for more details on configuration options.

_Note:_ This Helm Chart does not support configuring [Multiple Configuration Files](https://www.instana.com/docs/setup_and_manage/host_agent/configuration#multiple-configuration-files).

### Agent Pod Sizing

The `agent.pod.requests.cpu`, `agent.pod.requests.memory`, `agent.pod.limits.cpu` and `agent.pod.limits.memory` settings allow you to change the sizing of the `instana-agent` pods.
If you are using the [Kubernetes Sensor Deployment](#kubernetes-sensor-deployment) functionality, you may be able to reduce the default amount of resources, and especially memory, allocated to the Instana agents that monitor your applications.
Actual sizing data depends very much on how many pods, containers and applications are monitored, and how much traces they generate, so we cannot really provide a rule of thumb for the sizing.

### Bring your own Keys secret

In case you have automation that creates secrets for you, it may not be desirable for this Helm chart to create a secret containing the `agent.key` and `agent.downloadKey`.
In this case, you can instead specify the name of an alread-existing secret in the namespace in which you install the Instana agent that carries the agent key and download key.

The secret you specify The secret you specify _must_ have a field called `key`, which would contain the value you would otherwise set to `agent.key`, and _may_ contain a field called `downloadKey`, which would contain the value you would otherwise set to `agent.downloadKey`.

### Configuring Additional Configuration Files

[Multiple configuration files](https://www.instana.com/docs/setup_and_manage/host_agent/configuration#multiple-configuration-files) is a capability of the Instana agent that allows for modularity in its configurations files.

The experimental `agent.configuration.autoMountConfigEntries`, which uses functionality available in Helm 3.1+ to automatically look up the entries of the default `instana-agent` ConfigMap, and mount as agent configuration files in the `instana-agent` container under the `/opt/instana/agent/etc/instana` directory all ConfigMap entries with keys that match the `configuration-*.yaml` scheme.

**IMPORTANT:** Needs Helm 3.1+ as it is built on the `lookup` function
**IMPORTANT:** Editing the ConfigMap adding keys requires a `helm upgrade` to take effect

### Configuring Additional Backends

You may want to have your Instana agents report to multiple backends.
The first backend must be configured as shown in the [Configuring the Instana Backend](#configuring-the-instana-backend); every backend after the first, is configured in the `agent.additionalBackends` list in the [values.yaml](values.yaml) as follows:

```yaml
agent:
  additionalBackends:
  # Second backend
  - endpointHost: my-instana.instana.io # endpoint host; e.g., my-instana.instana.io
    endpointPort: 443 # default is 443, so this line could be omitted
    key: ABCDEFG # agent key for this backend
  # Third backend
  - endpointHost: another-instana.instana.io # endpoint host; e.g., my-instana.instana.io
    endpointPort: 1444 # default is 443, so this line could be omitted
    key: LMNOPQR # agent key for this backend
```

The snippet above configures the agent to report to two additional backends.
The same effect as the above can be accomplished via the command line via:

```sh
$ helm install -n instana-agent instana-agent ... \
    --repo https://agents.instana.io/helm \
    --set 'agent.additionalBackends[0].endpointHost=my-instana.instana.io' \
    --set 'agent.additionalBackends[0].endpointPort=443' \
    --set 'agent.additionalBackends[0].key=ABCDEFG' \
    --set 'agent.additionalBackends[1].endpointHost=another-instana.instana.io' \
    --set 'agent.additionalBackends[1].endpointPort=1444' \
    --set 'agent.additionalBackends[1].key=LMNOPQR' \
    instana-agent
```

_Note:_ There is no hard limitation on the number of backends an Instana agent can report to, although each comes at the cost of a slight increase in CPU and memory consumption.

### Configuring a Proxy between the Instana agents and the Instana backend

If your infrastructure uses a proxy, you should ensure that you set values for:

* `agent.proxyHost`
* `agent.proxyPort`
* `agent.proxyProtocol`
* `agent.proxyUser`
* `agent.proxyPassword`
* `agent.proxyUseDNS`

#### Same Proxy for Repository and the Instana backend

If the same proxy is utilized for both backend and repository, configure only the 'Agent' proxy settings  using the following parameter:
 ```
  --set agent.proxyHost='<Hostname/address of a proxy>' 
 ```

#### Separate Proxies for Repository and the Instana backend

In scenarios where distinct proxy settings are employed for the backend and repository, both proxies must be configured separately. The key is to ensure that `INSTANA_REPOSITORY_PROXY_ENABLED=true` is set.

To use this variant, execute helm install with the following additional parameters:

```
--set agent.proxyHost='Hostname/address of a proxy'
--set agent.env.INSTANA_REPOSITORY_PROXY_ENABLED='true'
--set agent.env.INSTANA_REPOSITORY_PROXY_HOST='Hostname/address of a proxy'
```
Make sure to replace 'Hostname/address of a proxy' with the actual hostname or address of your proxy.

### Configuring which Networks the Instana Agent should listen on

If your infrastructure has multiple networks defined, you might need to allow the agent to listen on all addresses (typically with value set to `*`):

* `agent.listenAddress`

### Setup TLS Encryption for Agent Endpoint

TLS encryption can be added via two variants.
Either an existing secret can be used or a certificate and a private key can be used during the installation.

#### Using existing secret

An existing secret of type `kubernetes.io/tls` can be used.
Only the `secretName` must be provided during the installation with `--set 'agent.tls.secretName=<YOUR_SECRET_NAME>'`.
The files from the provided secret are then mounted into the agent.

#### Provide certificate and private key

On the other side, a certificate and a private key can be added during the installation.
The certificate and private key must be base64 encoded.

To use this variant, execute `helm install` with the following additional parameters:

```
--set 'agent.tls.certificate=<YOUR_CERTIFICATE_BASE64_ENCODED>'
--set 'agent.tls.key=<YOUR_PRIVATE_KEY_BASE64_ENCODED>'
```

If `agent.tls.secretName` is set, then `agent.tls.certificate` and `agent.tls.key` are ignored.

### Development and debugging options

These options will be rarely used outside of development or debugging of the agent.

| Parameter               | Description                                      | Default |
| ----------------------- | ------------------------------------------------ | ------- |
| `agent.host.repository` | Host path to mount as the agent maven repository | `nil`   |

### Kubernetes Sensor Deployment

 _Note: leader-elector and kubernetes sensor are fully deprecated and can no longer be chosen. Instead, the k8s_sensor will be used._

The Helm chart will schedule additional Instana agents running _only_ the Kubernetes sensor that runs in a dedicated `k8sensor` Deployment inside the `instana-agent` namespace.
The pods containing agents that run only the Kubernetes sensor are called `k8sensor` pods.
When `k8s_sensor.deployment.enabled=true`, the `instana-agent` pods running inside the daemonset do _not_ contain the `leader-elector` container, which is instead scheduled inside the `k8sensor` pods.

The `instana-agent` and `k8sensor` pods share the same configurations in terms of backend-related configurations (including [additional backends](#configuring-additional-backends)).

The `k8s_sensor.deployment.pod.requests.cpu`, `k8s_sensor.deployment.pod.requests.memory`, `k8s_sensor.deployment.pod.limits.cpu` and `k8s_sensor.deployment.pod.limits.memory` settings, allow you to change the sizing of the `k8sensor` pods.

### Multiple Zones

You can list zones to use affinities and tolerations as the basis to associate a specific daemonset per tainted node pool. Each zone will have the following data:

* `name` (required) - zone name.
* `mode` (optional) - instana agent mode (e.g. APM, INFRASTRUCTURE, etc).
* `affinity` (optional) - standard kubernetes pod affinity list for the daemonset.
* `tolerations` (optional) - standard kubernetes pod toleration list for the daemonset.

The following is an example that will create 2 zones an api-server and a worker zone:

```yaml
zones:
  - name: workers
    mode: APM
  - name: api-server
    mode: INFRASTRUCTURE
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
            - matchExpressions:
                - key: node-role.kubernetes.io/control-plane
                  operator: Exists
    tolerations:
    - key: "node-role.kubernetes.io/master"
      operator: "Exists"
      effect: "NoSchedule"
```

### Environment variables

The Instana Agent helm chart supports two ways to define environment variables for the agent pods:

#### 1. Legacy Method: Simple Key-Value Pairs

The original method uses a simple key-value map in the `agent.env` field:

```yaml
  agent:
    env:
      INSTANA_AGENT_TAGS: dev,test
      CUSTOM_ENV_VAR: custom-value
```

This method is simple but limited to string values only.

#### 2. Enhanced Method: Full Kubernetes EnvVar Support

The new method uses the standard Kubernetes EnvVar structure in the `agent.pod.env` field, which provides more flexibility:

```yaml
agent:
  pod:
    env:
      # Simple value
      - name: INSTANA_AGENT_TAGS
        value: "kubernetes,production,custom"

      # From field reference
      - name: MY_POD_NAME
        valueFrom:
          fieldRef:
            fieldPath: metadata.name

      # From secret
      - name: DATABASE_PASSWORD
        valueFrom:
          secretKeyRef:
            name: app-secrets
            key: db-password
            optional: true

      # From ConfigMap
      - name: APP_CONFIG
        valueFrom:
          configMapKeyRef:
            name: app-config
            key: config.json
            optional: true
```

#### Supported ValueFrom Sources

The enhanced method supports all standard Kubernetes environment variable sources:

1. **Field References**: Access pod metadata and status fields
   ```yaml
   valueFrom:
     fieldRef:
       fieldPath: metadata.name
   ```

2. **Resource Field References**: Access container resource limits and requests
   ```yaml
   valueFrom:
     resourceFieldRef:
       containerName: instana-agent
       resource: requests.cpu
       divisor: 1m
   ```

3. **ConfigMap References**: Get values from ConfigMaps
   ```yaml
   valueFrom:
     configMapKeyRef:
       name: my-config
       key: my-key
       optional: true
   ```

4. **Secret References**: Get values from Secrets
   ```yaml
   valueFrom:
     secretKeyRef:
       name: my-secret
       key: my-key
       optional: true
   ```

#### Precedence

If both `agent.env` and `agent.pod.env` are defined, both will be applied to the agent container. In case of duplicate environment variable names, the values from `agent.pod.env` will take precedence.

### Volumes and volumeMounts

You can define volumes and volumeMounts in the helm configuration to make files available to the agent pod, e.g. to provide client certificates or custom certificate authorities for a sensor to reach a monitored target.

Example:

An application requires the usage of a customer provided java key store (JKS) to interact with a monitored process, e.g. IBM MQ. The keystore file is created as secret in the cluster.

To create the secret, the file can be uploaded with the Kubernetes `kubectl` or Openshift `oc` command line tools.

```bash
kubectl create secret generic keystore-secret-name --from-file=./application.jks -n instana-agent
```

Create a custom values file for the helm installation, e.g. `custom-values.yaml` and adjust the following content accordingly.

```yaml
agent:
  pod:
    volumeMounts:
    - mountPath: /opt/instana/agent/etc/application.jks
      name: jks-mount
      subPath: application.jks
    volumes:
    - name: jks-mount
      secret:
        secretName: keystore-secret-name
```

To deploy the helm chart with the custom mount, specify the configuration as additional parameter.

```bash
helm install instana-agent \
  --repo https://agents.instana.io/helm \
  --namespace instana-agent \
  --set agent.key='<your_agent_key>' \
  --set agent.endpointHost='<your_host_agent_endpoint>' \
  --set agent.endpointPort=443 \
  --set cluster.name='<your_cluster_name>' \
  --set zone.name='<your_zone_name>' \
  -f custom-values.yaml \
  instana-agent
```

See [Kubernetes documentation](https://kubernetes.io/docs/concepts/storage/volumes/) for other examples of volume options.


The mounted file will be available inside the agent pods after the installation.

```
$ kubectl exec instana-agent-xxxxx -- ls /opt/instana/agent/etc/application.jks
/opt/instana/agent/etc/application.jks
```

### Secret Mounts Feature

The Secret Mounts feature improves security by mounting sensitive information as files instead of exposing them as environment variables in Kubernetes pods. This is a security best practice that prevents credentials from being visible during command line debugging or in process listings.

When enabled (default), the Instana Agent Operator:

1. Creates a secrets directory at `/opt/instana/agent/etc/instana/secrets/`
2. Mounts sensitive information as files in this directory
3. Skips setting sensitive environment variables
4. Configures the agent to read secrets from files when available

The feature is controlled by the `useSecretMounts` flag at the top level of the spec:

```yaml
apiVersion: instana.io/v1
kind: InstanaAgent
metadata:
  name: instana-agent
  namespace: instana-agent
spec:
  useSecretMounts: true  # Set to false to disable secret mounts
  agent:
    key: <your-agent-key>
    endpointHost: <your-endpoint-host>
    endpointPort: <your-endpoint-port>
```

The same configuration applies to `InstanaAgentRemote`.

The feature is **enabled by default** (useSecretMounts: true), no action is required to use this feature in new deployments

If you need to revert to the previous behavior (using environment variables for secrets), set the property to false:

```yaml
spec:
  useSecretMounts: false
```

When the feature is enabled, the following secrets are mounted as files:

Secret | File Path |
|--------|-----------|
Agent Key | `/opt/instana/agent/etc/instana/secrets/INSTANA_AGENT_KEY` |
Download Key | `/opt/instana/agent/etc/instana/secrets/INSTANA_DOWNLOAD_KEY` |
Proxy User | `/opt/instana/agent/etc/instana/secrets/INSTANA_AGENT_PROXY_USER` |
Proxy Password | `/opt/instana/agent/etc/instana/secrets/INSTANA_AGENT_PROXY_PASSWORD` |
HTTPS Proxy | `/opt/instana/agent/etc/instana/secrets/HTTPS_PROXY` |
Release Repo Mirror Username | `/opt/instana/agent/etc/instana/secrets/AGENT_RELEASE_REPOSITORY_MIRROR_USERNAME` |
Release Repo Mirror Password | `/opt/instana/agent/etc/instana/secrets/AGENT_RELEASE_REPOSITORY_MIRROR_PASSWORD` |
Shared Repo Mirror Username | `/opt/instana/agent/etc/instana/secrets/INSTANA_SHARED_REPOSITORY_MIRROR_USERNAME` |
Shared Repo Mirror Password | `/opt/instana/agent/etc/instana/secrets/INSTANA_SHARED_REPOSITORY_MIRROR_PASSWORD` |

Security Benefits:

- Prevents secrets from being exposed in environment variables
- Reduces risk of credential exposure during debugging
- Follows Kubernetes security best practices for handling sensitive information
- Improves compliance with security standards that require protection of credentials

## Remote Agent Support

The Instana Agent Operator now supports remote agents through a dedicated Custom Resource Definition (CRD) called `AgentRemote`. This feature allows you to monitor systems that are not directly part of your Kubernetes cluster.

Unlike the regular Agent custom resource, which is managed by the Helm chart, the Remote Agent custom resource must be created manually. The Remote Agent feature is completely optional.

An example of the Remote Agent CR can be found here: https://github.com/instana/instana-agent-operator/blob/main/config/samples/instana_v1_instanaagentremote.yaml

## ETCD and RestClient Configuration

The Instana Agent Helm chart supports configuring secure connections to ETCD and controlling REST client access. These configurations are particularly useful for securing the monitoring of Kubernetes clusters.

### ETCD Configuration

ETCD configuration allows you to set up secure scraping of ETCD metrics:

```yaml
# Using Helm values
k8s_sensor:
  etcd:
    # Whether to use insecure connection to ETCD (default: false)
    insecure: false
    
    # CA configuration for ETCD
    ca:
      # Path where the CA should be mounted
      mountPath: "/etc/instana/etcd-ca"
      # Kubernetes Secret name containing the CA certificate
      secretName: "etcd-ca-cert"
      # Name of the file containing the CA Certificate (key in the Kubernetes Secret)
      filename: "ca.crt"
    
    # Optional ETCD targets for vanilla clusters
    targets:
      - "https://etcd-0.example.com:2379"
      - "https://etcd-1.example.com:2379"
```

You can apply these settings using Helm:

```bash
helm install instana-agent \
  --namespace instana-agent \
  --repo https://agents.instana.io/helm \
  --set agent.key=INSTANA_AGENT_KEY \
  --set agent.endpointHost=HOST \
  --set zone.name=ZONE_NAME \
  --set cluster.name="CLUSTER_NAME" \
  --set k8s_sensor.etcd.insecure=false \
  --set k8s_sensor.etcd.ca.mountPath="/etc/instana/etcd-ca" \
  --set k8s_sensor.etcd.ca.secretName="etcd-ca-cert" \
  --set k8s_sensor.etcd.ca.filename="ca.crt" \
  --set k8s_sensor.etcd.targets[0]="https://etcd-0.example.com:2379" \
  --set k8s_sensor.etcd.targets[1]="https://etcd-1.example.com:2379" \
  instana-agent
```

### REST Client Configuration

REST client configuration allows you to control which hosts the k8s_sensor can connect to and configure secure connections:

```yaml
# Using Helm values
k8s_sensor:
  restClient:
    # List of hosts allowed for REST client connections
    hostAllowlist:
      - "api.example.com"
      - "monitoring.example.com"
    
    # CA configuration for control plane
    ca:
      # Path where the CA should be mounted
      mountPath: "/etc/instana/rest-ca"
      # Kubernetes Secret name containing the CA certificate
      secretName: "rest-ca-cert"
      # Name of the file containing the CA Certificate (key in the Kubernetes Secret)
      filename: "ca.crt"
```

You can apply these settings using Helm:

```bash
helm install instana-agent \
  --namespace instana-agent \
  --repo https://agents.instana.io/helm \
  --set agent.key=INSTANA_AGENT_KEY \
  --set agent.endpointHost=HOST \
  --set zone.name=ZONE_NAME \
  --set cluster.name="CLUSTER_NAME" \
  --set k8s_sensor.restClient.hostAllowlist[0]="api.example.com" \
  --set k8s_sensor.restClient.hostAllowlist[1]="monitoring.example.com" \
  --set k8s_sensor.restClient.ca.mountPath="/etc/instana/rest-ca" \
  --set k8s_sensor.restClient.ca.secretName="rest-ca-cert" \
  --set k8s_sensor.restClient.ca.filename="ca.crt" \
  instana-agent
```

### Combined Configuration Example for ETCD and RestClient

This values.yaml file can be used to configure etcd and restClient for the k8sensor in a single configuration.
Especially, if settings become more complex, the values.yaml is the preferred options.

```yaml
cluster:
  name: my-cluster
agent:
  key: your-agent-key
  endpointHost: ingress-red-saas.instana.io
  endpointPort: 443
k8s_sensor:
  # ETCD configuration for secure scraping
  etcd:
    # Whether to use insecure connection to ETCD
    insecure: false
    # CA configuration for ETCD
    ca:
      # Path where the CA should be mounted
      mountPath: "/etc/instana/etcd-ca"
      # Kubernetes Secret name containing the CA certificate
      secretName: "etcd-ca-cert"
      # Name of the file containing the CA Certificate (key in the Kubernetes Secret)
      filename: "ca.crt"
    # Optional ETCD targets for vanilla clusters
    targets:
      - "https://etcd-0.example.com:2379"
      - "https://etcd-1.example.com:2379"
  
  # REST client configuration
  restClient:
    # List of hosts allowed for REST client connections
    hostAllowlist:
      - "api.example.com"
      - "monitoring.example.com"
    # CA configuration for control plane
    ca:
      # Path where the CA should be mounted
      mountPath: "/etc/instana/rest-ca"
      # Kubernetes Secret name containing the CA certificate
      secretName: "rest-ca-cert"
      # Name of the file containing the CA Certificate (key in the Kubernetes Secret)
      filename: "ca.crt"
```

This will create this agent CR used by the instana-agent-operator:

You can combine both ETCD and RestClient configurations:

```yaml
apiVersion: instana.io/v1
kind: InstanaAgent
metadata:
  name: instana-agent
spec:
  cluster:
    name: my-cluster
  agent:
    key: your-agent-key
    endpointHost: ingress-red-saas.instana.io
    endpointPort: "443"
  k8s_sensor:
    # ETCD configuration for secure scraping
    etcd:
      # Whether to use insecure connection to ETCD
      insecure: false
      # CA configuration for ETCD
      ca:
        # Path where the CA should be mounted
        mountPath: "/etc/instana/etcd-ca"
        # Kubernetes Secret name containing the CA certificate
        secretName: "etcd-ca-cert"
        # Name of the file containing the CA Certificate (key in the Kubernetes Secret)
        filename: "ca.crt"
      # Optional ETCD targets for vanilla clusters
      targets:
        - "https://etcd-0.example.com:2379"
        - "https://etcd-1.example.com:2379"
    
    # REST client configuration
    restClient:
      # List of hosts allowed for REST client connections
      hostAllowlist:
        - "api.example.com"
        - "monitoring.example.com"
      # CA configuration for control plane
      ca:
        # Path where the CA should be mounted
        mountPath: "/etc/instana/rest-ca"
        # Kubernetes Secret name containing the CA certificate
        secretName: "rest-ca-cert"
        # Name of the file containing the CA Certificate (key in the Kubernetes Secret)
        filename: "ca.crt"
```
### Liveness Probe Configuration

The Instana Agent supports customization of the liveness probe settings for the agent container. This allows you to adjust health check parameters to match your environment's requirements.

#### Default Settings

By default, the agent uses the following liveness probe configuration:

```yaml
livenessProbe:
  httpGet:
    host: 127.0.0.1
    path: /status
    port: 42699
  initialDelaySeconds: 600  # Wait 10 minutes before first check
  timeoutSeconds: 5          # Allow 5 seconds for the probe to complete
  periodSeconds: 10          # Check every 10 seconds
  failureThreshold: 6        # Allow 6 consecutive failures before restart
```

#### Customizing Liveness Probe

You can override these settings using the `agent.pod.livenessProbe` configuration in your values.yaml:

```yaml
agent:
  pod:
    livenessProbe:
      httpGet:
        host: 127.0.0.1
        path: /status
        port: 42699
      initialDelaySeconds: 900  # Wait 15 minutes before first check
      timeoutSeconds: 10         # Allow 10 seconds for the probe to complete
      periodSeconds: 15          # Check every 15 seconds
      failureThreshold: 5        # Allow 5 consecutive failures before restart
```

Or using Helm command line:

```bash
helm install instana-agent \
  --namespace instana-agent \
  --repo https://agents.instana.io/helm \
  --set agent.key=INSTANA_AGENT_KEY \
  --set agent.endpointHost=HOST \
  --set zone.name=ZONE_NAME \
  --set cluster.name="CLUSTER_NAME" \
  --set agent.pod.livenessProbe.initialDelaySeconds=900 \
  --set agent.pod.livenessProbe.timeoutSeconds=10 \
  --set agent.pod.livenessProbe.periodSeconds=15 \
  --set agent.pod.livenessProbe.failureThreshold=5 \
  instana-agent
```

#### Configuration Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `httpGet.host` | The host to connect to for the health check | `127.0.0.1` |
| `httpGet.path` | The path to request for the health check | `/status` |
| `httpGet.port` | The port to connect to for the health check | `42699` |
| `initialDelaySeconds` | Number of seconds after the container has started before liveness probes are initiated | `600` |
| `timeoutSeconds` | Number of seconds after which the probe times out | `5` |
| `periodSeconds` | How often (in seconds) to perform the probe | `10` |
| `failureThreshold` | Number of consecutive failures before the container is restarted | `6` |

#### Use Cases

**High-Load Environments**: Increase `initialDelaySeconds` and `timeoutSeconds` to allow more time for the agent to start and respond:

```yaml
agent:
  pod:
    livenessProbe:
      initialDelaySeconds: 900
      timeoutSeconds: 10
      failureThreshold: 5
```

**Fast Recovery**: Decrease `periodSeconds` and `failureThreshold` for quicker detection and recovery:

```yaml
agent:
  pod:
    livenessProbe:
      periodSeconds: 5
      failureThreshold: 3
```

**Note**: The liveness probe configuration is optional. If not specified, the operator will use the default values.

## References

[1] ["Using Kubernetes Helm to push ConfigMap changes to your Deployments", by Sander Knape; Mar 7, 2019](https://sanderknape.com/2019/03/kubernetes-helm-configmaps-changes-deployments/)
