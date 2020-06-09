#!/bin/bash
ifIndexi=$(snmpwalk -On -v2c -c public 10.16.68.203 1.3.6.1.2.1.2.2.1.1 | awk -F "\: " '{print $2}')
for index in $ifIndexi; do
	ifSpeedOID=1.3.6.1.2.1.2.2.1.5.${index}
	ifTypeOID=1.3.6.1.2.1.2.2.1.3.${index}
	ifPhysAddressOID=1.3.6.1.2.1.2.2.1.6.${index}
	ifNameOID=1.3.6.1.2.1.31.1.1.1.1.${index}
	ifAliasOID=1.3.6.1.2.1.31.1.1.1.18.${index}
	# izvuci vrijednost
	ifSpeed=$(snmpget -v2c -c public 10.16.68.203 $ifSpeedOID | awk -F "\: " '{print $2}')
	ifType=$(snmpget -v2c -c public 10.16.68.203 $ifTypeOID | awk -F "\: " '{print $2}')
	ifPhysAddress=$(snmpget -v2c -c public 10.16.68.203 $ifPhysAddressOID | awk -F "\: " '{print $2}')
	ifName=$(snmpget -v2c -c public 10.16.68.203 $ifNameOID | awk -F "\: " '{print $2}')
	ifAlias=$(snmpget -v2c -c public 10.16.68.203 $ifAliasOID | awk -F "\: " '{print $2}')
	# izbaci vrijednost
	echo $index - 10.16.68.203 - $ifName - $ifAlias - $ifType - $ifSpeed - $Type - $ifPhysAddress
done
