[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/csi-wekafs)](https://artifacthub.io/packages/search?repo=csi-wekafs)
# CSI WekaFS Driver

This repository hosts the CSI WekaFS driver and all of its build and dependent configuration files to deploy the driver.

## Pre-requisite
- Kubernetes cluster of version 1.18 and up, 1.19 and up recommended, 1.13 and up should work but were not tested. 
- Helm v3 must be installed and configured properly
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

