data:
  hostname: data
  image: %IMAGE_PREFIX%-data:%IMAGE_TAG%
http:
  hostname: http
  image: %IMAGE_PREFIX%-http:%IMAGE_TAG%
  links:
    - db
    - websocket
  ports:
    - "80:80"
  env_file:
    - env/orocrm.yml
  volumes_from:
    - data
websocket:
  hostname: websocket
  image: %IMAGE_PREFIX%-ws:%IMAGE_TAG%
  links:
    - db
  ports:
    - "8080:8080"
  env_file:
    - env/orocrm.yml
  volumes_from:
    - data
job:
  hostname: job
  image: %IMAGE_PREFIX%-job:%IMAGE_TAG%
  links:
    - db
    - websocket
  env_file:
    - env/orocrm.yml
  volumes_from:
    - data
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
