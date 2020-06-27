#!/bin/bash

insertInto () {
case $1 in
    uredjaji)
        su - postgres -c  "psql rnms -c \"update uredjaji set status='$status' where id='$uredjajID'\";" | grep -v UPDATE
        ;;
    sucelja)
        su - postgres -c  "psql rnms -c \"update sucelja set status='$ifOperStatus' where id='$suceljeID'\";"  | grep -v UPDATE
        ;;
esac
}

checkNodeStatus () {
    echo "*************************************************"
    echo "Uredjaj $ip/$community - provjera statusa:"
    echo "*************************************************"
    uptime=$(snmpget -v 2c -c $community $ip 1.3.6.1.2.1.1.3.0)
    if [ ! -z "$uptime" ]; then
        status='OK (SNMP)'
        echo " UREDAJ $ip: $status"
        if [ $rnms -eq 0 ]; then
            checkInterfaces
            true
        else
            insertInto uredjaji
        fi
    else
        status='nije OK (SNMP)'
        echo " UREDAJ $ip: $status"
        false
    fi
}

checkInterfaces () {
    ifIndexi=$(snmpwalk -On -v2c -c $community $ip 1.3.6.1.2.1.2.2.1.1 | awk -F "\: " '{print $2}')
    for index in $ifIndexi; do
        ifName=$(snmpget -v2c -c $community $ip 1.3.6.1.2.1.31.1.1.1.1.${index} | awk -F "\: " '{print $2}')
        ifOperStatus=$(snmpget -m+IF-MIB -v 2c -c $community $ip 1.3.6.1.2.1.2.2.1.8.$index  | awk -F "INTEGER: " '{print $2}')
        if [ -z $ifOperStatus ]; then
            ifOperStatus="nepoznat"
        fi
        echo "  - sucelje ${ifName} (index $index) | operativni status: $ifOperStatus"
        if [ $rnms -eq 1 ]; then
            insertInto sucelja
        fi
    done
}

pingaj () {
    counter=$1
    previse=$2
    izgubljeniPaketi=$(ping -W 3 -c 1 $ip | grep loss | awk '{print $6}' | sed 's/%//g')
    case $izgubljeniPaketi in
        0)
            status="OK (ICMP)"
            echo " UREDAJ $ip: $status"
            if [ $rnms -eq 1 ]; then
                insertInto uredjaji
            fi
        ;;
        100)
            counter=$(( $counter + 1 ))
            if [ "$counter" -lt "$previse" ]
                then pingaj $counter $previse
            else
                status="nije OK (ICMP)"
                echo " UREDAJ $ip: $status"
            fi
        ;;
    esac
}

rnms () {
    rnms=1
    IFS=$'\n'
    uredjajiSNMP=$(su - postgres -c "psql rnms -c \"copy (select * from uredjaji where snmp='da') to STDOUT WITH CSV HEADER;\"" | tail -n +2 | sed 's/\"//g')
    for line in $uredjajiSNMP;do
        uredjajID=$(echo $line | awk -F , '{print $1}')
        ip=$(echo $line | awk -F , '{print $2}')
        community=$(echo $line | awk -F , '{print $8}')
        checkNodeStatus
        interfaces=$(su - postgres -c "psql rnms -c \"copy (select * from sucelja where nodeid='$uredjajID') to STDOUT WITH CSV HEADER;\"" | tail -n +2 |  sed 's/\"//g' | sort | uniq)
        if [[ "$status" == "OK (SNMP)" ]]; then
            for sucelje in $interfaces; do
                suceljeID=$(echo $sucelje | awk -F , '{print $1}')
                ifName=$(echo $sucelje | awk -F , '{print $4}')
                ifIndex=$(echo $sucelje | awk -F , '{print $3}')
                #ifAdminStatus=$(snmpget -v 2c -c $community $ip 1.3.6.1.2.1.2.2.1.7.$ifIndex | awk -F "INTEGER: " '{print $2}' )
                ifOperStatus=$(snmpget -m+IF-MIB -v 2c -c $community $ip 1.3.6.1.2.1.2.2.1.8.$ifIndex  | awk -F "INTEGER: " '{print $2}')
                if [ -z $ifOperStatus ]; then
                    ifOperStatus="nepoznat"
                fi
                echo "  - sucelje ${ifName} (index $ifIndex) | operativni status: $ifOperStatus"
                insertInto sucelja
            done
        else
            for sucelje in $interfaces; do
                suceljeID=$(echo $sucelje | awk -F , '{print $1}');
                ifOperStatus="nepoznat"
                echo "  - sucelje ${ifName} (index $index) | operativni status: $ifOperStatus"
                ifIndex=$(echo $sucelje | awk -F , '{print $3}')
                insertInto sucelja
            done
        fi
    done
    uredjajiNonSNMP=$(su - postgres -c "psql rnms -c \"copy (select * from uredjaji where snmp='ne') to STDOUT WITH CSV HEADER;\"" | tail -n +2 | sed 's/\"//g')
    for line in $uredjajiNonSNMP;do
        uredjajID=$(echo $line | awk -F , '{print $1}')
        ip=$(echo $line | awk -F , '{print $2}')
        #previse je varijabla koja simbolizira broj izgubljenih paketa zaredom nakon koje ce node prozvati nedostupnim
        pingaj 0 2 2>/dev/null && insertInto uredjaji
    done
    unset IFS	
}

if [ -z $1 ]; then
    rnms
else
    rnms=0
    ip=$1
    community=$2
    checkNodeStatus || pingaj 0 2
fi