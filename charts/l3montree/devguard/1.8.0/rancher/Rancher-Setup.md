# Rancher (local dev)

## On MacOS: run inside a Linux VM

OrbStack / Docker Desktop for macOS don't support nested containers (DinD)
properly. The `rancher/rancher` all-in-one image runs an embedded k3s with its
**own** containerd inside the container. On OrbStack that inner containerd cannot
mount `/proc` into pod sandboxes (`read-only file system`), so **no pod ever
starts** — CoreDNS, the fleet helm-operation pods, and the cluster agent all
fail, and Rancher hangs during bootstrap (`RDPClient: Dialer is not built yet…`).

**The fix is to run Rancher inside a real Linux VM, which has a genuine kernel and
supports nested containers. This tutorial assumes that you are using OrbStack on MacOS.**

### 1. Create the VM

```bash
orb create ubuntu rancher-vm
```

### 2. Install Docker in the VM

```bash
orb -m rancher-vm bash -c '
  curl -fsSL https://get.docker.com | sudo sh
  sudo usermod -aG docker $(whoami)
'
```

### 3. Deploy Rancher on the VM's native filesystem

Keep the data on the VM's ext4 filesystem — **not** the mounted Mac path
(`/Users/...` is virtiofs and reintroduces mount problems for the k3s data).

```bash
orb -m rancher-vm bash -c '
  mkdir -p ~/rancher
  cp /Users/'"$USER"'/projects/l3montree/rancher/compose.yml ~/rancher/compose.yml
  cd ~/rancher && docker compose up -d
'
```

### 4. Access Rancher

```bash
orb list   # find the VM IP (e.g. 192.168.139.54)

# bootstrap password
orb -m rancher-vm docker logs rancher-rancher-1 2>&1 | grep "Bootstrap Password:"
```

Open `https://rancher-vm.orb.local/` in the browser and accept the self-signed cert.

### Managing / resetting the VM

```bash
orb -m rancher-vm bash -c 'cd ~/rancher && docker compose logs -f'   # follow logs
orb -m rancher-vm bash -c 'cd ~/rancher && docker compose down'      # stop
orb -m rancher-vm bash -c 'cd ~/rancher && docker compose rm -v'     # delete incl. anon volumes
orb -m rancher-vm bash -c 'rm -rf ~/rancher/data'                    # wipe state for a clean start
orb delete rancher-vm                                                # delete whole VM
```

## Setup DevGuard

- Setup custom DNS
  - Add the following entries to the `/etc/hosts` file
  - ```bash
      # sudo nano /etc/hosts
      127.0.0.1 api.devguard.rancher-local.de
      127.0.0.1 devguard.rancher-local.de
      127.0.0.1 rancher-local.de
    ```
- Setup Reverse-Proxy
  - `brew install caddy`
  - `caddy run --config Caddyfile`
- Install the [local path provisioner](https://github.com/rancher/local-path-provisioner):
  - Click ☰ > Cluster Management.
  - Go to the cluster you want to access with kubectl and click Explore.
  - In the top navigation menu, click the Kubectl Shell button. Use the window that opens to interact with your Kubernetes cluster.
  - `kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.36/deploy/local-path-storage.yaml`
- Add Test-Repo
  - Login to Rancher -> Apps -> Repositories -> Create: https://rancher-vm.orb.local/dashboard/c/local/apps/catalog.cattle.io.clusterrepo/create
  - Select `Git Repository` and enter URL: https://github.com/l3montree-dev/rancher-partner-charts.git (Branch: main-source)
  - Optional: Disable the official "Partners" Repo - otherwise all apps will appear twice
- Install DevGuard
  - Apps → DevGuard -> Install
  - Create new Namespace `devguard`
  - API Ingress Host: `api.devguard.rancher-local.de`
  - Web Ingress Host: `devguard.rancher-local.de`
  - Storage: `local-path`
- Check under "Deployments" if it's running
  - https://rancher-local.de/dashboard/c/local/explorer/apps.deployment
- Setup Port Forwarding
  - In Rancher select the Cluster and download the Kubeconfig. Copy it to `~/Downloads/kubernetes/rancher-local/config.yaml` and run the following commands to setup the port forwarding
  - ```bash
      export KUBECONFIG=~/Downloads/kubernetes/rancher-local/config.yaml
      # kubectl config get-clusters
      kubectl config unset clusters.local.certificate-authority-data
      kubectl config set-cluster rancher --insecure-skip-tls-verify=true
      kubectl port-forward -n devguard svc/devguard-api-service 8080:8080
      kubectl port-forward -n devguard svc/devguard-web-service 3000:3000
    ```
  - ...
- Uninstall DevGuard
  - Apps -> Installed Apps -> Three dot menu -> Uninstall

In theory you can also use Ranchers proxy URLs but DevGuard doesn't support Prefix Paths properly so it's not possible at this point. E.g. https://rancher-vm.orb.local/api/v1/namespaces/devguard/services/http:devguard-api-service:8080/proxy/api/v1/info (API seems to work but Frontend and especially ORY has issues with it.)
