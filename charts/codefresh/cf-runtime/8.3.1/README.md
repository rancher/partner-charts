## Codefresh Runner

![Version: 8.3.1](https://img.shields.io/badge/Version-8.3.1-informational?style=flat-square)

Helm chart for deploying [Codefresh Runner](https://codefresh.io/docs/docs/installation/codefresh-runner/) to Kubernetes.

## Table of Content

- [Prerequisites](#prerequisites)
- [Get Chart Info](#get-chart-info)
- [Install Chart](#install-chart)
- [Chart Configuration](#chart-configuration)
- [Upgrade Chart](#upgrade-chart)
  - [⚠️ Known issues](#⚠️-known-issues)
  - [To 2.x](#to-2-x)
  - [To 3.x](#to-3-x)
  - [To 4.x](#to-4-x)
  - [To 5.x](#to-5-x)
  - [To 6.x](#to-6-x)
  - [To 7.x](#to-7-x)
  - [To 7.9.x](#to-7-9-x)
  - [To 8.x](#to-8-x)
  - [To 8.2.x](#to-8-2-x)
- [Architecture](#architecture)
- [Configuration](#configuration)
  - [EBS backend volume configuration in AWS](#ebs-backend-volume-configuration)
  - [Azure Disks backend volume configuration in AKS](#azure-disks-backend-volume-configuration)
  - [GCE Disks backend volume configuration in GKE](#gce-disks-backend-volume-configuration-in-gke)
  - [Custom volume mounts](#custom-volume-mounts)
  - [Custom global environment variables](#custom-global-environment-variables)
  - [Volume reuse policy](#volume-reuse-policy)
  - [Volume cleaners](#volume-cleaners)
  - [Rootless DinD](#rootless-dind)
  - [ARM](#arm)
  - [Openshift](#openshift)
  - [On-premise](#on-premise)
- [Migrating from CLI-based installation to Helm chart](#migrating-from-cli-based-installation-to-helm-chart)

## Prerequisites

- Kubernetes **1.19+**
- Helm **3.8.0+**

⚠️⚠️⚠️
> Since version 6.2.x chart is pushed **only** to OCI registry at `oci://quay.io/codefresh/cf-runtime`

> Versions prior to 6.2.x are still available in ChartMuseum at `http://chartmuseum.codefresh.io/cf-runtime`

## Get Chart Info

```console
helm show all oci://quay.io/codefresh/cf-runtime
```
See [Use OCI-based registries](https://helm.sh/docs/topics/registries/)

## Install Chart

**Important:** only helm3 is supported

- Specify the following mandatory values

`values.yaml`
```yaml
# -- Global parameters
# @default -- See below
global:
  # -- User token in plain text (required if `global.codefreshTokenSecretKeyRef` is omitted!)
  # Ref: https://g.codefresh.io/user/settings (see API Keys)
  # Minimal API key scopes: Runner-Installation(read+write), Agent(read+write), Agents(read+write)
  codefreshToken: ""
  # -- User token that references an existing secret containing API key (required if `global.codefreshToken` is omitted!)
  codefreshTokenSecretKeyRef: {}
  # E.g.
  # codefreshTokenSecretKeyRef:
  #   name: my-codefresh-api-token
  #   key: codefresh-api-token

  # -- Account ID (required!)
  # Can be obtained here https://g.codefresh.io/2.0/account-settings/account-information
  accountId: ""

  # -- K8s context name (required!)
  context: ""
  # E.g.
  # context: prod-ue1-runtime-1

  # -- Agent Name (optional!)
  # If omitted, the following format will be used '{{ .Values.global.context }}_{{ .Release.Namespace }}'
  agentName: ""
  # E.g.
  # agentName: prod-ue1-runtime-1

  # -- Runtime name (optional!)
  # If omitted, the following format will be used '{{ .Values.global.context }}/{{ .Release.Namespace }}'
  runtimeName: ""
  # E.g.
  # runtimeName: prod-ue1-runtime-1/namespace
```

- Install chart

```console
helm upgrade --install cf-runtime oci://quay.io/codefresh/cf-runtime -f values.yaml --create-namespace --namespace codefresh
```

## Chart Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing).

## Upgrade Chart

### ⚠️ Known issues

Please check the following known issues before upgrading the chart:

- Charts **7.1.1–7.4.3** have a bug because of which the following feature does not work: [“Secret Store — Kubernetes-Runtime Secret”](https://codefresh.io/docs/docs/integrations/secret-storage/#secret-store-setup-for-codefresh-runner-installation).

### To 2.x

This major release renames and deprecated several values in the chart. Most of the workload templates have been refactored.

Affected values:
- `dockerRegistry` is deprecated. Replaced with `global.imageRegistry`
- `re` is renamed to `runtime`
- `storage.localVolumeMonitor` is replaced with `volumeProvisioner.dind-lv-monitor`
- `volumeProvisioner.volume-cleanup` is replaced with `volumeProvisioner.dind-volume-cleanup`
- `image` values structure has been updated. Split to `image.registry` `image.repository` `image.tag`
- pod's `annotations` is renamed to `podAnnotations`

### To 3.x

⚠️⚠️⚠️
### READ this before the upgrade!

This major release adds [runtime-environment](https://codefresh.io/docs/docs/installation/codefresh-runner/#runtime-environment-specification) spec into chart templates.
That means it is possible to set parametes for `dind` and `engine` pods via [values.yaml](./values.yaml).

**If you had any overrides (i.e. tolerations/nodeSelector/environment variables/etc) added in runtime spec via [codefresh CLI](https://codefresh-io.github.io/cli/) (for example, you did use [get](https://codefresh-io.github.io/cli/runtime-environments/get-runtime-environments/) and [patch](https://codefresh-io.github.io/cli/runtime-environments/apply-runtime-environments/) commands to modify the runtime-environment), you MUST add these into chart's [values.yaml](./values.yaml) for `.Values.runtime.dind` or(and) .`Values.runtime.engine`**

**For backward compatibility, you can disable updating runtime-environment spec via** `.Values.runtime.patch.enabled=false`

Affected values:
- added **mandatory** `global.codefreshToken`/`global.codefreshTokenSecretKeyRef` **You must specify it before the upgrade!**
- `runtime.engine` is added
- `runtime.dind` is added
- `global.existingAgentToken` is replaced with `global.agentTokenSecretKeyRef`
- `global.existingDindCertsSecret` is replaced with `global.dindCertsSecretRef`

### To 4.x

This major release adds **agentless inCluster** runtime mode (relevant only for [Codefresh On-Premises](#on-premise) users)

Affected values:
- `runtime.agent` / `runtime.inCluster` / `runtime.accounts` / `runtime.description` are added

### To 5.x

This major release converts `.runtime.dind.pvcs` from **list** to **dict**

> 4.x chart's values example:
```yaml
runtime:
  dind:
    pvcs:
      - name: dind
        storageClassName: my-storage-class-name
        volumeSize: 32Gi
        reuseVolumeSelector: 'codefresh-app,io.codefresh.accountName'
        reuseVolumeSortOrder: pipeline_id
```

> 5.x chart's values example:
```yaml
runtime:
  dind:
    pvcs:
      dind:
        name: dind
        storageClassName: my-storage-class-name
        volumeSize: 32Gi
        reuseVolumeSelector: 'codefresh-app,io.codefresh.accountName'
        reuseVolumeSortOrder: pipeline_id
```

Affected values:
- `.runtime.dind.pvcs` converted from **list** to **dict**

### To 6.x

⚠️⚠️⚠️
### READ this before the upgrade!

This major release deprecates previously required `codefresh runner init --generate-helm-values-file`.

Affected values:
- **Replaced** `.monitor.clusterId` with `.global.context` as **mandatory** value!
- **Deprecated** `.global.agentToken` / `.global.agentTokenSecretKeyRef`
- **Removed** `.global.agentId`
- **Removed** `.global.keys` / `.global.dindCertsSecretRef`
- **Removed** `.global.existingAgentToken` / `existingDindCertsSecret`
- **Removed** `.monitor.clusterId` / `.monitor.token` / `.monitor.existingMonitorToken`

#### Migrate the Helm chart from version 5.x to 6.x

Given this is the legacy `generated_values.yaml` values:

> legacy `generated_values.yaml`
```yaml
{
    "appProxy": {
        "enabled": false,
    },
    "monitor": {
        "enabled": false,
        "clusterId": "my-cluster-name",
        "token": "1234567890"
    },
    "global": {
        "namespace": "namespace",
        "codefreshHost": "https://g.codefresh.io",
        "agentToken": "0987654321",
        "agentId": "agent-id-here",
        "agentName": "my-cluster-name_my-namespace",
        "accountId": "my-account-id",
        "runtimeName": "my-cluster-name/my-namespace",
        "codefreshToken": "1234567890",
        "keys": {
            "key": "-----BEGIN RSA PRIVATE KEY-----...",
            "csr": "-----BEGIN CERTIFICATE REQUEST-----...",
            "ca": "-----BEGIN CERTIFICATE-----...",
            "serverCert": "-----BEGIN CERTIFICATE-----..."
        }
    }
}
```

Update `values.yaml` for new chart version:

> For existing installation for backward compatibility `.Values.global.agentToken/agentTokenSecretKeyRef` **must be provided!** For installation from scratch this value is no longer required.

> updated `values.yaml`
```yaml
global:
  codefreshToken: "1234567890"
  accountId: "my-account-id"
  context: "my-cluster-name"
  agentToken: "0987654321"  # MANDATORY when migrating from < 6.x chart version !
  agentName: "my-cluster-name_my-namespace" # optional
  runtimeName: "my-cluster-name/my-namespace" # optional
```

> **Note!** Though it's still possible to update runtime-environment via [get](https://codefresh-io.github.io/cli/runtime-environments/get-runtime-environments/) and [patch](https://codefresh-io.github.io/cli/runtime-environments/apply-runtime-environments/) commands, it's recommended to enable sidecar container to pull runtime spec from Codefresh API to detect any drift in configuration.

```yaml
runner:
  # -- Sidecar container
  # Reconciles runtime spec from Codefresh API for drift detection
  sidecar:
    enabled: true
```

### To 7.x

⚠️⚠️⚠️ **BREAKING CHANGE** ⚠️⚠️⚠️

7.0.0 release adds image digests to all images in default values, for example:

```yaml
runtime:
  engine:
    image:
      registry: quay.io
      repository: codefresh/engine
      tag: 1.174.15
      pullPolicy: IfNotPresent
      digest: sha256:d547c2044c1488e911ff726462cc417adf2dda731cafd736493c4de4eb9e357b
```

Which means any overrides for tags won't be used and underlying Kubernetes runtime will pull the image by the digest.

See [Pull an image by digest (immutable identifier)](https://docs.docker.com/reference/cli/docker/image/pull/#pull-an-image-by-digest-immutable-identifier)

### To 7.9.x

We changed the type of `.Values.runtime.engine.runtimeImages` from key-value maps to a list of maps with `registry`, `repository`, `tag` and `digest` fields.

If you used this value, please migrate like below:

```yaml
# before
runtime:
  engine:
    runtimeImages:
      COMPOSE_IMAGE: quay.io/codefresh/compose:v2.37.0-1.5.4@sha256:e74494370100678ccb1c1058e6ef3ddcf67b21fcd37da8b3482376c8282549ad

# after
runtime:
  engine:
    runtimeImages:
      compose:
        registry: quay.io
        repository: codefresh/compose
        tag: v2.37.0-1.5.4
        digest: sha256:e74494370100678ccb1c1058e6ef3ddcf67b21fcd37da8b3482376c8282549ad
```

### To 8.x

⚠️⚠️⚠️ **BREAKING CHANGE** ⚠️⚠️⚠️

Docker engine in `dind` component is upgraded to 28.x. The main change is that in this version the image manifest v2 schema 1 and "Docker Image v1" formats were deprecated in favor of the v2 schema 2 and OCI image spec formats. Read [the official Docker documentation](https://docs.docker.com/engine/deprecated/#pushing-and-pulling-with-image-manifest-v2-schema-1) for more details.

This means that any existing images in your pipelines that were created using these older formats will no longer be pulled after upgrade. **This may affect pipelines operation.**

To avoid operation disruption, you have to identify and convert such deprecated images to modern formats. Tutorial: [https://codefresh.io/docs/docs/kb/articles/upgrade-deprecated-docker-images/](https://codefresh.io/docs/docs/kb/articles/upgrade-deprecated-docker-images/)

### To 8.2.x

⚠️⚠️⚠️ **BREAKING CHANGE in metrics configuration** ⚠️⚠️⚠️

In this release, the `engine` component has migrated its metrics collection to OpenTelemetry, using the *push* model by default.

You can still switch to the *pull* model by setting the `OTEL_METRICS_EXPORTER=prometheus` environment variable for the `engine`. However, we recommend using the default configuration, as it is better suited for the short-lived nature of Classic Builds and provides more precise and complete metrics.

View [default chart values](https://artifacthub.io/packages/helm/codefresh-runner/cf-runtime?modal=values&path=runtime.engine.env) for more configuration options.

The `engine` metrics have also been redesigned to follow OpenTelemetry standards and to deliver more actionable insights. Full list of metrics: https://codefresh.io/docs/docs/installation/runner/classic-runtime-monitoring/

For a smooth transition, the previous Prometheus metrics are still available but are now disabled by default. **These legacy metrics will be removed in future releases.** If you need to temporarily retain the old metrics, add the following values to your chart configuration:

```yaml
runtime:
  engine:
    env:
      CF_TELEMETRY_PROMETHEUS_ENABLE: "false" # Disable new Prometheus metrics to avoid ports conflict and data duplication
      CF_TELEMETRY_OTEL_ENABLE: "false" # Disable new OTel metrics to avoid data duplication
      METRICS_PROMETHEUS_ENABLED: "true" # Enable old Prometheus metrics
```

## Architecture

[Codefresh Runner architecture](https://codefresh.io/docs/docs/installation/codefresh-runner/#codefresh-runner-architecture)

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing).

### EBS backend volume configuration

`dind-volume-provisioner` should have permissions to create/attach/detach/delete/get EBS volumes

Minimal IAM policy for `dind-volume-provisioner`

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AttachVolume",
        "ec2:CreateSnapshot",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:DeleteSnapshot",
        "ec2:DeleteTags",
        "ec2:DeleteVolume",
        "ec2:DescribeInstances",
        "ec2:DescribeSnapshots",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DetachVolume"
      ],
      "Resource": "*"
    }
  ]
}
```

There are three options:

1. Run `dind-volume-provisioner` pod on the node/node-group with IAM role

```yaml
storage:
  # -- Set backend volume type (`local`/`ebs`/`ebs-csi`/`gcedisk`/`azuredisk`)
  backend: ebs-csi

  ebs:
    availabilityZone: "us-east-1a"

volumeProvisioner:
  # -- Set node selector
  nodeSelector: {}
  # -- Set tolerations
  tolerations: []
```

2. Pass static credentials in `.Values.storage.ebs.accessKeyId/accessKeyIdSecretKeyRef` and `.Values.storage.ebs.secretAccessKey/secretAccessKeySecretKeyRef`

```yaml
storage:
  # -- Set backend volume type (`local`/`ebs`/`ebs-csi`/`gcedisk`/`azuredisk`)
  backend: ebs-csi

  ebs:
    availabilityZone: "us-east-1a"

    # -- Set AWS_ACCESS_KEY_ID for volume-provisioner (optional)
    accessKeyId: ""
    # -- Existing secret containing AWS_ACCESS_KEY_ID.
    accessKeyIdSecretKeyRef: {}
    # E.g.
    # accessKeyIdSecretKeyRef:
    #   name:
    #   key:

    # -- Set AWS_SECRET_ACCESS_KEY for volume-provisioner (optional)
    secretAccessKey: ""
    # -- Existing secret containing AWS_SECRET_ACCESS_KEY
    secretAccessKeySecretKeyRef: {}
    # E.g.
    # secretAccessKeySecretKeyRef:
    #   name:
    #   key:
```

3. Assign IAM role to `dind-volume-provisioner` service account

```yaml
storage:
  # -- Set backend volume type (`local`/`ebs`/`ebs-csi`/`gcedisk`/`azuredisk`)
  backend: ebs-csi

  ebs:
    availabilityZone: "us-east-1a"

volumeProvisioner:
  # -- Service Account parameters
  serviceAccount:
    # -- Create service account
    create: true
    # -- Additional service account annotations
    annotations:
      eks.amazonaws.com/role-arn: "arn:aws:iam::<ACCOUNT_ID>:role/<IAM_ROLE_NAME>"
```

### Custom volume mounts

You can add your own volumes and volume mounts in the runtime environment, so that all pipeline steps will have access to the same set of external files.

```yaml
runtime:
  dind:
    userVolumes:
      regctl-docker-registry:
        name: regctl-docker-registry
        secret:
          items:
            - key: .dockerconfigjson
              path: config.json
          secretName: regctl-docker-registry
          optional: true
    userVolumeMounts:
      regctl-docker-registry:
        name: regctl-docker-registry
        mountPath: /home/appuser/.docker/
        readOnly: true

```

### Azure Disks backend volume configuration

`dind-volume-provisioner` should have permissions to create/delete/get Azure Disks

Role definition for `dind-volume-provisioner`

`dind-volume-provisioner-role.json`
```json
{
  "Name": "CodefreshDindVolumeProvisioner",
  "Description": "Perform create/delete/get disks",
  "IsCustom": true,
  "Actions": [
      "Microsoft.Compute/disks/read",
      "Microsoft.Compute/disks/write",
      "Microsoft.Compute/disks/delete"

  ],
  "AssignableScopes": ["/subscriptions/<YOUR_SUBSCRIPTION_ID>"]
}
```

When creating an AKS cluster in Azure there is the option to use a [managed identity](https://learn.microsoft.com/en-us/azure/aks/use-managed-identity) that is assigned to the kubelet. This identity is assigned to the underlying node pool in the AKS cluster and can then be used by the dind-volume-provisioner.

```console
export ROLE_DEFINITIN_FILE=dind-volume-provisioner-role.json
export SUBSCRIPTION_ID=$(az account show --query "id" | xargs echo )
export RESOURCE_GROUP=<YOUR_RESOURCE_GROUP_NAME>
export AKS_NAME=<YOUR_AKS_NAME>
export LOCATION=$(az aks show -g $RESOURCE_GROUP -n $AKS_NAME --query location | xargs echo)
export NODES_RESOURCE_GROUP=MC_${RESOURCE_GROUP}_${AKS_NAME}_${LOCATION}
export NODE_SERVICE_PRINCIPAL=$(az aks show -g $RESOURCE_GROUP -n $AKS_NAME --query identityProfile.kubeletidentity.objectId | xargs echo)

az role definition create --role-definition @${ROLE_DEFINITIN_FILE}
az role assignment create --assignee $NODE_SERVICE_PRINCIPAL --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$NODES_RESOURCE_GROUP --role CodefreshDindVolumeProvisioner
```

Deploy Helm chart with the following values:

`values.yaml`
```yaml
volumeProvisioner:
  podSecurityContext:
    enabled: true
    runAsUser: 0
    runAsGroup: 0
    fsGroup: 0

storage:
  backend: azuredisk
  azuredisk:
    availabilityZone: northeurope-1 # replace with your zone
    resourceGroup: my-resource-group-name

  mountAzureJson: true

runtime:
  dind:
    nodeSelector:
      topology.kubernetes.io/zone: northeurope-1
```

### GCE Disks backend volume configuration in GKE

`dind-volume-provisioner` should have `ComputeEngine.StorageAdmin` permissions

There are three options:

1. Run `dind-volume-provisioner` pod on the node/node-group with IAM Service Account

```yaml
storage:
  # -- Set backend volume type (`local`/`ebs`/`ebs-csi`/`gcedisk`/`azuredisk`)
  backend: gcedisk

  gcedisk:
    # -- Set GCP volume backend type (`pd-ssd`/`pd-standard`)
    volumeType: "pd-standard"
    # -- Set GCP volume availability zone
    availabilityZone: "us-central1-c"

volumeProvisioner:
  # -- Set node selector
  nodeSelector: {}
  # -- Set tolerations
  tolerations: []

# -- Set runtime parameters
runtime:
  # -- Parameters for DinD (docker-in-docker) pod
  dind:
    # -- Set node selector.
    nodeSelector:
      topology.kubernetes.io/zone: us-central1-c
```

2. Pass static credentials in `.Values.storage.gcedisk.serviceAccountJson` (inline) or `.Values.storage.gcedisk.serviceAccountJsonSecretKeyRef` (from your own secret)

```yaml
storage:
  # -- Set backend volume type (`local`/`ebs`/`ebs-csi`/`gcedisk`/`azuredisk`)
  backend: gcedisk

  gcedisk:
    # -- Set GCP volume backend type (`pd-ssd`/`pd-standard`)
    volumeType: "`pd-standard"
    # -- Set GCP volume availability zone
    availabilityZone: "us-central1-c"
    # -- Set Google SA JSON key for volume-provisioner (optional)
    serviceAccountJson: |
        {
        "type": "service_account",
        "project_id": "...",
        "private_key_id": "...",
        "private_key": "...",
        "client_email": "...",
        "client_id": "...",
        "auth_uri": "...",
        "token_uri": "...",
        "auth_provider_x509_cert_url": "...",
        "client_x509_cert_url": "..."
        }
    # -- Existing secret containing containing Google SA JSON key for volume-provisioner (optional)
    serviceAccountJsonSecretKeyRef: {}
    # E.g.:
    # serviceAccountJsonSecretKeyRef:
    #   name: gce-service-account
    #   key: service-account.json

# -- Set runtime parameters
runtime:
  # -- Parameters for DinD (docker-in-docker) pod
  dind:
    # -- Set node selector.
    nodeSelector:
      topology.kubernetes.io/zone: us-central1-c
```

3. Assign IAM role to `dind-volume-provisioner` service account

```yaml
storage:
  # -- Set backend volume type (`local`/`ebs`/`ebs-csi`/`gcedisk`/`azuredisk`)
  backend: gcedisk

  gcedisk:
    # -- Set GCP volume backend type (`pd-ssd`/`pd-standard`)
    volumeType: "`pd-standard"
    # -- Set GCP volume availability zone
    availabilityZone: "us-central1-c"

volumeProvisioner:
  # -- Service Account parameters
  serviceAccount:
    # -- Create service account
    create: true
    # -- Additional service account annotations
    annotations:
      iam.gke.io/gcp-service-account: <GSA_NAME>@<PROJECT_ID>.iam.gserviceaccount.com

# -- Set runtime parameters
runtime:
  # -- Parameters for DinD (docker-in-docker) pod
  dind:
    # -- Set node selector.
    nodeSelector:
      topology.kubernetes.io/zone: us-central1-c
```

### Custom global environment variables

You can add your own environment variables to the runtime environment. All pipeline steps have access to the global variables.

```yaml
runtime:
  engine:
    userEnvVars:
    - name: GITHUB_TOKEN
      valueFrom:
        secretKeyRef:
          name: github-token
          key: token
```

### Volume reuse policy

Volume reuse behavior depends on the configuration for `reuseVolumeSelector` in the runtime environment spec.

```yaml
runtime:
  dind:
    pvcs:
      - name: dind
        ...
        reuseVolumeSelector: 'codefresh-app,io.codefresh.accountName'
        reuseVolumeSortOrder: pipeline_id
```

The following options are available:
- `reuseVolumeSelector: 'codefresh-app,io.codefresh.accountName'` - PV can be used by ANY pipeline in the specified account (default).
Benefit: Fewer PVs, resulting in lower costs. Since any PV can be used by any pipeline, the cluster needs to maintain/reserve fewer PVs in its PV pool for Codefresh.
Downside: Since the PV can be used by any pipeline, the PVs could have assets and info from different pipelines, reducing the probability of cache.

- `reuseVolumeSelector: 'codefresh-app,io.codefresh.accountName,project_id'` - PV can be used by ALL pipelines in your account, assigned to the same project.

- `reuseVolumeSelector: 'codefresh-app,io.codefresh.accountName,pipeline_id'` - PV can be used only by a single pipeline.
Benefit: More probability of cache without “spam” from other pipelines.
Downside: More PVs to maintain and therefore higher costs.

- `reuseVolumeSelector: 'codefresh-app,io.codefresh.accountName,pipeline_id,io.codefresh.branch_name'` - PV can be used only by single pipeline AND single branch.

- `reuseVolumeSelector: 'codefresh-app,io.codefresh.accountName,pipeline_id,trigger'` - PV can be used only by single pipeline AND single trigger.

### Volume cleaners

Codefresh pipelines require disk space for:
  * [Pipeline Shared Volume](https://codefresh.io/docs/docs/pipelines/introduction-to-codefresh-pipelines/#sharing-the-workspace-between-build-steps) (`/codefresh/volume`, implemented as [docker volume](https://docs.docker.com/storage/volumes/))
  * Docker containers, both running and stopped
  * Docker images and cached layers

Codefresh offers two options to manage disk space and prevent out-of-space errors:
* Use runtime cleaners on Docker images and volumes
* [Set the minimum disk space per pipeline build volume](https://codefresh.io/docs/docs/pipelines/pipelines/#set-minimum-disk-space-for-a-pipeline-build)

To improve performance by using Docker cache, Codefresh `volume-provisioner` can provision previously used disks with Docker images and pipeline volumes from previously run builds.

### Types of runtime volume cleaners

Docker images and volumes must be cleaned on a regular basis.

* [IN-DIND cleaner](https://github.com/codefresh-io/dind/tree/master/cleaner): Deletes extra Docker containers, volumes, and images in **DIND pod**.
* [External volume cleaner](https://github.com/codefresh-io/dind-volume-cleanup): Deletes unused **external** PVs (EBS, GCE/Azure disks).
* [Local volume cleaner](https://github.com/codefresh-io/dind-volume-utils/blob/master/local-volumes/lv-cleaner.sh): Deletes **local** volumes if node disk space is close to the threshold.

### IN-DIND cleaner

**Purpose:** Removes unneeded *docker containers, images, volumes* inside Kubernetes volume mounted on the DIND pod

**How it runs:** Inside each DIND pod as script

**Triggered by:** SIGTERM and also during the run when disk usage > 90% (configurable)

**Configured by:**  Environment Variables which can be set in Runtime Environment spec

**Configuration/Logic:** [README.md](https://github.com/codefresh-io/dind/tree/master/cleaner#readme)

Override `.Values.runtime.dind.env` if necessary (the following are **defaults**):

```yaml
runtime:
  dind:
    env:
      CLEAN_PERIOD_SECONDS: '21600' # launch clean if last clean was more than CLEAN_PERIOD_SECONDS seconds ago
      CLEAN_PERIOD_BUILDS: '5' # launch clean if last clean was more CLEAN_PERIOD_BUILDS builds since last build
      IMAGE_RETAIN_PERIOD: '14400' # do not delete docker images if they have events since current_timestamp - IMAGE_RETAIN_PERIOD
      VOLUMES_RETAIN_PERIOD: '14400' # do not delete docker volumes if they have events since current_timestamp - VOLUMES_RETAIN_PERIOD
      DISK_USAGE_THRESHOLD: '0.8' # launch clean based on current disk usage DISK_USAGE_THRESHOLD
      INODES_USAGE_THRESHOLD: '0.8' # launch clean based on current inodes usage INODES_USAGE_THRESHOLD
```

### External volumes cleaner

**Purpose:** Removes unused *kubernetes volumes and related backend volumes*

**How it runs:** Runs as `dind-volume-cleanup` CronJob. Installed in case the Runner uses non-local volumes `.Values.storage.backend != local`

**Triggered by:** CronJob every 10min (configurable)

**Configuration:**

Set `codefresh.io/volume-retention` for dinds' PVCs:

```yaml
runtime:
  dind:
    pvcs:
      dind:
        ...
        annotations:
          codefresh.io/volume-retention: 7d
```

Or override environment variables for `dind-volume-cleanup` cronjob:

```yaml
volumeProvisioner:
  dind-volume-cleanup:
    env:
      RETENTION_DAYS: 7   # clean volumes that were last used more than `RETENTION_DAYS` (default is 4) ago
```

### Local volumes cleaner

**Purpose:** Deletes local volumes when node disk space is close to the threshold

**How it runs:** Runs as `dind-lv-monitor` DaemonSet. Installed in case the Runner uses local volumes `.Values.storage.backend == local`

**Triggered by:** Disk space usage or inode usage that exceeds thresholds (configurable)

**Configuration:**

Override environment variables for `dind-lv-monitor` daemonset:

```yaml
volumeProvisioner:
  dind-lv-monitor:
    env:
      KB_USAGE_THRESHOLD: 60  # default 80 (percentage)
      INODE_USAGE_THRESHOLD: 60  # default 80
```

### Rootless DinD

DinD pod runs a `priviliged` container with **rootfull** docker.

To run the docker daemon as non-root user (**rootless** mode), refer to `values-rootless.yaml`:

```yaml
volumeProvisioner:
  env:
    IS_ROOTLESS: true
  # -- Only if local volumes are used as backend storage (ignored for ebs/ebs-csi disks)
  dind-lv-monitor:
    image:
      tag: 1.30.0-rootless
      digest: sha256:712e549e6e843b04684647f17e0973f8047e0d60e6e8b38a693ea64dc75b0479
    containerSecurityContext:
      runAsUser: 1000
    podSecurityContext:
      fsGroup: 1000
      # Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#configure-volume-permission-and-ownership-change-policy-for-pods
      fsGroupChangePolicy: "OnRootMismatch"
    # -- Enable initContainer to run chmod for /var/lib/codefresh/dind-volumes on host nodes
    volumePermissions:
      enabled: false

runtime:
  dind:
    image:
      tag: 26.1.4-1.28.10-rootless
      digest: sha256:59dfc004eb22a8f09c8a3d585271a055af9df4591ab815bca418c24a2077f5c8
    userVolumeMounts:
      dind:
        name: dind
        mountPath: /home/rootless/.local/share/docker
    containerSecurityContext:
      privileged: true
      runAsUser: 1000
    podSecurityContext:
      fsGroup: 1000
      # Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#configure-volume-permission-and-ownership-change-policy-for-pods
      fsGroupChangePolicy: "OnRootMismatch"
    # -- Enable initContainer to run chmod for /home/rootless in DinD pod
    # !!! Will slow down dind pod startup
    volumePermissions:
      enabled: true
```

### ARM

With the Codefresh Runner, you can run native ARM64v8 builds.

> **Note!**
> You cannot run both amd64 and arm64 images within the same pipeline. As one pipeline can map only to one runtime, you can run either amd64 or arm64 within the same pipeline.

Provide `nodeSelector` and(or) `tolerations` for dind pods:

`values.yaml`
```yaml
runtime:
  dind:
    nodeSelector:
      arch: arm64
    tolerations:
    - key: arch
      operator: Equal
      value: arm64
      effect: NoSchedule
```

### Openshift

To install Codefresh Runner on OpenShift use the following `values.yaml` example

```yaml
runner:
  podSecurityContext:
    enabled: false

volumeProvisioner:
  podSecurityContext:
    enabled: false
  env:
    PRIVILEGED_CONTAINER: true
  dind-lv-monitor:
    containerSecurityContext:
      enabled: true
      privileged: true
    volumePermissions:
      enabled: true
      securityContext:
        privileged: true
        runAsUser: auto
```

Grant `privileged` SCC to `cf-runtime-runner` and `cf-runtime-volume-provisioner` service accounts.

```console
oc adm policy add-scc-to-user privileged system:serviceaccount:codefresh:cf-runtime-runner

oc adm policy add-scc-to-user privileged system:serviceaccount:codefresh:cf-runtime-volume-provisioner
```

### On-premise

If you have [Codefresh On-Premises](https://artifacthub.io/packages/helm/codefresh-onprem/codefresh) deployed, you can install Codefresh Runner in **agentless** mode.

**What is agentless mode?**

Agent (aka venona) is Runner component which responsible for calling Codefresh API to run builds and create dind/engine pods and pvc objects. Agent can only be assigned to a single account, thus you can't share one runtime across multiple accounts. However, with **agentless** mode it's possible to register the runtime as **system**-type runtime so it's registered on the platform level and can be assigned/shared across multiple accounts.

**What are the prerequisites?**
- You have a running [Codefresh On-Premises](https://artifacthub.io/packages/helm/codefresh-onprem/codefresh) control-plane environment
- You have a Codefresh API token with platform **Admin** permissions scope

### How to deploy agentless runtime when it's on the SAME k8s cluster as On-Premises control-plane environment?

- Enable cluster-level permissions for cf-api (On-Premises control-plane component)

> `values.yaml` for [Codefresh On-Premises](https://artifacthub.io/packages/helm/codefresh-onprem/codefresh) Helm chart
```yaml
cfapi:
  ...
  # -- Enable ClusterRole/ClusterRoleBinding
  rbac:
    namespaced: false
```

- Set the following values for Runner Helm chart

`.Values.global.codefreshHost=...` \
`.Values.global.codefreshToken=...` \
`.Values.global.runtimeName=system/...` \
`.Values.runtime.agent=false` \
`.Values.runtime.inCluster=true`

> `values.yaml` for [Codefresh Runner](https://artifacthub.io/packages/helm/codefresh-runner/cf-runtime) helm chart
```yaml
global:
  # -- URL of Codefresh On-Premises Platform
  codefreshHost: "https://myonprem.somedomain.com"
  # -- User token in plain text with Admin permission scope
  codefreshToken: ""
  # -- User token that references an existing secret containing API key.
  codefreshTokenSecretKeyRef: {}
  # E.g.
  # codefreshTokenSecretKeyRef:
  #   name: my-codefresh-api-token
  #   key: codefresh-api-token

  # -- Distinguished runtime name
  # (for On-Premise only; mandatory!) Must be prefixed with "system/..."
  runtimeName: "system/prod-ue1-some-cluster-name"

# -- Set runtime parameters
runtime:
  # -- (for On-Premise only; mandatory!) Disable agent
  agent: false
  # -- (for On-Premise only; optional) Set inCluster runtime (default: `true`)
  # `inCluster=true` flag is set when Runtime and On-Premises control-plane are run on the same cluster
  # `inCluster=false` flag is set when Runtime and On-Premises control-plane are on different clusters
  inCluster: true
  # -- (for On-Premise only; optional) Assign accounts to runtime (list of account ids; default is empty)
  # Accounts can be assigned to the runtime in Codefresh UI later so you can kepp it empty.
  accounts: []
  # -- Set parent runtime to inherit.
  runtimeExtends: []
```

- Install the chart

```console
helm upgrade --install cf-runtime oci://quay.io/codefresh/cf-runtime -f values.yaml --create-namespace --namespace cf-runtime
```

- Verify the runtime and run test pipeline

Go to [https://<YOUR_ONPREM_DOMAIN_HERE>/admin/runtime-environments/system](https://<YOUR_ONPREM_DOMAIN_HERE>/admin/runtime-environments/system) to check the runtime. Assign it to the required account(s). Run test pipeline on it.

### How to deploy agentless runtime when it's on the DIFFERENT k8s cluster than On-Premises control-plane environment?

In this case, it's required to mount runtime cluster's `KUBECONFIG` into On-Premises `cf-api` deployment

- Create the neccessary RBAC resources

> `values.yaml` for [Codefresh Runner](https://artifacthub.io/packages/helm/codefresh-runner/cf-runtime) helm chart
```yaml
extraResources:
- apiVersion: rbac.authorization.k8s.io/v1
  kind: Role
  metadata:
    name: codefresh-role
    namespace: '{{ .Release.Namespace }}'
  rules:
    - apiGroups: [""]
      resources: ["pods", "persistentvolumeclaims", "persistentvolumes"]
      verbs: ["list", "watch", "get", "create", "patch", "delete"]
    - apiGroups: ["snapshot.storage.k8s.io"]
      resources: ["volumesnapshots"]
      verbs: ["list", "watch", "get", "create", "patch", "delete"]
- apiVersion: v1
  kind: ServiceAccount
  metadata:
    name: codefresh-runtime-user
    namespace: '{{ .Release.Namespace }}'
- apiVersion: rbac.authorization.k8s.io/v1
  kind: RoleBinding
  metadata:
    name: codefresh-runtime-user
    namespace: '{{ .Release.Namespace }}'
  roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: Role
    name: codefresh-role
  subjects:
  - kind: ServiceAccount
    name: codefresh-runtime-user
    namespace: '{{ .Release.Namespace }}'
- apiVersion: v1
  kind: Secret
  metadata:
    name: codefresh-runtime-user-token
    namespace: '{{ .Release.Namespace }}'
    annotations:
      kubernetes.io/service-account.name: codefresh-runtime-user
  type: kubernetes.io/service-account-token
```

- Set up the following environment variables to create a `KUBECONFIG` file

```shell
NAMESPACE=cf-runtime
CLUSTER_NAME=prod-ue1-some-cluster-name
CURRENT_CONTEXT=$(kubectl config current-context)

USER_TOKEN_VALUE=$(kubectl -n $NAMESPACE get secret/codefresh-runtime-user-token -o=go-template='{{.data.token}}' | base64 --decode)
CURRENT_CLUSTER=$(kubectl config view --raw -o=go-template='{{range .contexts}}{{if eq .name "'''${CURRENT_CONTEXT}'''"}}{{ index .context "cluster" }}{{end}}{{end}}')
CLUSTER_CA=$(kubectl config view --raw -o=go-template='{{range .clusters}}{{if eq .name "'''${CURRENT_CLUSTER}'''"}}"{{with index .cluster "certificate-authority-data" }}{{.}}{{end}}"{{ end }}{{ end }}')
CLUSTER_SERVER=$(kubectl config view --raw -o=go-template='{{range .clusters}}{{if eq .name "'''${CURRENT_CLUSTER}'''"}}{{ .cluster.server }}{{end}}{{ end }}')

export -p USER_TOKEN_VALUE CURRENT_CONTEXT CURRENT_CLUSTER CLUSTER_CA CLUSTER_SERVER CLUSTER_NAME
```

- Create a kubeconfig file

```console
cat << EOF > $CLUSTER_NAME-kubeconfig
apiVersion: v1
kind: Config
current-context: ${CLUSTER_NAME}
contexts:
- name: ${CLUSTER_NAME}
  context:
    cluster: ${CLUSTER_NAME}
    user: codefresh-runtime-user
    namespace: ${NAMESPACE}
clusters:
- name: ${CLUSTER_NAME}
  cluster:
    certificate-authority-data: ${CLUSTER_CA}
    server: ${CLUSTER_SERVER}
users:
- name: codefresh-runtime-user
  user:
    token: ${USER_TOKEN_VALUE}
EOF
```

- **Switch context to On-Premises control-plane cluster**. Create k8s secret (via any tool like [ESO](https://external-secrets.io/v0.4.4/), `kubectl`, etc ) containing runtime cluster's `KUBECONFG` created in previous step.

```shell
NAMESPACE=codefresh
kubectl create secret generic dind-runtime-clusters --from-file=$CLUSTER_NAME=$CLUSTER_NAME-kubeconfig -n $NAMESPACE
```

- Mount secret containing runtime cluster's `KUBECONFG` into cf-api in On-Premises control-plane cluster

> `values.yaml` for [Codefresh On-Premises](https://artifacthub.io/packages/helm/codefresh-onprem/codefresh) helm chart
```yaml
cf-api:
  ...
  volumes:
    dind-clusters:
      enabled: true
      type: secret
      nameOverride: dind-runtime-clusters
      optional: true
```
> volumeMount `/etc/kubeconfig` is already configured in cf-api Helm chart template. No need to specify it.

- Set the following values for Runner helm chart

> `values.yaml` for [Codefresh Runner](https://artifacthub.io/packages/helm/codefresh-runner/cf-runtime) helm chart

`.Values.global.codefreshHost=...` \
`.Values.global.codefreshToken=...` \
`.Values.global.runtimeName=system/...` \
`.Values.runtime.agent=false` \
`.Values.runtime.inCluster=false`

**Important!**
`.Values.global.name` ("system/" prefix is ignored!) should match the cluster name (key in `dind-runtime-clusters` secret created previously)
```yaml
global:
  # -- URL of Codefresh On-Premises Platform
  codefreshHost: "https://myonprem.somedomain.com"
  # -- User token in plain text with Admin permission scope
  codefreshToken: ""
  # -- User token that references an existing secret containing API key.
  codefreshTokenSecretKeyRef: {}
  # E.g.
  # codefreshTokenSecretKeyRef:
  #   name: my-codefresh-api-token
  #   key: codefresh-api-token

  # -- Distinguished runtime name
  # (for On-Premise only; mandatory!) Must be prefixed with "system/..."
  name: "system/prod-ue1-some-cluster-name"

# -- Set runtime parameters
runtime:
  # -- (for On-Premise only; mandatory!) Disable agent
  agent: false
  # -- (for On-Premise only; optional) Set inCluster runtime (default: `true`)
  # `inCluster=true` flag is set when Runtime and On-Premises control-plane are run on the same cluster
  # `inCluster=false` flag is set when Runtime and On-Premises control-plane are on different clusters
  inCluster: false
  # -- (for On-Premise only; optional) Assign accounts to runtime (list of account ids; default is empty)
  # Accounts can be assigned to the runtime in Codefresh UI later so you can kepp it empty.
  accounts: []
  # -- (optional) Set parent runtime to inherit.
  runtimeExtends: []
```

- Install the chart

```console
helm upgrade --install cf-runtime oci://quay.io/codefresh/cf-runtime -f values.yaml --create-namespace --namespace cf-runtime
```

- Verify the runtime and run test pipeline

Go to [https://<YOUR_ONPREM_DOMAIN_HERE>/admin/runtime-environments/system](https://<YOUR_ONPREM_DOMAIN_HERE>/admin/runtime-environments/system) to see the runtime. Assign it to the required account(s).

## Migrating from CLI-based installation to Helm chart

If you have previously installed Codefresh Runner via CLI, you can migrate to the Helm chart by following these steps:

Get Agent and Runtime from existing installation:

```console
NAMESPACE=codefresh
AGENT_NAME=$(kubectl -n $NAMESPACE get deploy runner -o json | jq -r '.spec.template.spec.containers[].env[] | select(.name == "AGENT_ID") | .value')
RUNTIME_NAME=$(kubectl -n $NAMESPACE get secret runnerconf -o json | jq -r '.data | to_entries | .[0].value' | base64 -d | grep 'name:' | cut -d':' -f2 | tr -d ' ')
echo "AGENT_NAME: $AGENT_NAME"
echo "RUNTIME_NAME: $RUNTIME_NAME"
```

Delete the legacy k8s resources created via CLI with `./scripts/delete-legacy-cli-resources.sh` script:

⚠️⚠️⚠️ **DO NOT DELETE `runner` secret!** ⚠️⚠️⚠️

```console
NAMESPACE=codefresh
./scripts/delete-legacy-cli-resources.sh $NAMESPACE
```

Fill Agent and Runtime names in the `values.yaml` file:

```console
cat << EOF > my-values.yaml
global:
  agentName: $AGENT_NAME
  runtimeName: $RUNTIME_NAME
  agentTokenSecretKeyRef:
    name: runner
    key: codefresh.token
EOF
```

⚠️ Any customizations in runtime-environment spec done via CLI (like `nodeSelector`, `tolerations`, `podLabels`, etc) should be added to the `values.yaml` file as well.

Install the Helm chart

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| oci://quay.io/codefresh/charts | cf-common | 0.21.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| appProxy.affinity | object | `{}` | Set affinity |
| appProxy.enabled | bool | `false` | Enable app-proxy |
| appProxy.env | object | `{}` | Add additional env vars |
| appProxy.image | object | `{"digest":"sha256:06417d368b0bf296597441e9f7796ee19905c3205472d81eebf2bcd3cb2cfd98","registry":"quay.io","repository":"codefresh/cf-app-proxy","tag":"0.0.56"}` | Set image |
| appProxy.ingress.annotations | object | `{}` | Set extra annotations for ingress object |
| appProxy.ingress.class | string | `""` | Set ingress class |
| appProxy.ingress.host | string | `""` | Set DNS hostname the ingress will use |
| appProxy.ingress.pathPrefix | string | `""` | Set path prefix for ingress (keep empty for default `/` path) |
| appProxy.ingress.tlsSecret | string | `""` | Set k8s tls secret for the ingress object |
| appProxy.nodeSelector | object | `{}` | Set node selector |
| appProxy.podAnnotations | object | `{}` | Set pod annotations |
| appProxy.podSecurityContext | object | `{}` | Set security context for the pod |
| appProxy.rbac | object | `{"create":true,"namespaced":true,"rules":[]}` | RBAC parameters |
| appProxy.rbac.create | bool | `true` | Create RBAC resources |
| appProxy.rbac.namespaced | bool | `true` | Use Role(true)/ClusterRole(true) |
| appProxy.rbac.rules | list | `[]` | Add custom rule to the role |
| appProxy.readinessProbe | object | See below | Readiness probe configuration |
| appProxy.replicasCount | int | `1` | Set number of pods |
| appProxy.resources | object | `{}` | Set requests and limits |
| appProxy.serviceAccount | object | `{"annotations":{},"create":true,"name":"","namespaced":true}` | Service Account parameters |
| appProxy.serviceAccount.annotations | object | `{}` | Additional service account annotations |
| appProxy.serviceAccount.create | bool | `true` | Create service account |
| appProxy.serviceAccount.name | string | `""` | Override service account name |
| appProxy.serviceAccount.namespaced | bool | `true` | Use Role(true)/ClusterRole(true) |
| appProxy.tolerations | list | `[]` | Set tolerations |
| appProxy.updateStrategy | object | `{"type":"RollingUpdate"}` | Upgrade strategy |
| ballast | object | See below | Ballast parameters |
| ballast.dind.image | object | `{"digest":"sha256:ee6521f290b2168b6e0935a181d4cff9be1ac3f505666ef0e3c98fae8199917a","registry":"registry.k8s.io","repository":"pause","tag":3.1}` | Set image |
| ballast.dind.podAnnotations | object | `{}` | Set pod annotations |
| ballast.dind.podSecurityContext | object | `{}` | Add additional env vars |
| ballast.dind.replicasCount | int | `1` | Set number of pods |
| ballast.dind.resources | object | `{}` | Set resources |
| ballast.engine.image | object | `{"digest":"sha256:ee6521f290b2168b6e0935a181d4cff9be1ac3f505666ef0e3c98fae8199917a","registry":"registry.k8s.io","repository":"pause","tag":3.1}` | Set image |
| ballast.engine.podAnnotations | object | `{}` | Set pod annotations |
| ballast.engine.podSecurityContext | object | `{}` | Add additional env vars |
| ballast.engine.replicasCount | int | `1` | Set number of pods |
| ballast.engine.resources | object | `{}` | Set resources |
| dockerRegistry | string | `""` |  |
| event-exporter | object | See below | Event exporter parameters |
| event-exporter.affinity | object | `{}` | Set affinity |
| event-exporter.enabled | bool | `false` | Enable event-exporter |
| event-exporter.env | object | `{}` | Add additional env vars |
| event-exporter.image | object | `{"digest":"sha256:cf52048f1378fb6659dffd1394d68fdf23a7ea709585dc14b5007f3e5a1b7584","registry":"docker.io","repository":"codefresh/k8s-event-exporter","tag":"latest"}` | Set image |
| event-exporter.name | string | `""` | Set name for the event-exporter deployment |
| event-exporter.nodeSelector | object | `{"kubernetes.io/arch":"amd64"}` | Set node selector |
| event-exporter.podAnnotations | object | `{}` | Set pod annotations |
| event-exporter.podSecurityContext | object | See below | Set security context for the pod |
| event-exporter.rbac | object | `{"create":true,"rules":[]}` | RBAC parameters |
| event-exporter.rbac.create | bool | `true` | Create RBAC resources |
| event-exporter.rbac.rules | list | `[]` | Add custom rule to the role |
| event-exporter.replicasCount | int | `1` | Set number of pods |
| event-exporter.resources | object | `{}` | Set resources |
| event-exporter.serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | Service Account parameters |
| event-exporter.serviceAccount.annotations | object | `{}` | Additional service account annotations |
| event-exporter.serviceAccount.create | bool | `true` | Create service account |
| event-exporter.serviceAccount.name | string | `""` | Override service account name |
| event-exporter.tolerations | list | `[]` | Set tolerations |
| event-exporter.updateStrategy | object | `{"type":"Recreate"}` | Upgrade strategy |
| extraResources | list | `[]` | Array of extra objects to deploy with the release |
| extraRuntimes | object | `{}` | Extra runtimes to create |
| fullnameOverride | string | `""` | String to fully override cf-runtime.fullname template |
| global | object | See below | Global parameters |
| global.accountId | string | `""` | Account ID (required!) Can be obtained here https://g.codefresh.io/2.0/account-settings/account-information |
| global.agentName | string | `""` | Agent Name (optional!) If omitted, the following format will be used `{{ .Values.global.context }}_{{ .Release.Namespace }}` |
| global.agentToken | string | `""` | DEPRECATED Agent token in plain text. !!! MUST BE provided if migrating from < 6.x chart version |
| global.agentTokenSecretKeyRef | object | `{}` | DEPRECATED Agent token that references an existing secret containing API key. !!! MUST BE provided if migrating from < 6.x chart version |
| global.codefreshHost | string | `"https://g.codefresh.io"` | URL of Codefresh Platform (required!) |
| global.codefreshToken | string | `""` | User token in plain text (required if `global.codefreshTokenSecretKeyRef` is omitted!) Ref: https://g.codefresh.io/user/settings (see API Keys) Minimal API key scopes: Runner-Installation(read+write), Agent(read+write), Agents(read+write) |
| global.codefreshTokenSecretKeyRef | object | `{}` | User token that references an existing secret containing API key (required if `global.codefreshToken` is omitted!) |
| global.context | string | `""` | K8s context name (required!) |
| global.imagePullSecrets | list | `[]` | Global Docker registry secret names as array |
| global.imageRegistry | string | `""` | Global Docker image registry |
| global.runtimeName | string | `""` | Runtime name (optional!) If omitted, the following format will be used `{{ .Values.global.context }}/{{ .Release.Namespace }}` |
| monitor.affinity | object | `{}` | Set affinity |
| monitor.enabled | bool | `false` | Enable monitor Ref: https://codefresh.io/docs/docs/installation/codefresh-runner/#install-monitoring-component |
| monitor.env | object | `{}` | Add additional env vars |
| monitor.image | object | `{"digest":"sha256:890cf228f2ac4ee66e35efc55b56a7a27627b7ad4eebc93f21ac74bb56b5860e","registry":"quay.io","repository":"codefresh/cf-k8s-agent","tag":"1.3.24"}` | Set image |
| monitor.nodeSelector | object | `{}` | Set node selector |
| monitor.podAnnotations | object | `{}` | Set pod annotations |
| monitor.podSecurityContext | object | `{}` |  |
| monitor.rbac | object | `{"create":true,"namespaced":true,"rules":[]}` | RBAC parameters |
| monitor.rbac.create | bool | `true` | Create RBAC resources |
| monitor.rbac.namespaced | bool | `true` | Use Role(true)/ClusterRole(true) |
| monitor.rbac.rules | list | `[]` | Add custom rule to the role |
| monitor.readinessProbe | object | See below | Readiness probe configuration |
| monitor.replicasCount | int | `1` | Set number of pods |
| monitor.resources | object | `{}` | Set resources |
| monitor.serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | Service Account parameters |
| monitor.serviceAccount.annotations | object | `{}` | Additional service account annotations |
| monitor.serviceAccount.create | bool | `true` | Create service account |
| monitor.serviceAccount.name | string | `""` | Override service account name |
| monitor.tolerations | list | `[]` | Set tolerations |
| monitor.updateStrategy | object | `{"type":"RollingUpdate"}` | Upgrade strategy |
| nameOverride | string | `""` | String to partially override cf-runtime.fullname template (will maintain the release name) |
| podMonitor | object | See below | Add podMonitor |
| podMonitor.main.enabled | bool | `false` | Enable pod monitor for engine pods |
| podMonitor.runner.enabled | bool | `false` | Enable pod monitor for runner pod |
| podMonitor.volume-provisioner.enabled | bool | `false` | Enable pod monitor for volumeProvisioner pod |
| re | object | `{}` |  |
| runner | object | See below | Runner parameters |
| runner.affinity | object | `{}` | Set affinity |
| runner.enabled | bool | `true` | Enable the runner |
| runner.env | object | `{}` | Add additional env vars |
| runner.image | object | `{"digest":"sha256:d00c6645039c3716e778217cc22fb44ae2324fd3349d8e782dd3a8af05dc0e2d","registry":"quay.io","repository":"codefresh/venona","tag":"2.0.6"}` | Set image |
| runner.init | object | `{"image":{"digest":"sha256:bbf49935b078eb0f282fec4ff674eea55f880b101809c6415e3ead7a0c729261","registry":"quay.io","repository":"codefresh/cli","tag":"0.89.3-rootless"},"resources":{"limits":{"cpu":"1","memory":"512Mi"},"requests":{"cpu":"0.2","memory":"256Mi"}}}` | Init container |
| runner.name | string | `""` | Set runner deployment name |
| runner.nodeSelector | object | `{}` | Set node selector |
| runner.podAnnotations | object | `{}` | Set pod annotations |
| runner.podSecurityContext | object | See below | Set security context for the pod |
| runner.rbac | object | `{"create":true,"rules":[]}` | RBAC parameters |
| runner.rbac.create | bool | `true` | Create RBAC resources |
| runner.rbac.rules | list | `[]` | Add custom rule to the role |
| runner.readinessProbe | object | See below | Readiness probe configuration |
| runner.replicasCount | int | `1` | Set number of pods |
| runner.resources | object | `{}` | Set requests and limits |
| runner.serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | Service Account parameters |
| runner.serviceAccount.annotations | object | `{}` | Additional service account annotations |
| runner.serviceAccount.create | bool | `true` | Create service account |
| runner.serviceAccount.name | string | `""` | Override service account name |
| runner.sidecar | object | `{"enabled":false,"env":{"RECONCILE_INTERVAL":300},"image":{"digest":"sha256:da0c9d12b4772e6cd6c1ecb93883471e8785d4d61c9108c9f7d0dc9cc2f5a149","registry":"quay.io","repository":"codefresh/kubectl","tag":"1.33.0"},"resources":{}}` | Sidecar container Reconciles runtime spec from Codefresh API for drift detection |
| runner.tolerations | list | `[]` | Set tolerations |
| runner.updateStrategy | object | `{"type":"RollingUpdate"}` | Upgrade strategy |
| runtime | object | See below | Set runtime parameters |
| runtime.accounts | list | `[]` | (for On-Premise only) Assign accounts to runtime (list of account ids) |
| runtime.agent | bool | `true` | (for On-Premise only) Enable agent |
| runtime.description | string | `""` | Runtime description |
| runtime.dind | object | `{"affinity":{},"containerSecurityContext":{},"env":{"CLEAN_DOCKER":true,"CLEAN_PERIOD_BUILDS":"5","CLEAN_PERIOD_SECONDS":"21600","DISK_USAGE_THRESHOLD":"0.8","IMAGE_RETAIN_PERIOD":"14400","INODES_USAGE_THRESHOLD":"0.8","VOLUMES_RETAIN_PERIOD":"14400"},"image":{"digest":"sha256:0f2a83603e27e6d88768a6ab8ead3e2426eaf989cd93919fa1128d98a7c617c6","pullPolicy":"IfNotPresent","registry":"quay.io","repository":"codefresh/dind","tag":"28.3.3-3.0.2"},"nodeSelector":{},"podAnnotations":{},"podLabels":{},"podSecurityContext":{},"pvcs":{"dind":{"annotations":{},"name":"dind","reuseVolumeSelector":"codefresh-app,io.codefresh.accountName","reuseVolumeSortOrder":"pipeline_id","storageClassName":"{{ include \"dind-volume-provisioner.storageClassName\" . }}","volumeSize":"16Gi"}},"resources":{"limits":{"cpu":"400m","memory":"800Mi"},"requests":null},"schedulerName":"","serviceAccount":"codefresh-engine","terminationGracePeriodSeconds":30,"tolerations":[],"userAccess":true,"userVolumeMounts":{},"userVolumes":{},"volumePermissions":{"enabled":false,"image":{"digest":"sha256:de0eb0b3f2a47ba1eb89389859a9bd88b28e82f5826b6969ad604979713c2d4f","registry":"docker.io","repository":"alpine","tag":3.18},"resources":{},"securityContext":{"runAsUser":0}}}` | Parameters for DinD (docker-in-docker) pod (aka "runtime" pod). |
| runtime.dind.affinity | object | `{}` | Set affinity |
| runtime.dind.containerSecurityContext | object | `{}` | Set container security context. |
| runtime.dind.env | object | `{"CLEAN_DOCKER":true,"CLEAN_PERIOD_BUILDS":"5","CLEAN_PERIOD_SECONDS":"21600","DISK_USAGE_THRESHOLD":"0.8","IMAGE_RETAIN_PERIOD":"14400","INODES_USAGE_THRESHOLD":"0.8","VOLUMES_RETAIN_PERIOD":"14400"}` | Set additional env vars. |
| runtime.dind.env.CLEAN_DOCKER | bool | `true` | Enable in-docker cleaner |
| runtime.dind.env.CLEAN_PERIOD_BUILDS | string | `"5"` | Run cleanup if there have been more than CLEAN_PERIOD_BUILDS builds since the last cleanup |
| runtime.dind.env.CLEAN_PERIOD_SECONDS | string | `"21600"` | Run cleanup if the last cleanup was more than CLEAN_PERIOD_SECONDS seconds ago |
| runtime.dind.env.DISK_USAGE_THRESHOLD | string | `"0.8"` | Run cleanup if current disk usage exceeds DISK_USAGE_THRESHOLD |
| runtime.dind.env.IMAGE_RETAIN_PERIOD | string | `"14400"` | Do not delete Docker images if they have events newer than `NOW minus IMAGE_RETAIN_PERIOD` |
| runtime.dind.env.INODES_USAGE_THRESHOLD | string | `"0.8"` | Run cleanup if current inodes usage exceeds INODES_USAGE_THRESHOLD |
| runtime.dind.env.VOLUMES_RETAIN_PERIOD | string | `"14400"` | Do not delete Docker volumes if they have events newer than `NOW minus VOLUMES_RETAIN_PERIOD` |
| runtime.dind.image | object | `{"digest":"sha256:0f2a83603e27e6d88768a6ab8ead3e2426eaf989cd93919fa1128d98a7c617c6","pullPolicy":"IfNotPresent","registry":"quay.io","repository":"codefresh/dind","tag":"28.3.3-3.0.2"}` | Set dind image. |
| runtime.dind.nodeSelector | object | `{}` | Set node selector. |
| runtime.dind.podAnnotations | object | `{}` | Set pod annotations. |
| runtime.dind.podLabels | object | `{}` | Set pod labels. |
| runtime.dind.podSecurityContext | object | `{}` | Set security context for the pod. |
| runtime.dind.pvcs | object | `{"dind":{"annotations":{},"name":"dind","reuseVolumeSelector":"codefresh-app,io.codefresh.accountName","reuseVolumeSortOrder":"pipeline_id","storageClassName":"{{ include \"dind-volume-provisioner.storageClassName\" . }}","volumeSize":"16Gi"}}` | PV claim spec parametes. |
| runtime.dind.pvcs.dind | object | `{"annotations":{},"name":"dind","reuseVolumeSelector":"codefresh-app,io.codefresh.accountName","reuseVolumeSortOrder":"pipeline_id","storageClassName":"{{ include \"dind-volume-provisioner.storageClassName\" . }}","volumeSize":"16Gi"}` | Default dind PVC parameters |
| runtime.dind.pvcs.dind.annotations | object | `{}` | PV annotations. |
| runtime.dind.pvcs.dind.name | string | `"dind"` | PVC name prefix. Keep `dind` as default! Don't change! |
| runtime.dind.pvcs.dind.reuseVolumeSelector | string | `"codefresh-app,io.codefresh.accountName"` | PV reuse selector. Ref: https://codefresh.io/docs/docs/installation/codefresh-runner/#volume-reuse-policy |
| runtime.dind.pvcs.dind.storageClassName | string | `"{{ include \"dind-volume-provisioner.storageClassName\" . }}"` | PVC storage class name. Change ONLY if you need to use storage class NOT from Codefresh volume-provisioner |
| runtime.dind.pvcs.dind.volumeSize | string | `"16Gi"` | PVC size. |
| runtime.dind.resources | object | `{"limits":{"cpu":"400m","memory":"800Mi"},"requests":null}` | Set dind resources. |
| runtime.dind.schedulerName | string | `""` | Set scheduler name. |
| runtime.dind.serviceAccount | string | `"codefresh-engine"` | Set service account for pod. |
| runtime.dind.terminationGracePeriodSeconds | int | `30` | Set termination grace period. |
| runtime.dind.tolerations | list | `[]` | Set tolerations. |
| runtime.dind.userAccess | bool | `true` | Keep `true` as default! |
| runtime.dind.userVolumeMounts | object | `{}` | Add extra volume mounts |
| runtime.dind.userVolumes | object | `{}` | Add extra volumes |
| runtime.dindDaemon | object | See below | DinD pod daemon config |
| runtime.engine | object | `{"affinity":{},"command":["npm","run","start"],"env":{"CF_TELEMETRY_LOGS_LEVEL":"debug","CF_TELEMETRY_OTEL_ALLOW_HTTP_INSTRUMENTATION":"false","CF_TELEMETRY_OTEL_ENABLE":"true","CF_TELEMETRY_PROMETHEUS_ENABLE":"false","CF_TELEMETRY_PROMETHEUS_ENABLE_PROCESS_METRICS":"false","CF_TELEMETRY_PROMETHEUS_HOST":"0.0.0.0","CF_TELEMETRY_PROMETHEUS_PORT":"9100","CF_TELEMETRY_PYROSCOPE_ENABLE":"false","CONTAINER_LOGGER_EXEC_CHECK_INTERVAL_MS":1000,"DOCKER_REQUEST_TIMEOUT_MS":30000,"FORCE_COMPOSE_SERIAL_PULL":false,"LOGGER_LEVEL":"debug","LOG_OUTGOING_HTTP_REQUESTS":false,"METRICS_PROMETHEUS_COLLECT_PROCESS_METRICS":false,"METRICS_PROMETHEUS_ENABLED":false,"METRICS_PROMETHEUS_ENABLE_LEGACY_METRICS":false,"METRICS_PROMETHEUS_HOST":"0.0.0.0","METRICS_PROMETHEUS_PORT":9100,"METRICS_PROMETHEUS_SCRAPE_TIMEOUT":"15000","METRICS_SCRAPE_TIMEOUT_MS":"0","OTEL_EXPORTER_OTLP_COMPRESSION":"gzip","OTEL_EXPORTER_OTLP_ENDPOINT":"http://localhost:4317","OTEL_EXPORTER_OTLP_PROTOCOL":"grpc","OTEL_EXPORTER_PROMETHEUS_HOST":"0.0.0.0","OTEL_EXPORTER_PROMETHEUS_PORT":"9464","OTEL_LOGS_EXPORTER":"none","OTEL_METRICS_EXPORTER":"otlp","OTEL_METRIC_EXPORT_INTERVAL":"10000","OTEL_METRIC_EXPORT_TIMEOUT":"5000","OTEL_SEMCONV_STABILITY_OPT_IN":"http","OTEL_TRACES_EXPORTER":"none","OTEL_TRACES_SAMPLER":"parentbased_always_on","PYROSCOPE_SERVER_ADDRESS":"","TRUSTED_QEMU_IMAGES":"tonistiigi/binfmt"},"image":{"digest":"sha256:1dff082bed386f008462f15c2d34b8da23c5646d61829fb0a22325530510a2ac","pullPolicy":"IfNotPresent","registry":"quay.io","repository":"codefresh/engine","tag":"1.179.3"},"nodeSelector":{},"podAnnotations":{},"podLabels":{},"resources":{"limits":{"cpu":"1000m","memory":"2048Mi"},"requests":{"cpu":"100m","memory":"128Mi"}},"runtimeImages":{"alpine":{"digest":"sha256:115729ec5cb049ba6359c3ab005ac742012d92bbaa5b8bc1a878f1e8f62c0cb8","registry":"docker.io","repository":"alpine","tag":"edge"},"compose":{"digest":"sha256:e74494370100678ccb1c1058e6ef3ddcf67b21fcd37da8b3482376c8282549ad","registry":"quay.io","repository":"codefresh/compose","tag":"v2.37.0-1.5.4"},"container-logger":{"digest":"sha256:6e376bb00e824827cb038e15160ccf0fead4f868197b75bbc80dbd6bc34af8d6","registry":"quay.io","repository":"codefresh/cf-container-logger","tag":"1.12.8"},"cosign-image-signer":{"digest":"sha256:ad74291dc11833e13dbf7ae1919446dee2baedb16b96a8a3acc600b5499c716d","registry":"quay.io","repository":"codefresh/cf-cosign-image-signer","tag":"2.5.2-cf.1"},"default-qemu":{"digest":"sha256:1b804311fe87047a4c96d38b4b3ef6f62fca8cd125265917a9e3dc3c996c39e6","registry":"docker.io","repository":"tonistiigi/binfmt","tag":"qemu-v9.2.2"},"docker-builder":{"digest":"sha256:1d02df4dcf703a97c7a64b147cd2c3f6ec2c708aad16be5abbd337f3c13a48ad","registry":"quay.io","repository":"codefresh/cf-docker-builder","tag":"1.4.7"},"docker-puller":{"digest":"sha256:914f071bcb1893bcb42c3f8907f8f3874f1f30db1a2ccaa4b825dab9bb157e60","registry":"quay.io","repository":"codefresh/cf-docker-puller","tag":"8.0.22"},"docker-pusher":{"digest":"sha256:bad3773029a68f33953f1dc245cb92c386b5311a996340eea41fe6b9cc52a96c","registry":"quay.io","repository":"codefresh/cf-docker-pusher","tag":"6.0.20"},"docker-tag-pusher":{"digest":"sha256:ec4416525bbf4912786035fbb2e1f26ae04f94559c535f02232b48eb0a1c5fa7","registry":"quay.io","repository":"codefresh/cf-docker-tag-pusher","tag":"1.3.19"},"fs-ops":{"digest":"sha256:70d53821b9314d88e3571dfb096e8f577caf3e4c2199253621b8d0c85d20b8ad","registry":"quay.io","repository":"codefresh/fs-ops","tag":"1.2.10"},"gc-builder":{"digest":"sha256:33ac914e6b844909f188a208cf90e569358cafa5aaa60f49848f49d99bcaf875","registry":"quay.io","repository":"codefresh/cf-gc-builder","tag":"0.5.3"},"git-cloner":{"digest":"sha256:2e09eef18d5caddae708058ec63247825ac4e4ee5e5763986f65e1312fbcc449","registry":"quay.io","repository":"codefresh/cf-git-cloner","tag":"10.3.2"},"kube-deploy":{"digest":"sha256:35649b14eb43717d3752d08597ada77d3737b2508f1b8e1f52f67b7a0e5ff263","registry":"quay.io","repository":"codefresh/cf-deploy-kubernetes","tag":"16.2.9"},"pipeline-debugger":{"digest":"sha256:37975653b4ef5378bd1e38d453c7dac4721cba1c1977a5ca6118a67b98a47925","registry":"quay.io","repository":"codefresh/cf-debugger","tag":"1.3.9"},"template-engine":{"digest":"sha256:b3f499fcf93037e69fba599d2f292cfc9f28a158052dd57d5de9cdf9756f1f60","registry":"quay.io","repository":"codefresh/pikolo","tag":"0.14.6"}},"runtimeImagesRegisty":"","schedulerName":"","serviceAccount":"codefresh-engine","terminationGracePeriodSeconds":180,"tolerations":[],"userEnvVars":[],"workflowLimits":{"MAXIMUM_ALLOWED_TIME_BEFORE_PRE_STEPS_SUCCESS":600,"MAXIMUM_ALLOWED_WORKFLOW_AGE_BEFORE_TERMINATION":86400,"MAXIMUM_ELECTED_STATE_AGE_ALLOWED":900,"MAXIMUM_POST_STEPS_GRACE_PERIOD_MINUTES":30,"MAXIMUM_RETRY_ATTEMPTS_ALLOWED":20,"MAXIMUM_TERMINATING_STATE_AGE_ALLOWED":900,"MAXIMUM_TERMINATING_STATE_AGE_ALLOWED_WITHOUT_UPDATE":300,"TIME_ENGINE_INACTIVE_UNTIL_TERMINATION":300,"TIME_ENGINE_INACTIVE_UNTIL_UNHEALTHY":60,"TIME_INACTIVE_UNTIL_TERMINATION":2700}}` | Parameters for Engine pod (aka "pipeline" orchestrator). |
| runtime.engine.affinity | object | `{}` | Set affinity |
| runtime.engine.command | list | `["npm","run","start"]` | Set container command. |
| runtime.engine.env | object | `{"CF_TELEMETRY_LOGS_LEVEL":"debug","CF_TELEMETRY_OTEL_ALLOW_HTTP_INSTRUMENTATION":"false","CF_TELEMETRY_OTEL_ENABLE":"true","CF_TELEMETRY_PROMETHEUS_ENABLE":"false","CF_TELEMETRY_PROMETHEUS_ENABLE_PROCESS_METRICS":"false","CF_TELEMETRY_PROMETHEUS_HOST":"0.0.0.0","CF_TELEMETRY_PROMETHEUS_PORT":"9100","CF_TELEMETRY_PYROSCOPE_ENABLE":"false","CONTAINER_LOGGER_EXEC_CHECK_INTERVAL_MS":1000,"DOCKER_REQUEST_TIMEOUT_MS":30000,"FORCE_COMPOSE_SERIAL_PULL":false,"LOGGER_LEVEL":"debug","LOG_OUTGOING_HTTP_REQUESTS":false,"METRICS_PROMETHEUS_COLLECT_PROCESS_METRICS":false,"METRICS_PROMETHEUS_ENABLED":false,"METRICS_PROMETHEUS_ENABLE_LEGACY_METRICS":false,"METRICS_PROMETHEUS_HOST":"0.0.0.0","METRICS_PROMETHEUS_PORT":9100,"METRICS_PROMETHEUS_SCRAPE_TIMEOUT":"15000","METRICS_SCRAPE_TIMEOUT_MS":"0","OTEL_EXPORTER_OTLP_COMPRESSION":"gzip","OTEL_EXPORTER_OTLP_ENDPOINT":"http://localhost:4317","OTEL_EXPORTER_OTLP_PROTOCOL":"grpc","OTEL_EXPORTER_PROMETHEUS_HOST":"0.0.0.0","OTEL_EXPORTER_PROMETHEUS_PORT":"9464","OTEL_LOGS_EXPORTER":"none","OTEL_METRICS_EXPORTER":"otlp","OTEL_METRIC_EXPORT_INTERVAL":"10000","OTEL_METRIC_EXPORT_TIMEOUT":"5000","OTEL_SEMCONV_STABILITY_OPT_IN":"http","OTEL_TRACES_EXPORTER":"none","OTEL_TRACES_SAMPLER":"parentbased_always_on","PYROSCOPE_SERVER_ADDRESS":"","TRUSTED_QEMU_IMAGES":"tonistiigi/binfmt"}` | Set additional env vars. |
| runtime.engine.env.CF_TELEMETRY_LOGS_LEVEL | string | `"debug"` | Level of logging for engine |
| runtime.engine.env.CF_TELEMETRY_OTEL_ALLOW_HTTP_INSTRUMENTATION | string | `"false"` | Enable OTel HTTP instrumentation. Make sure to sanitize `url.full` and `url.query` span attributes on collector before enabling this flag, as it may contain sensitive information. |
| runtime.engine.env.CF_TELEMETRY_OTEL_ENABLE | string | `"true"` | Enable OpenTelemetry signals (logs, metrics, traces) |
| runtime.engine.env.CF_TELEMETRY_PROMETHEUS_ENABLE | string | `"false"` | Enable Prometheus server (used solely to emit process metrics, if CF_TELEMETRY_PROMETHEUS_ENABLE_PROCESS_METRICS=true) If enabled, make sure to disable legacy metrics by specifying METRICS_PROMETHEUS_ENABLED=false. |
| runtime.engine.env.CF_TELEMETRY_PROMETHEUS_ENABLE_PROCESS_METRICS | string | `"false"` | Enable collecting process metrics |
| runtime.engine.env.CF_TELEMETRY_PROMETHEUS_HOST | string | `"0.0.0.0"` | Host for Prometheus metrics server |
| runtime.engine.env.CF_TELEMETRY_PROMETHEUS_PORT | string | `"9100"` | Port for Prometheus metrics server |
| runtime.engine.env.CF_TELEMETRY_PYROSCOPE_ENABLE | string | `"false"` | Enable Pyroscope profiling. If enabled, the Pyroscope server address must be set in PYROSCOPE_SERVER_ADDRESS. |
| runtime.engine.env.CONTAINER_LOGGER_EXEC_CHECK_INTERVAL_MS | int | `1000` | Interval to check the exec status in the container-logger |
| runtime.engine.env.DOCKER_REQUEST_TIMEOUT_MS | int | `30000` | Timeout while doing requests to the Docker daemon |
| runtime.engine.env.FORCE_COMPOSE_SERIAL_PULL | bool | `false` | If "true", composition images will be pulled sequentially |
| runtime.engine.env.LOGGER_LEVEL | string | `"debug"` | Level of logging for engine |
| runtime.engine.env.LOG_OUTGOING_HTTP_REQUESTS | bool | `false` | Enable debug-level logging of outgoing HTTP/HTTPS requests. Use with caution, as it may log sensitive information. |
| runtime.engine.env.METRICS_PROMETHEUS_COLLECT_PROCESS_METRICS | bool | `false` | DEPRECATED: Use OpenTelemetry metrics instead. This option enables process metrics and will be removed in a future release. |
| runtime.engine.env.METRICS_PROMETHEUS_ENABLED | bool | `false` | DEPRECATED: Use OpenTelemetry metrics instead. This option enables Prometheus metrics and will be removed in a future release. If enabled, make sure to disable newest metrics by specifying CF_TELEMETRY_PROMETHEUS_ENABLE=false. |
| runtime.engine.env.METRICS_PROMETHEUS_ENABLE_LEGACY_METRICS | bool | `false` | DEPRECATED: Use OpenTelemetry metrics instead. This option enables legacy metrics and will be removed in a future release. |
| runtime.engine.env.METRICS_PROMETHEUS_HOST | string | `"0.0.0.0"` | DEPRECATED: Use OpenTelemetry metrics instead. This options sets the host for Prometheus metrics server and will be removed in a future release. |
| runtime.engine.env.METRICS_PROMETHEUS_PORT | int | `9100` | DEPRECATED: Use OpenTelemetry metrics instead. This options sets the port for Prometheus metrics server and will be removed in a future release. |
| runtime.engine.env.METRICS_PROMETHEUS_SCRAPE_TIMEOUT | string | `"15000"` | DEPRECATED: Use OpenTelemetry metrics instead. This options sets exit timeout for Prometheus metrics server and will be removed in a future release. If set, the engine will wait <timeout>ms for the scrape before exiting. |
| runtime.engine.env.METRICS_SCRAPE_TIMEOUT_MS | string | `"0"` | On exit, wait <timeout>ms for the scrape before exiting. No waiting will be done if set to 0. If OTEL_METRICS_EXPORTER=prometheus, it's recommended to set this to 4×scrape_interval. |
| runtime.engine.env.OTEL_EXPORTER_OTLP_COMPRESSION | string | `"gzip"` | Specifies the compression algorithm to be used for all telemetry data. Ref: https://opentelemetry.io/docs/specs/otel/protocol/exporter/ |
| runtime.engine.env.OTEL_EXPORTER_OTLP_ENDPOINT | string | `"http://localhost:4317"` | Base endpoint URL for all OpenTelemetry signals. Ref: https://opentelemetry.io/docs/languages/sdk-configuration/otlp-exporter/ |
| runtime.engine.env.OTEL_EXPORTER_OTLP_PROTOCOL | string | `"grpc"` | Specifies the OTLP transport protocol to be used for all telemetry data. Ref: https://opentelemetry.io/docs/languages/sdk-configuration/otlp-exporter/ |
| runtime.engine.env.OTEL_EXPORTER_PROMETHEUS_HOST | string | `"0.0.0.0"` | Host used by the Prometheus OTel metrics exporter if OTEL_METRICS_EXPORTER=prometheus |
| runtime.engine.env.OTEL_EXPORTER_PROMETHEUS_PORT | string | `"9464"` | Port used by the Prometheus OTel metrics exporter if OTEL_METRICS_EXPORTER=prometheus |
| runtime.engine.env.OTEL_LOGS_EXPORTER | string | `"none"` | OTel Logs exporter to be used. Ref: https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/ |
| runtime.engine.env.OTEL_METRICS_EXPORTER | string | `"otlp"` | OTel metrics exporter to be used. Set to "prometheus" to export metrics in Prometheus format. If set to "prometheus", it's recommended to set METRICS_SCRAPE_TIMEOUT_MS=4×scrape_interval. Ref: https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/ |
| runtime.engine.env.OTEL_METRIC_EXPORT_INTERVAL | string | `"10000"` | The time interval (in milliseconds) between the start of two export attempts for push metric exporters, such as "otlp". Ref: https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/ |
| runtime.engine.env.OTEL_METRIC_EXPORT_TIMEOUT | string | `"5000"` | Maximum allowed time (in milliseconds) to export data for push metric exporters, such as "otlp". Ref: https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/ |
| runtime.engine.env.OTEL_SEMCONV_STABILITY_OPT_IN | string | `"http"` | Emit the stable HTTP and networking OTel conventions if CF_TELEMETRY_OTEL_ALLOW_HTTP_INSTRUMENTATION=true. |
| runtime.engine.env.OTEL_TRACES_EXPORTER | string | `"none"` | OTel traces exporter to be used. Ref: https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/ |
| runtime.engine.env.OTEL_TRACES_SAMPLER | string | `"parentbased_always_on"` | OTel sampler to be used for traces. Ref: https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/ |
| runtime.engine.env.PYROSCOPE_SERVER_ADDRESS | string | `""` | Pyroscope server address |
| runtime.engine.env.TRUSTED_QEMU_IMAGES | string | `"tonistiigi/binfmt"` | Trusted QEMU images used for docker builds - when left blank defaults to .runtime.engine.runtimeImages.DEFAULT_QEMU_IMAGE value |
| runtime.engine.image | object | `{"digest":"sha256:1dff082bed386f008462f15c2d34b8da23c5646d61829fb0a22325530510a2ac","pullPolicy":"IfNotPresent","registry":"quay.io","repository":"codefresh/engine","tag":"1.179.3"}` | Set image. |
| runtime.engine.nodeSelector | object | `{}` | Set node selector. |
| runtime.engine.podAnnotations | object | `{}` | Set pod annotations. |
| runtime.engine.podLabels | object | `{}` | Set pod labels. |
| runtime.engine.resources | object | `{"limits":{"cpu":"1000m","memory":"2048Mi"},"requests":{"cpu":"100m","memory":"128Mi"}}` | Set resources. |
| runtime.engine.runtimeImages | object | See below. | Set system(base) runtime images. |
| runtime.engine.runtimeImagesRegisty | string | `""` | Override docker image registry for runtime images. |
| runtime.engine.schedulerName | string | `""` | Set scheduler name. |
| runtime.engine.serviceAccount | string | `"codefresh-engine"` | Set service account for pod. |
| runtime.engine.terminationGracePeriodSeconds | int | `180` | Set termination grace period. |
| runtime.engine.tolerations | list | `[]` | Set tolerations. |
| runtime.engine.userEnvVars | list | `[]` | Set extra env vars |
| runtime.engine.workflowLimits | object | `{"MAXIMUM_ALLOWED_TIME_BEFORE_PRE_STEPS_SUCCESS":600,"MAXIMUM_ALLOWED_WORKFLOW_AGE_BEFORE_TERMINATION":86400,"MAXIMUM_ELECTED_STATE_AGE_ALLOWED":900,"MAXIMUM_POST_STEPS_GRACE_PERIOD_MINUTES":30,"MAXIMUM_RETRY_ATTEMPTS_ALLOWED":20,"MAXIMUM_TERMINATING_STATE_AGE_ALLOWED":900,"MAXIMUM_TERMINATING_STATE_AGE_ALLOWED_WITHOUT_UPDATE":300,"TIME_ENGINE_INACTIVE_UNTIL_TERMINATION":300,"TIME_ENGINE_INACTIVE_UNTIL_UNHEALTHY":60,"TIME_INACTIVE_UNTIL_TERMINATION":2700}` | Set workflow limits. |
| runtime.engine.workflowLimits.MAXIMUM_ALLOWED_TIME_BEFORE_PRE_STEPS_SUCCESS | int | `600` | Maximum time allowed to the engine to wait for the pre-steps (aka "Initializing Process") to succeed; seconds. |
| runtime.engine.workflowLimits.MAXIMUM_ALLOWED_WORKFLOW_AGE_BEFORE_TERMINATION | int | `86400` | Maximum time for workflow execution; seconds. |
| runtime.engine.workflowLimits.MAXIMUM_ELECTED_STATE_AGE_ALLOWED | int | `900` | Maximum time allowed to workflow to spend in "elected" state; seconds. |
| runtime.engine.workflowLimits.MAXIMUM_POST_STEPS_GRACE_PERIOD_MINUTES | int | `30` | Maximum time for internal build chores before termination; minutes. For on-prem installations may be overridden by the platform admin. |
| runtime.engine.workflowLimits.MAXIMUM_RETRY_ATTEMPTS_ALLOWED | int | `20` | Maximum retry attempts allowed for workflow. |
| runtime.engine.workflowLimits.MAXIMUM_TERMINATING_STATE_AGE_ALLOWED | int | `900` | Maximum time allowed to workflow to spend in "terminating" state until force terminated; seconds. |
| runtime.engine.workflowLimits.MAXIMUM_TERMINATING_STATE_AGE_ALLOWED_WITHOUT_UPDATE | int | `300` | Maximum time allowed to workflow to spend in "terminating" state without logs activity until force terminated; seconds. |
| runtime.engine.workflowLimits.TIME_ENGINE_INACTIVE_UNTIL_TERMINATION | int | `300` | Time since the last health check report after which workflow is terminated; seconds. |
| runtime.engine.workflowLimits.TIME_ENGINE_INACTIVE_UNTIL_UNHEALTHY | int | `60` | Time since the last health check report after which the engine is considered unhealthy; seconds. |
| runtime.engine.workflowLimits.TIME_INACTIVE_UNTIL_TERMINATION | int | `2700` | Time since the last workflow logs activity after which workflow is terminated; seconds. |
| runtime.gencerts | object | See below | Parameters for `gencerts-dind` post-upgrade/install hook |
| runtime.inCluster | bool | `true` | (for On-Premise only) Set inCluster runtime |
| runtime.kubeconfigFilePath | string | `""` | (for On-Premise only) Set kubeconfig name and path |
| runtime.patch | object | See below | Parameters for `runtime-patch` post-upgrade/install hook |
| runtime.patch.cronjob | object | `{"affinity":{},"enabled":true,"failedJobsHistory":1,"image":{"digest":"sha256:bbf49935b078eb0f282fec4ff674eea55f880b101809c6415e3ead7a0c729261","registry":"quay.io","repository":"codefresh/cli","tag":"0.89.3-rootless"},"nodeSelector":{},"podSecurityContext":{},"resources":{},"schedule":"0/5 * * * *","successfulJobsHistory":1,"tolerations":[]}` | CronJob to update the runtime on schedule |
| runtime.rbac | object | `{"create":true,"rules":[]}` | RBAC parameters |
| runtime.rbac.create | bool | `true` | Create RBAC resources |
| runtime.rbac.rules | list | `[]` | Add custom rule to the engine role |
| runtime.runtimeExtends | list | `["system/default/hybrid/k8s_low_limits"]` | Set parent runtime to inherit. Should not be changes. Parent runtime is controlled from Codefresh side. |
| runtime.serviceAccount | object | `{"annotations":{},"create":true}` | Set annotation on engine Service Account Ref: https://codefresh.io/docs/docs/administration/codefresh-runner/#injecting-aws-arn-roles-into-the-cluster |
| serviceMonitor | object | See below | Add serviceMonitor |
| serviceMonitor.main.enabled | bool | `false` | Enable service monitor for dind pods |
| storage.azuredisk.cachingMode | string | `"None"` |  |
| storage.azuredisk.skuName | string | `"Premium_LRS"` | Set storage type (`Premium_LRS`) |
| storage.backend | string | `"local"` | Set backend volume type (`local`/`ebs`/`ebs-csi`/`gcedisk`/`azuredisk`) |
| storage.ebs.accessKeyId | string | `""` | Set AWS_ACCESS_KEY_ID for volume-provisioner (optional) Ref: https://codefresh.io/docs/docs/installation/codefresh-runner/#dind-volume-provisioner-permissions |
| storage.ebs.accessKeyIdSecretKeyRef | object | `{}` | Existing secret containing AWS_ACCESS_KEY_ID. |
| storage.ebs.availabilityZone | string | `"us-east-1a"` | Set EBS volumes availability zone (required) |
| storage.ebs.encrypted | string | `"false"` | Enable encryption (optional) |
| storage.ebs.kmsKeyId | string | `""` | Set KMS encryption key ID (optional) |
| storage.ebs.secretAccessKey | string | `""` | Set AWS_SECRET_ACCESS_KEY for volume-provisioner (optional) Ref: https://codefresh.io/docs/docs/installation/codefresh-runner/#dind-volume-provisioner-permissions |
| storage.ebs.secretAccessKeySecretKeyRef | object | `{}` | Existing secret containing AWS_SECRET_ACCESS_KEY |
| storage.ebs.volumeType | string | `"gp2"` | Set EBS volume type (`gp2`/`gp3`/`io1`) (required) |
| storage.fsType | string | `"ext4"` | Set filesystem type (`ext4`/`xfs`) |
| storage.fullnameOverride | string | `""` | Override storage class name for dind volumes |
| storage.gcedisk.availabilityZone | string | `"us-west1-a"` | Set GCP volume availability zone |
| storage.gcedisk.serviceAccountJson | string | `""` | Set Google SA JSON key for volume-provisioner (optional) |
| storage.gcedisk.serviceAccountJsonSecretKeyRef | object | `{}` | Existing secret containing containing Google SA JSON key for volume-provisioner (optional) |
| storage.gcedisk.volumeType | string | `"pd-ssd"` | Set GCP volume backend type (`pd-ssd`/`pd-standard`) |
| storage.local.volumeParentDir | string | `"/var/lib/codefresh/dind-volumes"` | Set volume path on the host filesystem |
| storage.mountAzureJson | bool | `false` |  |
| volumeProvisioner | object | See below | Volume Provisioner parameters |
| volumeProvisioner.affinity | object | `{}` | Set affinity |
| volumeProvisioner.dind-lv-monitor | object | See below | `dind-lv-monitor` DaemonSet parameters (local volumes cleaner) |
| volumeProvisioner.enabled | bool | `true` | Enable volume-provisioner |
| volumeProvisioner.env | object | `{}` | Add additional env vars |
| volumeProvisioner.image | object | `{"digest":"sha256:94323807949da518a051fc8d95947da32f9276bfb78388cb133b2f38de818838","registry":"quay.io","repository":"codefresh/dind-volume-provisioner","tag":"1.35.4"}` | Set image |
| volumeProvisioner.name | string | `""` | Set volume-provisioner deployment name |
| volumeProvisioner.nodeSelector | object | `{}` | Set node selector |
| volumeProvisioner.podAnnotations | object | `{}` | Set pod annotations |
| volumeProvisioner.podSecurityContext | object | See below | Set security context for the pod |
| volumeProvisioner.rbac | object | `{"create":true,"rules":[]}` | RBAC parameters |
| volumeProvisioner.rbac.create | bool | `true` | Create RBAC resources |
| volumeProvisioner.rbac.rules | list | `[]` | Add custom rule to the role |
| volumeProvisioner.replicasCount | int | `1` | Set number of pods |
| volumeProvisioner.resources | object | `{}` | Set resources |
| volumeProvisioner.serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | Service Account parameters |
| volumeProvisioner.serviceAccount.annotations | object | `{}` | Additional service account annotations |
| volumeProvisioner.serviceAccount.create | bool | `true` | Create service account |
| volumeProvisioner.serviceAccount.name | string | `""` | Override service account name |
| volumeProvisioner.tolerations | list | `[]` | Set tolerations |
| volumeProvisioner.updateStrategy | object | `{"type":"Recreate"}` | Upgrade strategy |
