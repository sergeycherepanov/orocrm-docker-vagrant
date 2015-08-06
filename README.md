# What is OroCRM?

OroCRM is a OpenSource Customer Relationship Management (CRM) application.

## Usage

Start and connect to vagrant

    vagrant up && vagrant ssh

### Build docker images

    /vagrant/build.sh <git repository uri> <branchname or tags/tagname> <image name> <image tag>

example:

    /vagrant/build.sh https://github.com/orocrm/crm-application.git tags/1.7.4 scherepanov/orocrm 1.7.4
