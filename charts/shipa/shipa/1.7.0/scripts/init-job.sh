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

TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
ADDR=$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT

cp -v /scripts/default-cluster-template.yaml /etc/shipa/default-cluster-template.yaml

sed -i "s/CLUSTER_ADDR/$ADDR/g" /etc/shipa/default-cluster-template.yaml

$SHIPA_CLIENT cluster connect -f /etc/shipa/default-cluster-template.yaml -r | kubectl apply -f -

echo 'waiting for cluster creation to complete'
while [[ true ]]; do
    event=$($SHIPA_CLIENT event list --target cluster --target-value shipa-cluster --kind "cluster.create" | grep -e "true" -e "false" | head -n 1)
    outcome=$(echo "$event" | awk  -F  "|" '/1/ {print $4}' | xargs echo)

    if [[ "$outcome" == "..." ]]; then
        echo 'waiting for shipa agent to initialize cluster'
    elif [[ "$outcome" == "false" ]]; then
        echo "failed to create shipa-cluster"
        $SHIPA_CLIENT event info $(echo "$event" | awk  -F  "|" '/1/ {print $2}')
        exit 1
    elif [[ "$outcome" == "true" ]]; then
        echo "cluster creation successful"
        break
    else
        echo "wating for shipa agent to start"
    fi
    sleep 2
done

$SHIPA_CLIENT role add TeamAdmin team
$SHIPA_CLIENT role permission add TeamAdmin team
$SHIPA_CLIENT role permission add TeamAdmin app
$SHIPA_CLIENT role permission add TeamAdmin cluster

$SHIPA_CLIENT role add FrameworkAdmin framework
$SHIPA_CLIENT role permission add FrameworkAdmin framework
$SHIPA_CLIENT role permission add FrameworkAdmin node
$SHIPA_CLIENT role permission add FrameworkAdmin cluster

$SHIPA_CLIENT role add ClusterAdmin cluster
$SHIPA_CLIENT role permission add ClusterAdmin cluster

$SHIPA_CLIENT role default add --team-create TeamAdmin
$SHIPA_CLIENT role default add --framework-add FrameworkAdmin
$SHIPA_CLIENT role default add --cluster-add ClusterAdmin

if [ "x$DASHBOARD_ENABLED" != "xtrue" ]; then
    echo "The dashboard is disabled"
    exit 0
fi

COUNTER=0
echo "Deploying the dashboard app"
until $SHIPA_CLIENT app deploy -a dashboard \
    --framework=shipa-framework \
    --team=shipa-admin-team \
    -e SHIPA_ADMIN_USER=$USERNAME \
    -e SHIPA_CLOUD=$SHIPA_CLOUD \
    -e SHIPA_TARGETS=$SHIPA_TARGETS \
    -e SHIPA_PAY_API_HOST=$SHIPA_PAY_API_HOST \
    -e GOOGLE_RECAPTCHA_SITEKEY=$GOOGLE_RECAPTCHA_SITEKEY \
    -e SHIPA_API_INTERNAL_URL=http://$SHIPA_ENDPOINT:$SHIPA_ENDPOINT_PORT \
    -e SMARTLOOK_PROJECT_KEY=$SMARTLOOK_PROJECT_KEY \
    -i $DASHBOARD_IMAGE; do
    echo "Create dashboard failed with $?, waiting 15 seconds then trying again"
    sleep 15
    COUNTER=COUNTER+1
    if [ $COUNTER -gt 3 ]; then
        echo "Failed to deploy dashboard three times, giving up"
        exit 1
    fi
done


echo "Setting private envs for dashboard"
$SHIPA_CLIENT env set -a dashboard \
    SHIPA_PAY_API_TOKEN=$SHIPA_PAY_API_TOKEN \
    GOOGLE_RECAPTCHA_SECRET=$GOOGLE_RECAPTCHA_SECRET \
    LAUNCH_DARKLY_SDK_KEY=$LAUNCH_DARKLY_SDK_KEY -p

# we need to restart api because of sidecar injection
if [[ $INGRESS_TYPE == "istio" ]]; then
    kubectl rollout restart deployments $RELEASE_NAME-api -n $POD_NAMESPACE
fi