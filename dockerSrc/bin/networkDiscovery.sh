#!/bin/bash
. pomagalice && hostIP > /dev/null
insertInto () {
status='--'
case $1 in
    uredjaji)
        unosBaza "insert into uredjaji (ip,hostname,systemname,snmp,tipuredjaja,status,community,netflow,routing) VALUES ('$ip','$hostname','$sysName','$SNMP','$sysObjectId','$status','$community','ne','ne')"
        id=$(upitBaza "select id from uredjaji where ip like '$ip'")
        if [ ! -z $id ]; then
            echo "    - $ip je učitan u RNMS bazu podataka pod id: $id"
            echo "      po završetku procesa mrežnog otkrivanja više detalja o uređaju će biti dostupno na:"
            echo "      http://$RNMS_IP/details.sh?id=$id"
        fi
        echo
    ;;
    sucelja)
        unosBaza "insert into sucelja (nodeid,ifindex,ifname,ifalias,iftype,ifphysaddress,status,ip_adresa,ifspeed) VALUES ('$nodeId','$index','$ifName','$ifAlias','$ifType','$ifPhysAddress','$status','$ipAddr','$ifSpeed')"
        echo "      - $ifName sučelje (index: ${index}) s $uredjaj učitano u RNMS bazu podataka"
        echo
    ;;
    kartice)
        unosBaza "insert into kartice (nodeid,entphysicalindex,entphysicalname,entphysicaldescr,entphysicalclass,entphysicalserialnum,entphysicalmodelname,status) VALUES ('$nodeId','$entphysicalIndex','$entityPhysicalName','$entPhysicalDescr','$entPhysicalClass','$entPhysicalSerialNum','$entPhysicalModelName','$status')" 
        echo "      - $entPhysicalDescr kartica (entphysicalIndex: $entphysicalIndex) s $uredjaj učitana u RNMS bazu podataka"
        echo
    ;;
esac
unset IFS
}

checkNode () {
case $1 in
    ima)
        ima=$(upitBaza "select * from uredjaji where ip='$ip'" | wc -l)
    ;;
    id)
        nodeId=$(upitBaza "select id from uredjaji where ip='$ip'" | head -1)
    ;;
esac
}

getCards () {
    echo "  OTKRIVANJE KARTICA NA UREĐAJU $uredjaj"
    entityIndex=$(snmpwalk -m+ENTITY-MIB -On -v 2c -c $community $ip 1.3.6.1.2.1.47.1.1.1.1.5 | grep -P 'chassis|power|module' | awk -F = '{print $1}' | awk -F . '{print $14}')
    echo "    - broj kartica = $(echo $entityIndex |  grep -o " " | wc -l)"
    for index in ${entityIndex}; do
        entphysicalIndex=$index
        entPhysicalName=$(snmpget -m+ENTITY-MIB -On -v 2c -c $community $ip 1.3.6.1.2.1.47.1.1.1.1.7.${index}  | awk -F "\: " '{print $2}')
        entPhysicalDescr=$(snmpget -m+ENTITY-MIB -On -v 2c -c $community $ip 1.3.6.1.2.1.47.1.1.1.1.2.${index}  | awk -F "\: " '{print $2}')
        entPhysicalClass=$(snmpget -m+ENTITY-MIB -On -v 2c -c $community $ip 1.3.6.1.2.1.47.1.1.1.1.5.${index}  | awk -F "\: " '{print $2}')
        entPhysicalSerialNum=$(snmpget -m+ENTITY-MIB -On -v 2c -c $community $ip 1.3.6.1.2.1.47.1.1.1.1.11.${index}  | awk -F "\: " '{print $2}')
        entPhysicalModelName=$(snmpget -m+ENTITY-MIB -On -v 2c -c $community $ip 1.3.6.1.2.1.47.1.1.1.1.13.${index}  | awk -F "\: " '{print $2}')
        status="--"
        echo "    KARTICA: $entPhysicalDescr na $ip"
        echo "      entPhysicalName=$entPhysicalName"
        echo "      entPhysicalClass=$entPhysicalClass"
        echo "      entPhysicalSerialNum=$entPhysicalSerialNum"
        echo "      entPhysicalModelName=$entPhysicalModelName"
        insertInto kartice 2>/dev/null | grep -v INSERT
    done
}

getInterfaces () {
    echo "    OTKRIVANJE SUČELJA NA UREĐAJU $uredjaj"
    ifIndexi=$(snmpwalk -On -v2c -c $community $ip 1.3.6.1.2.1.2.2.1.1 | awk -F "\: " '{print $2}')
    echo "    - broj sučelja = $(echo $ifIndexi |  grep -o " " | wc -l)"
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
        ipAddr=$(snmpwalk -v 2c -c $community $ip 1.3.6.1.2.1.4.20.1.2 | grep -P " INTEGER: ${index}$" | awk -F "." '{print $11"."$12"."$13"."$14}' | awk -F " =" '{print $1}' | sed ':a;N;$!ba;s/\n/ /g')
        # prikazi vrijednost
        echo "    SUČELJE: $ifName na $ip"
        echo "      ifSpeed=$ifSpeed bps"
        echo "      ifType=$ifType"
        echo "      ifPhysAddress=$ifPhysAddress"
        echo "      ifAlias=$ifAlias"
        if [ ! -z $ipAddr ]; then
            echo "      ipAddr=$ipAddr"
        fi
        # ubacider u baazu
        insertInto sucelja 2>/dev/null | grep -v INSERT
    done
    getCards
}

for ipRaspon in $@; do
    # separiraj IP raspon i community string
    raspon=$(echo $ipRaspon | awk -F , '{print $1}')
    community=$(echo $ipRaspon | awk -F , '{print $2}')
    echo "****************************************************************"
    echo "Otkrivanje mreže za raspon $raspon koristeći $community:"	
    echo "*****************************************************************"
    # kreiraj listu IP adresa/uredjaja za svaki raspon
    uredjaji=$(nmap -sP $raspon | grep -Po "\d*\.\d*\.\d*\.\d*")
    # za svaku IP adresu kreni u analizu
    for uredjaj in ${uredjaji}; do
        ip=$uredjaj
        echo " OTKRIVEN UREĐAJ - $uredjaj"
        # ako uredjaj s istim IP-em postoji u bazi preskoci na iduci
        checkNode ima
        if [ $ima -ge 1 ]; then
            id=$(upitBaza "select id from uredjaji where ip like '$ip'")
            echo "  - navedeni uređaj ($uredjaj) se već nalazi u RNMS bazi podataka pod id: $id, otkrivanje nepotrebno"
            # nastavi s iducim uredjajem - preskoci
            continue;
        else
        # ako se radi o novom uredjaju, izvuci detalje
            sysObjectId=$(snmpget -v 2c -On -c $community $ip 1.3.6.1.2.1.1.2.0 | awk -F "OID\: " '{print $2}')
            sysName=$(snmpget -v 2c -On -c $community $ip 1.3.6.1.2.1.1.5.0 | awk -F "STRING\: " '{print $2}')
            hostname=$(host $ip)
            if [[ $hostname == *"not found"* ]]; then hostname=ne; else hostname=$(echo $hostname | awk '{print $5}'); fi
                if [ ! -z $sysObjectId ]; then
                    echo "  - UREDJAJ $uredjaj podržava SNMP i $community je ispravan community string, početak SNMP discoverya"
                    SNMP=da 
                    insertInto uredjaji 2>/dev/null | grep -v INSERT
                    checkNode id && mkdir /RNMS/netflow/$nodeId
                    getInterfaces
                else
                    SNMP=ne
                    sysObjectId=0
                    sysName=noSNMP
                    community='--'
                    echo "  - UREDJAJ $uredjaj ne podržava SNMP ili $community nije ispravan community string"
                    insertInto uredjaji 2>/dev/null | grep -v INSERT
                    checkNode id && mkdir /RNMS/netflow/$nodeId
                fi
            fi
    done
done