#!/bin/sh
set -xe
mkdir /var/log/redis/ -p
mkdir mkdir /var/lib/redis -p
redis-server /usr/local/etc/redis/redis.conf
