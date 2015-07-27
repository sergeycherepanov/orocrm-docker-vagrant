#!/bin/bash
echo "Building webscoket image..."
export DEBIAN_FRONTEND=noninteractive

# supervisor config
mv /tmp/supervisord.conf /etc/supervisord.conf
