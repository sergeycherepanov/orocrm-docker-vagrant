bap:
  hostname: bap
  image: %IMAGE_PREFIX%:%IMAGE_TAG%
  links:
    - db
  ports:
    - "80:80"
  env_file:
    - env/orocrm.yml
db:
  hostname: db
  image: mysql:5.5
  expose:
    - 3306
  environment:
    - MYSQL_ROOT_PASSWORD=root
    - MYSQL_DATABASE=orocrm
    - MYSQL_USER=orocrm
    - MYSQL_PASSWORD=orocrm
