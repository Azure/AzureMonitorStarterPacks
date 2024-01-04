# Runtime,Type, OS, Name,Version
dpkg --list | awk '/^ii/ {print strftime("%Y-%m-%dT%H:%M:%s%z"),"application","Linux",$2,$3}' | sort | sed 's/ /,/g' | sed '1i name,version' >> /opt/microsoft/discovery/discoveredapps.csv
