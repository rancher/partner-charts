# Overview
Helm Chart for Weka wekafs CSI driver deployment

# Usage

## Build charts
> **NOTE**: To simplify source control and packaging process, software versions and git tags are not stored in repository. 
> For this reason, make is necessary.

```shell
make
```

## Install driver
 
 - Optionally modify values.yaml 
 - Install the driver:
   ```
   helm install csi-wekafsplugin --namespace csi-wekafsplugin --create-namespace .
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