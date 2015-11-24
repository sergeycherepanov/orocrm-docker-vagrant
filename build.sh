#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
export COMPOSER_PROCESS_TIMEOUT=3600

DIR=$(dirname $(readlink -f $0))

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

if [ -z $1 ] || [ -z $2 ] || [ -z $3 ] || [ -z $4 ]; then
  info "usage: $0 <git-uri> <git-ref> <image-name> <image-tag>"
  exit 1
fi

GIT_REPOSITORY_URI=$1
GIT_REPOSITORY_BRANCH=$2
DOCKER_IMAGE_NAME=$3
DOCKER_IMAGE_TAG=$4
IMAGE_NAME="${DOCKER_IMAGE_NAME}"

TMP_DIR=/tmp/docker-bap
# Checkout source code
SOURCE_DIR=${TMP_DIR}/source
GIT_DIR=${TMP_DIR}/git
WORKING_DIR=$(pwd)

if [ -d ${GIT_DIR} ]; then
  rm -rf ${GIT_DIR}
fi

mkdir -p ${SOURCE_DIR}
mkdir -p ${GIT_DIR}

cd ${GIT_DIR}
git init
git remote add origin ${GIT_REPOSITORY_URI}

if [ 0 -eq $(expr match "${GIT_REPOSITORY_BRANCH}" "tags/") ];then
    (git fetch origin ${GIT_REPOSITORY_BRANCH}); exitCode=$?
else
    (git fetch origin ${GIT_REPOSITORY_BRANCH}:${GIT_REPOSITORY_BRANCH}); exitCode=$?
fi
if [ 0 -lt ${exitCode} ]
then
  error "Can't fetch ${GIT_REPOSITORY_URI} ${GIT_REPOSITORY_BRANCH}"
fi

(git checkout -f ${GIT_REPOSITORY_BRANCH}); exitCode=$?
if [ 0 -lt ${exitCode} ]
then
  error "Can't checkout ${GIT_REPOSITORY_URI} ${GIT_REPOSITORY_BRANCH}"
fi
git submodule update --init

# Export source code
/usr/bin/python ${DIR}/git-archive-all $(find . -name ".*" -size 0  | while read -r line; do printf '%s ' '--extra '$line;done) ${TMP_DIR}/source.tar
tar -xf ${TMP_DIR}/source.tar -C $(dirname ${SOURCE_DIR})
# If is composer application
if [ -f ${SOURCE_DIR}/composer.json ]; then
    composer install --no-interaction --prefer-dist --optimize-autoloader -d ${SOURCE_DIR}; exitCode=$?
    if [ 0 -lt ${exitCode} ]
    then
        error "Can't install dependencies"
    fi
    php ${DIR}/composer-map-env.php ${SOURCE_DIR}/composer.json
else
    error "${SOURCE_DIR}/composer.json not found!"
fi

cd ${WORKING_DIR}

mkdir -p ${DIR}/image/source
sudo mount --bind ${TMP_DIR}/source ${DIR}/image/source

# Build image
info "Building ${IMAGE_NAME}:${DOCKER_IMAGE_TAG} image"
(docker build -t "${IMAGE_NAME}:${DOCKER_IMAGE_TAG}" "${DIR}/image"); exitCode=$?
if [ 0 -lt ${exitCode} ]
then
  error "Can't build ${IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
fi

# Cleanup
sudo umount ${DIR}/image/source
rm -rf ${TMP_DIR}
