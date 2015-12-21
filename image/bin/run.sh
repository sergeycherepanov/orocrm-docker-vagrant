#!/bin/bash

APP_ROOT="/var/www"
DATA_ROOT="/srv/app-data"

# Prepare folders for persistent data
[[ -d ${DATA_ROOT}/config ]]         || sudo -u www-data mkdir -p ${DATA_ROOT}/config
[[ -d ${DATA_ROOT}/cache ]]          || sudo -u www-data mkdir -p ${DATA_ROOT}/cache
[[ -d ${DATA_ROOT}/media ]]          || sudo -u www-data mkdir -p ${DATA_ROOT}/media
[[ -d ${DATA_ROOT}/uploads ]]        || sudo -u www-data mkdir -p ${DATA_ROOT}/uploads
[[ -d ${DATA_ROOT}/attachment ]]     || sudo -u www-data mkdir -p ${DATA_ROOT}/attachment

# If it's the first run
if [ 0 -eq $(ls ${DATA_ROOT}/config/ | wc -l) ]
then
    # Generate parameters.yml
    sudo -u www-data -E composer run-script post-install-cmd -n -d ${APP_ROOT};

    # Copy configs
    sudo -u www-data cp -r ${APP_ROOT}/app/config/* ${DATA_ROOT}/config/
fi

# Clean exists folders
[[ -d ${APP_ROOT}/app/config ]]     && rm -r ${APP_ROOT}/app/config
[[ -d ${APP_ROOT}/app/cache ]]      && rm -r ${APP_ROOT}/app/cache
[[ -d ${APP_ROOT}/web/media ]]      && rm -r ${APP_ROOT}/web/media
[[ -d ${APP_ROOT}/web/uploads ]]    && rm -r ${APP_ROOT}/web/uploads
[[ -d ${APP_ROOT}/app/attachment ]] && rm -r ${APP_ROOT}/app/attachment

# Linking persistent data
sudo -u www-data ln -s ${DATA_ROOT}/config      ${APP_ROOT}/app/config
sudo -u www-data ln -s ${DATA_ROOT}/cache       ${APP_ROOT}/app/cache
sudo -u www-data ln -s ${DATA_ROOT}/media       ${APP_ROOT}/web/media
sudo -u www-data ln -s ${DATA_ROOT}/uploads     ${APP_ROOT}/web/uploads
sudo -u www-data ln -s ${DATA_ROOT}/attachment  ${APP_ROOT}/app/attachment

# If already installed
if [ -f /var/www/app/config/parameters.yml ] && [ 0 -lt `cat /var/www/app/config/parameters.yml | grep ".*installed:\s*[\']\{0,1\}[a-zA-Z0-9\:\+\-]\{1,\}[\']\{0,1\}" | grep -v "null" | wc -l` ]
then
    echo "Running application..."
    cd ${APP_ROOT}
    rm -r ${APP_ROOT}/app/cache/*
    sudo -u www-data ${APP_ROOT}/app/console --env=prod oro:platform:update --force
fi

# Starting services
exec /usr/local/bin/supervisord -n

