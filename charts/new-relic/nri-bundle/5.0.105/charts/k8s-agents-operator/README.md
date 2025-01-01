# k8s-agents-operator

![Version: 0.19.0](https://img.shields.io/badge/Version-0.19.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.19.0](https://img.shields.io/badge/AppVersion-0.19.0-informational?style=flat-square)

A Helm chart for the Kubernetes Agents Operator

**Homepage:** <https://github.com/newrelic/k8s-agents-operator/blob/main/charts/k8s-agents-operator/README.md>

## Prerequisites

[Helm](https://helm.sh) must be installed to use the charts.  Please refer to Helm's [documentation](https://helm.sh/docs) to get started.

## Installation

### Requirements

Add the `k8s-agents-operator` Helm chart repository:
```shell
helm repo add k8s-agents-operator https://newrelic.github.io/k8s-agents-operator
```

### Instrumentation

Install the [`k8s-agents-operator`](https://github.com/newrelic/k8s-agents-operator) Helm chart:
```shell
helm upgrade --install k8s-agents-operator k8s-agents-operator/k8s-agents-operator \
  --namespace newrelic \
  --create-namespace \
  --values your-custom-values.yaml
```

### Monitored namespaces

For each namespace you want the operator to be instrumented, a secret will be replicated from the newrelic operator namespace.

For each `Instrumentation` custom resource created, specifying which APM agent you want to instrument for each language. All available APM
 agent docker images and corresponding tags are listed on DockerHub:

* [.NET](https://hub.docker.com/repository/docker/newrelic/newrelic-dotnet-init/general)
* [Java](https://hub.docker.com/repository/docker/newrelic/newrelic-java-init/general)
* [Node](https://hub.docker.com/repository/docker/newrelic/newrelic-node-init/general)
* [Python](https://hub.docker.com/repository/docker/newrelic/newrelic-python-init/general)
* [Ruby](https://hub.docker.com/repository/docker/newrelic/newrelic-ruby-init/general)

For .NET

```yaml
apiVersion: newrelic.com/v1alpha2
kind: Instrumentation
metadata:
  name: newrelic-instrumentation-dotnet
spec:
  agent:
    language: dotnet
    image: newrelic/newrelic-dotnet-init:latest # Please ensure you're using a trusted New Relic image
    # env: ...
```

For Java

```yaml
apiVersion: newrelic.com/v1alpha2
kind: Instrumentation
metadata:
  name: newrelic-instrumentation-java
  namespace: newrelic
spec:
  agent:
    language: java
    image: newrelic/newrelic-java-init:latest # Please ensure you're using a trusted New Relic image
    # env: ...
```

For NodeJS

```yaml
apiVersion: newrelic.com/v1alpha2
kind: Instrumentation
metadata:
  name: newrelic-instrumentation-nodejs
  namespace: newrelic
spec:
  agent:
    language: nodejs
    image: newrelic/newrelic-node-init:latest # Please ensure you're using a trusted New Relic image
    # env: ...
```

For Python

```yaml
apiVersion: newrelic.com/v1alpha2
kind: Instrumentation
metadata:
  name: newrelic-instrumentation-python
  namespace: newrelic
spec:
  agent:
    language: python
    image: newrelic/newrelic-python-init:latest # Please ensure you're using a trusted New Relic image
    # env: ...
```

For Ruby

```yaml
apiVersion: newrelic.com/v1alpha2
kind: Instrumentation
metadata:
  name: newrelic-instrumentation-ruby
  namespace: newrelic
spec:
  agent:
    language: ruby
    image: newrelic/newrelic-ruby-init:latest # Please ensure you're using a trusted New Relic image
    # env: ...
```

For environment specific configurations

```yaml
apiVersion: newrelic.com/v1alpha2
kind: Instrumentation
metadata:
  name: newrelic-instrumentation-lang
  namespace: newrelic
spec:
  agent:
    env:
    # Example New Relic agent supported environment variables
      - name: NEW_RELIC_LABELS
        value: "environment:auto-injection"
    # Example setting the pod name based on the metadata
      - name: NEW_RELIC_POD_NAME
        valueFrom:
          fieldRef:
            fieldPath: metadata.name
    # Example overriding the appName configuration
      - name: NEW_RELIC_APP_NAME
        value: "$(NEW_RELIC_LABELS)-$(NEW_RELIC_POD_NAME)"
```

Targeting everything in a specific namespace with a label

```yaml
apiVersion: newrelic.com/v1alpha2
kind: Instrumentation
metadata:
  name: newrelic-instrumentation-lang
  namespace: newrelic
spec:
  #agent: ...
  namespaceLabelSelector:
    matchExpressions:
      - key: "app.newrelic.instrumentation"
        operator: "In"
        values: ["java"]
```

Targeting a pod with a specific label

```yaml
apiVersion: newrelic.com/v1alpha2
kind: Instrumentation
metadata:
  name: newrelic-instrumentation-lang
  namespace: newrelic
spec:
  # agent: ...
  podLabelSelector:
    matchExpressions:
      - key: "app.newrelic.instrumentation"
        operator: "In"
        values: ["dotnet"]
```

Using a secret with a non-default name

```yaml
apiVersion: newrelic.com/v1alpha2
kind: Instrumentation
metadata:
  name: newrelic-instrumentation-lang
  namespace: newrelic
spec:
  # agent: ...
  licenseKeySecret: the-name-of-the-custom-secret
```

In the example above, we show how you can configure the agent settings globally using environment variables. See each agent's configuration documentation for available configuration options:
* [Java](https://docs.newrelic.com/docs/apm/agents/java-agent/configuration/java-agent-configuration-config-file/)
* [Node](https://docs.newrelic.com/docs/apm/agents/nodejs-agent/installation-configuration/nodejs-agent-configuration/)
* [Python](https://docs.newrelic.com/docs/apm/agents/python-agent/configuration/python-agent-configuration/)
* [.NET](https://docs.newrelic.com/docs/apm/agents/net-agent/configuration/net-agent-configuration/)
* [Ruby](https://docs.newrelic.com/docs/apm/agents/ruby-agent/configuration/ruby-agent-configuration/)

### cert-manager

The K8s Agents Operator supports the use of [`cert-manager`](https://github.com/cert-manager/cert-manager) if preferred.

Install the [`cert-manager`](https://github.com/cert-manager/cert-manager) Helm chart:
```shell
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set crds.enabled=true
```

In your `values.yaml` file, set `admissionWebhooks.autoGenerateCert.enabled: false` and `admissionWebhooks.certManager.enabled: true`. Then install the chart as normal.

## Security

This operator requires a privileged environment to run correctly. As with all components that run in a privileged environment, please exercise caution when granting access to the namespace (and other resources) that the K8s Agent Operator is deployed on.

## Available Chart Releases

To see the available charts:
```shell
helm search repo k8s-agents-operator
```

If you want to see a list of all available charts and releases, check [index.yaml](https://newrelic.github.io/k8s-agents-operator/index.yaml).

## Source Code

* <https://github.com/newrelic/k8s-agents-operator>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://helm-charts.newrelic.com | common-library | 1.3.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| admissionWebhooks | object | `{"autoGenerateCert":{"certPeriodDays":365,"enabled":true,"recreate":true},"caFile":"","certFile":"","certManager":{"enabled":false},"create":true,"keyFile":""}` | Admission webhooks make sure only requests with correctly formatted rules will get into the Operator |
| admissionWebhooks.autoGenerateCert.certPeriodDays | int | `365` | Cert validity period time in days. |
| admissionWebhooks.autoGenerateCert.enabled | bool | `true` | If true and certManager.enabled is false, Helm will automatically create a self-signed cert and secret for you. |
| admissionWebhooks.autoGenerateCert.recreate | bool | `true` | If set to true, new webhook key/certificate is generated on helm upgrade. |
| admissionWebhooks.caFile | string | `""` | Path to the CA cert. |
| admissionWebhooks.certFile | string | `""` | Path to your own PEM-encoded certificate. |
| admissionWebhooks.certManager.enabled | bool | `false` | If true and autoGenerateCert.enabled is false, cert-manager will create a self-signed cert and secret for you. |
| admissionWebhooks.keyFile | string | `""` | Path to your own PEM-encoded private key. |
| affinity | object | `{}` | Sets all pods' affinities. Can be configured also with `global.affinity` |
| containerSecurityContext | object | `{}` | Sets all security context (at container level). Can be configured also with `global.securityContext.container` |
| controllerManager.kubeRbacProxy.containerSecurityContext | object | `{}` | Sets security context (at container level) for kubeRbacProxy. Overrides `containerSecurityContext` and `global.containerSecurityContext` |
| controllerManager.kubeRbacProxy.image.repository | string | `"gcr.io/kubebuilder/kube-rbac-proxy"` | Sets the repository and image to use for kube-rbac-proxy. Please ensure you're using a trusted image. |
| controllerManager.kubeRbacProxy.image.version | string | `"sha256:771a9a173e033a3ad8b46f5c00a7036eaa88c8d8d1fbd89217325168998113ea"` | Sets the kube-rbac-proxy image version to retrieve. Could be a tag i.e. "v0.16.0" or a SHA digest i.e. "sha256:771a9a173e033a3ad8b46f5c00a7036eaa88c8d8d1fbd89217325168998113ea" |
| controllerManager.kubeRbacProxy.resources.limits.cpu | string | `"500m"` |  |
| controllerManager.kubeRbacProxy.resources.limits.memory | string | `"128Mi"` |  |
| controllerManager.kubeRbacProxy.resources.requests.cpu | string | `"5m"` |  |
| controllerManager.kubeRbacProxy.resources.requests.memory | string | `"64Mi"` |  |
| controllerManager.manager.containerSecurityContext | object | `{}` | Sets security context (at container level) for the manager. Overrides `containerSecurityContext` and `global.containerSecurityContext` |
| controllerManager.manager.image.pullPolicy | string | `nil` |  |
| controllerManager.manager.image.repository | string | `"newrelic/k8s-agents-operator"` | Sets the repository and image to use for the manager. Please ensure you're using trusted New Relic images. |
| controllerManager.manager.image.version | string | `nil` | Sets the manager image version to retrieve. Could be a tag i.e. "v0.17.0" or a SHA digest i.e. "sha256:e2399e70e99ac370ca6a3c7e5affa9655da3b246d0ada77c40ed155b3726ee2e" |
| controllerManager.manager.leaderElection | object | `{"enabled":true}` | Enable leader election mechanism for protecting against split brain if multiple operator pods/replicas are started |
| controllerManager.manager.resources.requests.cpu | string | `"100m"` |  |
| controllerManager.manager.resources.requests.memory | string | `"64Mi"` |  |
| controllerManager.replicas | int | `1` |  |
| dnsConfig | object | `{}` | Sets pod's dnsConfig. Can be configured also with `global.dnsConfig` |
| kubernetesClusterDomain | string | `"cluster.local"` |  |
| labels | object | `{}` | Additional labels for chart objects |
| licenseKey | string | `""` | This set this license key to use. Can be configured also with `global.licenseKey` |
| metricsService.ports[0].name | string | `"https"` |  |
| metricsService.ports[0].port | int | `8443` |  |
| metricsService.ports[0].protocol | string | `"TCP"` |  |
| metricsService.ports[0].targetPort | string | `"https"` |  |
| metricsService.type | string | `"ClusterIP"` |  |
| nodeSelector | object | `{}` | Sets all pods' node selector. Can be configured also with `global.nodeSelector` |
| podAnnotations | object | `{}` | Annotations to be added to the deployment. |
| podLabels | object | `{}` | Additional labels for chart pods |
| podSecurityContext | object | `{"fsGroup":65532,"runAsGroup":65532,"runAsNonRoot":true,"runAsUser":65532}` | SecurityContext holds pod-level security attributes and common container settings |
| priorityClassName | string | `""` | Sets pod's priorityClassName. Can be configured also with `global.priorityClassName` |
| serviceAccount | object | See `values.yaml` | Settings controlling ServiceAccount creation |
| serviceAccount.create | bool | `true` | Specifies whether a ServiceAccount should be created |
| tolerations | list | `[]` | Sets all pods' tolerations to node taints. Can be configured also with `global.tolerations` |
| webhookService.ports[0].port | int | `443` |  |
| webhookService.ports[0].protocol | string | `"TCP"` |  |
| webhookService.ports[0].targetPort | int | `9443` |  |
| webhookService.type | string | `"ClusterIP"` |  |

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| csongnr |  | <https://github.com/csongnr> |
| dbudziwojskiNR |  | <https://github.com/dbudziwojskiNR> |
| danielstokes |  | <https://github.com/danielstokes> |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
