#!/bin/sh

set -euxo pipefail

is_shipa_initialized() {

    # By default we create secret with empty certificates
    # and save them to the secret as a result of the first run of boostrap.sh

    CA=$(kubectl get secret/shipa-certificates -o json | jq ".data[\"ca.pem\"]")
    LENGTH=${#CA}

    if [ "$LENGTH" -gt "100" ]; then
      return 0
    fi
    return 1
}

echo "Waiting for nginx ingress to be ready"

if [[ $WAIT_FOR_NGINX == "true" ]]; then
        # This helper gets an IP address or DNS name of NGINX_SERVICE and prints it to /tmp/nginx-ip
    /bin/bootstrap-helper --service-name=$NGINX_SERVICE --namespace=$POD_NAMESPACE --timeout=600 --filename=/tmp/nginx-ip
    MAIN_INGRESS_IP=$(cat /tmp/nginx-ip)
    HOST_ADDRESS=$(cat /tmp/nginx-ip)
else
    MAIN_INGRESS_IP=$INGRESS_IP
    HOST_ADDRESS=$INGRESS_IP
fi



# If target CNAMEs are set by user in values.yaml, then use the first CNAME from the list as HOST_ADDRESS 
# since Shipa host can be only one in the shipa.conf
if [ ! -z "$SHIPA_MAIN_TARGET" -a "$SHIPA_MAIN_TARGET" != " " ]; then
    HOST_ADDRESS=$SHIPA_MAIN_TARGET
fi


echo "Prepare shipa.conf"
cp -v /etc/shipa-default/shipa.conf /etc/shipa/shipa.conf
sed -i "s/SHIPA_PUBLIC_IP/$HOST_ADDRESS/g" /etc/shipa/shipa.conf
sed -ie "s/SHIPA_ORGANIZATION_ID/$SHIPA_ORGANIZATION_ID/g" /etc/shipa/shipa.conf

echo "shipa.conf: "
cat /etc/shipa/shipa.conf

CERTIFICATES_DIRECTORY=/tmp/certs
mkdir $CERTIFICATES_DIRECTORY

if is_shipa_initialized; then

# migration for before API was assessable over any ingress controller
if [[ $INGRESS_TYPE == "nginx" ]]; then
  echo "Refreshing API secrets"
  # before we used TCP streaming on ports 8080 and 8081 and Shipa API was doing certificate checks
  # today we let nginx do certificate checks
  # because 80 and 443 are reserverd for Ingress and can't use TCP streaming, we need to create secret for nginx
  # we want to create dedicated secret for nginx based on shipa-certificates secret
  if [[ $WAIT_FOR_NGINX == "true" ]]; then
    kubectl get secrets -n "$POD_NAMESPACE" shipa-certificates -o json | jq ".data[\"api-server.crt\"]" | xargs echo | base64 -d > $CERTIFICATES_DIRECTORY/api-server.pem
    kubectl get secrets -n "$POD_NAMESPACE" shipa-certificates -o json | jq ".data[\"api-server.key\"]" | xargs echo | base64 -d > $CERTIFICATES_DIRECTORY/api-server-key.pem

    API_SERVER_CERT=$(cat $CERTIFICATES_DIRECTORY/api-server.pem | base64)
    API_SERVER_KEY=$(cat $CERTIFICATES_DIRECTORY/api-server-key.pem | base64)

    kubectl -n $POD_NAMESPACE create secret tls $RELEASE_NAME-api-ingress-secret --key=$CERTIFICATES_DIRECTORY/api-server-key.pem --cert=$CERTIFICATES_DIRECTORY/api-server.pem --dry-run -o yaml | kubectl apply -f -
  fi
fi

  echo "Skip bootstrapping because shipa is already initialized"
  exit 0
fi

echo "Cert For: $MAIN_INGRESS_IP"
echo "Cert For: $SHIPA_API_CNAMES"

# certificate generation for default domain
sed "s/SHIPA_PUBLIC_IP/$MAIN_INGRESS_IP/g" /scripts/csr-shipa-ca.json > $CERTIFICATES_DIRECTORY/csr-shipa-ca.json
sed "s/SHIPA_PUBLIC_IP/$MAIN_INGRESS_IP/g" /scripts/csr-docker-cluster.json > $CERTIFICATES_DIRECTORY/csr-docker-cluster.json
sed "s/SHIPA_PUBLIC_IP/$MAIN_INGRESS_IP/g" /scripts/csr-api-config.json > $CERTIFICATES_DIRECTORY/csr-api-config.json
sed "s/SHIPA_PUBLIC_IP/$MAIN_INGRESS_IP/g" /scripts/csr-api-server.json > $CERTIFICATES_DIRECTORY/csr-api-server.json

# certificate generation for CNAMES
sed "s/SHIPA_API_CNAMES/$SHIPA_API_CNAMES/g" --in-place $CERTIFICATES_DIRECTORY/csr-docker-cluster.json
sed "s/SHIPA_API_CNAMES/$SHIPA_API_CNAMES/g" --in-place $CERTIFICATES_DIRECTORY/csr-api-server.json

# certificate generation for Internal DNS so that internal services could connect to it.
sed "s/SHIPA_INTERNAL_DNS/$SHIPA_INTERNAL_DNS/g" --in-place $CERTIFICATES_DIRECTORY/csr-docker-cluster.json
sed "s/SHIPA_INTERNAL_DNS/$SHIPA_INTERNAL_DNS/g" --in-place $CERTIFICATES_DIRECTORY/csr-api-server.json

jq 'fromstream(tostream | select(length == 1 or .[1] != ""))' $CERTIFICATES_DIRECTORY/csr-docker-cluster.json > $CERTIFICATES_DIRECTORY/file.tmp && mv $CERTIFICATES_DIRECTORY/file.tmp $CERTIFICATES_DIRECTORY/csr-docker-cluster.json
jq 'fromstream(tostream | select(length == 1 or .[1] != ""))' $CERTIFICATES_DIRECTORY/csr-api-server.json > $CERTIFICATES_DIRECTORY/file.tmp && mv $CERTIFICATES_DIRECTORY/file.tmp $CERTIFICATES_DIRECTORY/csr-api-server.json

cp /scripts/csr-client-ca.json $CERTIFICATES_DIRECTORY/csr-client-ca.json

cfssl gencert -initca $CERTIFICATES_DIRECTORY/csr-shipa-ca.json | cfssljson -bare $CERTIFICATES_DIRECTORY/ca
cfssl gencert -initca $CERTIFICATES_DIRECTORY/csr-client-ca.json | cfssljson -bare $CERTIFICATES_DIRECTORY/client-ca

cfssl gencert \
    -ca=$CERTIFICATES_DIRECTORY/ca.pem \
    -ca-key=$CERTIFICATES_DIRECTORY/ca-key.pem \
    -profile=server \
    $CERTIFICATES_DIRECTORY/csr-docker-cluster.json | cfssljson -bare $CERTIFICATES_DIRECTORY/docker-cluster

cfssl gencert \
    -ca=$CERTIFICATES_DIRECTORY/ca.pem \
    -ca-key=$CERTIFICATES_DIRECTORY/ca-key.pem \
    -config=$CERTIFICATES_DIRECTORY/csr-api-config.json \
    -profile=server \
    $CERTIFICATES_DIRECTORY/csr-api-server.json | cfssljson -bare $CERTIFICATES_DIRECTORY/api-server

rm -f $CERTIFICATES_DIRECTORY/*.csr
rm -f $CERTIFICATES_DIRECTORY/*.json

CA_CERT=$(cat $CERTIFICATES_DIRECTORY/ca.pem | base64)
CA_KEY=$(cat $CERTIFICATES_DIRECTORY/ca-key.pem | base64)

CLIENT_CA_CERT=$(cat $CERTIFICATES_DIRECTORY/client-ca.pem | base64)
CLIENT_CA_KEY=$(cat $CERTIFICATES_DIRECTORY/client-ca-key.pem | base64)

DOCKER_CLUSTER_CERT=$(cat $CERTIFICATES_DIRECTORY/docker-cluster.pem | base64)
DOCKER_CLUSTER_KEY=$(cat $CERTIFICATES_DIRECTORY/docker-cluster-key.pem | base64)

API_SERVER_CERT=$(cat $CERTIFICATES_DIRECTORY/api-server.pem | base64)
API_SERVER_KEY=$(cat $CERTIFICATES_DIRECTORY/api-server-key.pem | base64)

# all ingress controlelers require different type of secret to work with self signed
if [[ $INGRESS_TYPE == "nginx" ]]; then
kubectl -n $POD_NAMESPACE create secret tls $RELEASE_NAME-api-ingress-secret --key=$CERTIFICATES_DIRECTORY/api-server-key.pem --cert=$CERTIFICATES_DIRECTORY/api-server.pem --dry-run -o yaml | kubectl apply -f -
# restart nginx to reload secret
if [[ $WAIT_FOR_NGINX == "true" ]]; then
    kubectl -n $POD_NAMESPACE rollout restart deployment $NGINX_DEPLOYMENT_NAME
fi
fi

if [[ $INGRESS_TYPE == "traefik" ]]; then
openssl x509 -in $CERTIFICATES_DIRECTORY/api-server.pem -out $CERTIFICATES_DIRECTORY/api-server.crt
openssl pkey -in $CERTIFICATES_DIRECTORY/api-server-key.pem -out $CERTIFICATES_DIRECTORY/api-server.key
kubectl -n $POD_NAMESPACE create secret generic $RELEASE_NAME-api-ingress-secret --from-file=tls.crt=$CERTIFICATES_DIRECTORY/api-server.crt --from-file=tls.key=$CERTIFICATES_DIRECTORY/api-server.key --dry-run -o yaml | kubectl apply -f -
fi

if [[ $INGRESS_TYPE == "istio" ]]; then
openssl x509 -in $CERTIFICATES_DIRECTORY/api-server.pem -out $CERTIFICATES_DIRECTORY/api-server.crt
openssl pkey -in $CERTIFICATES_DIRECTORY/api-server-key.pem -out $CERTIFICATES_DIRECTORY/api-server.key
kubectl -n istio-system create secret tls $RELEASE_NAME-api-ingress-secret --key=$CERTIFICATES_DIRECTORY/api-server.key --cert=$CERTIFICATES_DIRECTORY/api-server.crt --dry-run -o yaml | kubectl apply -f -
fi

# FIXME: name of secret
kubectl get secrets shipa-certificates -o json \
        | jq ".data[\"ca.pem\"] |= \"$CA_CERT\"" \
        | jq ".data[\"ca-key.pem\"] |= \"$CA_KEY\"" \
        | jq ".data[\"client-ca.crt\"] |= \"$CLIENT_CA_CERT\"" \
        | jq ".data[\"client-ca.key\"] |= \"$CLIENT_CA_KEY\"" \
        | jq ".data[\"cert.pem\"] |= \"$DOCKER_CLUSTER_CERT\"" \
        | jq ".data[\"key.pem\"] |= \"$DOCKER_CLUSTER_KEY\"" \
        | jq ".data[\"api-server.crt\"] |= \"$API_SERVER_CERT\"" \
        | jq ".data[\"api-server.key\"] |= \"$API_SERVER_KEY\"" \
        | kubectl apply -f -


echo "CA:"
openssl x509 -in $CERTIFICATES_DIRECTORY/ca.pem -text -noout

echo "Docker cluster:"
openssl x509 -in $CERTIFICATES_DIRECTORY/docker-cluster.pem -text -noout
