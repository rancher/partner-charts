#!/bin/bash

set -x

NAMESPACE=$1
if [ -z "$NAMESPACE" ]; then
  echo "Usage: $0 <namespace> <cluster-name>"
  exit 1
fi
CLUSTER_NAME=$2
if [ -z "$CLUSTER_NAME" ]; then
  echo "Usage: $0 <namespace> <cluster-name>"
  exit 1
fi
CURRENT_CONTEXT=$(kubectl config current-context)

USER_TOKEN_VALUE=$(kubectl -n $NAMESPACE get secret/codefresh-runtime-user-token -o=go-template='{{.data.token}}' | base64 --decode)
CURRENT_CLUSTER=$(kubectl config view --raw -o=go-template='{{range .contexts}}{{if eq .name "'''${CURRENT_CONTEXT}'''"}}{{ index .context "cluster" }}{{end}}{{end}}')
CLUSTER_CA=$(kubectl config view --raw -o=go-template='{{range .clusters}}{{if eq .name "'''${CURRENT_CLUSTER}'''"}}"{{with index .cluster "certificate-authority-data" }}{{.}}{{end}}"{{ end }}{{ end }}')
CLUSTER_SERVER=$(kubectl config view --raw -o=go-template='{{range .clusters}}{{if eq .name "'''${CURRENT_CLUSTER}'''"}}{{ .cluster.server }}{{end}}{{ end }}')

export -p USER_TOKEN_VALUE CURRENT_CONTEXT CURRENT_CLUSTER CLUSTER_CA CLUSTER_SERVER CLUSTER_NAME

cat << EOF > $CLUSTER_NAME-kubeconfig
apiVersion: v1
kind: Config
current-context: ${CLUSTER_NAME}
contexts:
- name: ${CLUSTER_NAME}
  context:
    cluster: ${CLUSTER_NAME}
    user: codefresh-runtime-user
    namespace: ${NAMESPACE}
clusters:
- name: ${CLUSTER_NAME}
  cluster:
    certificate-authority-data: ${CLUSTER_CA}
    server: ${CLUSTER_SERVER}
users:
- name: codefresh-runtime-user
  user:
    token: ${USER_TOKEN_VALUE}
EOF
