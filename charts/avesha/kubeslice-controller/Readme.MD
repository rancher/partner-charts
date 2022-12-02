# Kubeslice Enterprise Controller Helm Charts


The KubeSlice Controller is installed in one of the clusters and provides a central configuration management system, for slices across multiple clusters. Please refer to the [documentation](https://docs.avesha.io/documentation/enterprise/0.2.0/architecture) for more details.

# Usage

[Helm](https://helm.sh) must be installed to use the charts.
Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

Once Helm is set up properly, add the repo as follows:

```console
helm repo add kubeslice https://kubeslice.aveshalabs.io/repository/kubeslice-helm-ent-prod/ 
```

You can then run `helm search repo kubeslice` to see the charts.

## Setting Up Kubeslice Controller

### Install Chart

See [Kubeslice Controller Installation](https://docs.avesha.io/documentation/enterprise/0.2.0/getting-started-with-kind-clusters#installing-the-kubeslice-controller) for instructions on istalling worker operator on [`kind`](https://kind.sigs.k8s.io/) for non-production use.

For setting up Kubeslice Controller on other cloud platforms, refer to the [Kubeslice Controller Installation on Cloud](https://docs.avesha.io/documentation/enterprise/0.2.0/getting-started-with-cloud-clusters/installing-kubeslice/installing-the-kubeslice-controller).

### Uninstall Chart

Please refer the following Kubeslice Controller [uninstallation](https://docs.avesha.io/documentation/enterprise/0.2.0/getting-started-with-cloud-clusters/uninstalling-kubeslice/) steps

### Upgrading Chart

```console
helm upgrade [RELEASE_NAME] kubeslice/kubeslice-controller [flags]
```

# Kubeslice Manager Helm Charts


KubeSlice Manager is a UI application to register clusters and manage application slices. It connects to the KubeSlice Controller API gateway to access data. Users can log in using a service account to manage the slices. Please refer to the [documentation](https://docs.avesha.io/documentation/enterprise/0.2.0/architecture) for more details.

# Usage

[Helm](https://helm.sh) must be installed to use the charts.
Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

Once Helm is set up properly, add the repo as follows:

```console
helm repo add kubeslice https://kubeslice.aveshalabs.io/repository/kubeslice-helm-ent-prod/ 
```

You can then run `helm search repo kubeslice` to see the charts.

## Setting Up Kubeslice Manager

### Install Chart

See [Kubeslice Manager Installation](https://docs.avesha.io/documentation/enterprise/0.2.0/getting-started-with-kind-clusters#installing-the-kubeslice-manager) for instructions on istalling Kubeslice Manager on [`kind`](https://kind.sigs.k8s.io/) for non-production use.

For setting up Kubeslice Manager on other cloud platforms, refer to the [Kubeslice Manager Installation on Cloud](https://docs.avesha.io/documentation/enterprise/0.2.0/getting-started-with-cloud-clusters/installing-kubeslice/installing-the-kubeslice-controller#installing-the-kubeslice-manager).

### Uninstall Chart

Please refer the following Kubeslice Manager [uninstallation](https://docs.avesha.io/documentation/enterprise/0.2.0/getting-started-with-cloud-clusters/uninstalling-kubeslice/) steps

### Upgrading Chart

```console
helm upgrade [RELEASE_NAME] kubeslice/kubeslice-ui [flags]
```

Guide
---
A full and comprehensive documentation is available on our enterprise [documentation](https://docs.avesha.io/documentation/enterprise/0.2.0/) website.


