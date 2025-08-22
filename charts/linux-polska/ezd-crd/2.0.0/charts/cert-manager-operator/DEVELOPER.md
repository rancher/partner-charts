# For developers / Dla deweloperow 
 
## Installing from repo / Instalacja z repo 
 
```bash 
 
export CHART_VERSION=1.1.0
export CHART_NAMESPACE=cert-manager
 
cd charts/charts/cert-manager-operator/${CHART_VERSION} 

 
helm upgrade --install -n ${CHART_NAMESPACE} --create-namespace \
cert-manager .  
 
``` 
## Removing


```bash

helm uninstall -n ${CHART_NAMESPACE} cert-manager

```
