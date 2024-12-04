#!/bin/bash

echo "-----"
echo "API_HOST:         ${API_HOST}"
echo "AGENT_NAME:       ${AGENT_NAME}"
echo "KUBE_CONTEXT:     ${KUBE_CONTEXT}"
echo "KUBE_NAMESPACE:   ${KUBE_NAMESPACE}"
echo "OWNER_NAME:       ${OWNER_NAME}"
echo "RUNTIME_NAME:     ${RUNTIME_NAME}"
echo "SECRET_NAME:      ${SECRET_NAME}"
echo "-----"

create_agent_secret() {

  kubectl apply -f - <<EOF
  apiVersion: v1
  kind: Secret
  type: Opaque
  metadata:
    name: ${SECRET_NAME}
    namespace: ${KUBE_NAMESPACE}
    labels:
      codefresh.io/internal: "true"
    finalizers:
    - kubernetes
    ownerReferences:
    - apiVersion: apps/v1
      kind: Deploy
      name: ${OWNER_NAME}
      uid: ${OWNER_UID}
  stringData:
    agent-codefresh-token: ${1}
EOF

}

OWNER_UID=$(kubectl get deploy ${OWNER_NAME} --namespace ${KUBE_NAMESPACE} -o jsonpath='{.metadata.uid}')
echo "got owner uid: ${OWNER_UID}"

if [ ! -z "${AGENT_CODEFRESH_TOKEN}" ]; then
    echo "-----"
    echo "runtime and agent are already initialized"
    echo "-----"
    exit 0
fi

if [ ! -z "${EXISTING_AGENT_CODEFRESH_TOKEN}" ]; then
    echo "using existing agentToken value"
    create_agent_secret $EXISTING_AGENT_CODEFRESH_TOKEN
    exit 0
fi

if [ -z "${USER_CODEFRESH_TOKEN}" ]; then
    echo "-----"
    echo "missing codefresh user token. must supply \".global.codefreshToken\" if agent-codefresh-token does not exist"
    echo "-----"
    exit 1
fi

codefresh auth create-context --api-key ${USER_CODEFRESH_TOKEN} --url ${API_HOST}

# AGENT_TOKEN might be empty, in which case it will be returned by the call
RES=$(codefresh install agent \
    --name ${AGENT_NAME} \
    --kube-context-name ${KUBE_CONTEXT} \
    --kube-namespace ${KUBE_NAMESPACE} \
    --agent-kube-namespace ${KUBE_NAMESPACE} \
    --install-runtime \
    --runtime-name ${RUNTIME_NAME} \
    --skip-cluster-creation \
    --platform-only)

AGENT_CODEFRESH_TOKEN=$(echo "${RES}" | tail -n 1)
echo "generated agent + runtime in platform"

create_agent_secret $AGENT_CODEFRESH_TOKEN

echo "-----"
echo "done initializing runtime and agent"
echo "-----"
