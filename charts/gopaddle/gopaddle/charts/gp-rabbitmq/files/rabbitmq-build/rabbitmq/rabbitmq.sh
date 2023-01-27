#!/bin/bash
set -x
apt-get update -y
apt-get install jq -y
rabbitmq-server > /var/log/rabbitmq/rabbitmq.log &
sleep 60  
rabbitmqctl add_vhost /activity
rabbitmqctl add_vhost /apps
rabbitmqctl add_vhost /build
rabbitmqctl add_vhost /billing
rabbitmqctl list_users
present = `rabbitmqctl list_users --formatter json | jq '.[] .user' | grep "admin"`
export present
if [ -z "$present" ]
then
echo "admin user doesnt exist."
else
echo "admin user already exists. deleting the user."
rabbitmqctl delete_user admin
fi
rabbitmqctl add_user admin 'cGFzc3dvcmQ'
rabbitmqctl set_user_tags admin none
rabbitmqctl set_permissions -p /activity admin ".*" ".*" ".*"
rabbitmqctl set_permissions -p /apps admin ".*" ".*" ".*"
rabbitmqctl set_permissions -p /build admin ".*" ".*" ".*"
rabbitmqctl set_permissions -p /billing admin ".*" ".*" ".*"
tail -f /var/log/rabbitmq/rabbitmq.log

