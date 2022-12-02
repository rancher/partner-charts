# Komodor

Komodor is a Kubernetes reliability platform, complete with automated troubleshooting playbooks for every K8s resource, and static-prevention monitors that enrich live & historical data with contextual insights to help enforce best practices and stop incidents in their tracks.

For each K8s resource, Komodor automatically constructs a coherent view, including the relevant deploys, config changes, dependencies, metrics, and past incidents. Komodor seamlessly integrates and utilizes data from cloud providers, source controls, CI/CD pipelines, monitoring tools, and incident response platforms.

- Discover the root cause automatically with a timeline that tracks all changes made in your application and infrastructure.
- Quickly tackle the issue, with easy-to-follow remediation instructions.
- Give your entire team a way to troubleshoot independently, without having to escalate.

## Prerequisites

- Kubernetes 1.16+
- Helm 2/3

## Komodor Installation

1. Sign up to [Komodor](https://auth.komodor.com/u/signup/identifier?state=hKFo2SB0WVMtMUJtcndaU0JKSEQ1XzNBd1JGbGJBeTcwdld0d6Fur3VuaXZlcnNhbC1sb2dpbqN0aWTZIFNDUktFX0xRRmZ3c3VWRENmaDNBclBzYmtJNHZsRWJpo2NpZNkgbGJvcFI3NHpIZDcyWU9INEFjdmpWbkt0TTZCcld6WjQ) and verify your email address.
2. Go to [app.komodor.com](https://app.komodor.com) and click on ‘Add a Kubernetes Cluster’ to Install the k8s-watcher Agent on any of your clusters
3. Enter your cluster’s name like so:\
   ![cluster-name](https://assets-komodor-public.s3.amazonaws.com/k8s_install_step_1.png)
4. After entering the cluster name you will receive a command similar to this:\
   ![helm-command](https://assets-komodor-public.s3.amazonaws.com/k8s_install_step_2.png)
5. Copy the API key from the command output you’ve received, and paste it in the appropriate field when prompted to by the Rancher installer

The following table lists the configurable parameters of the chart and their default values.

| Parameter                                          | Description                                                                                                                                                                   | Default                                    |
| -------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------ |
| `apiKey`                                           | Komodor kubernetes api key (required if `existingSecret` not specified)                                                                                                       | ``                                         |
| `existingSecret`                                   | Existing kubernetes secret resource containing Komodor kubernetes apiKey (required if `apiKey` not specified)                                                                 | ``                                         |
| `watcher.redact`                                   | List of regular expressions. Config values for keys that matches one of these expressions will show up at Komodor as "REDACTED:\<SHA of config value\>"                       | `[]`                                       |
| `watcher.clusterName`                              | Override auto-discovery of Cluster Name with one of your choosing                                                                                                             | ``                                         |
| `watcher.watchNamespace`                           | Watch a specific namespace, or all namespaces ("", "all")                                                                                                                     | `all`                                      |
| `watcher.namespacesDenylist`                       | Exclude specific namespaces (list)                                                                                                                                            | `[]`                                       |
| `watcher.nameDenylist`                             | Exclude specific resource names that contains any of these strings (list) - example: `` watcher.nameDenylist=["dont-watch"] --> `pod/backend-dont-watch` wont be collected `` | `[]`                                       |
| `watcher.collectHistory`                           | On startup collect existing cluster resources in addition to watching new resources (true / false)                                                                            | `true`                                     |
| `watcher.sinks.webhook.enabled`                    | Enables a Webhook output                                                                                                                                                      | `true`                                     |
| `watcher.sinks.webhook.url`                        | URL to send webhooks to                                                                                                                                                       | `https://app.komodor.io/k8s-events/event/` |
| `watcher.sinks.webhook.headers`                    | Headers to attach to the webhooks                                                                                                                                             | `{}`                                       |
| `watcher.resources.event`                          | Enables watching Event                                                                                                                                                        | `true`                                     |
| `watcher.resources.deployment`                     | Enables watching Deployments                                                                                                                                                  | `true`                                     |
| `watcher.resources.replicationController`          | Enables watching ReplicationControllers                                                                                                                                       | `true`                                     |
| `watcher.resources.replicaSet`                     | Enables watching ReplicaSets                                                                                                                                                  | `true`                                     |
| `watcher.resources.daemonSet`                      | Enables watching DaemonSets                                                                                                                                                   | `true`                                     |
| `watcher.resources.statefulSet`                    | Enables watching StatefulSets                                                                                                                                                 | `true`                                     |
| `watcher.resources.service`                        | Enables watching Services                                                                                                                                                     | `true`                                     |
| `watcher.resources.pod`                            | Enables watching Pods                                                                                                                                                         | `true`                                     |
| `watcher.resources.job`                            | Enables watching Jobs                                                                                                                                                         | `true`                                     |
| `watcher.resources.node`                           | Enables watching Nodes                                                                                                                                                        | `true`                                     |
| `watcher.resources.clusterRole`                    | Enables watching ClusterRoles                                                                                                                                                 | `true`                                     |
| `watcher.resources.serviceAccount`                 | Enables watching ServiceAccounts                                                                                                                                              | `true`                                     |
| `watcher.resources.persistentVolume`               | Enables watching PersistentVolumes                                                                                                                                            | `true`                                     |
| `watcher.resources.persistentVolumeClaim`          | Enables watching PersistentVolumeClaims                                                                                                                                       | `true`                                     |
| `watcher.resources.namespace`                      | Enables watching Namespaces                                                                                                                                                   | `true`                                     |
| `watcher.resources.secret`                         | Enables watching Secrets                                                                                                                                                      | `false`                                    |
| `watcher.resources.configMap`                      | Enables watching ConfigMaps                                                                                                                                                   | `true`                                     |
| `watcher.resources.ingress`                        | Enables watching Ingresses                                                                                                                                                    | `true`                                     |
| `watcher.resources.storageClass`                   | Enables watching StorageClasses                                                                                                                                               | `true`                                     |
| `watcher.resources.rollout`                        | Enables watching Argo Rollouts                                                                                                                                                | `true`                                     |
| `watcher.resources.metrics`                        | Enables watching Metrics                                                                                                                                                      | `true`                                     |
| `watcher.resources.limitRange`                     | Enables watching LimitRange                                                                                                                                                   | `true`                                     |
| `watcher.resources.podTemplate`                    | Enables watching PodTemplate                                                                                                                                                  | `true`                                     |
| `watcher.resources.resourceQuota`                  | Enables watching ResourceQuota                                                                                                                                                | `true`                                     |
| `watcher.resources.admissionRegistrationResources` | Enables watching MutatingWebhookConfigurations and ValidatingWebhookConfigurations                                                                                            | `true`                                     |
| `watcher.resources.controllerRevision`             | Enables watching ControllerRevision                                                                                                                                           | `true`                                     |
| `watcher.resources.authorizationResources`         | Enables watching Authorization Resources                                                                                                                                      | `true`                                     |
| `watcher.resources.horizontalPodAutoscaler`        | Enables watching HorizontalPodAutoscaler                                                                                                                                      | `true`                                     |
| `watcher.resources.certificateSigningRequest`      | Enables watching CertificateSigningRequest                                                                                                                                    | `true`                                     |
| `watcher.resources.lease`                          | Enables watching Lease                                                                                                                                                        | `true`                                     |
| `watcher.resources.endpointSlice`                  | Enables watching EndpointSlice                                                                                                                                                | `true`                                     |
| `watcher.resources.flowControlResources`           | Enables watching FlowControl Resources                                                                                                                                        | `true`                                     |
| `watcher.resources.ingressClass`                   | Enables watching IngressClass                                                                                                                                                 | `true`                                     |
| `watcher.resources.networkPolicy`                  | Enables watching NetworkPolicy                                                                                                                                                | `true`                                     |
| `watcher.resources.runtimeClass`                   | Enables watching RuntimeClass                                                                                                                                                 | `true`                                     |
| `watcher.resources.policyResources`                | Enables watching Policy Resources                                                                                                                                             | `true`                                     |
| `watcher.resources.clusterRoleBinding`             | Enables watching ClusterRoleBinding                                                                                                                                           | `true`                                     |
| `watcher.resources.roleBinding`                    | Enables watching RoleBinding                                                                                                                                                  | `true`                                     |
| `watcher.resources.role`                           | Enables watching Role                                                                                                                                                         | `true`                                     |
| `watcher.resources.PriorityClass`                  | Enables watching PriorityClass                                                                                                                                                | `true`                                     |
| `watcher.resources.csiDriver`                      | Enables watching CSIDriver                                                                                                                                                    | `true`                                     |
| `watcher.resources.csiNode`                        | Enables watching CSINode                                                                                                                                                      | `true`                                     |
| `watcher.resources.csiStorageCapacity `            | Enables watching CSIStorageCapacity                                                                                                                                           | `true`                                     |
| `watcher.resources.volumeAttachment`               | Enables watching VolumeAttachment                                                                                                                                             | `true`                                     |
| `watcher.servers.healthCheck.port`                 | Port of the health check                                                                                                                                                      |
| server                                             | `8090`                                                                                                                                                                        |
| `resources.requests.cpu`                           | CPU resource requests                                                                                                                                                         | `0.25`                                     |
| `resources.limits.cpu`                             | CPU resource limits                                                                                                                                                           | `1`                                        |
| `resources.requests.memory`                        | Memory resource requests                                                                                                                                                      | `256Mi`                                    |
| `resources.limits.memory`                          | Memory resource limits                                                                                                                                                        | `4096Mi`                                   |
| `image.repository`                                 | Image registry/name                                                                                                                                                           | `docker.io/komodorio/k8s-watcher`          |
| `image.tag`                                        | Image tag                                                                                                                                                                     | `0.1.10`                                   |
| `image.pullPolicy`                                 | Image pull policy                                                                                                                                                             | `IfNotPresent`                             |
| `serviceAccount.create`                            | Creates a service account                                                                                                                                                     | `true`                                     |
| `serviceAccount.name`                              | Optional name for the service account                                                                                                                                         | `{RELEASE_FULLNAME}`                       |
| `proxy.enabled`                                    | Configure proxy for watcher                                                                                                                                                   | `true`                                     |
| `proxy.http`                                       | Configure Proxy setting (HTTP_PROXY)                                                                                                                                          | ``                                         |
| `proxy.https`                                      | Configure Proxy setting (HTTPS_PROXY)                                                                                                                                         | ``                                         |
| `proxy.no_proxy`                                   | Configure Proxy setting (NO_PROXY)                                                                                                                                            | ``                                         |
| `watcher.controller.resync.period`                 | Resync period (in minutes, minimum 5) to resync the state of selected controllers (deployment, daemonset, statefulset)                                                        | `"0"`                                      |
| `watcher.enableAgentTaskExecution`                 | Enable to the agent to execute tasks in the cluster such as log streaming                                                                                                     | `true`                                     |
| `watcher.allowReadingPodLogs`.                     | Enable the agent to read pod logs from the cluster                                                                                                                            | `true`                                     |
| `createNamespace`                                  | Creates the namespace                                                                                                                                                         | `true`                                     |
| `podAnnotations`                                   | Adds custom annotations on the agent pod - Example: `--set podAnnotations."app\.komodor\.com/app"="komodor-agent"`                                                            | `{}`                                       |
| `deploymentAnnotations`                            | Adds custom annotations on the agent deployment - Example: `--set deploymentAnnotations."app\.komodor\.com/app"="komodor-agent"`                                              | `{}`                                       |

The above parameters map to a yaml configuration file used by the watcher.
Specify each parameter using the --set key=value[,key=value] argument to helm install.\
For example:
helm upgrade --install k8s-watcher komodorio/k8s-watcher --set apiKey="YOUR*API_KEY_HERE" --set watcher.enableAgentTaskExecution=true --set watcher.allowReadingPodLogs=true
Alternativly, you can pass the configuration as environment variables using the KOMOKW* prefix and by replacing all the ׳.׳ to ׳\_׳. For the root items the camelcase transforms into underscores as well.\
For example:
\# apiKey
KOMOKW_API_KEY=1a2b3c4d5e6f7g7h
\# watcher.resources.replicaSet
KOMOKW_RESOURCES_REPLICASET=false
\# watcher.watchNamespace
KOMOKW_WATCH_NAMESPACE=my-namespace
\# watcher.collectHistory
KOMOKW_COLLECT_HISTORY=true

Tip: You can use the default values.yaml

## Updating the Agent using Helm

helm repo update
helm upgrade --install k8s-watcher komodorio/k8s-watcher --reuse-values

## Uninstalling Komodor

helm uninstall k8s-watcher

## External Links

- [Documentation](https://docs.komodor.com/)
- [Sandbox](https://app.komodor.com/sandbox)
