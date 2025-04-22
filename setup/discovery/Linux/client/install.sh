if [ ! -d "/opt/microsoft/discovery" ]; then
    mkdir /opt/microsoft/discovery
fi
cp ./discovery.sh /opt/microsoft/discovery
cp ./uninstall.sh /opt/microsoft/discovery
cat ./crontab | crontab -
chmod 777 /opt/microsoft/discovery/discovery.sh
chmod 777 /opt/microsoft/discovery/uninstall.sh
