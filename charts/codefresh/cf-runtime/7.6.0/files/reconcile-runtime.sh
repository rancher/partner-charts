#!/bin/bash

echo "-----"
echo "API_HOST:             ${API_HOST}"
echo "KUBE_CONTEXT:         ${KUBE_CONTEXT}"
echo "KUBE_NAMESPACE:       ${KUBE_NAMESPACE}"
echo "OWNER_NAME:           ${OWNER_NAME}"
echo "RUNTIME_NAME:         ${RUNTIME_NAME}"
echo "CONFIGMAP_NAME:       ${CONFIGMAP_NAME}"
echo "RECONCILE_INTERVAL:   ${RECONCILE_INTERVAL}"
echo "-----"

msg() { echo -e "\e[32mINFO ---> $1\e[0m"; }
err() { echo -e "\e[31mERR ---> $1\e[0m" ; return 1; }


if [ -z "${USER_CODEFRESH_TOKEN}" ]; then
    err "missing codefresh user token. must supply \".global.codefreshToken\" if agent-codefresh-token does not exist"
    exit 1
fi

codefresh auth create-context --api-key ${USER_CODEFRESH_TOKEN} --url ${API_HOST}

while true; do
  msg "Reconciling ${RUNTIME_NAME} runtime"

  sleep $RECONCILE_INTERVAL

  codefresh get re \
      --name ${RUNTIME_NAME} \
      -o yaml \
      | yq 'del(.version, .metadata.changedBy, .metadata.creationTime)' > /tmp/runtime.yaml

  kubectl get cm ${CONFIGMAP_NAME} -n ${KUBE_NAMESPACE} -o yaml \
  | yq 'del(.metadata.resourceVersion, .metadata.uid)' \
  | yq eval '.data["runtime.yaml"] = load_str("/tmp/runtime.yaml")' \
  | kubectl apply -f -
done
