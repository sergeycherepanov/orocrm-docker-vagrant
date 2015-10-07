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
function sucess {
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
DOCKER_IMAGE_NAME_PREFIX=$3
DOCKER_IMAGE_TAG=$4

IMAGE_NAME_BASE="${DOCKER_IMAGE_NAME_PREFIX}-base"
IMAGE_NAME_DATA="${DOCKER_IMAGE_NAME_PREFIX}-data"
IMAGE_NAME_HTTP="${DOCKER_IMAGE_NAME_PREFIX}-http"
IMAGE_NAME_JOB="${DOCKER_IMAGE_NAME_PREFIX}-job"
IMAGE_NAME_WS="${DOCKER_IMAGE_NAME_PREFIX}-ws"

# Checkout source code
SOURCE_DIR=/tmp/source
GIT_DIR=/tmp/git
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
/usr/bin/python ${DIR}/git-archive-all $(find . -name ".*" -size 0  | while read -r line; do printf '%s ' '--extra '$line;done) /tmp/source.tar
tar -xf /tmp/source.tar -C $(dirname ${SOURCE_DIR})
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

mkdir -p /vagrant/image-base/source
sudo mount --bind /tmp/source ${DIR}/image-base/source

# Build base image
baseImage=`echo "${IMAGE_NAME_BASE}:${DOCKER_IMAGE_TAG}" | sed -e 's/[\.\:\/&]/\\\\&/g'`
info "Building ${IMAGE_NAME_BASE}:${DOCKER_IMAGE_TAG} image"
(docker build -t "${IMAGE_NAME_BASE}:${DOCKER_IMAGE_TAG}" "${DIR}/image-base"); exitCode=$?
if [ 0 -lt ${exitCode} ]
then
  error "Can't build ${IMAGE_NAME_BASE}:${DOCKER_IMAGE_TAG}"
fi

# Build services
info "Building DATA container..."
cat "${DIR}/image-data/Dockerfile.tpl" | sed -e 's/%FROM%/'${baseImage}'/g' > "${DIR}/image-data/Dockerfile"
(docker build -t "${IMAGE_NAME_DATA}:${DOCKER_IMAGE_TAG}" "${DIR}/image-data"); exitCode=$?
if [ 0 -lt ${exitCode} ]
then
  error "Can't build ${IMAGE_NAME_DATA}:${DOCKER_IMAGE_TAG}"
fi

info "Building HTTP container..."
cat "${DIR}/image-http/Dockerfile.tpl" | sed -e 's/%FROM%/'${baseImage}'/g' > "${DIR}/image-http/Dockerfile"
(docker build -t "${IMAGE_NAME_HTTP}:${DOCKER_IMAGE_TAG}" "${DIR}/image-http"); exitCode=$?
if [ 0 -lt ${exitCode} ]
then
  error "Can't build ${IMAGE_NAME_HTTP}:${DOCKER_IMAGE_TAG}"
fi

info "Building WEBSOCKET container..."
cat "${DIR}/image-ws/Dockerfile.tpl" | sed -e 's/%FROM%/'${baseImage}'/g' > "${DIR}/image-ws/Dockerfile"
(docker build -t "${IMAGE_NAME_WS}:${DOCKER_IMAGE_TAG}" "${DIR}/image-ws"); exitCode=$?
if [ 0 -lt ${exitCode} ]
then
  error "Can't build ${IMAGE_NAME_WS}:${DOCKER_IMAGE_TAG}"
fi

info "Building JOB container..."
cat "${DIR}/image-job/Dockerfile.tpl" | sed -e 's/%FROM%/'${baseImage}'/g' > "${DIR}/image-job/Dockerfile"
(docker build -t "${IMAGE_NAME_JOB}:${DOCKER_IMAGE_TAG}" "${DIR}/image-job"); exitCode=$?
if [ 0 -lt ${exitCode} ]
then
  error "Can't build ${IMAGE_NAME_JOB}:${DOCKER_IMAGE_TAG}"
fi

# Cleanup
sudo umount ${DIR}/image-base/source
rm -f ${DIR}/image-http/Dockerfile
rm -f ${DIR}/image-ws/Dockerfile
rm -f ${DIR}/image-job/Dockerfile
rm -rf /tmp/*
