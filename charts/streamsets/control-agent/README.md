# StreamSets Control Agent

The [StreamSets](https://streamsets.com) control agent manages StreamSets Control Hub deployments.

## Introduction

This chart supports both RBAC and non-RBAC enabled clusters. It has no dependencies.

## Installing the Chart

First, add the streamsets stable repository to helm.

```bash
helm repo add streamsets https://streamsets.github.io/helm-charts/stable
```

To install the chart with the release name `my-release` into the namespace `streamsets`:

```bash
helm install streamsets/control-agent --name my-release --namespace streamsets
```

## Configuration

The following tables lists the configurable parameters of the chart and their default values.

| Parameter                       | Description                                                          | Default                                   |
| ------------------------------- | -------------------------------------------------------------------- | ----------------------------------------- |
| `image.repository`              | Control Agent image name                                             | `streamsets/control-agent`                |
| `image.tag`                     | The version of the official image to use                             | `3.0.0`                                   |
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
