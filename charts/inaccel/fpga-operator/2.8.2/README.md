# InAccel FPGA Operator

Simplifying FPGA management in Kubernetes

## Introduction

[InAccel FPGA Operator](https://artifacthub.io/packages/helm/inaccel/fpga-operator)
is a cloud-native method to standardize and automate the deployment of all the
necessary components for provisioning FPGA-enabled Kubernetes systems. FPGA
Operator delivers a universal accelerator orchestration and monitoring layer, to
automate scalability and lifecycle management of containerized FPGA applications
on any Kubernetes cluster.

The FPGA operator allows cluster admins to manage their remote FPGA-powered
servers the same way they manage CPU-based systems, but also regular users to
target particular FPGA types and explicitly consume FPGA resources in their
workloads. This makes it easy to bring up a fleet of remote systems and run
accelerated applications without additional technical expertise on the ground.

### Audience and Use-Cases

The FPGA Operator allows administrators of Kubernetes clusters to manage FPGA
nodes just like CPU nodes in the cluster. Instead of provisioning a special OS
image for FPGA nodes, administrators can rely on a standard OS image for both
CPU and FPGA nodes and then rely on the FPGA Operator to provision the required
software components for FPGAs.

Note that the FPGA Operator is specifically useful for scenarios where the
Kubernetes cluster needs to scale quickly - for example provisioning additional
FPGA nodes on the cloud and managing the lifecycle of the underlying software
components.

## Installing the Chart

To install the chart with the release name `my-fpga-operator`:

```console
$ helm repo add inaccel https://setup.inaccel.com/helm
$ helm install my-fpga-operator inaccel/fpga-operator
```

These commands deploy InAccel FPGA Operator on the Kubernetes cluster in the
default configuration.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-fpga-operator` deployment:

```console
$ helm uninstall my-fpga-operator
```

The command removes all the Kubernetes components associated with the chart and
deletes the release.

## Parameters

The following table lists the configurable parameters of the InAccel FPGA
Operator chart and their default values.

| Parameter                | Description                                             | Default            |
| ------------------------ | ------------------------------------------------------- | ------------------ |
| `coral.httpsProxy`       | Sets HTTPS_PROXY environment variable in the container. |                    |
| `coral.image`            | Container image name.                                   | `inaccel/coral`    |
| `coral.logLevel`         | Sets LOG_LEVEL environment variable in the container.   | `info`             |
| `coral.port`             | Number of port to expose on the host.                   |                    |
| `coral.pullPolicy`       | Image pull policy.                                      | `Always`           |
| `coral.resources`        | Compute resources required by this container.           |                    |
| `coral.tag`              | Release version.                                        | *APP VERSION*      |
| `daemon.debug`           | Argument --debug to the entrypoint.                     | `false`            |
| `daemon.image`           | Container image name.                                   | `inaccel/daemon`   |
| `daemon.pullPolicy`      | Image pull policy.                                      |                    |
| `daemon.resources`       | Compute resources required by this container.           |                    |
| `daemon.tag`             | Release version.                                        | `latest`           |
| `driver.enabled`         | Indicates whether driver should be enabled.             | `true`             |
| `driver.image`           | Container image name.                                   | `inaccel/driver`   |
| `driver.pullPolicy`      | Image pull policy.                                      |                    |
| `driver.tag`             | Release version.                                        | `latest`           |
| `fpga-discovery.enabled` | Dependency condition.                                   | `true`             |
| `kubelet`                | Directory path for managing kubelet files.              | `/var/lib/kubelet` |
| `license`                | String value of the secret license key.                 |                    |
| `mkrt.image`             | Container image name.                                   | `inaccel/mkrt`     |
| `mkrt.pullPolicy`        | Image pull policy.                                      |                    |
| `mkrt.tag`               | Release version.                                        | `latest`           |
| `monitor.image`          | Container image name.                                   | `inaccel/monitor`  |
| `monitor.port`           | Number of port to expose on the host.                   |                    |
| `monitor.pullPolicy`     | Image pull policy.                                      | `Always`           |
| `monitor.resources`      | Compute resources required by this container.           |                    |
| `monitor.tag`            | Release version.                                        | *APP VERSION*      |
| `reef.debug`             | Argument --debug to the entrypoint.                     | `false`            |
| `reef.image`             | Container image name.                                   | `inaccel/reef`     |
| `reef.pullPolicy`        | Image pull policy.                                      |                    |
| `reef.resources`         | Compute resources required by this container.           |                    |
| `reef.tag`               | Release version.                                        | `latest`           |
| `replicas`               | Number of desired pods.                                 |                    |
| `root.config`            | Host-specific system configuration.                     | `/etc/inaccel`     |
| `root.state`             | Variable state information.                             | `/var/lib/inaccel` |
| `tests.vadd.image`       | Container image name.                                   | `inaccel/vadd`     |
| `tests.vadd.platforms`   | FPGA platforms to test.                                 |                    |
| `tests.vadd.pullPolicy`  | Image pull policy.                                      |                    |
| `tests.vadd.tag`         | Release version.                                        | `latest`           |

Specify each parameter using the `--set key=value[,key=value]` argument to
`helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be
provided while installing the chart. For example,

```console
$ helm install my-fpga-operator -f values.yaml inaccel/fpga-operator
```

> **Tip**: You can use the default `values.yaml`
