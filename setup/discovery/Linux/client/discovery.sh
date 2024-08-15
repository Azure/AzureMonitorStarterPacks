# Runtime,Type, OS, Name,Version
# get Linux OS version from bash
OSVERSION=$(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)
dpkg --list | awk '/^ii/ {print strftime("%Y-%m-%dT%H:%M:%S%z"),"application","Linux",ENVIRON["OSVERSION"],$2,$3}' | sort | sed 's/ /,/g' | sed '1i name,version' >> /opt/microsoft/discovery/discoveredapps.csv
