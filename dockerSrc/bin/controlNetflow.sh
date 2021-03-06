#!/bin/bash
. pomagalice
PID=/var/run/nfcapd.pid
pid=$(ps -ef | grep nfcapd | grep -Pv "grep|\[" | awk '{print $2}' |  head -1)
if [ ! -z "$pid" ]; then
  echo "Netflow proces aktivan [${pid}], pokusaj restarta..."
  kill -9 $pid && rm -f $PID
fi
## NFCAPD - NetFlow collector - kreiraj argumente i pokreni daemon
# -P PID file; -p UDP PORT; -D daemon mode; -T all -all extensions
# iz baze podataka izvuci netflow enabled uredjaje i
# kreiraj argumente nfcapd-u za netflow direktorij po ID-u
# npr.
# -n prvi,10.16.68.250,/RNMS/netflow/prvi
/usr/bin/nfcapd -P /var/run/nfcapd.pid -D -t 600 -T all -p 2055 \
$(for line in $(su - postgres -c "psql rnms -c \"copy (select uredjaji.id,uredjaji.ip from uredjaji where netflow='da') to STDOUT WITH CSV HEADER;\"" | tail -n +2); do nodeId=$(echo $line | awk -F "," '{print $1}'); nodeIp=$(echo $line | awk -F "," '{print $2}'); echo " -n $nodeId,$nodeIp,/RNMS/netflow/$nodeId ";  done;) 

if [ $? -eq 0  ]; then
  echo -e "Netflow collector pokrenut s novim postavkama, PID=$(ps -ef | grep nfcapd | grep -v grep | awk '{print $2}' | head -1)\n\n$(ps -ef | grep nfcapd | grep -v grep)"
else
  echo "Neuspjesno pokretanje"
fi
