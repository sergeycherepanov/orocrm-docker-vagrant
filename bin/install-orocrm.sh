#!/bin/bash
APP_ROOT="/var/www"
ARGUMENTS_IS_VALID="true";
for var in OROCRM_DB_HOST OROCRM_DB_USER OROCRM_DB_NAME OROCRM_USER_EMAIL OROCRM_USER_NAME OROCRM_USER_PASSWORD OROCRM_USER_FIRSTNAME OROCRM_USER_LASTNAME OROCRM_ORGANIZATION_NAME OROCRM_HOSTNAME
do
  if [ -z ${!var} ]; then
    echo  ${var} "argument is required!"
    ARGUMENTS_IS_VALID=""
  fi
done

if [ -z ARGUMENTS_IS_VALID ]; then
    exit 1
fi

echo "Copying parameters.yml..."
sudo -u www-data /bin/bash -c "/bin/cp ${APP_ROOT}/app/config/parameters.yml.tpl ${APP_ROOT}/app/config/parameters.yml"

sed -i -e "s/%DB_HOST%/${OROCRM_DB_HOST}/g" ${APP_ROOT}/app/config/parameters.yml
sed -i -e "s/%DB_PORT%/${OROCRM_DB_PORT}/g" ${APP_ROOT}/app/config/parameters.yml
sed -i -e "s/%DB_USER%/${OROCRM_DB_USER}/g" ${APP_ROOT}/app/config/parameters.yml
sed -i -e "s/%DB_PASSWORD%/${OROCRM_DB_PASSWORD}/g" ${APP_ROOT}/app/config/parameters.yml
sed -i -e "s/%DB_NAME%/${OROCRM_DB_NAME}/g" ${APP_ROOT}/app/config/parameters.yml

echo "Running installation process..."
sudo -u www-data /bin/bash -c 'cd '${APP_ROOT}' && /usr/bin/php '${APP_ROOT}'/app/console oro:install \
--env prod \
--organization-name="'${OROCRM_ORGANIZATION_NAME}'" \
--application-url="http://'${OROCRM_HOSTNAME}'" \
--user-name="'${OROCRM_USER_NAME}'" \
--user-email="'${OROCRM_USER_EMAIL}'" \
--user-firstname="'${OROCRM_USER_FIRSTNAME}'" \
--user-lastname="'${OROCRM_USER_LASTNAME}'" \
--user-password="'${OROCRM_USER_PASSWORD}'"'

echo "Configuring crontab..."
sudo -u www-data /bin/bash -c '/bin/echo "* * * * * /usr/bin/php '${APP_ROOT}'/app/console oro:cron --env prod" | /usr/bin/crontab'

