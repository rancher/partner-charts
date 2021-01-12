# Streamsets

[Streamsets](https://www.streamsets.com/) is a data engineering platform. This chart adds the Streamsets Agent to all nodes in your cluster. The agent communicates with Control Hub to automatically provision Data Collector containers in the Kubernetes cluster in which it runs [Streamsets Control Hub](https://streamsets.com/documentation/controlhub/latest/help/controlhub/UserGuide/GettingStarted/DPM.html#concept_l45_qwf_xw. For more information about deploying Streamsets on Kubernetes, please refer to the [Streamsets documentation website](https://streamsets.com/documentation/controlhub/latest/help/controlhub/UserGuide/DataCollectorsProvisioned/Provisioned.html#concept_jsd_v24_lbb).

Streamsets [Docker Image](https://hub.docker.com/r/streamsets/datacollector).

## Prerequisites

The minimum provisioning requirements depend on whether or not you need to provision Data Collectors enabled for Kerberos authentication:

# Not Enabled for Kerberos Authentication
Any version of Docker
Kubernetes version 1.6+ or Openshift 3.6+
Helm 2.x or Helm 3.x

# Enabled for Kerberos Authentication
Any version of Docker
Kubernetes version 1.8+ or OpenShift 3.9+
Helm 2.x or Helm 3.x

## Quick start

First, add the streamsets stable repository to helm.

```bash
helm repo add streamsets https://streamsets.github.io/helm-charts/stable
```

### Installing the Streamsets Chart

To install the chart with the release name `<RELEASE_NAME>`, retrieve your Streamsets Control Hub Authentication Token from your [Agent Installation Instructions](https://streamsets.com/documentation/controlhub/latest/help/controlhub/UserGuide/DataCollectorsProvisioned/ProvisionSteps.html#concept_wl2_snb_12b) and run:

## Configuration

The following tables lists the configurable parameters of the chart and their default values.

| Parameter                       | Description                                                          | Default                                   |
| ------------------------------- | -------------------------------------------------------------------- | ----------------------------------------- |
| `image.repository`              | Control Agent image name                                             | `streamsets/control-agent`                |
| `image.tag`                     | The version of the official image to use                             | `3.20.0`                                   |
| `image.pullPolicy`              | Pull policy for the image                                            | `IfNotPresent`                            |
| `streamsets.orgId`              | This is the part of your SCH/DPM username after the `@`              | None       (Required)                     |
| `streamsets.api.url`            | The URL for the SCH/DPM instance to connect to                       | `https://cloud.streamsets.com`            |
| `streamsets.api.token`          | Agent auth token from the SCH/DPM REST API or UI                     | None (Required)                           |
| `rbac.enabled`                  | Creates req'd ServiceAccount and Role on RBAC-enabled cluster        | `true`                                    |
| `resources`                     | Resource request for the pod                                         | None                                      |
| `nodeSelector`                  | Node Selector to apply to the deployment                             | None                                      |

`streamsets.api.token` and `streamsets.orgId` are required values

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example:

```bash
helm install streamsets/control-agent --set streamsets.api.token="my_api_token" --set streamsets.orgId="my_org"
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while
installing the chart. For example:

```bash
helm install streamsets/control-agent --values values.yaml
```
