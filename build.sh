#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
export COMPOSER_PROCESS_TIMEOUT=3600

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

if [ -z $1 ] || [ -z $2 ] || [ -z $3 ] || [ -z $4 ]; then
  info "usage: $0 <git-uri> <git-ref> <image-name> <image-tag>"
  exit 1
fi

GIT_REPOSITORY_URI=$1
GIT_REPOSITORY_BRANCH=$2
DOCKER_IMAGE_NAME=$3
DOCKER_IMAGE_TAG=$4
BASE_IMAGE_NAME="bap-base-system"
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
    git fetch origin ${GIT_REPOSITORY_BRANCH}
else
    git fetch origin ${GIT_REPOSITORY_BRANCH}:${GIT_REPOSITORY_BRANCH}
fi

[[ 0 -lt $? ]] && error "Can't fetch ${GIT_REPOSITORY_URI} ${GIT_REPOSITORY_BRANCH}"

git checkout -f ${GIT_REPOSITORY_BRANCH} || error "Can't checkout ${GIT_REPOSITORY_URI} ${GIT_REPOSITORY_BRANCH}"
git submodule update --init

# Export source code
/usr/bin/python ${DIR}/git-archive-all $(find . -name ".*" -size 0  | while read -r line; do printf '%s ' '--extra '$line;done) ${TMP_DIR}/source.tar
tar -xf ${TMP_DIR}/source.tar -C $(dirname ${SOURCE_DIR})
# If is composer application
if [ -f ${SOURCE_DIR}/composer.json ]; then
    composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader -d ${SOURCE_DIR} || error "Can't install dependencies"
    php ${DIR}/composer-map-env.php ${SOURCE_DIR}/composer.json
else
    error "${SOURCE_DIR}/composer.json not found!"
fi

cd ${WORKING_DIR}

# Data image
if [ 0 -eq $(docker images | grep "${IMAGE_NAME}-data" | grep ${DOCKER_IMAGE_TAG} | wc -l) ]; then
    info "${IMAGE_NAME}-data:${DOCKER_IMAGE_TAG} image not found, building..."
    docker build -t "${IMAGE_NAME}-data:${DOCKER_IMAGE_TAG}" "${DIR}/image-data"
    [[ 0 -lt $? ]] && error "Can't build ${IMAGE_NAME}:${DOCKER_IMAGE_TAG}"

    success "${IMAGE_NAME}-data:${DOCKER_IMAGE_TAG} image successfully builded"
else
    success "${IMAGE_NAME}-data:${DOCKER_IMAGE_TAG} image already exists"
fi

# Basy system
if [ 0 -eq $(docker images | grep ${BASE_IMAGE_NAME} | wc -l) ]; then
    info "${BASE_IMAGE_NAME} image not found, building..."
    info "Building ${BASE_IMAGE_NAME} image"
    docker build -t "${BASE_IMAGE_NAME}" "${DIR}/image"
    [[ 0 -lt $? ]] && error "Can't build ${IMAGE_NAME}:${DOCKER_IMAGE_TAG}"

    success "${BASE_IMAGE_NAME} image successfully builded"
else
    success "${BASE_IMAGE_NAME} image already exists"
fi

# Copy source code
ID=$(docker run -d -v "${DIR}/image/OroRequirements.php:/OroRequirements.php" -v "${SOURCE_DIR}:/source" -v "${DIR}/image/bin:/optbin" "${BASE_IMAGE_NAME}" bash -c "cp -r /optbin /opt/bin && chmod +x /opt/bin/* && cp -r /source /var/www && cp /OroRequirements.php /var/www/app/OroRequirements.php && chown -R www-data:www-data /var/www")
docker wait ${ID}
docker commit -c 'CMD ["/bin/bash", "/opt/bin/run.sh"]' ${ID} ${IMAGE_NAME}:${DOCKER_IMAGE_TAG}

# Cleanup
rm -rf ${TMP_DIR}
