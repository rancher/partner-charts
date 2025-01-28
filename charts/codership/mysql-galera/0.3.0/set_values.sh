#!/usr/bin/env bash
#
set -x
#
cd $(dirname $0)
#

if ! test -f values.tmpl; then
  echo "No values template found, exiting"
  exit 1
fi

if [[ -f VARIABLES ]]; then
  . VARIABLES
fi

while [[ $# -gt 0 ]]; do
  case $1 in
    --repo )
      REPOSITORY=$2
      shift 2
      ;;
    --tag)
      TAG=$2
      shift 2
      ;;
    --rootpw)
      MYSQL_ROOT_PASSWORD=$2
      shift 2
      ;;
    --dbuser)
      DBUSER=$2
      shift 2
      ;;
    --userpw)
      USER_PW=$2
      shift 2
      ;;
    --docker-user)
      DOCKER_USER=$2
      shift 2
      ;;
    --docker-pw)
      DOCKER_PASSWORD=$2
      shift 2
      ;;
    *)
      echo "Error! Unknown parameter: $1"
      exit 1
      ;;
  esac
done

sed \
    -e "s:@@REPOSITORY@@:${REPOSITORY}:g" \
    -e "s:@@IMAGE_TAG@@:${TAG}:g" \
    -e "s:@@MYSQL_ROOT_PASSWORD@@:${MYSQL_ROOT_PASSWORD}:g" \
    -e "s:@@MYSQL_USER@@:${DBUSER}:g" \
    -e "s:@@MYSQL_USER_PASSWORD@@:${USER_PW}:g" \
    -e "s:@@USERNAME@@:${DOCKER_USER}:g" \
    -e "s:@@PASSWORD@@:${DOCKER_PASSWORD}:g" \
    values.tmpl > values.yaml
