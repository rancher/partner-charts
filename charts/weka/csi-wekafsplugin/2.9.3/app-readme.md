# WekaIO CSI Plugin
[Weka's](https://weka.io) parallel file system delivers the highest performance for the most data-intensive workloads, 
powering solutions to problems the world has never seen before.

This repository hosts the CSI WekaFS driver and all of its build and dependent configuration files to deploy the driver.

## Pre-requisite
- Kubernetes cluster
- Helm v3
- Running version 1.18 or later. Although older versions from 1.13 and up should work, they were not tested
- Weka system pre-configured and Weka client installed and registered in cluster for each Kubernetes node
## Deployment
```shell
helm repo add csi-wekafs https://weka.github.io/csi-wekafs
helm install csi-wekafsplugin csi-wekafs/csi-wekafsplugin --namespace csi-wekafsplugin --create-namespace
```
## Usage
- [Deploy an Example application](https://github.com/weka/csi-wekafs/blob/master/docs/usage.md)
## Additional Documentation
- [Official Weka CSI Plugin documentation](https://docs.weka.io/appendix/weka-csi-plugin)
