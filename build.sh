#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
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
IMAGE_NAME_JOB="${DOCKER_IMAGE_NAME_PREFIX}-job"
IMAGE_NAME_HTTP="${DOCKER_IMAGE_NAME_PREFIX}-http"
IMAGE_NAME_WS="${DOCKER_IMAGE_NAME_PREFIX}-ws"

# Checkout source code
WORK_DIR=${DIR}/image-base/source
GIT_DIR=/tmp/git

mkdir -p ${WORK_DIR}
mkdir -p ${GIT_DIR}

# Checkout source code
info "Checking-out sources..."
git --work-tree=${WORK_DIR} --git-dir=${GIT_DIR} init
git --work-tree=${WORK_DIR} --git-dir=${GIT_DIR} remote add origin ${GIT_REPOSITORY_URI}
git --work-tree=${WORK_DIR} --git-dir=${GIT_DIR} fetch origin ${GIT_REPOSITORY_BRANCH}:${GIT_REPOSITORY_BRANCH}
(git --work-tree=${WORK_DIR} --git-dir=${GIT_DIR} checkout -f ${GIT_REPOSITORY_BRANCH}); exitCode=$?
if [ 0 -lt ${exitCode} ]
then
  error "Can't checkout ${GIT_REPOSITORY_URI} ${GIT_REPOSITORY_BRANCH}"
fi

baseImage=`echo "${IMAGE_NAME_BASE}:${DOCKER_IMAGE_TAG}" | sed -e 's/[\.\:\/&]/\\\\&/g'`
# Build base image
info "Building ${IMAGE_NAME_BASE}:${DOCKER_IMAGE_TAG} image"
(docker build -t "${IMAGE_NAME_BASE}:${DOCKER_IMAGE_TAG}" "${DIR}/image-base"); exitCode=$?
if [ 0 -lt ${exitCode} ]
then
  error "Can't build ${IMAGE_NAME_BASE}:${DOCKER_IMAGE_TAG}"
fi

# Build services
info "Building HTTP service..."
cat "${DIR}/image-http/Dockerfile.tpl" | sed -e 's/%FROM%/'${baseImage}'/g' > "${DIR}/image-http/Dockerfile"
(docker build -t "${IMAGE_NAME_HTTP}:${DOCKER_IMAGE_TAG}" "${DIR}/image-http"); exitCode=$?
if [ 0 -lt ${exitCode} ]
then
  error "Can't build ${IMAGE_NAME_HTTP}:${DOCKER_IMAGE_TAG}"
fi

info "Building WEBSOCKET service..."
cat "${DIR}/image-ws/Dockerfile.tpl" | sed -e 's/%FROM%/'${baseImage}'/g' > "${DIR}/image-ws/Dockerfile"
(docker build -t "${IMAGE_NAME_WS}:${DOCKER_IMAGE_TAG}" "${DIR}/image-ws"); exitCode=$?
if [ 0 -lt ${exitCode} ]
then
  error "Can't build ${IMAGE_NAME_WS}:${DOCKER_IMAGE_TAG}"
fi

info "Building JOB service..."
cat "${DIR}/image-job/Dockerfile.tpl" | sed -e 's/%FROM%/'${baseImage}'/g' > "${DIR}/image-job/Dockerfile"
(docker build -t "${IMAGE_NAME_JOB}:${DOCKER_IMAGE_TAG}" "${DIR}/image-job"); exitCode=$?
if [ 0 -lt ${exitCode} ]
then
  error "Can't build ${IMAGE_NAME_JOB}:${DOCKER_IMAGE_TAG}"
fi

rm ${DIR}/image-http/Dockerfile
rm ${DIR}/image-ws/Dockerfile
rm ${DIR}/image-job/Dockerfile
