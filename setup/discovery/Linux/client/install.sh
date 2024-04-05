mkdir /opt/microsoft/discovery
cp ./discovery.sh /opt/microsoft/discovery
cp ./uninstall.sh /opt/microsoft/discovery
cat ./crontab | crontab -
chmod 777 /opt/microsoft/discovery/discovery.sh
