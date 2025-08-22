# For developers
 
## Installing from repo
 
```bash
export RELEASE_NAME=redis-ope
export CHART_NAME=redis-operator
export RELEASE_NAMESPACE=lp-system

git clone git@github.com:SourceMation/charts.git
cd charts/charts/${CHART_NAME}

helm upgrade --install -n ${RELEASE_NAMESPACE} --create-namespace \
${RELEASE_NAME} .
``` 

# Cleaning

```bash
helm uninstall -n ${RELEASE_NAMESPACE} ${RELEASE_NAME}
kubectl get crd -o name |grep 'redis.opstreelabs.in' |xargs kubectl delete
```

# Testing

```bash
kubectl -n ${RELEASE_NAMESPACE} get po
```
