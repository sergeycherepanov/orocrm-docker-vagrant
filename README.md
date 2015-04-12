# What is OroCRM?

OroCRM is a OpenSource Customer Relationship Management (CRM) application.


# How to use this image

    docker run -p 80:80 -p 8080:8080 \
    -e OROCRM_DB_HOST=... \
    -e OROCRM_DB_USER=... \
    [...] \
    scherepanov/orocrm

The following environment variables are also required for configuring your OroCRM instance:

-	`-e OROCRM_HOSTNAME=...` Server hostname or ip
-	`-e OROCRM_DB_HOST=...` MySQL server hostname or ip
-	`-e OROCRM_DB_PORT=...` MySQL server post (if empty will be used 3306)
-	`-e OROCRM_DB_USER=...` MySQL db username
-	`-e OROCRM_DB_PASSWORD=...` MySQL db password (can be empty)
-	`-e OROCRM_DB_NAME=...` MySQL database name
-	`-e OROCRM_USER_EMAIL=...` CRM user email
-	`-e OROCRM_USER_NAME=...` CRM user login
-	`-e OROCRM_USER_PASSWORD=...` CRM user password
-	`-e OROCRM_USER_FIRSTNAME=...` CRM user first name
-	`-e OROCRM_USER_LASTNAME=...` CRM user last name
-	`-e OROCRM_ORGANIZATION_NAME=...` CRM organitation name
