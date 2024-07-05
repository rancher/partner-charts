#!/bin/sh

set -euo pipefail

function logError {
  local _msg="${1}"
  echo -e "[ERROR] ${_msg}\n"
  echo "[ERROR] Automated upgrade of mongodb-replicaset cannot proceed."
  echo "[ERROR] For help with the upgrade process, see https://learn.shipa.io/docs/upgrading-self-managed-shipa"
  exit 1
}

EXISTING_MONGO_INSTALL="$(kubectl -n ${POD_NAMESPACE} get statefulsets.apps -l chart=mongodb-replicaset-3.11.3 -o name)"

if [[ -z "${EXISTING_MONGO_INSTALL}" ]]; then
  echo "[INFO] No deprecated MongoDB instance found."
  exit 0
else
  echo "[INFO] Found deprecated MongoDB instance running in the ${POD_NAMESPACE} namespace."
fi

EXISTING_REPLICA_COUNT="$(kubectl -n ${POD_NAMESPACE} get statefulsets.apps -l chart=mongodb-replicaset-3.11.3 -o jsonpath='{.items[].spec.replicas}')"
[[ ${EXISTING_REPLICA_COUNT} -gt 1 ]] && logError "Automatic database migration cannot occur with more than 1 replica."

EXISTING_PVC="$(kubectl -n ${POD_NAMESPACE} get pvc -l app=mongodb-replicaset -o jsonpath='{.items[].metadata.name}')"
[[ "${EXISTING_PVC}" != "${PERSISTENCE_EXISTING_CLAIM}" ]] && logError "You must provide the existing claim (${EXISTING_PVC}) value as mongodb.persistence.existingClaim to Helm."

EXISTING_STORAGE="$(kubectl get pvc -n ${POD_NAMESPACE} ${EXISTING_PVC} -o jsonpath='{.spec.resources.requests.storage}')"
[[ "${EXISTING_STORAGE}" != "${PERSISTENCE_SIZE}" ]] && logError "Requested size (currently ${PERSISTENCE_SIZE}) needs to be ${EXISTING_STORAGE} as mongodb.persistence.size in Helm to match existing PVC size."

VOLUME_NAME="$(kubectl -n ${POD_NAMESPACE} get pvc ${EXISTING_PVC} -o jsonpath='{.spec.volumeName}')"

echo "[INFO] Changing persistentVolumeReclaimPolicy to 'Retain' on the ${VOLUME_NAME} persistent volume."
kubectl patch pv ${VOLUME_NAME} -p '{"spec": {"persistentVolumeReclaimPolicy": "Retain"}}'

SHIPA_API="${RELEASE_NAME}-api"
echo "[INFO] Shutting down ${SHIPA_API} by setting replicas to 0, to avoid database corruption."
API_REPLICAS=$(kubectl get deployments.apps -n ${POD_NAMESPACE} ${SHIPA_API} -o jsonpath='{.spec.replicas}')
kubectl scale deployments/${SHIPA_API} --replicas=0 -n ${POD_NAMESPACE}

_iterations=0
while [[ $(kubectl get po -n ${POD_NAMESPACE} -l app.kubernetes.io/instance=shipa | wc -l) -ne 0 ]]; do
  _iterations=$((_iterations + 1))
  sleep 2
  [[ ${_iterations} -gt 150 ]] && logError "Shipa API did not shut down for the upgrade to proceed."
done

echo "[INFO] Deleting deprecated MongoDB resources."
kubectl delete configmaps -n ${POD_NAMESPACE} -l app=mongodb-replicaset
kubectl delete all -n ${POD_NAMESPACE} -l app=mongodb-replicaset

echo "[INFO] Setting replicas back to ${API_REPLICAS} for the Shipa API."
kubectl scale deployments/${SHIPA_API} --replicas=${API_REPLICAS} -n ${POD_NAMESPACE}
