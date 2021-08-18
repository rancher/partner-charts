# Overview
Helm Chart for Weka wekafs CSI driver deployment

# Usage
## Install driver
 
 - Optionally modify values.yaml 
 - Create a name space for CSI driver deployment by issuing
   ```
   kubectl create namespace csi-wekafsplugin
   ```
 - Install the driver:
   ```
   helm install csi-wekafsplugin --namespace csi-wekafsplugin -n=csi-wekafsplugin ./
   ```

## Uninstall driver
To uninstall a driver, issue the following command
```
helm uninstall csi-wekafsplugin --namespace csi-wekafsplugin -n=csi-wekafsplugin
```

# Upgrade
To upgrade from versions before v0.6.0, first uninstall the previous version using cleanup script:
```
./deploy/kubernetes-latest/cleanup.sh
``` 
Then install as usual.