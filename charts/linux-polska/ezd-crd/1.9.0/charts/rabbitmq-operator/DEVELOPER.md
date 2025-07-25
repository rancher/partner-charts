# For developers
 
## Installing from repo
 
```bash
export RELEASE_NAME=rabbitmq-ope
export CHART_NAME=rabbitmq-operator
export RELEASE_NAMESPACE=lp-system

git clone git@github.com:SourceMation/charts.git
cd charts/charts/${CHART_NAME}

helm -n ${RELEASE_NAMESPACE} upgrade --install --create-namespace \ 
${RELEASE_NAME} .
```

# Cleaning

```bash
helm -n ${RELEASE_NAMESPACE} uninstall ${RELEASE_NAME}
kubectl get crd -o name | grep 'rabbitmq.com' | xargs kubectl delete
```

# Testing

```bash
helm -n ${RELEASE_NAMESPACE} test ${RELEASE_NAME}
```
