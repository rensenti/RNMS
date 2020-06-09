#!/bin/bash

insertInto () {
case $1 in
        uredjaji)
su - postgres -c  "psql rnms -c \"update uredjaji set status='$status' where id='$uredjajID'\";" | grep -v UPDATE
	;;
        sucelja)
su - postgres -c  "psql rnms -c \"update sucelja set status='$ifOperStatus' where id='$suceljeID'\";"  | grep -v UPDATE
	;;
        kartice)
su - postgres -c  "psql rnms -c \"update kartice set status='$status'\";" | grep -v UPDATE
	;;
esac
}

checkNodeStatus () {
	uptime=$(snmpget -v 2c -c $community $uredjajIP 1.3.6.1.2.1.1.3.0)
	if [ ! -z "$uptime" ]; then
		status='OK (SNMP)'
	else
		status='notOK (SNMP)'
	fi
	insertInto uredjaji
}

pingaj () {
x=$(ping -W 3 -c 1 $uredjajIP | grep loss | awk '{print $6}' | sed 's/%//g')
case $x in
        0)
	        status="OK (ICMP)"
		insertInto uredjaji
           ;;
        100)
           counter=$(( $counter + 1 ))
           if [ "$counter" -lt "$previse" ]
               then pingaj
           else
	        status="notOK (ICMP)"
		insertInto uredjaji
           fi
        ;;
esac


}

IFS=$'\n'
uredjajiSNMP=$(su - postgres -c "psql rnms -c \"copy (select * from uredjaji where snmp='da') to STDOUT WITH CSV HEADER;\"" | tail -n +2 | sed 's/\"//g')
for line in $uredjajiSNMP;do
	uredjajID=$(echo $line | awk -F , '{print $1}')
	uredjajIP=$(echo $line | awk -F , '{print $2}')
	community=$(echo $line | awk -F , '{print $8}')
	echo "**************************************"
	echo "Uredjaj $uredjajIP - provjera statusa:"
	echo "**************************************"
	checkNodeStatus
	echo "  -uredjaj ${uredjajIP}- operativni status - $status"
	interfaces=$(su - postgres -c "psql rnms -c \"copy (select * from sucelja where nodeid='$uredjajID') to STDOUT WITH CSV HEADER;\"" | tail -n +2 |  sed 's/\"//g' | sort | uniq)
	for sucelje in $interfaces; do
		suceljeID=$(echo $sucelje | awk -F , '{print $1}')
		ifName=$(echo $sucelje | awk -F , '{print $4}')
		ifIndex=$(echo $sucelje | awk -F , '{print $3}')
#		ifAdminStatus=$(snmpget -v 2c -c $community $uredjajIP 1.3.6.1.2.1.2.2.1.7.$ifIndex | awk -F "INTEGER: " '{print $2}' )
		ifOperStatus=$(snmpget -m+IF-MIB -v 2c -c $community $uredjajIP 1.3.6.1.2.1.2.2.1.8.$ifIndex  | awk -F "INTEGER: " '{print $2}')
		if [ -z $ifOperStatus ]; then
			ifOperStatus="n/a"
		 fi
		echo "  -sucelje ${uredjajIP},${ifName}(index $ifIndex) - operativni status - $ifOperStatus"
		insertInto sucelja
	done
done
uredjajiNonSNMP=$(su - postgres -c "psql rnms -c \"copy (select * from uredjaji where snmp='ne') to STDOUT WITH CSV HEADER;\"" | tail -n +2 | sed 's/\"//g')
for line in $uredjajiNonSNMP;do
	uredjajID=$(echo $line | awk -F , '{print $1}')
        uredjajIP=$(echo $line | awk -F , '{print $2}')
	#previse je varijabla koja simbolizira broj izgubljenih paketa zaredom nakon koje ce node prozvati nedostupnim
	counter=0; previse=2
	pingaj
done
unset IFS	
