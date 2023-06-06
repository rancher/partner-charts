# Kubeslice Enterprise Worker Helm Charts

## Prerequisites 
- KubeSlice Controller needs to be installed
- Create and configure the worker cluster following instructions in prerequisites and "registering the worker cluster" sections [documentation](https://docs.avesha.io/documentation/enterprise/1.0.0/deployment-partners/deploying-kubeslice-on-rancher/installing-the-worker-operator-on-rancher)
- Copy the chart version from the upper right hand section of this page [VERSION parameter need during install and upgrade]
- Click on the download link from the upper right hand section of this page, save it to location available from command prompt <LOCATION OF DOWNLOADED CHART.tgz>
- Untar the chart to get the values.yaml file and edit the following fields 
  - controllerSecret: namespace, endpoint, ca.crt, token 
  - cluster: name, nodeIp, endpoint 
  - imagePullSecrets: username, passowrd and email [use the same info from KubeSlice Controller install]


# Installation

Add the repo:

```console
helm repo add kubeslice-rancher https://kubeslice.github.io/rancher-avesha-charts/
```

### Install Kubeslice Worker

```console
export KUBECONFIG=<WORKER CLUSTER KUBECONFIG>
helm install --namespace=kubeslice-system --create-namespace kubeslice-worker kubeslice-rancher/kubeslice-worker --timeout=10m0s --values=<LOCATION OF values.yaml>  --version=<VERSION> --wait=true 
```

### Upgrading Kubeslice Worker
  
```console
export KUBECONFIG=<WORKER CLUSTER KUBECONFIG>
helm upgrade --history-max=5 --namespace=kubeslice-system kubeslice-worker kubeslice-rancher/kubeslice-worker --timeout=10m0s --values=<LOCATION OF values.yaml> --version=<VERSION> --wait=true
```

### Uninstall Kubeslice Worker
- Follow instructions [documentation](https://docs.avesha.io/documentation/enterprise/1.0.0/getting-started-with-cloud-clusters/uninstalling-kubeslice/deregistering-the-worker-cluster)
  
```console
export KUBECONFIG=<WORKER CLUSTER KUBECONFIG>
helm uninstall  --namespace=kubeslice-system --timeout=10m0s --wait=true kubeslice-worker 
kubectl delete crd serviceexports.networking.kubeslice.io
kubectl delete crd serviceimports.networking.kubeslice.io
kubectl delete crd slicegateways.networking.kubeslice.io
kubectl delete crd slicenodeaffinities.networking.kubeslice.io
kubectl delete crd sliceresourcequotas.networking.kubeslice.io
kubectl delete crd slicerolebindings.networking.kubeslice.io
kubectl delete crd slices.networking.kubeslice.io
kubectl delete ns kubeslice-system
```
