#!/bin/bash

echo "-----"
echo "API_HOST:           ${API_HOST}"
echo "AGENT_NAME:         ${AGENT_NAME}"
echo "RUNTIME_NAME:       ${RUNTIME_NAME}"
echo "AGENT:              ${AGENT}"
echo "AGENT_SECRET_NAME:  ${AGENT_SECRET_NAME}"
echo "DIND_SECRET_NAME:   ${DIND_SECRET_NAME}"
echo "-----"

auth() {
  codefresh auth create-context --api-key ${API_TOKEN} --url ${API_HOST}
}

remove_runtime() {
  if [ "$AGENT" == "true" ]; then
    codefresh delete re ${RUNTIME_NAME} || true
  else
    codefresh delete sys-re ${RUNTIME_NAME} || true
  fi
}

remove_agent() {
  codefresh delete agent ${AGENT_NAME} || true
}

remove_secrets() {
  kubectl patch secret $(kubectl get secret -l codefresh.io/internal=true | awk 'NR>1{print $1}' | xargs) -p '{"metadata":{"finalizers":null}}' --type=merge || true
  kubectl delete secret $AGENT_SECRET_NAME || true
  kubectl delete secret $DIND_SECRET_NAME || true
}

auth
remove_runtime
remove_agent
remove_secrets