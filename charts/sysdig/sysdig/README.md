# Chart: Sysdig

---
**WARNING**

This chart is being deprecated. Please use the [supported chart](https://github.com/sysdiglabs/charts/tree/master/charts/sysdig-deploy) for production deployments.

---


[Sysdig](https://sysdig.com/) is a unified platform for container and microservices monitoring, troubleshooting,
security and forensics. Sysdig platform has been built on top of [Sysdig tool](https://sysdig.com/opensource/sysdig/)
and [Sysdig Inspect](https://sysdig.com/blog/sysdig-inspect/) open-source technologies.


## Table of Contents
- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Installing the Chart](#installing-the-chart)
- [Uninstalling the Chart](#uninstalling-the-chart)
- [Configuration](#configuration)
- [Resource profiles](#resource-profiles)
- [Node Analyzer](#node-analyzer)
- [GKE Autopilot](#gke-autopilot)
- [On-Premise backend deployment settings](#on-premise-backend-deployment-settings)
- [Using private Docker image registry](#using-private-docker-image-registry)
- [Modifying Sysdig agent configuration](#modifying-sysdig-agent-configuration)
- [Upgrading Sysdig agent configuration](#upgrading-sysdig-agent-configuration)
- [How to upgrade to the latest version](#how-to-upgrade-to-the-last-version)
- [Adding custom AppChecks](#adding-custom-appchecks)
- [Support](#support)

## Introduction

This chart adds the Sysdig agent for [Sysdig Monitor](https://sysdig.com/product/monitor/)
and [Sysdig Secure](https://sysdig.com/product/secure/) to all nodes in your cluster via a DaemonSet.

## Prerequisites

- Kubernetes 1.9+ with Beta APIs enabled

## Installing the Chart

First of all you need to add the Sysdig Helm Charts repository:

```bash
$ helm repo add sysdig https://charts.sysdig.com/
```

To install the chart with the release name `sysdig-agent`, run:

```bash
$ helm install --namespace sysdig-agent sysdig-agent --set sysdig.accessKey=YOUR-KEY-HERE --set sysdig.settings.collector=COLLECTOR_URL sysdig/sysdig --set nodeAnalyzer.apiEndpoint=API_ENDPOINT
```

To find the values:

- YOUR-KEY-HERE: This is the agent access key. You can retrieve this from Settings > Agent Installation in the Sysdig
  UI.
- COLLECTOR_URL: This value is region-dependent in SaaS and is auto-completed in install snippets in the UI. (It is
  a custom value in on-prem installations.)
- API_ENDPOINT: This is the base URL (region-dependent) for Sysdig Secure and is auto-completed in install snippets in the UI.
  E.g. secure.sysdig.com, us2.app.sysdig.com, eu1.app.sysdig.com.

After a few seconds, you should see hosts and containers appearing in Sysdig Monitor and Sysdig Secure.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `sysdig-agent` deployment:

```bash
$ helm delete --namespace sysdig-agent sysdig-agent
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the Sysdig chart and their default values.

| Parameter                                                            | Description                                                                              | Default                                                                        |
|----------------------------------------------------------------------|------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------|
| `image.registry`                                                     | Sysdig Agent image registry                                                              | `quay.io`                                                                      |
| `image.repository`                                                   | The image repository to pull from                                                        | `sysdig/agent`                                                                 |
| `image.tag`                                                          | The image tag to pull                                                                    | `12.14.1`                                                                      |
| `image.digest`                                                       | The image digest to pull                                                                 | ` `                                                                            |
| `image.pullPolicy`                                                   | The Image pull policy                                                                    | `IfNotPresent`                                                                 |
| `image.pullSecrets`                                                  | Image pull secrets                                                                       | `nil`                                                                          |
| `resourceProfile`                                                    | Sysdig Agent resource profile (see [Resource profiles](#resource-profiles))              | `small`                                                                        |
| `resources.requests.cpu`                                             | CPU requested for being run in a node                                                    | ` `                                                                            |
| `resources.requests.memory`                                          | Memory requested for being run in a node                                                 | ` `                                                                            |
| `resources.limits.cpu`                                               | CPU limit                                                                                | ` `                                                                            |
| `resources.limits.memory`                                            | Memory limit                                                                             | ` `                                                                            |
| `gke.autopilot`                                                      | If true, overrides the agent configuration to run on GKE Autopilot clusters              | `false`                                                                        |
| `rbac.create`                                                        | If true, create & use RBAC resources                                                     | `true`                                                                         |
| `scc.create`                                                         | Create OpenShift's Security Context Constraint                                           | `true`                                                                         |
| `psp.create`                                                         | Create Pod Security Policy to allow the agent running in clusters with PSP enabled       | `true`                                                                         |
| `serviceAccount.create`                                              | Create serviceAccount                                                                    | `true`                                                                         |
| `serviceAccount.name`                                                | Use this value as serviceAccountName                                                     | ` `                                                                            |
| `priorityClassName`                                                  | Set the priority class for the agent daemonset                                           | `""`                                                                           |
| `daemonset.deploy`                                                   | Deploy the agent daemonset                                                               | `true`                                                                         |
| `daemonset.env`                                                      | Environment variables for the agent container. Provide as map of `VAR: val`              | `{}`                                                                           |
| `daemonset.updateStrategy.type`                                      | The updateStrategy for updating the daemonset                                            | `RollingUpdate`                                                                |
| `daemonset.updateStrategy.type.maxUnavailable`                       | The maximum number of pods that can be unavailable during the update process             |                                                                                |
| `daemonset.nodeSelector`                                             | Node Selector                                                                            | `{}`                                                                           |
| `daemonset.arch`                                                     | Allowed architectures for scheduling                                                     | `[ amd64, arm64, s390x ]`                                                      |
| `daemonset.os`                                                       | Allowed OSes for scheduling                                                              | `[ linux ]`                                                                    |
| `daemonset.affinity`                                                 | Node affinities. Overrides `daemonset.arch` and `daemonset.os` values                    | `{}`                                                                           |
| `daemonset.annotations`                                              | Custom annotations for daemonset                                                         | `{}`                                                                           |
| `daemonset.labels`                                                   | Custom labels for daemonset (as a multi-line templated string map or as YAML)            |                                                                                |
| `daemonset.probes.initialDelay`                                      | Initial delay for liveness and readiness probes. daemonset                               | `{}`                                                                           |
| `daemonset.kmodule.env`     | Environment variables for the kernel module image builder. Provide as map of `VAR: val`  | `{}`                                                                           |
| `slim.enabled`                                                       | Use the slim based Sysdig Agent image                                                    | `true`                                                                         |
| `slim.image.repository`                                              | The slim Agent image repository                                                          | `sysdig/agent-slim`                                                            |
| `slim.kmoduleImage.repository`                                       | The kernel module image builder repository to pull from                                  | `sysdig/agent-kmodule`                                                         |
| `slim.kmoduleImage.digest`                                           | The image digest to pull                                                                 | ` `                                                                            |
| `slim.resources.requests.cpu`                                        | CPU requested for building the kernel module                                             | `1000m`                                                                        |
| `slim.resources.requests.memory`                                     | Memory requested for building the kernel module                                          | `348Mi`                                                                        |
| `slim.resources.limits.cpu`                                          | CPU limit for building the kernel module                                                 | `1000m`                                                                        |
| `slim.resources.limits.memory`                                       | Memory limit for building the kernel module                                              | `512Mi`                                                                        |
| `ebpf.enabled`                                                       | Enable eBPF support for Sysdig instead of `sysdig-probe` kernel module                   | `false`                                                                        |
| `ebpf.settings.mountEtcVolume`                                       | Needed to detect which kernel version are running in Google COS                          | `true`                                                                         |
| `clusterName`                                                        | Set a cluster name to identify events using *kubernetes.cluster.name* tag                | ` `                                                                            |
| `sysdig.accessKey`                                                   | Your Sysdig Agent Access Key                                                             | ` ` Either accessKey or existingAccessKeySecret is required                    |
| `sysdig.existingAccessKeySecret`                                     | Alternatively, specify the name of a Kubernetes secret containing an 'access-key' entry  | ` ` Either accessKey or existingAccessKeySecret is required                    |
| `sysdig.disableCaptures`                                             | Disable capture functionality (see https://docs.sysdig.com/en/disable-captures.html)     | `false`                                                                        |
| `sysdig.settings`                                                    | Additional settings, directly included in the agent's configuration file `dragent.yaml`  | `{}`                                                                           |
| `secure.enabled`                                                     | Enable Sysdig Secure                                                                     | `true`                                                                         |
| `secure.vulnerabilityManagement.newEngineOnly`                       | Enable only the new vulnerabilty management engine                                       | `false`                                                                        |
| `auditLog.enabled`                                                   | Enable K8s audit log support for Sysdig Secure                                           | `false`                                                                        |
| `auditLog.auditServerUrl`                                            | The URL where Sysdig Agent listens for K8s audit log events                              | `0.0.0.0`                                                                      |
| `auditLog.auditServerPort`                                           | Port where Sysdig Agent listens for K8s audit log events                                 | `7765`                                                                         |
| `auditLog.dynamicBackend.enabled`                                    | Deploy the Audit Sink where Sysdig listens for K8s audit log events                      | `false`                                                                        |
| `customAppChecks`                                                    | The custom app checks deployed with your agent                                           | `{}`                                                                           |
| `tolerations`                                                        | The tolerations for scheduling                                                           | `node-role.kubernetes.io/master:NoSchedule`                                    |
| `leaderelection.enable`                                              | Use the agent leader election algorithm                                                  | `false`                                                                        |
| `prometheus.file`                                                    | Use file to configure promscrape                                                         | `false`                                                                        |
| `prometheus.yaml`                                                    | prometheus.yaml content to configure metric collection: relabelling and filtering        | ` `                                                                            |
| `extraVolumes.volumes`                                               | Additional volumes to mount in the sysdig agent to pass new secrets or configmaps        | `[]`                                                                           |
| `extraVolumes.mounts`                                                | Mount points for additional volumes                                                      | `[]`                                                                           |
| `extraSecrets`                                                       | Allow passing extra secrets that can be mounted via extraVolumes                         | `[]`                                                                           |
| `kspm.deploy`                                                        | Enables Sysdig KSPM node analyzer & KSPM collector                                       | `false`                                                                        |
| `nodeAnalyzer.deploy`                                                | Deploy the Node Analyzer                                                                 | `true`                                                                         |
| `nodeAnalyzer.apiEndpoint`                                           | Sysdig secure API endpoint, without protocol (i.e. `secure.sysdig.com`)                  | ` `                                                                            |
| `nodeAnalyzer.sslVerifyCertificate`                                  | Can be set to false to allow insecure connections to the Sysdig backend, such as On-Prem |                                                                                |
| `nodeAnalyzer.debug`                                                 | Can be set to true to show debug logging, useful for troubleshooting                     |                                                                                |
| `nodeAnalyzer.labels`                                                | NodeAnalyzer specific labels (as a multi-line templated string map or as YAML)           |                                                                                |
| `nodeAnalyzer.priorityClassName`                                     | Priority class name variable                                                             |                                                                                |
| `nodeAnalyzer.httpProxy`                                             | Proxy configuration variables                                                            |                                                                                |
| `nodeAnalyzer.httpsProxy`                                            | Proxy configuration variables                                                            |                                                                                |
| `nodeAnalyzer.noProxy`                                               | Proxy configuration variables                                                            |                                                                                |
| `nodeAnalyzer.pullSecrets`                                           | Image pull secrets for the Node Analyzer containers                                      | `nil`                                                                          |
| `nodeAnalyzer.imageAnalyzer.deploy`                                  | Deploy the Image Analyzer                                                                | `true    `                                                                     |
| `nodeAnalyzer.imageAnalyzer.image.repository`                        | The image repository to pull the Node Image Analyzer from                                | `sysdig/node-image-analyzer`                                                   |
| `nodeAnalyzer.imageAnalyzer.image.tag`                               | The image tag to pull the Node Image Analyzer                                            | `0.1.27`                                                                       |
| `nodeAnalyzer.imageAnalyzer.image.digest`                            | The image digest to pull                                                                 | ` `                                                                            |
| `nodeAnalyzer.imageAnalyzer.image.pullPolicy`                        | The Image pull policy for the Node Image Analyzer                                        | `IfNotPresent`                                                                 |
| `nodeAnalyzer.imageAnalyzer.dockerSocketPath`                        | The Docker socket path                                                                   |                                                                                |
| `nodeAnalyzer.imageAnalyzer.criSocketPath`                           | The socket path to a CRI compatible runtime, such as CRI-O                               |                                                                                |
| `nodeAnalyzer.imageAnalyzer.containerdSocketPath`                    | The socket path to a CRI-Containerd daemon                                               |                                                                                |
| `nodeAnalyzer.imageAnalyzer.extraVolumes.volumes`                    | Additional volumes to mount in the Node Image Analyzer (i.e. for docker socket)          | `[]`                                                                           |
| `nodeAnalyzer.imageAnalyzer.extraVolumes.mounts`                     | Mount points for additional volumes                                                      | `[]`                                                                           |
| `nodeAnalyzer.imageAnalyzer.resources.requests.cpu`                  | Node Image Analyzer CPU requests per node                                                | `150m`                                                                         |
| `nodeAnalyzer.imageAnalyzer.resources.requests.memory`               | Node Image Analyzer Memory requests per node                                             | `512Mi`                                                                        |
| `nodeAnalyzer.imageAnalyzer.resources.limits.cpu`                    | Node Image Analyzer CPU limit per node                                                   | `500m`                                                                         |
| `nodeAnalyzer.imageAnalyzer.resources.limits.memory`                 | Node Image Analyzer Memory limit per node                                                | `1536Mi`                                                                       |
| `nodeAnalyzer.imageAnalyzer.env`                                     | Extra environment variables that will be passed onto pods                                | `{}`                                                                           |
| `nodeAnalyzer.hostAnalyzer.deploy`                                   | Deploy the Host Analyzer                                                                 | `true    `                                                                     |
| `nodeAnalyzer.hostAnalyzer.image.repository`                         | The image repository to pull the Host Analyzer from                                      | `sysdig/host-analyzer`                                                         |
| `nodeAnalyzer.hostAnalyzer.image.tag`                                | The image tag to pull the Host Analyzer                                                  | `0.1.16`                                                                       |
| `nodeAnalyzer.hostAnalyzer.image.digest`                             | The image digest to pull                                                                 | ` `                                                                            |
| `nodeAnalyzer.hostAnalyzer.image.pullPolicy`                         | The Image pull policy for the Host Analyzer                                              | `IfNotPresent`                                                                 |
| `nodeAnalyzer.hostAnalyzer.schedule`                                 | The scanning schedule specification for the host analyzer expressed as a crontab         | `@dailydefault`                                                                |
| `nodeAnalyzer.hostAnalyzer.dirsToScan`                               | The list of directories to inspect during the scan                                       | `/etc,/var/lib/dpkg,/usr/local,/usr/lib/sysimage/rpm,/var/lib/rpm,/lib/apk/db` |
| `nodeAnalyzer.hostAnalyzer.maxSendAttempts`                          | The number of times the analysis collector is allowed to retry sending results           | `3`                                                                            |
| `nodeAnalyzer.hostAnalyzer.resources.requests.cpu`                   | Host Analyzer CPU requests per node                                                      | `150m`                                                                         |
| `nodeAnalyzer.hostAnalyzer.resources.requests.memory`                | Host Analyzer Memory requests per node                                                   | `512Mi`                                                                        |
| `nodeAnalyzer.hostAnalyzer.resources.limits.cpu`                     | Host Analyzer CPU limit per node                                                         | `500m`                                                                         |
| `nodeAnalyzer.hostAnalyzer.resources.limits.memory`                  | Host Analyzer Memory limit per node                                                      | `1536Mi`                                                                       |
| `nodeAnalyzer.hostAnalyzer.env`                                      | Extra environment variables that will be passed onto pods                                | `{}`                                                                           |
| `nodeAnalyzer.benchmarkRunner.deploy`                                | Deploy the Benchmark Runner                                                              | `true    `                                                                     |
| `nodeAnalyzer.benchmarkRunner.image.repository`                      | The image repository to pull the Benchmark Runner from                                   | `sysdig/compliance-benchmark-runner`                                           |
| `nodeAnalyzer.benchmarkRunner.image.tag`                             | The image tag to pull the Benchmark Runner                                               | `1.1.0.8`                                                                      |
| `nodeAnalyzer.benchmarkRunner.image.digest`                          | The image digest to pull                                                                 | ` `                                                                            |
| `nodeAnalyzer.benchmarkRunner.image.pullPolicy`                      | The Image pull policy for the Benchmark Runner                                           | `IfNotPresent`                                                                 |
| `nodeAnalyzer.benchmarkRunner.includeSensitivePermissions`           | Grant the service account elevated permissions to run CIS Benchmark for OS4              | `false`                                                                        |
| `nodeAnalyzer.benchmarkRunner.resources.requests.cpu`                | Benchmark Runner CPU requests per node                                                   | `150m`                                                                         |
| `nodeAnalyzer.benchmarkRunner.resources.requests.memory`             | Benchmark Runner Memory requests per node                                                | `128Mi`                                                                        |
| `nodeAnalyzer.benchmarkRunner.resources.limits.cpu`                  | Benchmark Runner CPU limit per node                                                      | `500m`                                                                         |
| `nodeAnalyzer.benchmarkRunner.resources.limits.memory`               | Benchmark Runner Memory limit per node                                                   | `256Mi`                                                                        |
| `nodeAnalyzer.benchmarkRunner.env`                                   | Extra environment variables that will be passed onto pods                                | `{}`                                                                           |
| `nodeAnalyzer.runtimeScanner.deploy`                                 | Deploy the Runtime Scanner                                                               | `false`                                                                        |
| `nodeAnalyzer.runtimeScanner.extraMounts`                            | Specify a container engine custom socket path (docker, containerd, CRI-O)                |                                                                                |
| `nodeAnalyzer.runtimeScanner.image.repository`                       | The image repository to pull the Runtime Scanner from                                    | `sysdig/vuln-runtime-scanner`                                                  |
| `nodeAnalyzer.runtimeScanner.image.tag`                              | The image tag to pull the Runtime Scanner                                                | `1.4.12`                                                                       |
| `nodeAnalyzer.runtimeScanner.image.digest`                           | The image digest to pull                                                                 | ` `                                                                            |
| `nodeAnalyzer.runtimeScanner.image.pullPolicy`                       | The image pull policy for the Runtime Scanner                                            | `IfNotPresent`                                                                 |
| `nodeAnalyzer.runtimeScanner.resources.requests.cpu`                 | Runtime Scanner CPU requests per node                                                    | `250m`                                                                         |
| `nodeAnalyzer.runtimeScanner.resources.requests.memory`              | Runtime Scanner Memory requests per node                                                 | `512Mi`                                                                        |
| `nodeAnalyzer.runtimeScanner.resources.requests.ephemeral-storage`   | Runtime Scanner Storage requests per node                                                | `2Gi`                                                                          |
| `nodeAnalyzer.runtimeScanner.resources.limits.cpu`                   | Runtime Scanner CPU limit per node                                                       | `500m`                                                                         |
| `nodeAnalyzer.runtimeScanner.resources.limits.memory`                | Runtime Scanner Memory limit per node                                                    | `1536Mi`                                                                       |
| `nodeAnalyzer.runtimeScanner.resources.limits.ephemeral-storage`     | Runtime Scanner Storage limit per node                                                   | `4Gi`                                                                          |
| `nodeAnalyzer.runtimeScanner.env`                                    | Extra environment variables that will be passed onto pods                                | `{}`                                                                           |
| `nodeAnalyzer.runtimeScanner.settings.eveEnabled`                    | Enables Sysdig Eve                                                                       | `false`                                                                        |
| `nodeAnalyzer.runtimeScanner.eveConnector.image.repository`          | The image repository to pull the Eve Connector from                                      | `sysdig/eveclient-api`                                                         |
| `nodeAnalyzer.runtimeScanner.eveConnector.image.tag`                 | The image tag to pull the Eve Connector                                                  | `1.1.0`                                                                        |
| `nodeAnalyzer.runtimeScanner.eveConnector.deploy`                    | Enables Sysdig Eve Connector for third-party integrations                                | `false`                                                                        |
| `nodeAnalyzer.runtimeScanner.eveConnector.resources.requests.cpu`    | Eve Connector CPU requests per node                                                      | `100m`                                                                         |
| `nodeAnalyzer.runtimeScanner.eveConnector.resources.requests.memory` | Eve Connector Memory requests per node                                                   | `128Mi`                                                                        |
| `nodeAnalyzer.runtimeScanner.eveConnector.resources.limits.cpu`      | Eve Connector CPU limits per node                                                        | `1000m`                                                                        |
| `nodeAnalyzer.runtimeScanner.eveConnector.resources.limits.memory`   | Eve Connector Memory limits per node                                                     | `512Mi`                                                                        |
| `nodeAnalyzer.runtimeScanner.eveConnector.settings.replicas`         | Eve Connector deployment replicas                                                        | `1`                                                                            |
| `nodeAnalyzer.kspmAnalyzer.debug`                                    | Can be set to true to show KSPM node analyzer debug logging, useful for troubleshooting  | `false`                                                                        |
| `nodeAnalyzer.kspmAnalyzer.image.repository`                         | The image repository to pull the  KSPM node analyzer from                                | `sysdig/kspm-analyzer`                                                         |
| `nodeAnalyzer.kspmAnalyzer.image.tag`                                | The image tag to pull the  KSPM node analyzer                                            | `1.5.0`                                                                        |
| `nodeAnalyzer.kspmAnalyzer.image.digest`                             | The image digest to pull                                                                 | ` `                                                                            |
| `nodeAnalyzer.kspmAnalyzer.image.pullPolicy`                         | The image pull policy for the  KSPM node analyzer                                        | `IfNotPresent`                                                                 |
| `nodeAnalyzer.kspmAnalyzer.resources.requests.cpu`                   | KSPM node analyzer CPU requests per node                                                 | `150m`                                                                         |
| `nodeAnalyzer.kspmAnalyzer.resources.requests.memory`                | KSPM node analyzer Memory requests per node                                              | `256Mi`                                                                        |
| `nodeAnalyzer.kspmAnalyzer.resources.limits.cpu`                     | KSPM node analyzer CPU limits per node                                                   | `500m`                                                                         |
| `nodeAnalyzer.kspmAnalyzer.resources.limits.memory`                  | KSPM node analyzer Memory limits per node                                                | `1536Mi`                                                                       |
| `nodeAnalyzer.kspmAnalyzer.env`                                      | Extra environment variables that will be passed onto pods                                | `{}`                                                                           |
| `kspmCollector.image.tag`                                            | The image tag to pull the  KSPM collector                                                | `1.5.0`                                                                        |
| `kspmCollector.image.digest`                                         | The image digest to pull                                                                 | ` `                                                                            |
| `kspmCollector.image.pullPolicy`                                     | The image pull policy for the  KSPM collector                                            | `IfNotPresent`                                                                 |
| `kspmCollector.settings.replicas`                                    | KSPM collector deployment replicas                                                       | `1`                                                                            |
| `kspmCollector.settings.namespaces.included`                         | Namespaces to include in the KSPM collector scans, when empty scans all                  | ``                                                                             |
| `kspmCollector.settings.namespaces.excluded`                         | Namespaces to exclude in the KSPM collector scans                                        | ``                                                                             |
| `kspmCollector.settings.workloads.included`                          | Workloads to include in the KSPM collector scans, when empty scans all                   | ``                                                                             |
| `kspmCollector.settings.workloads.excluded`                          | Workloads to exclude in the KSPM collector scans, when empty scans all                   | ``                                                                             |
| `kspmCollector.settings.healthIntervalMin`                           | Minutes interval for KSPM collector health status messages                               | `5`                                                                            |
| `kspmCollector.resources.requests.cpu`                               | KSPM collector CPU requests per node                                                     | `150m`                                                                         |
| `kspmCollector.resources.requests.memory`                            | KSPM collector Memory requests per node                                                  | `256Mi`                                                                        |
| `kspmCollector.resources.limits.cpu`                                 | KSPM collector CPU limits per node                                                       | `500m`                                                                         |
| `kspmCollector.resources.limits.memory`                              | KSPM collector Memory limits per node                                                    | `1536Mi`                                                                       |
| `kspmCollector.env`                                                  | Extra environment variables that will be passed onto pods                                | `{}`                                                                           |
| `nodeAnalyzer.nodeSelector`                                          | Node Selector                                                                            | `{}`                                                                           |
| `nodeAnalyzer.affinity`                                              | Node affinities                                                                          | `schedule on amd64 and linux`                                                  |

Node Image Analyzer parameters (deprecated by nodeAnalyzer)

| Parameter                                                  | Description                                                                              | Default                       |
| ---------------------------------------------------------- | ---------------------------------------------------------------------------------------- |-------------------------------|
| `nodeImageAnalyzer.deploy`                                 | Deploy the Node Image Analyzer (See https://docs.sysdig.com/en/scan-running-images.html) | `false`                       |
| `nodeImageAnalyzer.settings.dockerSocketPath`              | The Docker socket path                                                                   |                               |
| `nodeImageAnalyzer.settings.criSocketPath`                 | The socket path to a CRI compatible runtime, such as CRI-O                               |                               |
| `nodeImageAnalyzer.settings.containerdSocketPath`          | The socket path to a CRI-Containerd daemon                                               |                               |
| `nodeImageAnalyzer.settings.collectorEndpoint`             | The endpoint to the Scanning Analysis collector                                          |                               |
| `nodeImageAnalyzer.settings.sslVerifyCertificate`          | Can be set to false to allow insecure connections to the Sysdig backend, such as On-Prem |                               |
| `nodeImageAnalyzer.settings.debug`                         | Can be set to true to show debug logging, useful for troubleshooting                     |                               |
| `nodeImageAnalyzer.settings.httpProxy`                     | Proxy configuration variables                                                            |                               |
| `nodeImageAnalyzer.settings.httpsProxy`                    | Proxy configuration variables                                                            |                               |
| `nodeImageAnalyzer.settings.noProxy`                       | Proxy configuration variables                                                            |                               |
| `nodeImageAnalyzer.image.repository`                       | The image repository to pull the Node Image Analyzer from                                | `sysdig/node-image-analyzer`  |
| `nodeImageAnalyzer.image.tag`                              | The image tag to pull the Node Image Analyzer                                            | `0.1.27`                      |
| `nodeImageAnalyzer.imagedigest`                            | The image digest to pull                                                                 | ` `                           |
| `nodeImageAnalyzer.image.pullPolicy`                       | The Image pull policy for the Node Image Analyzer                                        | `IfNotPresent`                |
| `nodeImageAnalyzer.image.pullSecrets`                      | Image pull secrets for the Node Image Analyzer                                           | `nil`                         |
| `nodeImageAnalyzer.resources.requests.cpu`                 | Node Image Analyzer CPU requests per node                                                | `250m`                        |
| `nodeImageAnalyzer.resources.requests.memory`              | Node Image Analyzer Memory requests per node                                             | `512Mi`                       |
| `nodeImageAnalyzer.resources.limits.cpu`                   | Node Image Analyzer CPU limit per node                                                   | `500m`                        |
| `nodeImageAnalyzer.resources.limits.memory`                | Node Image Analyzer Memory limit per node                                                | `1024Mi`                      |
| `nodeImageAnalyzer.extraVolumes.volumes`                   | Additional volumes to mount in the Node Image Analyzer (i.e. for docker socket)          | `[]`                          |
| `nodeImageAnalyzer.extraVolumes.mounts`                    | Mount points for additional volumes                                                      | `[]`                          |
| `nodeImageAnalyzer.priorityClassName`                      | Priority class name variable                                                             |                               |
| `nodeImageAnalyzer.affinity`                               | Node affinities                                                                          | `schedule on amd64 and linux` |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
$ helm install --namespace sysdig-agent sysdig-agent \
    --set sysdig.accessKey=YOUR-KEY-HERE,sysdig.settings.tags="role:webserver\,location:europe" \
    sysdig/sysdig
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For
example,

```bash
$ helm install --namespace sysdig-agent sysdig-agent -f values.yaml sysdig/sysdig
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Resource profiles

For ease of use, some predefined resource profiles are available:

* small

```yaml
requests:
  cpu: 1000m
  memory: 1024Mi
limits:
  cpu: 1000m
  memory: 1024Mi
```

* medium

```yaml
requests:
  cpu: 3000m
  memory: 3072Mi
limits:
  cpu: 3000m
  memory: 3072Mi
```

* large

```yaml
requests:
  cpu: 5000m
  memory: 6144Mi
limits:
  cpu: 5000m
  memory: 6144Mi
```

* custom

To set your own resource requests and limits to any values other than the ones defined above, you need to set `resourceProfile == custom` and then add specific values for `resources.*` to match your requirements by setting the appropriate values in the `resources` object.

See [Tuning Sysdig Agent](https://docs.sysdig.com/en/tuning-sysdig-agent.html) for more info.

## Node Analyzer

The Node Analyzer is deployed by default unless you set the value `nodeAnalyzer.deploy` to `false`.

The Node Analyzer daemonset contains three containers, each providing a specific functionality. This daemonset replaces
the (deprecated) Node Image Analyzer daemonset.

See
the [Node Analyzer installation documentation](https://docs.sysdig.com/en/node-analyzer--multi-feature-installation.html)
for details about installation, and
[Running Node Analyzer Behind a Proxy](https://docs.sysdig.com/en/node-analyzer--multi-feature-installation.html#UUID-35c14c46-b327-c2a8-ed9c-82a2af995218_section-idm51621039128136)
for proxy settings.

### Node Image Analyzer

See
the [Image Analyzer Configmap Options](https://docs.sysdig.com/en/node-analyzer--multi-feature-installation.html#UUID-35c14c46-b327-c2a8-ed9c-82a2af995218_section-idm514589352153208)
for details about the available options, and
the [Node Image Analyzer documentation](https://docs.sysdig.com/en/scan-running-images.html) for details about the Node
Image Analyzer feature.

The node image analyzer (NIA) provides the capability to scan images as soon as they start running on hosts where the
analyzer is installed. It is typically installed alongside the Sysdig agent container.

On container start-up, the analyzer scans all pre-existing running images present in the node. Additionally, it will
scan any new image that enters a running state in the node. It will scan each image once, then forward the results to
the Sysdig Secure scanning backend. Image metadata and the full scan report is then available in the Sysdig Secure UI.

### Host Analyzer

See
the [Host Scanning Configuration Options](https://docs.sysdig.com/en/node-analyzer--multi-feature-installation.html#UUID-35c14c46-b327-c2a8-ed9c-82a2af995218_UUID-6666385b-c550-0660-f563-956f3a4fe093)
for details about installation options, and
the [Host Scanning documentation](https://docs.sysdig.com/en/host-scanning.html) for details about the Host Scanning
feature.

The host analyzer provides the capability to scan packages installed on the host operating system to identify potential
vulnerabilities. It is typically installed as part of the Node Analyzer which in turn is installed alongside the Sysdig
Agent.

The host analyzer works by inspecting the files on the host root filesystem looking for installed packages and sending
them to the Sysdig backend. It performs this operation by default once a day and its schedule can be configured as
described below. Likewise, the list of directories to be examined during each scan can be configured.

### Benchmark Runner

See the [Benchmarks documentation](https://docs.sysdig.com/en/benchmarks.html) for details on the Benchmark feature. The
Benchmark Runner provides the capability to run CIS inspired benchmarks against your infrastructure. Benchmark tasks are
configured in the UI, and the runner automatically runs these benchmarks on the configured scope and schedule.
Note: if `nodeAnalyzer.benchmarkRunner.includeSensitivePermissions` is set to `false`, the service account will not have
the full set of permissions needed to execute `oc` commands, which most checks in `CIS Benchmark for OS4` require.

### KSPM Analyzer (Preview)

See the [Actionable Compliance documentation](https://docs.sysdig.com/en/docs/sysdig-secure/posture/compliance/actionable-compliance/) for details on the Actionable Compliance feature. The
KSPM Analyzer analyzes your host's configuration and sends the output to be evaluated against compliance policies.
The scan results are displayed in Sysdig Secure's Actionable Compliance screens.

The flag ```kspm.deploy``` enables KSPM node analyzer & KSPM collector.
The agent listens to port 12000 by default. To override it, you can set the AGENT_PORT environment variable.

For example:

```bash
$ helm install --namespace sysdig-agent sysdig-agent \
    --set sysdig.accessKey=YOUR-KEY-HERE \
    --set nodeAnalyzer.apiEndpoint=42.32.196.18 \
    --set kspm.deploy=true \
    --set nodeAnalyzer.kspmAnalyzer.env.AGENT_PORT=8888 \
    sysdig/sysdig
```

## KSPM Collector (Preview)

See the [Actionable Compliance documentation](https://docs.sysdig.com/en/docs/sysdig-secure/posture/compliance/actionable-compliance/) for details on the Actionable Compliance feature. The
KSPM Collector collects Kubernetes resource manifests and sends them to be evaluated against compliance policies.
The scan results are displayed in Sysdig Secure's Actionable Compliance screens.

To enable the KSPM Collector set the kspm.deploy flag to true:

```bash
--set kspm.deploy=true
```

Note that the flag ```kspm.deploy``` enables both KSPM node analyzer and KSPM collector.

## GKE Autopilot
Autopilot is an operation mode for creating and managing clusters in GKE.
With Autopilot, Google configures and manages the underlying node infrastructure for you.

To deploy the Sysdig agent in GKE clusters running in Autopilot mode, run:

```bash
$ helm install --namespace sysdig-agent sysdig-agent --set sysdig.accessKey=YOUR-KEY-HERE --set sysdig.settings.collector=COLLECTOR_URL sysdig/sysdig --set gke.autopilot=true
```

When the flag `gke.autopilot=true` gets `true`, the chart configuration is overridden as follows:
 - `nodeAnalyzer.deploy=false`
 - `ebpf.enabled=true`
 - `ebpf.settings.mountEtcVolume=false`
 - `daemonset.annotations='autopilot\.gke\.io/no-connect="true"'`
 - `daemonset.affinity=null'`

So, on GKE Autopilot clusters:
 - The NodeAnalyzed is not deployed,
 - The ebpf is enabled and the etcVolume is not mounted,
 - The daemonset affinity is set to `null`,
 - The daemonset annotation is set to enable the Agent to run on autopilot (required from GKE).


## On-Premise backend deployment settings

Sysdig platform backend can be also deployed On-Premise in your own infrastructure.

Installing the agent using the Helm chart is also possible in this scenario, and you can enable it with the following
parameters:

| Parameter                                | Description                                              | Default |
| ---------------------------------------- | -------------------------------------------------------- | ------- |
| `collectorSettings.collectorHost`        | The IP address or hostname of the collector              | ` `     |
| `collectorSettings.collectorPort`        | The port where collector is listening                    | 6443    |
| `collectorSettings.ssl`                  | The collector accepts SSL                                | `true`  |
| `collectorSettings.sslVerifyCertificate` | Set to false if you don't want to verify SSL certificate | `true`  |

For example:

```bash
$ helm install --namespace sysdig-agent sysdig-agent \
    --set sysdig.accessKey=YOUR-KEY-HERE \
    --set collectorSettings.collectorHost=42.32.196.18 \
    --set collectorSettings.collectorPort=6443 \
    --set collectorSettings.sslVerifyCertificate=false \
    sysdig/sysdig
```

## Using private Docker image registry

If you pull the Sysdig agent Docker image from a private registry that requires authentication, some additional
configuration is required.

First, create a secret that stores the registry credentials:

```bash
$ kubectl create secret docker-registry SECRET_NAME \
  --docker-server=SERVER \
  --docker-username=USERNAME \
  --docker-password=TOKEN \
  --docker-email=EMAIL
```

Then, point to this secret in the values YAML file:

```yaml
sysdig:
  accessKey: YOUR-KEY-HERE
image:
  registry: myrepo.mydomain.tld
  repository: sysdig-agent
  tag: latest-tag
  pullSecrets:
    - name: SECRET_NAME
```

Finally, set the accessKey value and you are ready to deploy the Sysdig agent using the Helm chart:

```bash
$ helm install --namespace sysdig-agent sysdig-agent -f values.yaml sysdig/sysdig
```

You can read more details about this
in [Kubernetes Documentation](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/).

## Modifying Sysdig agent configuration

The Sysdig agent uses a file called `dragent.yaml` to store the configuration.

Using the Helm chart, the default configuration settings can be updated using `sysdig.settings` either
via `--set sysdig.settings.key = value` or in the values YAML file. For example, to eanble Prometheus metrics scraping,
you need this in your `values.yaml` file::

```yaml
sysdig:
  accessKey: YOUR-KEY-HERE
  settings:
    prometheus:
      enabled: true
      histograms: true
```

```bash
$ helm install --namespace sysdig-agent sysdig-agent -f values.yaml sysdig/sysdig
```

## Upgrading Sysdig agent configuration

If you need to upgrade the agent configuration file, first modify the YAML file (in this case we are increasing the
metrics limit scraping Prometheus metrics):

```yaml
sysdig:
  accessKey: YOUR-KEY-HERE
  settings:
    prometheus:
      enabled: true
      histograms: true
      max_metrics: 2000
      max_metrics_per_process: 400
```

And then, upgrade Helm chart with:

```bash
$ helm upgrade --namespace sysdig-agent sysdig-agent -f values.yaml sysdig/sysdig
```

## How to upgrade to the last version

First of all ensure you have the lastest chart version

```bash
$ helm repo update
```

In case you deployed the chart with a values.yaml file, you just need to modify (or add if it's missing) the `image.tag`
field and execute:

```bash
$ helm upgrade --namespace sysdig-agent sysdig-agent -f values.yaml sysdig/sysdig
```

If you deployed the chart setting the values as CLI parameters, like for example:

```bash
$ helm install \
    --namespace sysdig-agent \
    sysdig-agent \
    --set sysdig.accessKey=xxxx \
    --set ebpf.enabled=true \
    sysdig/sysdig
```

You will need to execute:

```bash
$ helm upgrade \
    --namespace sysdig-agent \
    sysdig-agent \
    --set sysdig.accessKey=xxxx \
    --set ebpf.enabled=true \
    --set image.tag=<last_version> \
    sysdig/sysdig
```

## Adding custom AppChecks

[Application checks](https://sysdigdocs.atlassian.net/wiki/spaces/Monitor/pages/204767363/) are integrations that allow
the Sysdig agent to collect metrics exposed by specific services. Sysdig has several built-in AppChecks, but sometimes
you might need to [create your own](https://sysdigdocs.atlassian.net/wiki/spaces/Monitor/pages/204767436/).

Your own AppChecks can deployed with the Helm chart embedding them in the values YAML file:

```yaml
customAppChecks:
  sample.py: |-
    from checks import AgentCheck

    class MyCustomCheck(AgentCheck):
        def check(self, instance):
            self.gauge("testhelm", 1)

sysdig:
  accessKey: YOUR-KEY-HERE
  settings:
    app_checks:
      - name: sample
        interval: 10
        pattern: # pattern to match the application
          comm: myprocess
        conf:
          mykey: myvalue
```

The first section dumps the AppCheck in a Kubernetes configmap and makes it available within the Sysdig agent container.
The second one configures it on the `dragent.yaml` file.

Once the values YAML file is ready, we will deploy the Chart like before:

```bash
$ helm install --namespace sysdig-agent sysdig-agent -f values.yaml sysdig/sysdig
```

### Automating the generation of custom-app-checks.yaml file

Sometimes editing and maintaining YAML files can be a bit cumbersome and error-prone, so we have created a script for
automating this process and make your life easier.

Imagine that you have custom AppChecks for a number of services like Redis, MongoDB and Traefik.

You have already a `values.yaml` with just your configuration:

```yaml
sysdig:
  accessKey: YOUR-KEY-HERE
  settings:
    app_checks:
      - name: myredis
        [ ... ]
      - name: mymongo
        [ ... ]
      - name: mytraefik
        [ ... ]
```

You can generate an additional values YAML file with the custom AppChecks:

```bash
$ git clone https://github.com/sysdiglabs/charts.git
$ cd charts/sysdig
$ ./scripts/appchecks2helm appChecks/solr.py appChecks/traefik.py appChecks/nats.py > custom-app-checks.yaml
```

And deploy the Chart with both of them:

```bash
$ helm install --namespace sysdig-agent sysdig-agent -f custom-app-checks.yaml -f values.yaml sysdig/sysdig
```

### Adding prometheus.yaml to configure promscrape

Promscrape is the component used to collect Prometheus metrics from the sysdig agent. It is based on Prometheus and
accepts the same configuration format.

This file can contain relabelling rules and filters to remove certain metrics or add some configurations to the
collection. An example of this file could be:

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
scrape_configs:
  - job_name: 'prometheus' # config for federation
    honor_labels: true
    metrics_path: '/federate'
    metric_relabel_configs:
      - regex: 'kubernetes_pod_name'
        action: labeldrop
    params:
      'match[]':
        - '{sysdig="true"}'
    sysdig_sd_configs:
      - tags:
          namespace: monitoring
          deployment: prometheus-server
```

`sysdig_sd_configs` allows to select the targets obtained by Sysdig agents to apply the rules in the job.
Check [how to configure filtering in sysdig documentation](https://docs.sysdig.com/en/filtering-prometheus-metrics.html)
.

### Adding additional volumes

To add a new volume to the sysdig agent.

In order to pass new config maps or secrets used for authentication (for example for Prometheus endpoints) you can mount
additional secrets, configmaps or volumes. An example of this could be:

```yaml
extraVolumes:
  volumes:
    - name: sysdig-new-cm
      configMap:
        name: my-cm
        optional: true
    - name: sysdig-new-secret
        secret:
        secretName: my-secret
  mounts:
    - mountPath: /opt/draios/cm
      name: sysdig-new-cm
    - mountPath: /opt/draios/secret
      name: sysdig-new-secret
```

### Adding additional secrets

To add a new secret to the sysdig agent.

You can create additional secrets (for example for Prometheus basic auth). The values are Opaque type secrets and must be in base64 encoded.
An example of this could be:

```yaml
extraSecrets:
  - name: sysdig-new-secret
    data:
      sysdig-new-password-key1: bXlwYXNzd29yZA==
      sysdig-new-password-key2: bXlwYXNzd29yZA==
```

## Support

For getting support from the Sysdig team, you should refer to the official
[Sysdig Support page](https://sysdig.com/support).

In addition to this, you can browse the documentation for the different components of the Sysdig Platform:

* [Sysdig Monitor](https://app.sysdigcloud.com)
* [Sysdig Secure](https://secure.sysdig.com)
* [Platform Documentation](https://docs.sysdig.com/en/sysdig-platform.html)
* [Monitor Documentation](https://docs.sysdig.com/en/sysdig-monitor.html)
* [Secure Documentation](https://docs.sysdig.com/en/sysdig-secure.html)
