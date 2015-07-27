#!/bin/bash
DIR=$(dirname $(readlink -f $0))

./build.sh https://github.com/orocrm/crm-application.git tags/1.7.4 scherepanov/orocrm 1.7.4
