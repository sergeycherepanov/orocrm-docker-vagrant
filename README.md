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

### Build docker images

    You can use any [BAP](https://github.com/orocrm/platform) application source code for build docker containers.

    /vagrant/build.sh <git repository uri> <branchname or tags/tagname> <image name> <image tag>

    Example for build OroCRM community edition from github repository:

    /vagrant/build.sh https://github.com/orocrm/crm-application.git tags/1.7.4 scherepanov/orocrm 1.7.4

### Run containers

    cd /vagrant
    docker-compose up

    If all docker containers started without errors, you can see web installer here: http://orocrm.loc
