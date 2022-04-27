#!/bin/sh

set -o xtrace

kubectl delete crd apps.shipa.io --ignore-not-found=true;
kubectl delete crd frameworks.shipa.io --ignore-not-found=true
kubectl delete crd jobs.shipa.io --ignore-not-found=true
kubectl delete crd autodiscoveredapps.shipa.io --ignore-not-found=true
kubectl delete ds --selector=$SELECTOR $NAMESPACE_MOD --ignore-not-found=true
kubectl delete deployment --selector=$SELECTOR $NAMESPACE_MOD --ignore-not-found=true
kubectl delete jobs --selector=$SELECTOR --ignore-not-found=true $NAMESPACE_MOD
kubectl delete daemonsets --selector=$SELECTOR --ignore-not-found=true $NAMESPACE_MOD
kubectl delete services --selector=$SELECTOR $NAMESPACE_MOD --ignore-not-found=true
kubectl delete sa --selector=$SELECTOR $NAMESPACE_MOD --ignore-not-found=true
kubectl delete configmap {{ template "shipa.fullname" . }}-leader -n {{ .Release.Namespace }} --ignore-not-found=true
kubectl delete clusterrolebindings  --selector=$SELECTOR --ignore-not-found=true $NAMESPACE_MOD
kubectl delete clusterrole --selector=$SELECTOR --ignore-not-found=true $NAMESPACE_MOD
kubectl delete ingress --selector=$SELECTOR --ignore-not-found=true $NAMESPACE_MOD
kubectl delete endpoints --selector=$SELECTOR --ignore-not-found=true $NAMESPACE_MOD
kubectl delete netpol --selector=$SELECTOR --ignore-not-found=true $NAMESPACE_MOD

NAMESPACES=$(kubectl get ns  --no-headers -o custom-columns=":metadata.name" --selector=$SELECTOR)

for NAMESPACE in $NAMESPACES; do
    echo "Removing for namespace $NAMESPACE"

    SECRETS=$(kubectl -n $NAMESPACE get secrets --selector=$SELECTOR -o name)

    for SECRET in $SECRETS; do
        echo "Removing secret $SECRET"

        # remove all secrets, except secret for helm release
        if [[ $SECRET != "secret/sh.helm.release.*.$RELEASE_NAME.*" ]]; then
            kubectl -n $NAMESPACE delete $SECRET
        fi
    done
    kubectl delete secret $RELEASE_NAME-api-ingress-secret

    echo "Removing namespace $NAMESPACE"

    # remove all namespaces, except namespace of helm installation
    if [[ $NAMESPACE != $RELEASE_NAMESPACE ]]; then
        kubectl delete ns $NAMESPACE
    fi
done