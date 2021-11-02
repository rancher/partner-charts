
**Note:** The master branch is the main development branch. Please use releases instead of the master branch in order to get stable versions.

# Documentation

Documentation for Shipa can be found at https://learn.shipa.io

# Installation Requirements

1. Kubernetes 1.14+
2. Helm v3

# Defaults 

We create LoadBalancer service to expose Shipa to the internet:
1. 2379 -> etcd 
1. 8080 -> shipa api over http
1. 8081 -> shipa api over https

By default we use dynamic public IP set by a cloud-provider but there is a parameter to use static ip (if you have it):
```bash 
--set service.nginx.loadBalancerIP=35.192.15.168 
```

# Installation

Users can install Shipa on any existing Kubernetes cluster (version 1.10.x and newer), and Shipa leverages Helm charts for the install.

> ⚠️ NOTE: Installing or upgrading Shipa may require downtime in order to perform database migrations.


Below are the steps required to have Shipa installed in your existing Kubernetes cluster:

Create a namespace where the Shipa services should be installed   
```bash
NAMESPACE=shipa-system
kubectl create namespace $NAMESPACE
```
Create the values.override.yaml with the Admin user and password that will be used for Shipa
```bash
cat > values.override.yaml << EOF
auth:
  adminUser: <your email here>
  adminPassword: <your admin password> 
EOF
```
Add Shipa helm repo
```bash
helm repo add shipa-charts https://shipa-charts.storage.googleapis.com
```
Install Shipa
```bash
helm install shipa shipa-charts/shipa -n $NAMESPACE  --timeout=1000s -f values.override.yaml
```

## Upgrading shipa helm chart

```bash
helm upgrade shipa . --timeout=1000 --namespace=$NAMESPACE -f values.override.yaml
```

## Upgrading shipa helm chart if you have Pro license

We have two general ways how to execute helm upgrade if you have Pro license:
* Pass a license file to helm upgrade 

```bash
helm upgrade shipa . --timeout=1000 --namespace=$NAMESPACE -f values.override.yaml -f license.yaml
```
* Merge license key from a license file to values.override.yaml and execute helm upgrade as usual
```bash
cat license.yaml | grep "license:" >> values.override.yaml
```

# CI/CD

Packaging and signing helm charts is automated using Github Actions

Charts are uploaded to multiple buckets based on condition:

1. `shipa-charts-dev`, `push` to `master`, `push` to PR opened against `master`
2. `shipa-charts-cloud`,  `tag` containing `cloud`
3. `shipa-charts`, `tag` not containing `cloud`


Chart name is composed of:
`{last_tag}-{commit_hash}`

For on-prem releases, if tag is not pre-release, meaning it has semantic versioning without RC suffix (ex. 1.3.0, not 1.3.0-rc1), chart name is only `{last_tag}`, as otherwise it is seen by helm chart as development version

### Usage
```
# only first time
helm repo add shipa-dev https://shipa-charts-dev.storage.googleapis.com
helm repo add shipa-cloud https://shipa-charts-cloud.storage.googleapis.com
helm repo add shipa-onprem https://shipa-charts.storage.googleapis.com

# refresh available charts
helm repo update

# check available versions
helm search repo shipa --versions

# check available versions with development versions
helm search repo shipa --versions --devel

# check per repo
helm search repo shipa-dev --versions --devel
helm search repo shipa-cloud --versions --devel
helm search repo shipa-onprem --versions --devel

# helm install
helm install shipa shipa-dev/shipa --version 1.x.x -n shipa-system  --timeout=1000s -f values.override.yaml
```

# Shipa client

If you are looking to operate Shipa from your local machine, we have binaries of shipa client: https://learn.shipa.io/docs/downloading-the-shipa-client

# Collaboration/Contributing

We welcome all feedback or pull requests. If you have any questions feel free to reach us at info@shipa.io
