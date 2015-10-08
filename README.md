# Vagrant Box for OroCRM Docker Containers

Vagrant box for build and run OroCRM in Docker

## Prepare Vagrant Environment

Install VirtualBox https://www.virtualbox.org/wiki/Downloads

Install Vagrant from http://www.vagrantup.com/downloads

Install Vagrant plugins:

    vagrant plugin install vagrant-hostmanager

## Usage

#### Start vagrant and login via ssh

    vagrant up && vagrant ssh

### Build docker images from source

You can try to build containers from any [BAP](https://github.com/orocrm/platform) application source code.
But it's tested only with OroCRM

    /vagrant/build.sh <git repository uri> <branchname or tags/tagname> <image name prefix> <image tag>

Example for build OroCRM community edition from github repository:

    /vagrant/build.sh https://github.com/orocrm/crm-application.git tags/1.8.0 orocrm 1.8.0

### Generate docker-compose.yml for yout images

    /vagrant/compose-config.sh <image name prefix> <image tag>

For example:

    /vagrant/compose-config.sh orocrm 1.8.0

### Run containers

    cd /vagrant
    docker-compose up

If all docker containers started without errors, you can see web installer here: [http://orocrm.loc](http://orocrm.loc)

#### Mysql credentials for install:
```
host: db
database: orocrm 
user: orocrm 
password: orocrm
```
