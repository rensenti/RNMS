#!/bin/bash

insertInto () {
status='n/a'
case $1 in
	uredjaji)
		su - postgres -c  "psql rnms -c \"insert into uredjaji (ip,hostname,systemname,snmp,tipuredjaja,status,community,netflow) VALUES ('$ip','$hostname','$sysName','$SNMP','$sysObjectId','$status','$community','ne')\";"
	;;
	sucelja)
		su - postgres -c  "psql rnms -c \"insert into sucelja (nodeid,ifindex,ifname,ifalias,iftype,ifphysaddress,status,ip_adresa) VALUES ('$nodeId','$index','$ifName','$ifAlias','$ifType','$ifPhysAddress','$status','$ipAddr')\";"
	;;
	kartice)
		su - postgres -c  "psql rnms -c \"insert into kartice (nodeid,entphysicalindex,entphysicalname,entphysicaldescr,entphysicalclass,entphysicalserialnum,entphysicalmodelname,status) VALUES ('$nodeId','$entphysicalIndex','$entityPhysicalName','$entPhysicalDescr','$entPhysicalClass','$entPhysicalSerialNum','$entPhysicalModelName','$status')\";"
	;;
esac
unset IFS
}

checkNode () {
case $1 in
	ima)
		ima=$(su - postgres -c "psql rnms -c \"copy (select * from uredjaji where ip='$ip') to STDOUT;\"" | wc -l)
	;;
	id)
		nodeId=$(su - postgres -c "psql rnms -c \"copy (select id from uredjaji where ip='$ip') to STDOUT;\"" | head -1)
	;;
esac
}

getCards () {
	echo "OTKRIVANJE KARTICA"
	entityIndex=$(snmpwalk -m+ENTITY-MIB -On -v 2c -c $community $ip 1.3.6.1.2.1.47.1.1.1.1.5 | grep -P 'chassis|power|module' | awk -F = '{print $1}' | awk -F . '{print $14}')
	echo "BROJ KARTICA = $(echo $entityIndex |  grep -o " " | wc -l)"
	for index in ${entityIndex}; do
		entphysicalIndex=$index
		entPhysicalName=$(snmpget -m+ENTITY-MIB -On -v 2c -c $community $ip 1.3.6.1.2.1.47.1.1.1.1.7.${index}  | awk -F "\: " '{print $2}')
		entPhysicalDescr=$(snmpget -m+ENTITY-MIB -On -v 2c -c $community $ip 1.3.6.1.2.1.47.1.1.1.1.2.${index}  | awk -F "\: " '{print $2}')
		entPhysicalClass=$(snmpget -m+ENTITY-MIB -On -v 2c -c $community $ip 1.3.6.1.2.1.47.1.1.1.1.5.${index}  | awk -F "\: " '{print $2}')
		entPhysicalSerialNum=$(snmpget -m+ENTITY-MIB -On -v 2c -c $community $ip 1.3.6.1.2.1.47.1.1.1.1.11.${index}  | awk -F "\: " '{print $2}')
		entPhysicalModelName=$(snmpget -m+ENTITY-MIB -On -v 2c -c $community $ip 1.3.6.1.2.1.47.1.1.1.1.13.${index}  | awk -F "\: " '{print $2}')
		status="n/a"
		echo $ip - $entphysicalIndex - $entPhysicalName - $entPhysicalDescr - $entPhysicalClass - $entPhysicalSerialNum - $entPhysicalModelName
		insertInto kartice
	done
}

getInterfaces () {
	echo "OTKRIVANJE SUCELJA"
	ifIndexi=$(snmpwalk -On -v2c -c $community $ip 1.3.6.1.2.1.2.2.1.1 | awk -F "\: " '{print $2}')
	echo "BROJ SUCELJA = $(echo $ifIndexi |  grep -o " " | wc -l)"
	for index in $ifIndexi; do
		ifSpeedOID=1.3.6.1.2.1.2.2.1.5.${index}
		ifTypeOID=1.3.6.1.2.1.2.2.1.3.${index}
		ifPhysAddressOID=1.3.6.1.2.1.2.2.1.6.${index}
		ifNameOID=1.3.6.1.2.1.31.1.1.1.1.${index}
		ifAliasOID=1.3.6.1.2.1.31.1.1.1.18.${index}
		# izvuci vrijednost
		ifSpeed=$(snmpget -v2c -c $community $ip $ifSpeedOID | awk -F "\: " '{print $2}' | head -1)
		ifType=$(snmpget -m+IF-MIB -v2c -c $community $ip $ifTypeOID | awk -F "\: " '{print $2}')
		ifPhysAddress=$(snmpget -v2c -c $community $ip $ifPhysAddressOID | awk -F "\: " '{print $2}')
		ifName=$(snmpget -v2c -c $community $ip $ifNameOID | awk -F "\: " '{print $2}')
		ifAlias=$(snmpget -v2c -c $community $ip $ifAliasOID | awk -F "\: " '{print $2}' | sed 's/\"//g')
		ipAddr=$(snmpwalk -v 2c -c $community $ip 1.3.6.1.2.1.4.20.1.2 | grep -P " INTEGER: ${index}$" | awk -F "." '{print $11"."$12"."$13"."$14}' | awk -F " =" '{print $1}')
		# prikazi vrijednost
		echo $ip - index: ${index}: $ifName - $ifAlias - $ifType - $ifSpeed - $ifType - $ifPhysAddress - $ipAddr
		# ubacider u baazu
		insertInto sucelja
	done
	getCards
}

for ipRaspon in $@; do
	# separiraj IP raspon i community string
	raspon=$(echo $ipRaspon | awk -F , '{print $1}')
	community=$(echo $ipRaspon | awk -F , '{print $2}')
	# kreiraj listu IP adresa/uredjaja za svaki raspon
	uredjaji=$(nmap -sP $raspon | grep -Po "\d*\.\d*\.\d*\.\d*")
	# za svaku IP adresu kreni u analizu
	for uredjaj in ${uredjaji}; do
		ip=$uredjaj
		echo "OTKRIVEN UREDJAJ - $uredjaj"
		# ako uredjaj s istim IP-em postoji u bazi preskoci na iduci
		checkNode ima
		if [[ "$ima" -ge "1" ]]; then
			echo "uredjaj vec postoji u bazi"
			# nastavi s iducim uredjajem - preskoci
			continue;
		else
		# ako se radi o novom uredjaju, izvuci detalje
			echo $ip - $uredjaj
			sysObjectId=$(snmpget -v 2c -On -c $community $ip 1.3.6.1.2.1.1.2.0 | awk -F "OID\: " '{print $2}')
			sysName=$(snmpget -v 2c -On -c $community $ip 1.3.6.1.2.1.1.5.0 | awk -F "STRING\: " '{print $2}')
			hostname=$(host $ip)
			if [[ $hostname == *"not found"* ]]; then hostname=ne; else hostname=$(echo $hostname | awk '{print $5}'); fi
				if [ ! -z $sysObjectId ]; then
					echo "UREDJAJ - $uredjaj - pokreni SNMP discovery"
					SNMP=da 
					insertInto uredjaji
					checkNode id && mkdir /RNMS/netflow/$nodeId
					getInterfaces
				else
					SNMP=ne
					sysObjectId=0
					sysName=noSNMP
					community='n/a'
					echo "UREDJAJ - $uredjaj - ne podrzava SNMP"
					insertInto uredjaji
					checkNode id && mkdir /RNMS/netflow/$nodeId
				fi
			fi
	done
done
