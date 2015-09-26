#!/bin/sh

#Get device name from parameter
HOST="$1"

#Test if a host was supplied, exit with error if not
if [ -z "$HOST" ]; then
  echo "No valid host specified, valid options: $HOSTS"
  echo "You may also use a partial name as long as it produces a single match"
  exit 1
fi

#Get all available hosts from hosts file
HOSTS=$(tail -n+3 /etc/hosts | awk '{print tolower($2)}' | sed ':a;N;$!ba;s/\n/, /g')

#Get IP from hostsfile based on hostname
IP=$(grep -i "$HOST" /etc/hosts | awk '{print $1}')

#Test if the host given matched more than one IP
if [ "$(echo "$IP" | wc -l)" -ne 1 ]; then
  echo "Host specified matched multiple hosts, be more specific!"
  echo "Valid options: $HOSTS"
  exit 1
fi

#Get MAC from IP
MAC=$(grep "$IP" /etc/ethers | awk '{print $1}')

#Set broadcast based on IP
BR=$(echo "$IP" | cut -d"." -f1-3 | awk '{print $1".255"}')

#Send WOL packet
wol -v -p 9 -i "$BR" "$MAC"
