#!/bin/bash
ARGUMENTS_IS_VALID="true";
for var in OROCRM_DB_HOST OROCRM_DB_USER OROCRM_DB_NAME OROCRM_USER_EMAIL OROCRM_USER_NAME OROCRM_USER_PASSWORD OROCRM_USER_FIRSTNAME OROCRM_USER_LASTNAME OROCRM_ORGANIZATION_NAME 
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
cp /var/www/app/config/parameters.yml.tpl /var/www/app/config/parameters.yml

sed -i -e "s/%DB_HOST%/${OROCRM_DB_HOST}/g" /var/www/app/config/parameters.yml
sed -i -e "s/%DB_USER%/${OROCRM_DB_USER}/g" /var/www/app/config/parameters.yml
sed -i -e "s/%DB_PASSWORD%/${OROCRM_DB_PASSWORD}/g" /var/www/app/config/parameters.yml
sed -i -e "s/%DB_NAME%/${OROCRM_DB_NAME}/g" /var/www/app/config/parameters.yml

echo "Running installation process..."
/usr/bin/php /var/www/app/console oro:install \
--organization-name="${OROCRM_ORGANIZATION_NAME}" \
--user-name="${OROCRM_USER_NAME}" \
--user-email="${OROCRM_USER_EMAIL}" \
--user-firstname="${OROCRM_USER_FIRSTNAME}" \
--user-lastname="${OROCRM_USER_LASTNAME}" \
--user-password="${OROCRM_USER_PASSWORD}"

