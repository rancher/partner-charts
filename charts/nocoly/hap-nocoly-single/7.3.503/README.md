# Nocoly HAP Single-Node Helm Chart

This chart deploys Nocoly HAP as a single-node installation from Rancher Apps or Helm.

## Components

| Component | Purpose | Port |
| --- | --- | --- |
| `app` | Main HAP application services | 8880, exposed through NodePort |
| `sc` | MySQL, MongoDB, Redis, Kafka, ZooKeeper, Elasticsearch, MinIO, and file services | Internal |
| `command` | Code execution service | Internal |
| `doc` | Document preview service | Internal |
| `flink` | Data integration; optional with `flink.enabled=false` | 8081 |

## Prerequisites

- Kubernetes 1.23 or later.
- An existing StorageClass and working provisioner. Use `local-path` only if installed in your single-node cluster; this chart does not install a storage provisioner.
- Access to the public `nocoly` container images.
- Recommended production capacity: 8 CPU cores, 48 GiB RAM, and SSD storage. Minimum test capacity: 8 CPU cores and 32 GiB RAM.
- An external Captain license manager on a Linux AMD64 VM or physical server. Complete the steps below before installing HAP.

## Install Captain first

Captain provides HAP licensing/authorization and runs outside this chart. Its **x.y.z version must match the HAP image version**, not the chart revision: chart `7.3.503` deploys HAP `7.3.5` and requires Captain `7.3.5`.

1. Prepare a Linux AMD64 VM or physical server with a stable address reachable from the Kubernetes pods. Run the following commands as root on a new Captain host, with `curl`, `tar`, Bash, and `setsid` available:

   ```bash
   mkdir -p /opt/nocoly/captain/7.3.5
   cd /opt/nocoly/captain/7.3.5
   curl --fail --location --output hap_captain_linux_amd64.tar.gz \
     https://pdpublic.nocoly.com/7.3.5/hap_captain_linux_amd64.tar.gz
   tar -xzf hap_captain_linux_amd64.tar.gz
   bash ./service.sh start
   ```

   These commands start Captain and its companion installer UI. For this Helm deployment, install the HAP workloads through Rancher/Helm; do not also initialize a Docker Compose HAP deployment from the installer UI. Retain Captain's data (the package defaults to `/data/hap`) and arrange service startup after host reboots.

2. Confirm that the Captain process is listening on TCP `38880`:

   ```bash
   pgrep -x hap_captain
   ss -lntp 'sport = :38880'
   ```

3. Allow traffic from the HAP pods to the Captain host on TCP `38880`. The companion installer UI uses TCP `38881`; it is not the URL to enter in the chart. Use the host address reachable from the cluster, not `localhost` or `127.0.0.1`.
4. Set `hap.captainEndpoint`, for example `http://captain.example.internal:38880`. After deployment, verify that HAP can contact Captain and complete licensing/initial setup. A listening port alone does not prove that authorization is working. Contact [ops@nocoly.com](mailto:ops@nocoly.com) if a license, setup assistance, or a matching Captain package is needed.

The Captain download URL is version-specific. When adopting a new HAP `x.y.z` release, use the matching Captain package and that release's installation instructions. Documentation and links are updated with each chart release. The maintained documentation for the current chart is also available in the [source repository](https://github.com/nocoly/rancher-charts/tree/main/charts/hap-nocoly-single).

## Install

In Rancher, open **Apps > Charts**, select **Nocoly HAP Single-Node**, and choose **Install**. Enter the main access URL, an existing StorageClass, and the reachable Captain endpoint in the required questions. Review the generated values and install.

With Helm:

```bash
helm upgrade --install hap-nocoly-single ./hap-nocoly-single \
  --namespace nocoly \
  --create-namespace \
  --set-string hap.addressMain="http://YOUR_HOST:30880" \
  --set-string hap.captainEndpoint="http://CAPTAIN_HOST:38880" \
  --set-string persistence.storageClass="local-path"
```

## Required values

| Value | Description |
| --- | --- |
| `hap.addressMain` | Browser access URL including the port. It must match the URL used to access HAP. |
| `hap.captainEndpoint` | Required reachable HTTP URL of Captain matching HAP `7.3.5`; default port `38880`. Install Captain first. |
| `persistence.storageClass` | StorageClass used by both persistent volumes. |

## Main values

| Value | Default | Description |
| --- | --- | --- |
| `hap.nodePort` | `30880` | NodePort exposing application port 8880 |
| `hap.apiToken` | Empty | Generates 32 characters on first install and reuses the existing Secret on upgrades; an explicit value supplies or rotates the token |
| `hap.appVersion` | `7.3.5` | HAP application version |
| `flink.enabled` | `true` | Enables Flink data integration |
| `persistence.sharedDataSize` | `30Gi` | Shared data volume mounted at `/data` |
| `persistence.hapDataSize` | `10Gi` | Application data volume mounted at `/data/hap/data` |

## Storage

- `hap-shared-data` is shared by `app`, `sc`, and `flink` and contains databases, object storage, and indexes.
- `hap-data` is mounted by `app` at `/data/hap/data`.
- The chart uses ReadWriteOnce volumes and is intended for a single-node deployment.

## API token

The API token is stored in the `hap-secret` Kubernetes Secret. When `hap.apiToken` is empty, the first installation generates a 32-character alphanumeric token. Upgrades reuse the existing Secret. To rotate the token, run an upgrade with `--set-string hap.apiToken=NEW_VALUE`.

## Access

Open the URL configured in `hap.addressMain` and complete the initial HAP setup.

## Verification and support

```bash
helm status hap-nocoly-single --namespace nocoly
kubectl --namespace nocoly get deployments,pods,pvc
```

Confirm that all enabled components are available, both PVCs are bound, the configured HAP URL opens, and licensing works through Captain. Pod status alone is not a functional test.

The certification test baseline was HAP `7.3.5`, chart `7.3.502`, Rancher `2.14.3`, and RKE2 `v1.35.6+rke2r1` on Ubuntu `24.04.4 LTS` AMD64. The metadata's Kubernetes minimum is not a claim that every version has been tested. See [Nocoly deployment documentation](https://docs-pd.nocoly.com) for support information and contact [ops@nocoly.com](mailto:ops@nocoly.com) for installation, licensing, or version-specific assistance.

## Chart 7.3.503 changes

- Document Captain installation, version matching, endpoint connectivity, and support contact.
- Require an explicit Captain endpoint in both Rancher questions and Helm rendering.
- Keep HAP `7.3.5`, component images, and workload settings unchanged.
