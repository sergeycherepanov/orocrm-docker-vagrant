# OroCRM Docker builder on Vagrant 

### Vagrant box for build and run [BAP Application](http://www.orocrm.com/oro-platform)  in [Docker](https://www.docker.com/) Container

## Prepare Vagrant Environment

Install VirtualBox https://www.virtualbox.org/wiki/Downloads

Install Vagrant from http://www.vagrantup.com/downloads

Install Vagrant plugins:

    vagrant plugin install vagrant-hostmanager

## Usage

#### Start vagrant and login via ssh

    vagrant up && vagrant ssh
    
### Generate SSH keys

For checkout sources you need to generate ssh keys. Run command below  and follow instructions:

    ssh-keygen -t rsa -f /home/vagrant/.ssh/id_rsa
    
When key will be generated, you need to add public key into your github account. For get public key run:

    cat /home/vagrant/.ssh/id_rsa.pub

### Build docker images from your source code
    
For build docker image you can use source code of [Empty Application](https://github.com/orocrm/platform-application), or any BAP based application ([OroCRM](https://github.com/orocrm/crm-application), [OroCommerce](https://github.com/orocommerce/orocommerce-application), etc).

    /vagrant/build.sh <git repository uri> <branchname or tags/tagname> <image name prefix> <image tag> [base-image-name]

Example: build docker image of OroCRM Community Edition from official repository:

    /vagrant/build.sh git@github.com:orocrm/crm-application.git tags/1.8.0 orocrm 1.8.0
    
Build with already assembled base image
    
    docker pull scherepanov/bap-base-system
    /vagrant/build.sh git@github.com:orocrm/crm-application.git tags/1.8.0 orocrm 1.8.0 scherepanov/bap-base-system

### Generate docker-compose.yml for your images

    /vagrant/make-compose-config.sh <image name prefix> <image tag>

Example:

    /vagrant/make-compose-config.sh orocrm 1.8.0

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
