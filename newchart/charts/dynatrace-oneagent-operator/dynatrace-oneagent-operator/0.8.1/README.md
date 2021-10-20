# Welcome

Dynatrace automatically discovers, baselines, and intelligently monitors Kubernetes clusters and workloads. Learn more about Dynatrace at [our website](https://www.dynatrace.com/platform/).

# Dynatrace OneAgent Operator Helm Chart

The Dynatrace OneAgent Operator Helm Chart which supports the rollout and lifecycle of [Dynatrace OneAgent](https://www.dynatrace.com/support/help/get-started/introduction/what-is-oneagent/) in Kubernetes and OpenShift clusters.

This Helm Chart requires Helm 3.

### Platforms
Depending of the version of the Dynatrace OneAgent Operator, it supports the following platforms:

| Dynatrace OneAgent Operator Helm Chart version | Kubernetes | OpenShift Container Platform |
| ---------------------------------------------- | ---------- | ---------------------------- |
| v0.8.0                                         | 1.14+      | 3.11+                        |
| v0.7.1                                         | 1.14+      | 3.11+                        |
| v0.6.0                                         | 1.11+      | 3.11+                        |
| v0.5.4                                         | 1.11+      | 3.11+                        |


## Quick Start

The Dynatrace OneAgent Operator acts on its separate namespace `dynatrace`.
It holds the operator deployment and all dependent objects like permissions, custom resources and
corresponding DaemonSets.
To install the Dynatrace OneAgent Operator via Helm run the following command:

### Adding Dynatrace OneAgent Helm repository
```
$ helm repo add dynatrace https://raw.githubusercontent.com/Dynatrace/helm-charts/master/repos/stable
```

### Prepare tokens

Generate an API and a PaaS token in your Dynatrace environment.

https://www.dynatrace.com/support/help/reference/dynatrace-concepts/why-do-i-need-an-environment-id/#create-user-generated-access-tokens

To install the Dynatrace OneAgent Operator replace the APIUrl, the API token and the PaaS token in command and execute it

#### Kubernetes
```
$ kubectl create namespace dynatrace
$ helm install dynatrace-oneagent-operator dynatrace/dynatrace-oneagent-operator -n dynatrace --set platform="kubernetes",oneagent.apiUrl="https://ENVIRONMENTID.live.dynatrace.com/api",secret.apiToken="DYNATRACE_API_TOKEN",secret.paasToken="PLATFORM_AS_A_SERVICE_TOKEN"
```

#### OpenShift
```
$ oc adm new-project --node-selector="" dynatrace
$ helm install dynatrace-oneagent-operator dynatrace/dynatrace-oneagent-operator -n dynatrace --set platform="openshift",oneagent.apiUrl="https://ENVIRONMENTID.live.dynatrace.com/api",secret.apiToken="DYNATRACE_API_TOKEN",secret.paasToken="PLATFORM_AS_A_SERVICE_TOKEN"
```

This will automatically install the Dynatrace OneAgent Operator and create OneAgents for every of your nodes.

## Update procedure

To update simply update your helm repositories and check the latest version

```
$ helm repo update
```

You can then check for the latest version by searching your Helm repositories for the Dynatrace OneAgent Operator

```
$ helm search repo dynatrace-oneagent-operator
```

To then update to the latest version run this command and do not forget to add the `reuse-values` flag to keep your configuration

```
$ helm upgrade dynatrace-oneagent-operator dynatrace/dynatrace-oneagent-operator -n dynatrace --reuse-values
```

## Uninstall dynatrace-oneagent-operator
Remove OneAgent custom resources and clean-up all remaining OneAgent Operator specific objects:


```sh
$ helm uninstall dynatrace-oneagent-operator -n dynatrace
```

## License

Dynatrace OneAgent Operator Helm Chart is under Apache 2.0 license. See [LICENSE](../LICENSE) for details.
