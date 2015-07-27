#!/bin/bash
echo "Building job image..."
export DEBIAN_FRONTEND=noninteractive
# supervisor config
mv /tmp/supervisord.conf /etc/supervisord.conf
