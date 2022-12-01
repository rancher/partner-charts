# Upgrade Notes for Upgrading MongoDB Chart

Notes on upgrading Shipa can also be found at <https://learn.shipa.io/docs/upgrading-self-managed-shipa>.

By default, Shipa installs a MongoDB instance within the cluster for demonstration purposes. Ideally, an externally managed MongoDB should be used, but for those who are just trying out Shipa, this is a quick way to get up and running. Older versions of the Shipa Helm Chart installed MongoDB using the stable/mongodb-replicaset dependent chart, however this chart has been deprecated and now the officially recommended chart to use is the one maintained by Bitnami. By default, Shipa will now install MongoDB based on the Bitnami chart, but in an upgrade scenario there may be configuration required in order to proceed.

## Fresh install

For a fresh install, using the default values provided in this chart, a MongoDB instance will be created using the Bitnami mongodb chart.

## Upgrading when previously running MongoDB from stable/mongodb-replicaset chart

If Shipa was initially installed using Shipa chart version 1.6.3 or prior, there are a few options.

### Auto-upgrading MongoDB

The Shipa chart can attempt to automatically upgrade the MongoDB chart if the number of replicas for the MongoDB statefulset is 1 and the name of the persistent volume claim is provided to Shipa.

### Manual upgrade

To manually upgrade

```bash
export MONGO_NAMESPACE="$(kubectl get po -A -l app=mongodb-replicaset -o jsonpath='{.items[0].metadata.namespace}')"
export MONGO_POD="$(kubectl get po -A -l app=mongodb-replicaset -o jsonpath='{.items[0].metadata.name}')"
export MONGO_PVC="$(kubectl get pvc -n ${MONGO_NAMESPACE} -l app=mongodb-replicaset -o jsonpath='{.items[0].metadata.name}')"
export SHIPA_DEPLOYMENT="$(kubectl get deployments.apps -n ${MONGO_NAMESPACE} -l app.kubernetes.io/instance=shipa -o name | grep -e '.*-api$')"
export SHIPA_RELEASE="$(kubectl get deployments.apps -n ${MONGO_NAMESPACE} -l app.kubernetes.io/instance=shipa -o jsonpath='{.items[0].metadata.annotations.meta\.helm\.sh\/release-name}')"

if [[ -z "${MONGO_NAMESPACE}" || -z "${MONGO_POD}" || -z "${MONGO_PVC}" || -z "${SHIPA_DEPLOYMENT}" || -z "${SHIPA_RELEASE}" ]]; then
  echo "[ERROR] Could not pull required cluster information."
  exit 1
fi

# Stop Shipa API
kubectl scale ${SHIPA_DEPLOYMENT} --replicas=0 -n ${SHIPA_SYSTEM_NAMESPACE}
sleep 15

# Export data
kubectl exec -it -n ${MONGO_NAMESPACE} ${MONGO_POD} -c mongodb-replicaset -- mongodump -d shipa --gzip --archive=/tmp/mongobackup.gzip
kubectl cp -n ${MONGO_NAMESPACE} ${MONGO_POD}:/tmp/mongobackup.gzip /tmp/mongobackup.gzip -c mongodb-replicaset
if [[ ! -s /tmp/mongobackup.gzip ]]; then
  echo "[ERROR] Backup is missing or empty. Expected locally at /tmp/mongobackup.gzip"
  exit 1
fi
if ! gunzip --test /tmp/mongobackup.gzip; then
  echo "[ERROR] Backup appears to be corrupt."
  exit 1
fi

# Delete mongo components
kubectl delete svc -n ${MONGO_NAMESPACE} -l app=mongodb-replicaset
kubectl delete statefulsets.apps -n ${MONGO_NAMESPACE} -l app=mongodb-replicaset
kubectl delete configmaps -n ${MONGO_NAMESPACE} -l app=mongodb-replicaset
kubectl delete persistentvolumeclaims -n ${MONGO_NAMESPACE} -l app=mongodb-replicaset
sleep 15

# Helm upgrade (provide all your override values here)
helm upgrade ${SHIPA_RELEASE} -n ${MONGO_NAMESPACE} --timeout=15m ...

# Wait for MongoDB to be ready
kubectl wait --for=condition=ready --timeout=5m po -l app.kubernetes.io/name=mongodb -n ${MONGO_NAMESPACE}

# Import data
export MONGO_POD="$( kubectl get po -n ${MONGO_NAMESPACE} -l app.kubernetes.io/name=mongodb -o jsonpath='{.items[0].metadata.name}')"
kubectl cp -n ${MONGO_NAMESPACE} /tmp/mongobackup.gzip ${MONGO_POD}:/tmp/mongobackup.gzip -c mongodb
kubectl exec -it -n ${SHIPA_SYSTEM_NAMESPACE} ${MONGO_POD} -c mongodb -- mongorestore -d shipa --gzip --archive=/tmp/mongobackup.gzip

# Restart the Shipa API
kubectl scale ${SHIPA_DEPLOYMENT} --replicas=1 -n ${MONGO_NAMESPACE}
```
