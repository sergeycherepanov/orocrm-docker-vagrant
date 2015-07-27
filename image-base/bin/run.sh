#!/bin/bash
DIR=$(dirname $(readlink -f $0))
APP_ROOT="/var/www"

# update parameters yml
echo "Apply environment to ${APP_ROOT}/app/config/parameters.yml"
sed -i -e "s/%DB_HOST%/${OROCRM_DB_HOST}/g" ${APP_ROOT}/app/config/parameters.yml
sed -i -e "s/%DB_PORT%/${OROCRM_DB_PORT}/g" ${APP_ROOT}/app/config/parameters.yml
sed -i -e "s/%DB_USER%/${OROCRM_DB_USER}/g" ${APP_ROOT}/app/config/parameters.yml
sed -i -e "s/%DB_PASSWORD%/${OROCRM_DB_PASSWORD}/g" ${APP_ROOT}/app/config/parameters.yml
sed -i -e "s/%DB_NAME%/${OROCRM_DB_NAME}/g" ${APP_ROOT}/app/config/parameters.yml

sed -i -e "s/%MAILER_TRANSPORT%/${OROCRM_MAILER_TRANSPORT}/g" ${APP_ROOT}/app/config/parameters.yml
sed -i -e "s/%MAILER_HOST%/${OROCRM_MAILER_HOST}/g" ${APP_ROOT}/app/config/parameters.yml
sed -i -e "s/%MAILER_PORT%/${OROCRM_MAILER_PORT}/g" ${APP_ROOT}/app/config/parameters.yml
sed -i -e "s/%MAILER_ENCRYPTION%/${OROCRM_MAILER_ENCRYPTION}/g" ${APP_ROOT}/app/config/parameters.yml
sed -i -e "s/%MAILER_USER%/${OROCRM_MAILER_USER}/g" ${APP_ROOT}/app/config/parameters.yml
sed -i -e "s/%MAILER_PASSWORD%/${OROCRM_MAILER_PASSWORD}/g" ${APP_ROOT}/app/config/parameters.yml

sed -i -e "s/%WEBSOCKET_HOST%/${OROCRM_WEBSOCKET_HOST}/g" ${APP_ROOT}/app/config/parameters.yml
sed -i -e "s/%WEBSOCKET_PORT%/${OROCRM_WEBSOCKET_PORT}/g" ${APP_ROOT}/app/config/parameters.yml
sed -i -e "s/%INSTALLED%/${OROCRM_INSTALLED}/g" ${APP_ROOT}/app/config/parameters.yml

if [ -z ${OROCRM_INSTALLED} ]; then
    echo "Execute: ${DIR}/install.sh ${APP_ROOT}"
    sudo -u www-data ${DIR}/install.sh ${APP_ROOT}
fi
