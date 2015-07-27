#!/bin/bash
export ORO_PHP_PATH=/usr/bin/php
APP_ROOT=$1
cd ${APP_ROOT}
if /usr/bin/php /var/www/app/console oro:install \
--timeout 3600 \
--force \
--drop-database \
--env=prod \
--user-name="${OROCRM_USER_NAME}" \
--user-firstname="${OROCRM_USER_FIRSTNAME}" \
--user-lastname="${OROCRM_USER_LASTNAME}" \
--user-password="${OROCRM_USER_PASSWORD}" \
--user-email="${OROCRM_USER_EMAIL}" \
--organization-name="${OROCRM_ORGANIZATION_NAME}" \
--application-url="http://localhost/" ;then
    exit 0
fi

exit 1
