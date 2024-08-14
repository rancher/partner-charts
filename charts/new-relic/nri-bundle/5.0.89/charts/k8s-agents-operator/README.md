# k8s-agents-operator

![Version: 0.10.0](https://img.shields.io/badge/Version-0.10.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.10.0](https://img.shields.io/badge/AppVersion-0.10.0-informational?style=flat-square)

A Helm chart for the Kubernetes Agents Operator

**Homepage:** <https://github.com/newrelic/k8s-agents-operator/blob/main/charts/k8s-agents-operator/README.md>

## Prerequisites

[Helm](https://helm.sh) must be installed to use the charts.  Please refer to Helm's [documentation](https://helm.sh/docs) to get started.

## Installation

### Requirements

Add the `jetstack` and `k8s-agents-operator` Helm chart repositories:
```shell
helm repo add jetstack https://charts.jetstack.io
helm repo add k8s-agents-operator https://newrelic.github.io/k8s-agents-operator
```

Install the [`cert-manager`](https://github.com/cert-manager/cert-manager) Helm chart:
```shell
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set crds.enabled=true
```

### Instrumentation

Install the [`k8s-agents-operator`](https://github.com/newrelic/k8s-agents-operator) Helm chart:
```shell
helm upgrade --install k8s-agents-operator k8s-agents-operator/k8s-agents-operator \
  --namespace k8s-agents-operator \
  --create-namespace \
  --values your-custom-values.yaml
```

### Monitored namespaces

For each namespace you want the operator to be instrumented, create a secret containing a valid New Relic ingest license key:
```shell
kubectl create secret generic newrelic-key-secret \
  --namespace my-monitored-namespace \
  --from-literal=new_relic_license_key=<NEW RELIC INGEST LICENSE KEY>
```

Similarly, for each namespace you need to instrument create the `Instrumentation` custom resource, specifying which APM agents you want to instrument. All available APM agent docker images and corresponding tags are listed on DockerHub:
* [Java](https://hub.docker.com/repository/docker/newrelic/newrelic-java-init/general)
* [Node](https://hub.docker.com/repository/docker/newrelic/newrelic-node-init/general)
* [Python](https://hub.docker.com/repository/docker/newrelic/newrelic-python-init/general)
* [.NET](https://hub.docker.com/repository/docker/newrelic/newrelic-dotnet-init/general)
* [Ruby](https://hub.docker.com/repository/docker/newrelic/newrelic-ruby-init/general)

```yaml
apiVersion: newrelic.com/v1alpha1
kind: Instrumentation
metadata:
  labels:
    app.kubernetes.io/name: instrumentation
    app.kubernetes.io/created-by: k8s-agents-operator
  name: newrelic-instrumentation
spec:
  java:
    image: newrelic/newrelic-java-init:latest
    # env:
    # Example New Relic agent supported environment variables
    # - name: NEW_RELIC_LABELS
    #   value: "environment:auto-injection"
    # Example overriding the appName configuration
    # - name: NEW_RELIC_POD_NAME
    #   valueFrom:
    #     fieldRef:
    #       fieldPath: metadata.name
    # - name: NEW_RELIC_APP_NAME
    #   value: "$(NEW_RELIC_LABELS)-$(NEW_RELIC_POD_NAME)"
  nodejs:
    image: newrelic/newrelic-node-init:latest
  python:
    image: newrelic/newrelic-python-init:latest
  dotnet:
    image: newrelic/newrelic-dotnet-init:latest
  ruby:
    image: newrelic/newrelic-ruby-init:latest
```
In the example above, we show how you can configure the agent settings globally using environment variables. See each agent's configuration documentation for available configuration options:
* [Java](https://docs.newrelic.com/docs/apm/agents/java-agent/configuration/java-agent-configuration-config-file/)
* [Node](https://docs.newrelic.com/docs/apm/agents/nodejs-agent/installation-configuration/nodejs-agent-configuration/)
* [Python](https://docs.newrelic.com/docs/apm/agents/python-agent/configuration/python-agent-configuration/)
* [.NET](https://docs.newrelic.com/docs/apm/agents/net-agent/configuration/net-agent-configuration/)
* [Ruby](https://docs.newrelic.com/docs/apm/agents/ruby-agent/configuration/ruby-agent-configuration/)

Global agent settings can be overridden in your deployment manifest if a different configuration is required.

### Annotations

The `k8s-agents-operator` looks for language-specific annotations when your pods are being scheduled to know which applications you want to monitor.

Below are the currently supported annotations:
```yaml
instrumentation.newrelic.com/inject-java: "true"
instrumentation.newrelic.com/inject-nodejs: "true"
instrumentation.newrelic.com/inject-python: "true"
instrumentation.newrelic.com/inject-dotnet: "true"
instrumentation.newrelic.com/inject-ruby: "true"
```

Example deployment with annotation to instrument the Java agent:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: spring-petclinic
spec:
  selector:
    matchLabels:
      app: spring-petclinic
  replicas: 1
  template:
    metadata:
      labels:
        app: spring-petclinic
      annotations:
        instrumentation.newrelic.com/inject-java: "true"
    spec:
      containers:
        - name: spring-petclinic
          image: ghcr.io/pavolloffay/spring-petclinic:latest
          ports:
            - containerPort: 8080
          env:
          - name: NEW_RELIC_APP_NAME
            value: spring-petclinic-demo
```

## Available Chart Releases

To see the available charts:
```shell
helm search repo k8s-agents-operator
```

If you want to see a list of all available charts and releases, check [index.yaml](https://newrelic.github.io/k8s-agents-operator/index.yaml).

## Source Code

* <https://github.com/newrelic/k8s-agents-operator>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| admissionWebhooks | object | `{"create":true}` | Admission webhooks make sure only requests with correctly formatted rules will get into the Operator |
| controllerManager.kubeRbacProxy.image.repository | string | `"gcr.io/kubebuilder/kube-rbac-proxy"` |  |
| controllerManager.kubeRbacProxy.image.tag | string | `"v0.14.0"` |  |
| controllerManager.kubeRbacProxy.resources.limits.cpu | string | `"500m"` |  |
| controllerManager.kubeRbacProxy.resources.limits.memory | string | `"128Mi"` |  |
| controllerManager.kubeRbacProxy.resources.requests.cpu | string | `"5m"` |  |
| controllerManager.kubeRbacProxy.resources.requests.memory | string | `"64Mi"` |  |
| controllerManager.manager.image.pullPolicy | string | `nil` |  |
| controllerManager.manager.image.repository | string | `"newrelic/k8s-agents-operator"` |  |
| controllerManager.manager.image.tag | string | `nil` |  |
| controllerManager.manager.leaderElection | object | `{"enabled":true}` | Enable leader election mechanism for protecting against split brain if multiple operator pods/replicas are started |
| controllerManager.manager.resources.requests.cpu | string | `"100m"` |  |
| controllerManager.manager.resources.requests.memory | string | `"64Mi"` |  |
| controllerManager.manager.serviceAccount.create | bool | `true` |  |
| controllerManager.replicas | int | `1` |  |
| kubernetesClusterDomain | string | `"cluster.local"` |  |
| metricsService.ports[0].name | string | `"https"` |  |
| metricsService.ports[0].port | int | `8443` |  |
| metricsService.ports[0].protocol | string | `"TCP"` |  |
| metricsService.ports[0].targetPort | string | `"https"` |  |
| metricsService.type | string | `"ClusterIP"` |  |
| securityContext | object | `{"fsGroup":65532,"runAsGroup":65532,"runAsNonRoot":true,"runAsUser":65532}` | SecurityContext holds pod-level security attributes and common container settings |
| webhookService.ports[0].port | int | `443` |  |
| webhookService.ports[0].protocol | string | `"TCP"` |  |
| webhookService.ports[0].targetPort | int | `9443` |  |
| webhookService.type | string | `"ClusterIP"` |  |

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| juanjjaramillo |  | <https://github.com/juanjjaramillo> |
| csongnr |  | <https://github.com/csongnr> |
| dbudziwojskiNR |  | <https://github.com/dbudziwojskiNR> |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.13.1](https://github.com/norwoodj/helm-docs/releases/v1.13.1)
