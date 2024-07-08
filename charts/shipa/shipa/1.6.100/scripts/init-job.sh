#!/bin/sh

echo "Waiting for shipa api"

until $(curl --output /dev/null --silent http://$SHIPA_ENDPOINT:$SHIPA_ENDPOINT_PORT); do
    echo "."
    sleep 1
done

SHIPA_CLIENT="/bin/shipa"
$SHIPA_CLIENT target add -s local $SHIPA_ENDPOINT --insecure --port=$SHIPA_ENDPOINT_PORT --disable-cert-validation
$SHIPA_CLIENT login <<EOF
$USERNAME
$PASSWORD
EOF
$SHIPA_CLIENT team create shipa-admin-team
$SHIPA_CLIENT team create shipa-system-team
$SHIPA_CLIENT framework add /scripts/default-framework-template.yaml

# we need this delay because it takes some time to initialize etcd
sleep 10

TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
ADDR=$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT

cp -v /scripts/default-cluster-template.yaml /etc/shipa/default-cluster-template.yaml

# replace vars in shipa-cluster yaml
sed -i "s/CLUSTER_TOKEN/$TOKEN/g" /etc/shipa/default-cluster-template.yaml
sed -i "s/CLUSTER_ADDR/$ADDR/g" /etc/shipa/default-cluster-template.yaml
# append yaml head, before CLUSTER_CACERT
grep "CLUSTER_CACERT" /etc/shipa/default-cluster-template.yaml -B 10000 | head -n -1 > /etc/shipa/default-cluster-template-final.yaml 
# append ca.crt with indentation
sed 's/^/    /g' /var/run/secrets/kubernetes.io/serviceaccount/ca.crt >> /etc/shipa/default-cluster-template-final.yaml 
# append yaml tail, after CLUSTER_CACERT
grep "CLUSTER_CACERT" /etc/shipa/default-cluster-template.yaml -A 10000 | awk 'FNR>1' >> /etc/shipa/default-cluster-template-final.yaml 

$SHIPA_CLIENT cluster add --from-file /etc/shipa/default-cluster-template-final.yaml

$SHIPA_CLIENT role add TeamAdmin team
$SHIPA_CLIENT role permission add TeamAdmin team
$SHIPA_CLIENT role permission add TeamAdmin app
$SHIPA_CLIENT role permission add TeamAdmin cluster
$SHIPA_CLIENT role permission add TeamAdmin service
$SHIPA_CLIENT role permission add TeamAdmin service-instance

$SHIPA_CLIENT role add FrameworkAdmin framework
$SHIPA_CLIENT role permission add FrameworkAdmin framework
$SHIPA_CLIENT role permission add FrameworkAdmin node
$SHIPA_CLIENT role permission add FrameworkAdmin cluster

$SHIPA_CLIENT role add ClusterAdmin cluster
$SHIPA_CLIENT role permission add ClusterAdmin cluster

$SHIPA_CLIENT role add ServiceAdmin service
$SHIPA_CLIENT role add ServiceInstanceAdmin service-instance

$SHIPA_CLIENT role default add --team-create TeamAdmin
$SHIPA_CLIENT role default add --framework-add FrameworkAdmin
$SHIPA_CLIENT role default add --cluster-add ClusterAdmin
$SHIPA_CLIENT role default add --service-add ServiceAdmin
$SHIPA_CLIENT role default add --service-instance-add ServiceInstanceAdmin

if [ "x$DASHBOARD_ENABLED" != "xtrue" ]; then
    echo "The dashboard is disabled"
    exit 0
fi

COUNTER=0
echo "Creating the dashboard app"
until $SHIPA_CLIENT app create dashboard \
    --framework=shipa-framework \
    --team=shipa-admin-team \
    -e SHIPA_ADMIN_USER=$USERNAME \
    -e SHIPA_CLOUD=$SHIPA_CLOUD \
    -e SHIPA_TARGETS=$SHIPA_TARGETS \
    -e SHIPA_PAY_API_HOST=$SHIPA_PAY_API_HOST \
    -e GOOGLE_RECAPTCHA_SITEKEY=$GOOGLE_RECAPTCHA_SITEKEY \
    -e SHIPA_API_INTERNAL_URL=http://$SHIPA_ENDPOINT:$SHIPA_ENDPOINT_PORT \
    -e SMARTLOOK_PROJECT_KEY=$SMARTLOOK_PROJECT_KEY; do
    echo "Create dashboard failed with $?, waiting 15 seconds then trying again"
    sleep 15
    let COUNTER=COUNTER+1
    if [ $COUNTER -gt 3 ]; then
        echo "Failed to create dashboard three times, giving up"
        exit 1
    fi
done


echo "Setting private envs for dashboard"
$SHIPA_CLIENT env set -a dashboard \
    SHIPA_PAY_API_TOKEN=$SHIPA_PAY_API_TOKEN \
    GOOGLE_RECAPTCHA_SECRET=$GOOGLE_RECAPTCHA_SECRET \
    LAUNCH_DARKLY_SDK_KEY=$LAUNCH_DARKLY_SDK_KEY -p

COUNTER=0
until $SHIPA_CLIENT app deploy -a dashboard -i $DASHBOARD_IMAGE; do
    echo "Deploy dashboard failed with $?, waiting 30 seconds then trying again"
    sleep 30
    let COUNTER=COUNTER+1
    if [ $COUNTER -gt 3 ]; then
        echo "Failed to deploy dashboard three times, giving up"
        exit 1
    fi
done
