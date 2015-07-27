#!/bin/bash
echo "Building http image..."
export DEBIAN_FRONTEND=noninteractive

# supervisor config
mv /tmp/supervisord.conf /etc/supervisord.conf
