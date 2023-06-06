# Kubeslice Enterprise Controller Helm Charts

## Prerequisites
📖 Follow the overview and registration [documentation](https://docs.avesha.io/documentation/enterprise/1.0.0/deployment-partners/deploying-kubeslice-on-rancher/)

- Create and configure the controller cluster following instructions in the prerequisites section [documentation](https://docs.avesha.io/documentation/enterprise/1.0.0/deployment-partners/deploying-kubeslice-on-rancher/installing-the-kubeslice-controller-on-rancher)
- Copy the chart version from the upper right hand section of this page [VERSION parameter need during install and upgrade]
- Click on the download chart link from the upper right hand section of this page, save it to location available from command prompt 
- Untar the chart to get the values.yaml file, update values.yaml with the follwing information
  - cluster end point [documentation](https://docs.avesha.io/documentation/enterprise/1.0.0/deployment-partners/deploying-kubeslice-on-rancher/installing-the-kubeslice-controller-on-rancher#getting-the-controller-cluster-endpoint)
  - helm repository username, password and email [From registration]


# Installation

Add the repo as follows:

```console
helm repo add kubeslice-rancher https://kubeslice.github.io/rancher-avesha-charts/
```

### Install KubeSlice Controller
```console
export KUBECONFIG=<CONTROLLER CLUSTER KUBECONFIG>
helm install --namespace=kubeslice-controller --create-namespace kubeslice-controller kubeslice-rancher/kubeslice-controller --timeout=10m0s --values=<LOCATION OF values.yaml> --version=<VERSION> --wait=true 
```

### Upgrading KubeSlice Controller

```console
helm upgrade --history-max=5 --namespace=kubeslice-controller kubeslice-controller kubeslice-rancher/kubeslice-controller --timeout=10m0s --values=<LOCATION OF values.yaml> --version=<VERSION> --wait=true 
```

### Uninstall KubeSlice Controller
- Follow instructions [documentation](https://docs.avesha.io/documentation/enterprise/1.0.0/getting-started-with-cloud-clusters/uninstalling-kubeslice/uninstalling-the-kubeslice-controller/)

```console
export KUBECONFIG=<CONTROLLER CLUSTER KUBECONFIG>
helm uninstall --namespace=kubeslice-controller --timeout=10m0s --wait=true kubeslice-controller
```


