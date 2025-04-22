# command to remove the entry from crontab
crontab -l | grep -v 'discovery.sh' | crontab -