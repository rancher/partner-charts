# Chart: Sysdig

---
**WARNING**

This chart is being deprecated. Please use the [sydig-deploy chart](https://github.com/sysdiglabs/charts/tree/master/charts/sysdig-deploy) for production deployments.

---

## Overview

`sysdig` chart adds the Sysdig installation components for [Sysdig Monitor](https://sysdig.com/product/monitor/) and [Sysdig Secure](https://sysdig.com/product/secure/) to all  the nodes in your Kubernetes cluster via a DaemonSet. This chart deploys the following Sysdig components into your Kubernetes cluster.

- Sysdig Agent
- Node Analyzer
  - Sysdig Benchmark Runner
  - Sysdig Host Analyzer
  - Sysdig Image Analyzer
  - Sysdig KSPM Analyzer
- Sysdig KSPM Collector

## Installation

To deploy the Sysdig installation components, follow the installation instructions given on the Sysdig Documentation website:

### Sysdig Monitor

- [Installation Requirements](https://docs.sysdig.com/en/docs/installation/sysdig-monitor/install-sysdig-agent/#installation-requirements)
- [Installation Instructions](https://docs.sysdig.com/en/docs/installation/sysdig-monitor/install-sysdig-agent/kubernetes/)

### Sysdig Secure | Sysdig Secure + Sysdig Monitor

- [Component Overview](https://docs.sysdig.com/en/docs/installation/sysdig-secure/install-agent-components/)
- [Installation Requirements](https://docs.sysdig.com/en/docs/installation/sysdig-secure/install-agent-components/installation-requirements/sysdig-agent/)
- [Installation Instructions](https://docs.sysdig.com/en/docs/installation/sysdig-secure/install-agent-components/kubernetes/)

## Difference Between `sysdig` and `sysdig-deploy`

The majority of the differences are in the metadata names and labels in the `agent` and `node-analyzer` components in the `sysdig-deploy` chart.

- `helm.sh/chart: sysdig-<version>` has been changed to  `helm.sh.chart: nodeAnalyzer-<version>` or `helm.sh.chart: agent-<version>`
- Added the`app.kubernetes.io/name: agent` label  to the `agent` daemonset and pods.
- Added the `app.kubernetes.io/name: nodeanalyzer` label for the `node-analyzer` DaemonSet and pods.
- The new ConfigMap and secret for `node-analyzer` is named `<release-name>-nodeanalyzer`
- The `app: sysdig-agent` label is no longer available for the ` node-analyzer` components.

## Migrate to `sysdig-deploy` Chart

Use the [migration helper script](https://raw.githubusercontent.com/sysdiglabs/charts/master/charts/sysdig-deploy/scripts/migrate_values.py) to easily migrate from the  `sysdig` chart to the new unified `sysdig-deploy` chart. This script will help re-map your existing values from the `sysdig` chart, allowing you to deploy this chart with the exact same configuration.

Unlike the `sysdig` chart, `sysdig-deploy` only supports Helm v3. If you have not already done so, please upgrade your Helm version to 3.x to use this chart.

### Prerequisites

- Python 3.x
- PyYAML

### Migration

1. Save the custom-values from the currently deployed version of the `sysdig` chart:

   ```console
   helm get values -n sysdig-agent sysdig-agent -o yaml > values.old.yaml
   ```

2. (Optional) If the migration script has a dependency on `pyyaml`, install:

   ```console
   pip install pyyaml
   ```

3. Run the migration script and redirect the output to a new file. For example, if the old values were saved to `values.old.yaml`:

   ```console
   python scripts/migrate_values.py values.old.yaml > values.new.yaml
   ```

4. Remove the `sysdig` chart and replace it with the `sysdig-deploy` chart:

   ```console
   helm delete -n sysdig-agent sysdig-agent

   helm repo update
   helm install -n sysdig-agent sysdig sysdig/sysdig-deploy -f values.new.yaml
   ```

## Verify the integrity and origin
Sysdig Helm Charts are signed so users can verify the integrity and origin of each chart, the steps are as follows:

### Import the Public Key

```console
$ curl -o "/tmp/sysdig_public.gpg" "https://charts.sysdig.com/public.gpg"
$ gpg --import /tmp/sysdig_public.gpg
```

### Verify the chart

To check the integrity and the origin of the charts you can now append the `--verify` flag to the `install`, `upgrade` and `pull` helm commands.

## Configuration

You can use the Helm chart to update the default `sysdig` configurations by using either of the following:

- Using the key-value pair: `--set sysdig.settings.key = value`
- `values.yaml` file

### Using the Key-Value Pair

Specify each parameter using the `--set key=value[,key=value]` argument to the `helm install`command.

For example:

```console
helm install --namespace sysdig-agent sysdig-agent \
    --set sysdig.accessKey=YOUR-KEY-HERE,sysdig.settings.tags="role:webserver\,location:europe" \
    sysdig/sysdig
```

### Using values.yaml

The `values.yaml` file specifies the values for the `sysdig` configuration parameters.  You can add the configuration to the `values.yaml` file, then use it in the `helm install` command.

For example:

1. Add the following to the `values.yaml` file:

   ```yaml
   sysdig:
     accessKey: <YOUR-API-KEY>
     settings:
       prometheus:
         enabled: true
         histograms: true
   ```

   **Tip**: You can use the default [values.yaml](values.yaml) file.

2. Run the following:

   ```console
   helm install --namespace sysdig-agent sysdig-agent -f values.yaml sysdig/sysdig
   ```

## Configuration Parameters

The following table lists the configurable parameters of the Sysdig chart and their default values.

### General Parameters

| Parameter                                                    | Description                                                  | Default                                                      |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| `image.registry`                                             | Sysdig Agent image registry.                                 | `quay.io`                                                    |
| `image.repository`                                           | The image repository to pull from.                           | `sysdig/agent`                                               |
| `image.tag`                                                  | The image tag to pull                                        | `12.16.0`                                                    |
| `image.digest`                                               | The image digest to pull.                                    | ` `                                                          |
| `image.pullPolicy`                                           | The Image pull policy.                                       | `IfNotPresent`                                               |
| `image.pullSecrets`                                          | Image pull secrets.                                          | `nil`                                                        |
| `resourceProfile`                                            | Sysdig Agent resource profile. See [Resource profiles](#resource-profiles). | `small`                                                      |
| `resources.requests.cpu`                                     | The CPU requested to be run in a node.                       | ` `                                                          |
| `resources.requests.memory`                                  | The memory requested to be run in a node.                     | ` `                                                          |
| `resources.limits.cpu`                                       | The CPU limit.                                               | ` `                                                          |
| `resources.limits.memory`                                    | The memory limit.                                            | ` `                                                          |
| `gke.autopilot`                                              | If set to `true`,  the agent configuration will be overridden to run on GKE Autopilot clusters. | `false`                                                      |
| `rbac.create`                                                | If set to `true`,  RBAC resources are created and used.      | `true`                                                       |
| `scc.create`                                                 | Creates OpenShift's Security Context constrain.t             | `true`                                                       |
| `psp.create`                                                 | Creates Pod Security Policy to allow the agent that is running in clusters with PSP enabled. | `true`                                                       |
| `serviceAccount.create`                                      | Creates the serviceAccount.                                  | `true`                                                       |
| `serviceAccount.name`                                        | The value you specify will be used as the `serviceAccountName`. | ` `                                                          |
| `priorityClassName`                                          | Sets the priority class for the agent daemonset.             | `""`                                                         |
| `daemonset.deploy`                                           | Deploys the agent daemonset.                                 | `true`                                                       |
| `daemonset.env`                                              | Environment variables for the agent container. Provide as map of `VAR: val`. | `{}`                                                         |
| `daemonset.updateStrategy.type`                              | The updateStrategy for updating the daemonset.               | `RollingUpdate`                                              |
| `daemonset.updateStrategy.type.maxUnavailable`               | The maximum number of pods that can be unavailable during the update process. |                                                              |
| `daemonset.nodeSelector`                                     | Node Selector.                                               | `{}`                                                         |
| `daemonset.arch`                                             | Allowed architectures for scheduling.                        | `[ amd64, arm64, s390x ]`                                    |
| `daemonset.os`                                               | Allowed operating systems for scheduling.                    | `[ linux ]`                                                  |
| `daemonset.affinity`                                         | Node affinities. Overrides `daemonset.arch` and `daemonset.os` values. | `{}`                                                         |
| `daemonset.annotations`                                      | The custom annotations for DaemonSet.                        | `{}`                                                         |
| `daemonset.labels`                                           | The custom labels for daemonset as a multi-line templated string map or as YAML. |                                                              |
| `daemonset.probes.initialDelay`                              | Specifies the initial delay for liveness and readiness probes. DaemonSet. | `{}`                                                         |
| `daemonset.kmodule.env`                                      | Environment variables for the kernel module image builder. Provide as map of `VAR: val`. | `{}`                                                         |
| `slim.enabled`                                               | Uses the slim-based Sysdig Agent image.                      | `true`                                                       |
| `slim.image.repository`                                      | The slim Agent image repository.                             | `sysdig/agent-slim`                                          |
| `slim.kmoduleImage.repository`                               | The repository to pull the kernel module image builder from. | `sysdig/agent-kmodule`                                       |
| `slim.kmoduleImage.digest`                                   | The image digest to pull.                                    | ` `                                                          |
| `slim.resources.requests.cpu`                                | The CPU requested for building the kernel module.            | `1000m`                                                      |
| `slim.resources.requests.memory`                             | The memory requested for building the kernel module.         | `348Mi`                                                      |
| `slim.resources.limits.cpu`                                  | The CPU limit for building the kernel module                 | `1000m`                                                      |
| `slim.resources.limits.memory`                               | The memory limit for building the kernel module.             | `512Mi`                                                      |
| `ebpf.enabled`                                               | Enables eBPF support for Sysdig instead of `sysdig-probe` kernel module. | `false`                                                      |
| `ebpf.settings.mountEtcVolume`                               | Detects which kernel version are running in Google COS.      | `true`                                                       |
| `clusterName`                                                | Set sa cluster name to identify events using *kubernetes.cluster.name* tag. | ` `                                                          |
| `sysdig.accessKey`                                           | Your Sysdig Agent Access Key.                                | ` ` Either accessKey or existingAccessKeySecret is required  |
| `sysdig.existingAccessKeySecret`                             | Alternativel to providing the Sysdig Access Key. Specifies the name of a Kubernetes secret containing an `access-key` entry. | ` ` Either accessKey or existingAccessKeySecret is required  |
| `sysdig.disableCaptures`                                     | Disables capture functionality.  See [Capture](https://docs.sysdig.com/en/disable-captures.html). | `false`                                                      |
| `sysdig.settings`                                            | Specifies the additional settings that are  included in the agent configuration file, `dragent.yaml`. | `{}`                                                         |
| `secure.enabled`                                             | Enables Sysdig Secure.                                       | `true`                                                       |
| `secure.vulnerabilityManagement.newEngineOnly`               | Enables only the new vulnerabilty management engines         | `false`                                                      |
| `auditLog.enabled`                                           | Enables Kubernetes audit log support for Sysdig Secure.      | `false`                                                      |
| `auditLog.auditServerUrl`                                    | The URL where Sysdig Agent listens for Kubernetesaudit log events. | `0.0.0.0`                                                    |
| `auditLog.auditServerPort`                                   | The port where Sysdig Agent listens for Kubernetes audit log events. | `7765`                                                       |
| `auditLog.dynamicBackend.enabled`                            | Deploys the Audit Sink where Sysdig listens for Kubernetes audit log events. | `false`                                                      |
| `customAppChecks`                                            | The custom app checks deployed with your agent.              | `{}`                                                         |
| `tolerations`                                                | The tolerations for scheduling.                              | `node-role.kubernetes.io/master:NoSchedule`                  |
| `leaderelection.enable`                                      | Uses the agent leader election algorithm.                    | `false`                                                      |
| `prometheus.file`                                            | Uses file to configure promscrape.                           | `false`                                                      |
| `prometheus.yaml`                                            | The `prometheus.yaml` content to configure metric collection: relabelling and filtering | ` `                                                          |
| `extraVolumes.volumes`                                       | Additional volumes to mount in the sysdig agent to pass new secrets or ConfigMaps. | `[]`                                                         |
| `extraVolumes.mounts`                                        | The mount points for additional volumes.                     | `[]`                                                         |
| `extraSecrets`                                               | Allows passing extra secrets that can be mounted via extraVolumes. | `[]`                                                         |
| `kspm.deploy`                                                | Enables Sysdig KSPM node analyzer and KSPM collector.        | `false`                                                      |
| `nodeAnalyzer.deploy`                                        | Deploys the Node Analyzer.                                   | `true`                                                       |
| `nodeAnalyzer.apiEndpoint`                                   | Sysdig secure API endpoint without the protocol: `secure.sysdig.com` | ` `                                                          |
| `nodeAnalyzer.sslVerifyCertificate`                          | Set to `false` to allow insecure connections to the Sysdig backend, such as in an on-prem deployment. |                                                              |
| `nodeAnalyzer.debug`                                         | Set to `true` to show debug logging. Useful for troubleshooting. |                                                              |
| `nodeAnalyzer.labels`                                        | NodeAnalyzer specific labels as a multi-line templated string map or as YAML. |                                                              |
| `nodeAnalyzer.priorityClassName`                             | The priority class name variable.                            |                                                              |
| `nodeAnalyzer.httpProxy`                                     | The proxy configuration variables.                           |                                                              |
| `nodeAnalyzer.httpsProxy`                                    | The secure proxy configuration variables.                    |                                                              |
| `nodeAnalyzer.noProxy`                                       | The no proxy configuration variables.                        |                                                              |
| `nodeAnalyzer.pullSecrets`                                   | The image pull secrets for the Node Analyzer containers.     | `nil`                                                        |
| `nodeAnalyzer.imageAnalyzer.deploy`                          | Deploys the Image Analyzer.                                  | `true    `                                                   |
| `nodeAnalyzer.imageAnalyzer.image.repository`                | The image repository to pull the Node Image Analyzer from.   | `sysdig/node-image-analyzer`                                 |
| `nodeAnalyzer.imageAnalyzer.image.tag`                       | The image tag to pull the Node Image Analyzer.               | `0.1.29`                                                     |
| `nodeAnalyzer.imageAnalyzer.image.digest`                    | The image digest to pull.                                    | ` `                                                          |
| `nodeAnalyzer.imageAnalyzer.image.pullPolicy`                | The Image pull policy for the Node Image Analyzer.           | `IfNotPresent`                                               |
| `nodeAnalyzer.imageAnalyzer.dockerSocketPath`                | The Docker socket path.                                      |                                                              |
| `nodeAnalyzer.imageAnalyzer.criSocketPath`                   | The socket path to a CRI compatible runtime, such as CRI-O.  |                                                              |
| `nodeAnalyzer.imageAnalyzer.containerdSocketPath`            | The socket path to a CRI-Containerd daemon.                  |                                                              |
| `nodeAnalyzer.imageAnalyzer.extraVolumes.volumes`            | Additional volumes to mount in the Node Image Analyzer. For example, docker socket. | `[]`                                                         |
| `nodeAnalyzer.imageAnalyzer.extraVolumes.mounts`             | The mount points for additional volumes.                     | `[]`                                                         |
| `nodeAnalyzer.imageAnalyzer.resources.requests.cpu`          | Node Image Analyzer CPU requests per node.                   | `150m`                                                       |
| `nodeAnalyzer.imageAnalyzer.resources.requests.memory`       | Node Image Analyzer Memory requests per node.                | `512Mi`                                                      |
| `nodeAnalyzer.imageAnalyzer.resources.limits.cpu`            | Node Image Analyzer CPU limit per node.                      | `500m`                                                       |
| `nodeAnalyzer.imageAnalyzer.resources.limits.memory`         | Node Image Analyzer Memory limit per node.                   | `1536Mi`                                                     |
| `nodeAnalyzer.imageAnalyzer.env`                             | The extra environment variables that will be passed onto pods. | `{}`                                                         |
| `nodeAnalyzer.hostAnalyzer.deploy`                           | Deploys the Host Analyzer.                                   | `true    `                                                   |
| `nodeAnalyzer.hostAnalyzer.image.repository`                 | The image repository to pull the Host Analyzer from.         | `sysdig/host-analyzer`                                       |
| `nodeAnalyzer.hostAnalyzer.image.tag`                        | The image tag to pull the Host Analyzer.                     | `0.1.19`                                                     |
| `nodeAnalyzer.hostAnalyzer.image.digest`                     | The image digest to pull.                                    | ` `                                                          |
| `nodeAnalyzer.hostAnalyzer.image.pullPolicy`                 | The Image pull policy for the Host Analyzer.                 | `IfNotPresent`                                               |
| `nodeAnalyzer.hostAnalyzer.schedule`                         | The scanning schedule specification for the host analyzer expressed as a crontab. | `@dailydefault`                                              |
| `nodeAnalyzer.hostAnalyzer.dirsToScan`                       | The list of directories to inspect during the scan.          | `/etc,/var/lib/dpkg,/usr/local,/usr/lib/sysimage/rpm,/var/lib/rpm,/lib/apk/db` |
| `nodeAnalyzer.hostAnalyzer.maxSendAttempts`                  | The number of times the analysis collector is allowed to retry sending results. | `3`                                                          |
| `nodeAnalyzer.hostAnalyzer.resources.requests.cpu`           | Host Analyzer CPU requests per node.                         | `150m`                                                       |
| `nodeAnalyzer.hostAnalyzer.resources.requests.memory`        | Host Analyzer memory requests per node.                      | `512Mi`                                                      |
| `nodeAnalyzer.hostAnalyzer.resources.limits.cpu`             | Host Analyzer CPU limit per node.                            | `500m`                                                       |
| `nodeAnalyzer.hostAnalyzer.resources.limits.memory`          | Host Analyzer Memory limit per node.                         | `1536Mi`                                                     |
| `nodeAnalyzer.hostAnalyzer.env`                              | The extra environment variables that will be passed onto pods. | `{}`                                                         |
| `nodeAnalyzer.benchmarkRunner.deploy`                        | Deploys the Benchmark Runner.                                | `true    `                                                   |
| `nodeAnalyzer.benchmarkRunner.image.repository`              | The image repository to pull the Benchmark Runner from.      | `sysdig/compliance-benchmark-runner`                         |
| `nodeAnalyzer.benchmarkRunner.image.tag`                     | The image tag to pull the Benchmark Runner.                  | `1.1.0.8`                                                    |
| `nodeAnalyzer.benchmarkRunner.image.digest`                  | The image digest to pull.                                    | ` `                                                          |
| `nodeAnalyzer.benchmarkRunner.image.pullPolicy`              | The Image pull policy for the Benchmark Runner.              | `IfNotPresent`                                               |
| `nodeAnalyzer.benchmarkRunner.includeSensitivePermissions`   | Grants the service account elevated permissions to run CIS Benchmark for OS4. | `false`                                                      |
| `nodeAnalyzer.benchmarkRunner.resources.requests.cpu`        | Benchmark Runner CPU requests per node.                      | `150m`                                                       |
| `nodeAnalyzer.benchmarkRunner.resources.requests.memory`     | Benchmark Runner memory requests per node.                   | `128Mi`                                                      |
| `nodeAnalyzer.benchmarkRunner.resources.limits.cpu`          | Benchmark Runner CPU limit per node.                         | `500m`                                                       |
| `nodeAnalyzer.benchmarkRunner.resources.limits.memory`       | Benchmark Runner memory limit per node.                      | `256Mi`                                                      |
| `nodeAnalyzer.benchmarkRunner.env`                           | The extra environment variables that will be passed onto pods. | `{}`                                                         |
| `nodeAnalyzer.runtimeScanner.deploy`                         | Deploys the Runtime Scanner.                                 | `false`                                                      |
| `nodeAnalyzer.runtimeScanner.extraMounts`                    | Specifies a container engine custom socket path (docker, containerd, CRI-O). |                                                              |
| `nodeAnalyzer.runtimeScanner.image.repository`               | The image repository to pull the Runtime Scanner from.       | `sysdig/vuln-runtime-scanner`                                |
| `nodeAnalyzer.runtimeScanner.image.tag`                      | The image tag to pull the Runtime Scanner.                   | `1.6.6`                                                      |
| `nodeAnalyzer.runtimeScanner.image.digest`                   | The image digest to pull.                                    | ` `                                                          |
| `nodeAnalyzer.runtimeScanner.image.pullPolicy`               | The image pull policy for the Runtime Scanner.               | `IfNotPresent`                                               |
| `nodeAnalyzer.runtimeScanner.resources.requests.cpu`         | Runtime Scanner CPU requests per node.                       | `250m`                                                       |
| `nodeAnalyzer.runtimeScanner.resources.requests.memory`      | Runtime Scanner memory requests per node.                    | `512Mi`                                                      |
| `nodeAnalyzer.runtimeScanner.resources.requests.ephemeral-storage` | Runtime Scanner Storage requests per node.                   | `2Gi`                                                        |
| `nodeAnalyzer.runtimeScanner.resources.limits.cpu`           | Runtime Scanner CPU limit per node.                          | `500m`                                                       |
| `nodeAnalyzer.runtimeScanner.resources.limits.memory`        | Runtime Scanner memory limit per node.                       | `1536Mi`                                                     |
| `nodeAnalyzer.runtimeScanner.resources.limits.ephemeral-storage` | Runtime Scanner storage limit per node.                      | `4Gi`                                                        |
| `nodeAnalyzer.runtimeScanner.env`                            | The extra environment variables that will be passed onto pods. | `{}`                                                         |
| `nodeAnalyzer.runtimeScanner.settings.eveEnabled`            | Enables Sysdig Eve.                                          | `false`                                                      |
| `nodeAnalyzer.runtimeScanner.eveConnector.image.repository`  | The image repository to pull the Eve Connector from.         | `sysdig/eveclient-api`                                       |
| `nodeAnalyzer.runtimeScanner.eveConnector.image.tag`         | The image tag to pull the Eve Connector.                     | `1.1.0`                                                      |
| `nodeAnalyzer.runtimeScanner.eveConnector.deploy`            | Enables Sysdig Eve Connector for third-party integrations.   | `false`                                                      |
| `nodeAnalyzer.runtimeScanner.eveConnector.resources.requests.cpu` | Eve Connector CPU requests per node.                         | `100m`                                                       |
| `nodeAnalyzer.runtimeScanner.eveConnector.resources.requests.memory` | Eve Connector Memory requests per node.                      | `128Mi`                                                      |
| `nodeAnalyzer.runtimeScanner.eveConnector.resources.limits.cpu` | Eve Connector CPU limits per node.                           | `1000m`                                                      |
| `nodeAnalyzer.runtimeScanner.eveConnector.resources.limits.memory` | Eve Connector memory limits per node.                        | `512Mi`                                                      |
| `nodeAnalyzer.runtimeScanner.eveConnector.settings.replicas` | Eve Connector deployment replicas.                           | `1`                                                          |
| `nodeAnalyzer.kspmAnalyzer.debug`                            | Set to `true` to show KSPM node analyzer debug logging; useful for troubleshooting. | `false`                                                      |
| `nodeAnalyzer.kspmAnalyzer.image.repository`                 | The image repository to pull the  KSPM node analyzer from.   | `sysdig/kspm-analyzer`                                       |
| `nodeAnalyzer.kspmAnalyzer.image.tag`                        | The image tag to pull the  KSPM node analyzer.               | `1.5.0`                                                      |
| `nodeAnalyzer.kspmAnalyzer.image.digest`                     | The image digest to pull.                                    | ` `                                                          |
| `nodeAnalyzer.kspmAnalyzer.image.pullPolicy`                 | The image pull policy for the  KSPM node analyzer.           | `IfNotPresent`                                               |
| `nodeAnalyzer.kspmAnalyzer.resources.requests.cpu`           | KSPM node analyzer CPU requests per node.                    | `150m`                                                       |
| `nodeAnalyzer.kspmAnalyzer.resources.requests.memory`        | KSPM node analyzer Memory requests per node.                 | `256Mi`                                                      |
| `nodeAnalyzer.kspmAnalyzer.resources.limits.cpu`             | KSPM node analyzer CPU limits per node.                      | `500m`                                                       |
| `nodeAnalyzer.kspmAnalyzer.resources.limits.memory`          | KSPM node analyzer memory limits per node.                   | `1536Mi`                                                     |
| `nodeAnalyzer.kspmAnalyzer.env`                              | The extra environment variables that will be passed onto pods. | `{}`                                                         |
| `kspmCollector.image.tag`                                    | The image tag to pull the  KSPM collector.                   | `1.5.0`                                                      |
| `kspmCollector.image.digest`                                 | The image digest to pull.                                    | ` `                                                          |
| `kspmCollector.image.pullPolicy`                             | The image pull policy for the  KSPM collector.               | `IfNotPresent`                                               |
| `kspmCollector.settings.replicas`                            | KSPM collector deployment replicas.                          | `1`                                                          |
| `kspmCollector.settings.namespaces.included`                 | The namespaces to include in the KSPM collector scans, when empty scans all. | ``                                                           |
| `kspmCollector.settings.namespaces.excluded`                 | The namespaces to exclude in the KSPM collector scans.       | ``                                                           |
| `kspmCollector.settings.workloads.included`                  | The workloads to include in the KSPM collector scans, when empty scans all. | ``                                                           |
| `kspmCollector.settings.workloads.excluded`                  | The workloads to exclude in the KSPM collector scans, when empty scans all. | ``                                                           |
| `kspmCollector.settings.healthIntervalMin`                   | The interval in minutes for KSPM collector health status messages. | `5`                                                          |
| `kspmCollector.resources.requests.cpu`                       | KSPM collector CPU requests per node.                        | `150m`                                                       |
| `kspmCollector.resources.requests.memory`                    | KSPM collector memory requests per node.                     | `256Mi`                                                      |
| `kspmCollector.resources.limits.cpu`                         | KSPM collector CPU limits per node.                          | `500m`                                                       |
| `kspmCollector.resources.limits.memory`                      | KSPM collector memory limits per node.                       | `1536Mi`                                                     |
| `kspmCollector.env`                                          | The extra environment variables that will be passed onto pods. | `{}`                                                         |
| `nodeAnalyzer.nodeSelector`                                  | Node Selector.                                               | `{}`                                                         |
| `nodeAnalyzer.affinity`                                      | Node affinities.                                             | `schedule on amd64 and linux`                                |

### Node Image Analyzer Parameters (Deprecated by `nodeAnalyzer`)

| Parameter                                         | Description                                                  | Default                       |
| ------------------------------------------------- | ------------------------------------------------------------ | ----------------------------- |
| `nodeImageAnalyzer.deploy`                        | Deploys the Node Image Analyzer. See [Scan the Running Images](https://docs.sysdig.com/en/scan-running-images.html). | `false`                       |
| `nodeImageAnalyzer.settings.dockerSocketPath`     | The Docker socket path.                                      |                               |
| `nodeImageAnalyzer.settings.criSocketPath`        | The socket path to a CRI compatible runtime, such as CRI-O.  |                               |
| `nodeImageAnalyzer.settings.containerdSocketPath` | The socket path to a CRI-Containerd daemon.                  |                               |
| `nodeImageAnalyzer.settings.collectorEndpoint`    | The endpoint to the Scanning Analysis collector.             |                               |
| `nodeImageAnalyzer.settings.sslVerifyCertificate` | Set to `false` to allow insecure connections to the Sysdig backend, such as on-prem deployment. |                               |
| `nodeImageAnalyzer.settings.debug`                | Set to `true` to show debug logging; useful for troubleshooting. |                               |
| `nodeImageAnalyzer.settings.httpProxy`            | Th proxy configuration variables.                            |                               |
| `nodeImageAnalyzer.settings.httpsProxy`           | The secure proxy configuration variables.                    |                               |
| `nodeImageAnalyzer.settings.noProxy`              | The no proxy configuration variables.                        |                               |
| `nodeImageAnalyzer.image.repository`              | The image repository to pull the Node Image Analyzer from.   | `sysdig/node-image-analyzer`  |
| `nodeImageAnalyzer.image.tag`                     | The image tag to pull the Node Image Analyzer.               | `0.1.30`                      |
| `nodeImageAnalyzer.imagedigest`                   | The image digest to pull.                                    | ` `                           |
| `nodeImageAnalyzer.image.pullPolicy`              | The Image pull policy for the Node Image Analyzer.           | `IfNotPresent`                |
| `nodeImageAnalyzer.image.pullSecrets`             | Image pull secrets for the Node Image Analyzer.              | `nil`                         |
| `nodeImageAnalyzer.resources.requests.cpu`        | Node Image Analyzer CPU requests per node.                   | `250m`                        |
| `nodeImageAnalyzer.resources.requests.memory`     | Node Image Analyzer Memory requests per node.                | `512Mi`                       |
| `nodeImageAnalyzer.resources.limits.cpu`          | Node Image Analyzer CPU limit per node.                      | `500m`                        |
| `nodeImageAnalyzer.resources.limits.memory`       | Node Image Analyzer Memory limit per node.                   | `1024Mi`                      |
| `nodeImageAnalyzer.extraVolumes.volumes`          | Additional volumes to mount in the Node Image Analyzer. For example,  docker socket. | `[]`                          |
| `nodeImageAnalyzer.extraVolumes.mounts`           | The mount points for additional volumes.                     | `[]`                          |
| `nodeImageAnalyzer.priorityClassName`             | Priority class name variable.                                |                               |
| `nodeImageAnalyzer.affinity`                      | Node affinities.                                             | `schedule on amd64 and linux` |

## Additional Configuration

## Install on GKE Autopilot

Autopilot is an operation mode for creating and managing clusters in GKE. With Autopilot, Google configures and manages the underlying node infrastructure for you.

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

Therefore, on GKE Autopilot clusters:

 - The NodeAnalyzed is not deployed.
 - The ebpf is enabled and the etcVolume is not mounted.
 - The daemonset affinity is set to `null`.
 - The daemonset annotation is set to enable the Agent to run on autopilot (required from GKE).


## Install Agent Components in On-Prem

Sysdig agent can be deployed in your on-premise infrastructure.

You can use the Helm chart by enabling it as follows:

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

## Adding Custom AppChecks

[Application checks](https://docs.sysdig.com/en/docs/sysdig-monitor/integrations/working-with-integrations/legacy-integrations/legacyintegrate-applications-default-app-checks/) are integrations that allow the Sysdig agent to collect metrics exposed by specific services. Sysdig has several built-in AppChecks, but sometimes you might need to create your own.

Your AppChecks can deployed with the Helm chart by embedding them in the values YAML file:

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

The first section adds the AppCheck in a Kubernetes ConfigMap and makes it available within the Sysdig agent container.
The second one configures it on the `dragent.yaml` file.

Once the values YAML file is ready, deploy the chart:

```bash
$ helm install --namespace sysdig-agent sysdig-agent -f values.yaml sysdig/sysdig
```

### Automate Generating the `custom-app-checks.yaml` File

Sometimes editing and maintaining YAML files can be a bit cumbersome and error-prone, so you can use a script for
automating this process and make your life easier.

If you have custom AppChecks for a number of services like Redis, MongoDB and Traefik and a `values.yaml` with  your configuration as follows:

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

Then deploy the chart:

```bash
$ helm install --namespace sysdig-agent sysdig-agent -f custom-app-checks.yaml -f values.yaml sysdig/sysdig
```

### Configure `promscrape`

Promscrape is the component that collects Prometheus metrics from the sysdig agent. This component is created based on Prometheus and accepts the same configuration format.

This `prometheus.yaml` file can contain relabelling rules and filters to remove certain metrics or add some configurations to the
collection. An example is:

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

`sysdig_sd_configs` allows to select the targets obtained by Sysdig Agent to apply the rules in the job.
See [how to configure filtering in sysdig documentation](https://docs.sysdig.com/en/filtering-prometheus-metrics.html).

### Add Additional Volumes

In order to pass new ConfigMaps or secrets used for authentication, such as  for Prometheus endpoints, you can mount
additional secrets, ConfigMaps, or volumes. For example :

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

### Add Additional Secrets

You can create additional secrets, such as for Prometheus basic authentication. The values are opaque type secrets and must be in base64 encoded. For example:

```yaml
extraSecrets:
  - name: sysdig-new-secret
    data:
      sysdig-new-password-key1: bXlwYXNzd29yZA==
      sysdig-new-password-key2: bXlwYXNzd29yZA==
```

## Use Private Docker Image Registry

If you pull the Sysdig Agent image from a private registry that requires authentication, you need to configure additional parameters.

1. Create a secret that stores the registry credentials:

   ```YAML
   kubectl create secret docker-registry SECRET_NAME \
     --docker-server=SERVER \
     --docker-username=USERNAME \
     --docker-password=TOKEN \
     --docker-email=EMAIL
   ```

2. Point to this secret in the values YAML file:

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

3. set the accessKey value:

   ```console
   helm install --namespace sysdig-agent sysdig-agent -f values.yaml sysdig/sysdig
   ```

See [Kubernetes Documentation](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/) for more information.

## Resource Profiles

For ease of use, some predefined resource profiles are available:

### Small

```yaml
requests:
  cpu: 1000m
  memory: 1024Mi
limits:
  cpu: 1000m
  memory: 1024Mi
```

### Medium

```yaml
requests:
  cpu: 3000m
  memory: 3072Mi
limits:
  cpu: 3000m
  memory: 3072Mi
```

### Large

```yaml
requests:
  cpu: 5000m
  memory: 6144Mi
limits:
  cpu: 5000m
  memory: 6144Mi
```

### Custom

To set your own resource requests and limits to any values other than the ones defined above, you need to set `resourceProfile == custom` and then add specific values for `resources.*` to match your requirements by setting the appropriate values in the `resources` object.

See [Tuning Sysdig Agent](https://docs.sysdig.com/en/tuning-sysdig-agent.html) for more info.

## Upgrade Sysdig Agent Configuration

If you need to upgrade the agent configuration file,

1. Modify the YAML file if you are increasing the metrics limit scraping Prometheus metrics:

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

2. upgrade the chart:

   ```console
   helm upgrade --namespace sysdig-agent sysdig-agent -f values.yaml sysdig/sysdig
   ```

## Upgrade to the Last Version

1. Ensure that you have the latest chart version:

   ```console
   helm repo update
   ```

2. Do one of the following:

   - If you deployed the chart with a `values.yaml` file, modify (or add if it's missing) the `image.tag`
     field and execute:

     ```console
     helm upgrade --namespace sysdig-agent sysdig-agent -f values.yaml sysdig/sysdig
     ```

   - If you deployed the chart by setting the values as CLI parameters:

     ```console
     helm install \
         --namespace sysdig-agent \
         sysdig-agent \
         --set sysdig.accessKey=xxxx \
         --set ebpf.enabled=true \
         sysdig/sysdig
     ```

     You will need to execute:

     ```console
     helm upgrade \
         --namespace sysdig-agent \
         sysdig-agent \
         --set sysdig.accessKey=xxxx \
         --set ebpf.enabled=true \
         --set image.tag=<last_version> \
         sysdig/sysdig
     ```
