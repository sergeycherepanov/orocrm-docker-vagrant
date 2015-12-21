#!/bin/bash
cd `dirname $0` && DIR=$(pwd) && cd -

function info {
    printf "\033[0;36m${1}\033[0m \n"
}
function note {
    printf "\033[0;33m${1}\033[0m \n"
}
function success {
    printf "\033[0;32m${1}\033[0m \n"
}
function warning {
    printf "\033[0;95m${1}\033[0m \n"
}
function error {
    printf "\033[0;31m${1}\033[0m \n"
    exit 1
}

if [ -z $1 ] || [ -z $2 ]; then
  info "usage: $0 <image name> <image tag>"
  exit 1
fi

IMAGE_PREFIX=$1
IMAGE_TAG=$2

COMPOSE_TPL=`cat ${DIR}/docker-compose.tpl.yml`
COMPOSE_TPL=${COMPOSE_TPL//%IMAGE_PREFIX%/${IMAGE_PREFIX}}
COMPOSE_TPL=${COMPOSE_TPL//%IMAGE_TAG%/${IMAGE_TAG}}

echo "${COMPOSE_TPL}" > ${DIR}/docker-compose.yml

success "Compose config ${DIR}/docker-compose.yml saved!"
note "Run: \"docker-compose up\" to start services "
