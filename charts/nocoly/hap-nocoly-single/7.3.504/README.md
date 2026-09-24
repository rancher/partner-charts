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

Before installing this Helm chart, install the external Captain license manager on a Linux AMD64 VM or physical server reachable from the HAP pods. Captain's **x.y.z version must match the HAP image version**. This chart deploys HAP **7.3.5**, so use Captain **7.3.5**.

The following steps use the commands and installation directory from the [official Nocoly installation guide](https://docs-pd.nocoly.com/hap/deployment/docker-compose/standalone/demo#三单机版本安装), with the download version set to match this HAP release. Run them as root on the Captain host.

These steps are for a first installation. Ensure that `wget`, `tar`, Bash, `nohup`, and `setsid` are available and that ports **38880** and **38881** are not already in use. If `/usr/local/MDPrivateDeployment/` already exists, check the existing installation before extracting files into it.

### 1. Download Captain

```bash
wget https://pdpublic.nocoly.com/7.3.5/hap_captain_linux_amd64.tar.gz
```

### 2. Create the installation directory and extract the package

```bash
mkdir /usr/local/MDPrivateDeployment/
```

```bash
tar -zxvf hap_captain_linux_amd64.tar.gz -C /usr/local/MDPrivateDeployment/
```

### 3. Enter the installation directory and start Captain

```bash
cd /usr/local/MDPrivateDeployment/
```

```bash
bash ./service.sh start
```

### 4. Check the management page

Open `http://<CAPTAIN_HOST>:38881` in a browser and confirm that the management page is accessible. Replace `<CAPTAIN_HOST>` with the Captain server's IP address or hostname. Allow access to port **38881** from the administrator's workstation.

The linked guide describes a complete Docker Compose deployment. For this Rancher deployment, use the steps above to start Captain, then deploy the HAP workloads through this Helm chart. Do not perform a separate standalone HAP initialization in the management page.

### 5. Configure the Captain endpoint in Rancher

Allow the HAP pods to reach the Captain service on TCP port **38880**. In the Rancher installation form, set the required `hap.captainEndpoint` value to:

```text
http://<CAPTAIN_HOST>:38880
```

Use an address reachable from the HAP pods. Port **38881** is the management page; port **38880** is the Captain service endpoint used by HAP. Opening the management page does not by itself verify pod-to-Captain connectivity or successful licensing. After deploying HAP, confirm that the application can contact Captain and complete licensing/initial setup.

When the HAP x.y.z version changes, use the matching Captain package and the installation instructions for that release. For installation, licensing, or version-specific assistance, contact [ops@nocoly.com](mailto:ops@nocoly.com).

### 6. Keep Captain available

Keep Captain running and reachable while HAP is in use. The bundled script uses `/data/hap` as the service data path by default; preserve this data when maintaining or upgrading the Captain host. `/usr/local/MDPrivateDeployment/` is the installation directory.

The `bash ./service.sh start` command starts Captain and the companion installer processes; it does not configure automatic startup after a host reboot. Arrange for Captain to start after reboots and verify HAP-to-Captain connectivity again. If you need assistance configuring startup for a Captain-only host, contact [ops@nocoly.com](mailto:ops@nocoly.com).

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

## Chart 7.3.504 changes

- Align Captain download, extraction, and startup commands and the installation directory with the official Nocoly guide, while retaining the HAP-matched Captain 7.3.5 download.
- Clarify first-install prerequisites, the separate management and service ports, data preservation, and restart requirements.
- Keep templates, values, Rancher questions, and component images unchanged from chart 7.3.503. The Captain endpoint validation introduced in 7.3.503 is retained.

## Chart 7.3.503 changes

- Document Captain installation, version matching, endpoint connectivity, and support contact.
- Require an explicit Captain endpoint in both Rancher questions and Helm rendering.
- Keep HAP `7.3.5`, component images, and workload settings unchanged.
