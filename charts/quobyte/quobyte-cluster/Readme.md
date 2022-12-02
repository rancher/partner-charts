# Quobyte Cluster Helm Chart

This Helm Chart will install a Quobyte storage cluster.

## Preparation

You need to specify the infrastructure provider to provision 
storage devices. A sample "values.yaml" looks like this:

``` 
quobyte:
  # Name depends on the cloud environment, e.g. pd-ssd for Google Kubernetes Engine
  # flashStorage: "gp2" # AWS general purpose SSD
  # flashStorage: "Standard_LRS"  # Azure "Standard Locally Redundant Storage"
  flashStorage: "pd-ssd"
  # Storage provider depending to the cloud environment
  # storageProvisioner: "kubernetes.io/aws-ebs"
  # storageProvisioner: "kubernetes.io/azure-disk" 
  storageProvisioner: "kubernetes.io/gce-pd"

``` 

You can inspect the values.yaml for other values to modify, but default should work.

This Helm Chart can be installed as usual:

``` 
helm repo add quobyte https://quobyte.github.io/quobyte-k8s-resources/helm-charts
helm repo update
helm install my-storage-cluster quobyte/quobyte-cluster
``` 


