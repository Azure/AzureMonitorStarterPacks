#!/bin/bash
set -e

if [ ! -d "/opt/microsoft/discovery" ]; then
    sudo mkdir -p /opt/microsoft/discovery
fi

if [ ! -f "./discovery.sh" ] || [ ! -f "./uninstall.sh" ] || [ ! -f "./crontab" ]; then
    echo "Required files (discovery.sh, uninstall.sh, crontab) not found in current directory."
    exit 1
fi

sudo cp ./discovery.sh /opt/microsoft/discovery
sudo cp ./uninstall.sh /opt/microsoft/discovery
cat ./crontab | crontab -
sudo chmod 755 /opt/microsoft/discovery/discovery.sh
sudo chmod 755 /opt/microsoft/discovery/uninstall.sh
