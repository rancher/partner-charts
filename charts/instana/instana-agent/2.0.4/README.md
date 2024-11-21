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
helm uninstall instana-agent -n instana-agent && kubectl patch agent instana-agent -p '{"metadata":{"finalizers":null}}' --type=merge &&
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
| `podSecurityPolicy.enable`                          | Whether a PodSecurityPolicy should be authorized for the Instana Agent pods. Requires `rbac.create` to be `true` as well and it is available until Kubernetes version v1.25.                                                                                                                                           | `false` See [PodSecurityPolicy](https://docs.instana.io/setup_and_manage/host_agent/on/kubernetes/#podsecuritypolicy) for more details. |
| `podSecurityPolicy.name`                            | Name of an _existing_ PodSecurityPolicy to authorize for the Instana Agent pods. If not provided and `podSecurityPolicy.enable` is `true`, a PodSecurityPolicy will be created for you.                                                                                                                                | `nil`                                                                                                                                   |
| `rbac.create`                                       | Whether RBAC resources should be created                                                                                                                                                                                                                                                                               | `true`                                                                                                                                  |
| `opentelemetry.grpc.enabled`                        | Whether to configure the agent to accept telemetry from OpenTelemetry applications via gRPC. This option also implies `service.create=true`, and requires Kubernetes 1.21+, as it relies on `internalTrafficPolicy`.                                                                                                   | `true`                                                                                                                                  |
| `opentelemetry.http.enabled`                        | Whether to configure the agent to accept telemetry from OpenTelemetry applications via HTTP. This option also implies `service.create=true`, and requires Kubernetes 1.21+, as it relies on `internalTrafficPolicy`.                                                                                                   | `true`                                                                                                                                  |
| `prometheus.remoteWrite.enabled`                    | Whether to configure the agent to accept metrics over its implementation of the `remote_write` Prometheus endpoint. This option also implies `service.create=true`, and requires Kubernetes 1.21+, as it relies on `internalTrafficPolicy`.                                                                            | `false`                                                                                                                                 |
| `service.create`                                    | Whether to create a service that exposes the agents' Prometheus, OpenTelemetry and other APIs inside the cluster. Requires Kubernetes 1.21+, as it relies on `internalTrafficPolicy`. The `ServiceInternalTrafficPolicy` feature gate needs to be enabled (default: enabled).                                          | `true`                                                                                                                                  |
| `serviceAccount.create`                             | Whether a ServiceAccount should be created                                                                                                                                                                                                                                                                             | `true`                                                                                                                                  |
| `serviceAccount.name`                               | Name of the ServiceAccount to use                                                                                                                                                                                                                                                                                      | `instana-agent`                                                                                                                         |
| `serviceAccount.annotations`                        | Annotations to add to the service account                                                                                                                                                                                                                                                                              | `{}`                                                                                                                                    |
| `zone.name`                                         | Zone that detected technologies will be assigned to                                                                                                                                                                                                                                                                    | `nil` You must provide either `zone.name` or `cluster.name`, see [above](#installation) for details                                     |
| `zones`                                             | Multi-zone daemonset configuration.                                                                                                                                                                                                                                                                                    | `nil` see [below](#multiple-zones) for details                                                                                          |
| `k8s_sensor.podDisruptionBudget.enabled`            | Whether to create DisruptionBudget for k8sensor to limit the number of concurrent disruptions                                                                                                                                                                                                                          | `false`                                                                                                                                 |
| `k8s_sensor.deployment.pod.affinity`                | `k8sensor` deployment affinity format                                                                                                                                                                                                                                                                                  | `podAntiAffinity` defined in `values.yaml`                                                                                              |

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
* `agent.pod.proxyPort`
* `agent.pod.proxyProtocol`
* `agent.pod.proxyUser`
* `agent.pod.proxyPassword`
* `agent.pod.proxyUseDNS`

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

## Changelog

### 2.0.4

* Update to operator v2.1.10: Add roles for node metrics and stats for k8sensor

### 2.0.3

* Fix k8sensor deployment rendering

### 2.0.2

* Hardening for endpointPort and configuration parsing

### 2.0.1

* Fix rendering of the `spec.agent.env`, `spec.configuration_yaml`, `spec.agent.image.pullSecrets`

### 2.0.0

* Deploy the instana-agent operator instead of managing agent artifacts directly
* Always use the k8sensor, the deprecated kubernetes sensor is no longer supported (this is an internal change, Kubernetes clusters will still report into the Instana backend)
* BREAKING CHANGE: Due to limitations of helm to manage Custom Resource Definition (CRD) updates, the upgrade requires to apply the CRD from the helm chart crds folder manually. Find more details in the [upgrade](#upgrade) section.

### 1.2.74

* Enable OTLP by default

### 1.2.73

* Fix label for `io.instana/zone` to reflect the real agent mode
* Change the charts flag from ENABLE_AGENT_SOCKET to serviceMesh.enabled
* Add type: DirectoryOrCreate to DaemonSet definitions to ensure required directories exist

### 1.2.72

* Add minReadySeconds field to agent daemonset yaml

### 1.2.71

* Fix usage of digest for pulling images

### 1.2.70

* Allow the configuration of `minReadySeconds` for the agent daemonset and deployment

### 1.2.69

* Add possibility to set annotations for the serviceAccount.

### 1.2.68

* Add leader elector configuration back to allow for proper deprecation

### 1.2.67

* Fix variable name in the K8s deployment

### 1.2.66

* Allign the default Memory requests to 768Mi for the Agent container.

### 1.2.65

* Ensure we have appropriate SCC when running with new K8s sensor.

### 1.2.64

* Remove RBAC not required by agent when kubernetes-sensor is disabed.
* Add settings override for k8s-sensor affinity
* Add optional pod disruption budget for k8s-sensor

### 1.2.63

* Add RBAC required to allow access to /metrics end-points.

### 1.2.62

* Include k8s-sensor resources in the default static YAML definitions

### 1.2.61

* Increase timeout and initialDelay for the Agent container
* Add OTLP ports to headless service

### 1.2.60

* Enable the k8s_sensor by default

### 1.2.59

* Introduce unique selectorLabels and commonLabels for k8s-sensor deployment

### 1.2.58

* Default to `internalTrafficPolicy` instead of `topologyKeys` for rendering of static YAMLs

### 1.2.57

* Fix vulnerability in the leader-elector image

### 1.2.49

* Add zone name to label `io.instana/zone` in daemonset

### 1.2.48

* Set env var INSTANA_KUBERNETES_REDACT_SECRETS true if agent.redactKubernetesSecrets is enabled.
* Use feature PSP flag in k8sensor ClusterRole only when podsecuritypolicy.enable is true.

### 1.2.47

* Roll back the changes from version 1.2.46 to be compatible with the Agent Operator installation

### 1.2.46

* Use K8sensor by default.
* kubernetes.deployment.enabled setting overrides k8s_sensor.deployment.enabled setting.
* Use feature PSP flag in k8sensor ClusterRole only when podsecuritypolicy.enable is true.
* Throw failure if customer specifies proxy with k8sensor.
* Set env var INSTANA_KUBERNETES_REDACT_SECRETS true if agent.redactKubernetesSecrets is enabled.

### 1.2.45

* Use agent key secret in k8sensor deployment.

### 1.2.44

* Add support for enabling the hot-reload of `configuration.yaml` when the default `instana-agent` ConfigMap changes
* Enablement is done via the flag `--set agent.configuration.hotreloadEnabled=true`

### 1.2.43

* Bump leader-elector image to v0.5.16 (Update dependencies)

### 1.2.42

* Add support for creating multiple zones within the same cluster using affinity and tolerations.

### 1.2.41

* Add additional permissions (HPA, ResourceQuotas, etc) to k8sensor clusterrole.

### 1.2.40

* Mount all system mounts mountPropagation: HostToContainer.

### 1.2.39

* Add NO_PROXY to k8sensor deployment to prevent api-server requests from being routed to the proxy.

### 1.2.38

* Fix issue related to EKS version format when enabling OTel service.

### 1.2.37

* Fix issue where cluster_zone is used as cluster_name when `k8s_sensor.deployment.enabled=true`.
* Set `HTTPS_PROXY` in k8s deployment when proxy information is set.

### 1.2.36

* Remove Service `topologyKeys`, which was removed in Kubernetes v1.22. Replaced by `internalTrafficPolicy` which is available with Kubernetes v1.21+.

### 1.2.35

* Fix invalid backend port for new Kubernetes sensor (k8sensor)

### 1.2.34

* Add support for new Kubernetes sensor (k8sensor)
  * New Kubernetes sensor can be used via the flag `--set k8s_sensor.deployment.enabled=true`

### 1.2.33

* Bump leader-elector image to v0.5.15 (Update dependencies)

### 1.2.32

* Add support for containerd montoring on TKGI  

### 1.2.31

* Bump leader-elector image to v0.5.14 (Update dependencies)

### 1.2.30

* Pull agent image from IBM Cloud Container Registry (icr.io/instana/agent). No code changes have been made.
* Bump leader-elector image to v0.5.13 and pull from IBM Cloud Container Registry (icr.io/instana/leader-elector). No code changes have been made.

### 1.2.29

* Add an additional port to the Instana Agent `Service` definition, for the OpenTelemetry registered IANA port 4317.

### 1.2.28

* Fix deployment when `cluster.name` is not specified. Should be allowed according to docs but previously broke the Pod
    when starting up.

### 1.2.27

* Update leader elector image to `0.5.10` to tone down logging and make it configurable

### 1.2.26

* Add TLS support. An existing secret can be used of type `kubernetes.io/tls`. Or provide a certificate and a private key, which creates a new secret.
* Update leader elector image version to 0.5.9 to support PPCle

### 1.2.25

* Add `agent.pod.labels` to add custom labels to the Instana Agent pods

### 1.2.24

* Bump leader-elector image to v0.5.8 which includes a health-check endpoint. Update the `livenessProbe`
    correspondingly.

### 1.2.23

* Bump leader-elector image to v0.5.7 to fix a potential Golang bug in the elector

### 1.2.22

* Fix templating scope when defining multiple backends

### 1.2.21

* Internal updates

### 1.2.20

* upgrade leader-elector image to v0.5.6 to enable usage on s390x and arm64

### 1.2.18 / 1.2.19

* Internal change on generated DaemonSet YAML from the Helm charts

### 1.2.17

* Update Pod Security Policies as the `readOnly: true` appears not to be working for the mount points and
  actually causes the Agent deployment to fail when these policies are enforced in the cluster.

### 1.2.16

* Add configuration option for `INSTANA_MVN_REPOSITORY_URL` setting on the Agent container.

### 1.2.15

* Internal pipeline changes. No significant changes to the Helm charts

### v1.2.14

* Update Agent container mounts. Make some read-only as we don't need all mounts with read-write permissions.
    Additionally add the mount for `/var/data` which is needed in certain environments for the Agent to function
    properly.

### v1.2.13

* Update memory settings specifically for the Kubernetes sensor (Technical Preview)

### v1.2.11

* Simplify setup for using OpenTelemetry and the Prometheus `remote_write` endpoint using the `opentelemetry.enabled` and `prometheus.remoteWrite.enabled` settings, respectively.

### v1.2.9

* **Technical Preview:** Introduce a new mode of running to the Kubernetes sensor using a dedicated deployment.
  See the [Kubernetes Sensor Deployment](#kubernetes-sensor-deployment) section for more information.

### v1.2.7

* Fix: Make service opt-in, as it uses functionality (`topologyKeys`) that is available only in K8S 1.17+.

### v1.2.6

* Fix bug that might cause some OpenShift-specific resources to be created in other flavours of Kubernetes.

### v1.2.5

* Introduce the `instana-agent:instana-agent` Kubernetes service that allows you to talk to the Instana agent on the same node.

### v1.2.3

* Bug fix: Extend the built-in Pod Security Policy to cover the Docker socket mount for Tanzu Kubernetes Grid systems.

### v1.2.1

* Support OpenShift 4.x: just add --set openshift=true to the usual settings, and off you go :-)
* Restructure documentation for consistency and readability
* Deprecation: Helm 2 is no longer supported; the minimum Helm API version is now v2, which will make Helm 2 refuse to process the chart.

### v1.1.10

* Some linting of the whitespaces in the generated YAML

### v1.1.9

* Update the README to replace all references of `stable/instana-agent` with specifically setting the repo flag to `https://agents.instana.io/helm`.
* Add support for TKGI and PKS systems, providing a workaround for the [unexpected Docker socket location](https://github.com/cloudfoundry-incubator/kubo-release/issues/329).

### v1.1.7

* Store the cluster name in a new `cluster-name` entry of the `instana-agent` ConfigMap rather than directly as the value of the `INSTANA_KUBERNETES_CLUSTER_NAME`, so that you can edit the cluster name in the ConfigMap in deployments like VMware Tanzu Kubernetes Grid in which, when installing the Instana agent over the [Instana tile](https://www.instana.com/docs/setup_and_manage/host_agent/on/vmware_tanzu), you do not have directly control to the configuration of the cluster name.
If you edit the ConfigMap, you will need to delete the `instana-agent` pods for its new value to take effect.

### v1.1.6

* Allow to use user-specified memony measurement units in `agent.pod.requests.memory` and `agent.pod.limits.memory`.
  If the value set is numerical, the Chart will assume it to be expressed in `Mi` for backwards compatibility.
* Exposed `agent.updateStrategy.type` and `agent.updateStrategy.rollingUpdate.maxUnavailable` settings.

### v1.1.5

Restore compatibility with Helm 2 that was broken in v1.1.4 by the usage of the `lookup` function, a function actually introduced only with Helm 3.1.
Coincidentally, this has been an _excellent_ opportunity to introduce `helm lint` to our validation pipeline and end-to-end tests with Helm 2 ;-)

### v1.1.4

* Bring-your-own secret for agent keys: using the new `agent.keysSecret` setting, you can specify the name of the secret that contains the agent key and, optionally, the download key; refer to [Bring your own Keys secret](#bring-your-own-keys-secret) for more details.
* Add support for affinities for the instana agent pod via the `agent.pod.affinity` setting.
* Put some love into the ArtifactHub.io metadata; likely to add some more improvements related to this over time.

### v1.1.3

* No new features, just ironing some wrinkles out of our release automation.

### v1.1.2

* Improvement: Seamless support for Instana static agent images: When using an `agent.image.name` starting with `containers.instana.io`, automatically create a secret called `containers-instana-io` containing the `.dockerconfigjson` for `containers.instana.io`, using `_` as username and `agent.downloadKey` or, if missing, `agent.key` as password. If you want to control the creation of the image pull secret, or disable it, you can use `agent.image.pullSecrets`, passing to it the YAML to use for the `imagePullSecrets` field of the Daemonset spec, including an empty array `[]` to mount no pull secrets, no matter what.

### v1.1.1

* Fix: Recreate the `instana-agent` pods when there is a change in one of the following configuration, which are mapped to the chart-managed ConfigMap:

* `agent.configuration_yaml`
* `agent.additional_backends`

The pod recreation is achieved by annotating the `instana-agent` Pod with a new `instana-configuration-hash` annotation that has, as value, the SHA-1 hash of the configurations used to populate the ConfigMap.
This way, when the configuration changes, the respective change in the `instana-configuration-hash` annotation will cause the agent pods to be recreated.
This technique has been described at [1] (or, at least, that is were we learned about it) and it is pretty cool :-)

### v1.1.0

* Improvement: The `instana-agent` Helm chart has a new home at `https://agents.instana.io/helm` and `https://github.com/instana/helm-charts/instana-agent`!
This release is functionally equivalent to `1.0.34`, but we bumped the major to denote the new location ;-)

## References

[1] ["Using Kubernetes Helm to push ConfigMap changes to your Deployments", by Sander Knape; Mar 7, 2019](https://sanderknape.com/2019/03/kubernetes-helm-configmaps-changes-deployments/)
