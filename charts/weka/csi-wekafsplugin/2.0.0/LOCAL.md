# Overview
Helm Chart for Weka wekafs CSI driver deployment

# Usage

## Install driver
To install the driver, issue the following command
```
helm install csi-wekafsplugin --namespace csi-wekafsplugin --create-namespace .
```
> **NOTE:** Optionally modify values.yaml or set overrides via Helm command line  

## Uninstall driver
To uninstall a driver, issue the following command
```
helm uninstall csi-wekafsplugin --namespace csi-wekafsplugin -n=csi-wekafsplugin
```

# Upgrade
## Upgrading from versions v0.6.0 and below
> WARNING: Removal of CSI plugin from versions v0.6.0 and below requires checking out an older version of Weka CSI Plugin.
To upgrade from versions before v0.6.0, the previous version must be uninstalled using a cleanup script (deprecated!)
1. Checkout the sources of previous version of the Weka CSI Plugin by using the following command:
   ```shell
   git clone https://github.com/weka/csi-wekafs.git csi-wekafs
   git checkout v0.8.4
   ```
2. Run the cleanup script
   ```
   cd csi-wekafs
   ./deploy/kubernetes-latest/cleanup.sh
   ``` 
   Then proceed to [Helm installation](#install-driver)
## Upgrading from versions below v2.0.0
In version v2.0.0, fsGroup support was added to CSIDriver. Since CSIDriver component is considered immutable by Kubernetes,
upgrading the driver requires a complete removal and reinstallation of the CSI driver.

> **NOTE:** Existing Weka CSI volumes and workloads using those volumes will not be affected by Weka CSI Plugin uninstallation. 
