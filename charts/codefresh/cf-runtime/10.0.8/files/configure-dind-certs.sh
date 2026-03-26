#!/usr/bin/env bash
#

#---
fatal() {
   echo "ERROR: $1"
   exit 1
}

msg() { echo -e "\e[32mINFO ---> $1\e[0m"; }
err() { echo -e "\e[31mERR ---> $1\e[0m" ; return 1; }

exit_trap () {
  local lc="$BASH_COMMAND" rc=$?
  if [ $rc != 0 ]; then
    if [[ -n "$SLEEP_ON_ERROR" ]]; then
      echo -e "\nSLEEP_ON_ERROR is set - Sleeping to fix error"
      sleep $SLEEP_ON_ERROR
    fi
  fi
}
trap exit_trap EXIT

usage() {
    echo "Usage:
    $0 [-n | --namespace] [--server-cert-cn] [--server-cert-extra-sans] codefresh-api-host codefresh-api-token

Example:
   $0 -n workflow https://g.codefresh.io 21341234.423141234.412431234

"
}

# Args
while [[ $1 =~ ^(-(n|h)|--(namespace|server-cert-cn|server-cert-extra-sans|help)) ]]
do
  key=$1
  value=$2

  case $key in
    -h|--help)
        usage
        exit
      ;;
    -n|--namespace)
        NAMESPACE="$value"
        shift
      ;;
    --server-cert-cn)
        SERVER_CERT_CN="$value"
        shift
      ;;
    --server-cert-extra-sans)
        SERVER_CERT_EXTRA_SANS="$value"
        shift
      ;;
  esac
  shift # past argument or value
done

API_HOST=${1:-"$CF_API_HOST"}
API_TOKEN=${2:-"$CF_API_TOKEN"}

[[ -z "$API_HOST" ]] && usage && fatal "Missing API_HOST"
[[ -z "$API_TOKEN" ]] && usage && fatal "Missing token"


API_SIGN_PATH=${API_SIGN_PATH:-"api/custom_clusters/signServerCerts"}

NAMESPACE=${NAMESPACE:-default}
RELEASE=${RELEASE:-cf-runtime}

DIR=$(dirname $0)
TMPDIR=/tmp/codefresh/

TMP_CERTS_FILE_ZIP=$TMPDIR/cf-certs.zip
TMP_CERTS_HEADERS_FILE=$TMPDIR/cf-certs-response-headers.txt
CERTS_DIR=$TMPDIR/ssl
SRV_TLS_CA_CERT=${CERTS_DIR}/ca.pem
SRV_TLS_KEY=${CERTS_DIR}/server-key.pem
SRV_TLS_CSR=${CERTS_DIR}/server-cert.csr
SRV_TLS_CERT=${CERTS_DIR}/server-cert.pem
CF_SRV_TLS_CERT=${CERTS_DIR}/cf-server-cert.pem
CF_SRV_TLS_CA_CERT=${CERTS_DIR}/cf-ca.pem
mkdir -p $TMPDIR $CERTS_DIR

K8S_CERT_SECRET_NAME=codefresh-certs-server
echo -e "\n------------------\nGenerating server tls certificates ... "

SERVER_CERT_CN=${SERVER_CERT_CN:-"docker.codefresh.io"}
SERVER_CERT_EXTRA_SANS="${SERVER_CERT_EXTRA_SANS}"
###

  openssl genrsa -out $SRV_TLS_KEY 4096 || fatal "Failed to generate openssl key "
  openssl req -subj "/CN=${SERVER_CERT_CN}" -new -key $SRV_TLS_KEY -out $SRV_TLS_CSR  || fatal "Failed to generate openssl csr "
  GENERATE_CERTS=true
  CSR=$(sed ':a;N;$!ba;s/\n/\\n/g' ${SRV_TLS_CSR})

  SERVER_CERT_SANS="IP:127.0.0.1,DNS:dind,DNS:*.dind.${NAMESPACE},DNS:*.dind.${NAMESPACE}.svc${KUBE_DOMAIN},DNS:*.cf-cd.com,DNS:*.codefresh.io"
  if [[ -n "${SERVER_CERT_EXTRA_SANS}" ]]; then
    SERVER_CERT_SANS=${SERVER_CERT_SANS},${SERVER_CERT_EXTRA_SANS}
  fi
  echo "{\"reqSubjectAltName\": \"${SERVER_CERT_SANS}\", \"csr\": \"${CSR}\" }" > ${TMPDIR}/sign_req.json

  rm -fv ${TMP_CERTS_HEADERS_FILE} ${TMP_CERTS_FILE_ZIP}

  SIGN_STATUS=$(curl -k -sSL -d @${TMPDIR}/sign_req.json -H "Content-Type: application/json" -H "Authorization: ${API_TOKEN}" -H "Expect: " \
        -o ${TMP_CERTS_FILE_ZIP} -D ${TMP_CERTS_HEADERS_FILE} -w '%{http_code}' ${API_HOST}/${API_SIGN_PATH} )

  echo "Sign request completed with HTTP_STATUS_CODE=$SIGN_STATUS"
  if [[ $SIGN_STATUS != 200 ]]; then
     echo "ERROR: Cannot sign certificates"
     if [[ -f ${TMP_CERTS_FILE_ZIP} ]]; then
       mv ${TMP_CERTS_FILE_ZIP} ${TMP_CERTS_FILE_ZIP}.error
       cat ${TMP_CERTS_FILE_ZIP}.error
     fi
     exit 1
  fi
  unzip -o -d ${CERTS_DIR}/  ${TMP_CERTS_FILE_ZIP} || fatal "Failed to unzip certificates to ${CERTS_DIR} "
  cp -v ${CF_SRV_TLS_CA_CERT} $SRV_TLS_CA_CERT || fatal "received ${TMP_CERTS_FILE_ZIP} does not contains ca.pem"
  cp -v ${CF_SRV_TLS_CERT} $SRV_TLS_CERT || fatal "received ${TMP_CERTS_FILE_ZIP} does not contains cf-server-cert.pem"


echo -e "\n------------------\nCreating certificate secret "

kubectl -n $NAMESPACE create secret generic $K8S_CERT_SECRET_NAME \
    --from-file=$SRV_TLS_CA_CERT \
    --from-file=$SRV_TLS_KEY \
    --from-file=$SRV_TLS_CERT \
    --dry-run=client -o yaml | kubectl apply --overwrite -f -
kubectl -n $NAMESPACE label --overwrite secret ${K8S_CERT_SECRET_NAME} codefresh.io/internal=true
kubectl -n $NAMESPACE patch secret $K8S_CERT_SECRET_NAME -p '{"metadata": {"finalizers": ["kubernetes"]}}'
