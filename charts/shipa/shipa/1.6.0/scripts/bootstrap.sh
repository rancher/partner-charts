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

# This helper gets an IP address or DNS name of NGINX_SERVICE and prints it to /tmp/nginx-ip
/bin/bootstrap-helper --service-name=$NGINX_SERVICE --namespace=$POD_NAMESPACE --timeout=600 --filename=/tmp/nginx-ip

NGINX_ADDRESS=$(cat /tmp/nginx-ip)
HOST_ADDRESS=$(cat /tmp/nginx-ip)

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

if is_shipa_initialized; then
  echo "Skip bootstrapping because shipa is already initialized"
  exit 0
fi

CERTIFICATES_DIRECTORY=/tmp/certs
mkdir $CERTIFICATES_DIRECTORY

# certificate generation for default domain
sed "s/SHIPA_PUBLIC_IP/$NGINX_ADDRESS/g" /scripts/csr-shipa-ca.json > $CERTIFICATES_DIRECTORY/csr-shipa-ca.json
sed "s/SHIPA_PUBLIC_IP/$NGINX_ADDRESS/g" /scripts/csr-docker-cluster.json > $CERTIFICATES_DIRECTORY/csr-docker-cluster.json
sed "s/SHIPA_PUBLIC_IP/$NGINX_ADDRESS/g" /scripts/csr-etcd.json > $CERTIFICATES_DIRECTORY/csr-etcd.json
sed "s/SHIPA_PUBLIC_IP/$NGINX_ADDRESS/g" /scripts/csr-api-config.json > $CERTIFICATES_DIRECTORY/csr-api-config.json
sed "s/SHIPA_PUBLIC_IP/$NGINX_ADDRESS/g" /scripts/csr-api-server.json > $CERTIFICATES_DIRECTORY/csr-api-server.json
sed "s/ETCD_SERVICE/$ETCD_SERVICE/g" --in-place $CERTIFICATES_DIRECTORY/csr-etcd.json

# certificate generation for CNAMES
sed "s/SHIPA_API_CNAMES/$SHIPA_API_CNAMES/g" --in-place $CERTIFICATES_DIRECTORY/csr-docker-cluster.json
sed "s/SHIPA_API_CNAMES/$SHIPA_API_CNAMES/g" --in-place $CERTIFICATES_DIRECTORY/csr-etcd.json
sed "s/SHIPA_API_CNAMES/$SHIPA_API_CNAMES/g" --in-place $CERTIFICATES_DIRECTORY/csr-api-server.json

jq 'fromstream(tostream | select(length == 1 or .[1] != ""))' $CERTIFICATES_DIRECTORY/csr-docker-cluster.json > file.tmp && mv file.tmp $CERTIFICATES_DIRECTORY/csr-docker-cluster.json
jq 'fromstream(tostream | select(length == 1 or .[1] != ""))' $CERTIFICATES_DIRECTORY/csr-etcd.json > file.tmp && mv file.tmp $CERTIFICATES_DIRECTORY/csr-etcd.json
jq 'fromstream(tostream | select(length == 1 or .[1] != ""))' $CERTIFICATES_DIRECTORY/csr-api-server.json > file.tmp && mv file.tmp $CERTIFICATES_DIRECTORY/csr-api-server.json

cp /scripts/csr-etcd-client.json $CERTIFICATES_DIRECTORY/csr-etcd-client.json
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
    -profile=server \
    $CERTIFICATES_DIRECTORY/csr-etcd.json | cfssljson -bare $CERTIFICATES_DIRECTORY/etcd-server

cfssl gencert \
    -ca=$CERTIFICATES_DIRECTORY/ca.pem \
    -ca-key=$CERTIFICATES_DIRECTORY/ca-key.pem \
    -profile=client \
    $CERTIFICATES_DIRECTORY/csr-etcd-client.json | cfssljson -bare $CERTIFICATES_DIRECTORY/etcd-client

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

ETCD_SERVER_CERT=$(cat $CERTIFICATES_DIRECTORY/etcd-server.pem | base64)
ETCD_SERVER_KEY=$(cat $CERTIFICATES_DIRECTORY/etcd-server-key.pem | base64)

ETCD_CLIENT_CERT=$(cat $CERTIFICATES_DIRECTORY/etcd-client.pem | base64)
ETCD_CLIENT_KEY=$(cat $CERTIFICATES_DIRECTORY/etcd-client-key.pem | base64)

API_SERVER_CERT=$(cat $CERTIFICATES_DIRECTORY/api-server.pem | base64)
API_SERVER_KEY=$(cat $CERTIFICATES_DIRECTORY/api-server-key.pem | base64)


# FIXME: name of secret
kubectl get secrets shipa-certificates -o json \
        | jq ".data[\"ca.pem\"] |= \"$CA_CERT\"" \
        | jq ".data[\"ca-key.pem\"] |= \"$CA_KEY\"" \
        | jq ".data[\"client-ca.crt\"] |= \"$CLIENT_CA_CERT\"" \
        | jq ".data[\"client-ca.key\"] |= \"$CLIENT_CA_KEY\"" \
        | jq ".data[\"cert.pem\"] |= \"$DOCKER_CLUSTER_CERT\"" \
        | jq ".data[\"key.pem\"] |= \"$DOCKER_CLUSTER_KEY\"" \
        | jq ".data[\"etcd-server.crt\"] |= \"$ETCD_SERVER_CERT\"" \
        | jq ".data[\"etcd-server.key\"] |= \"$ETCD_SERVER_KEY\"" \
        | jq ".data[\"etcd-client.crt\"] |= \"$ETCD_CLIENT_CERT\"" \
        | jq ".data[\"etcd-client.key\"] |= \"$ETCD_CLIENT_KEY\"" \
        | jq ".data[\"api-server.crt\"] |= \"$API_SERVER_CERT\"" \
        | jq ".data[\"api-server.key\"] |= \"$API_SERVER_KEY\"" \
        | kubectl apply -f -

echo "CA:"
openssl x509 -in $CERTIFICATES_DIRECTORY/ca.pem -text -noout

echo "Docker cluster:"
openssl x509 -in $CERTIFICATES_DIRECTORY/docker-cluster.pem -text -noout

echo "Etcd server:"
openssl x509 -in $CERTIFICATES_DIRECTORY/etcd-server.pem -text -noout

echo "Etcd client:"
openssl x509 -in $CERTIFICATES_DIRECTORY/etcd-client.pem -text -noout
