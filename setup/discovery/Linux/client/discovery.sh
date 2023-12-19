dpkg --list | awk '/^ii/ {print $2, $3}' | sort | sed 's/ /,/g' | sed '1i name,version' >> /opt/microsoft/amspdiscovery/discoveredapps.csv
