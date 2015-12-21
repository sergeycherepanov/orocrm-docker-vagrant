#!/bin/bash

APP_ROOT="/var/www"
DATA_ROOT="/srv/app-data"

# Prepare folders for persistent data
[[ -d ${DATA_ROOT}/config ]]         || sudo -u www-data mkdir -p ${DATA_ROOT}/config
[[ -d ${DATA_ROOT}/cache ]]          || sudo -u www-data mkdir -p ${DATA_ROOT}/cache
[[ -d ${DATA_ROOT}/media ]]          || sudo -u www-data mkdir -p ${DATA_ROOT}/media
[[ -d ${DATA_ROOT}/uploads ]]        || sudo -u www-data mkdir -p ${DATA_ROOT}/uploads
[[ -d ${DATA_ROOT}/attachment ]]     || sudo -u www-data mkdir -p ${DATA_ROOT}/attachment

# Checking if first run
if [ ! -f ${DATA_ROOT}/config/parameters.yml ]
then
    # Generate parameters.yml
    # sudo -u www-data -E composer run-script post-install-cmd -n -d ${APP_ROOT};

    # Copy configs
    sudo -u www-data cp -r ${APP_ROOT}/app/config/* ${DATA_ROOT}/config/
fi

# Clean exists folders
rm -r ${APP_ROOT}/app/config
rm -r ${APP_ROOT}/app/cache
rm -r ${APP_ROOT}/app/cache
rm -r ${APP_ROOT}/web/uploads
rm -r ${APP_ROOT}/app/attachment

# Linking persistent data
sudo -u www-data ln -s ${DATA_ROOT}/config      ${APP_ROOT}/app/config
sudo -u www-data ln -s ${DATA_ROOT}/cache       ${APP_ROOT}/app/cache
sudo -u www-data ln -s ${DATA_ROOT}/media       ${APP_ROOT}/web/media
sudo -u www-data ln -s ${DATA_ROOT}/uploads     ${APP_ROOT}/web/uploads
sudo -u www-data ln -s ${DATA_ROOT}/attachment  ${APP_ROOT}/app/attachment

# Starting services
exec /usr/local/bin/supervisord -n

