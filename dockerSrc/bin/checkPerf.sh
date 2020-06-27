#!/bin/bash

azurirajBazu () {
    if [ $rnms -eq 1 ]; then
        pollingSek=$(( $polling * 60))
        baza=/RNMS/rrdb/$id-$ip/$ifName.rrdb
    else
        pollingSek=10
        baza=/RNMS/rrdb/na-zahtjev/${ip}_${ifName}.rrdb
    fi
    heartbeat=$(( $pollingSek * 3 ))
    if [ ! -f "$baza" ]; then
        mkdir -p $baza && rmdir $baza # :)
        rrdtool create $baza \
            --step $pollingSek \
                DS:ifInOctets:COUNTER:$heartbeat:U:U \
                DS:ifOutOctets:COUNTER:$heartbeat:U:U \
                DS:ifInErrors:COUNTER:$heartbeat:U:U \
                DS:ifOutErrors:COUNTER:$heartbeat:U:U \
                DS:ifInDiscards:COUNTER:$heartbeat:U:U \
                DS:ifOutDiscards:COUNTER:$heartbeat:U:U \
                RRA:AVERAGE:0.5:1:300
    fi
    rrdtool update $baza $vrijeme:$ifInOctets:$ifOutOctets:$ifInErrors:$ifOutErrors:$ifInDiscards:$ifOutDiscards
    echo " -sucelje ${ifName} (index $ifIndex):"
    echo "   -kreirana ili azurirana RRDTOOL baza podataka: $baza"
}

narisiGraf () {
    if [ ! -d $graphDir ]; then
        mkdir -p $graphDir;
    fi
    graf=$graphDir/${ip}_${ifName}.png
    granulacija=$(( $pollingSek / 2 ))
    rrdtool graph \
            $graf \
            --start -${grafUnazad} \
            -S $granulacija \
            --width 400 \
            --height 160 \
            -t "${ip}:${ifName}" \
            -z -c "BACK#616066" \
            -c "SHADEA#FFFFFF" \
            -c "SHADEB#FFFFFF" \
            -c "MGRID#AAAAAA" \
            -c "GRID#CCCCCC" \
            -c "ARROW#333333" \
            -c "FONT#333333" \
            -c "AXIS#333333" \
            -c "FRAME#333333" \
            -c "CANVAS#000000" \
            -c "FONT#FFFFFF" \
            -c "BACK#000000"\
            -l 0 \
            -a PNG \
            -v "B" \
            DEF:ifInOctets=$baza:ifInOctets:AVERAGE \
            DEF:ifOutOctets=$baza:ifOutOctets:AVERAGE \
            DEF:ifInErrors=$baza:ifInErrors:AVERAGE \
            DEF:ifOutErrors=$baza:ifOutErrors:AVERAGE \
            DEF:ifInDiscards=$baza:ifInDiscards:AVERAGE \
            DEF:ifOutDiscards=$baza:ifOutDiscards:AVERAGE \
            AREA:ifInOctets#00FF00:"Unutarnji promet" \
            AREA:ifOutOctets#0000FF:"Vanjski promet" \
            LINE1:ifInErrors#E5003D:"Errors in" \
            LINE2:ifOutErrors#E50008:"Erorrs out" \
            LINE3:ifInDiscards#E54A00:"Discards in" \
            LINE4:ifOutDiscards#E59C00:"Discards out" > /dev/null 2>&1
    echo "   -kreiran ili azuriran RRDTOOL graf: $URL/${ip}_${ifName}.png"
 }

preuzmiPerfPodatke () {
    vrijeme=$(date +%s)
    ifInOctets=$(snmpget -v 2c -c $community $ip 1.3.6.1.2.1.2.2.1.10.${ifIndex} | awk -F "Counter32: " '{print $2}')
    ifOutOctets=$(snmpget -v 2c -c $community $ip 1.3.6.1.2.1.2.2.1.16.${ifIndex} | awk -F "Counter32: " '{print $2}')
    ifInErrors=$(snmpget -v 2c -c $community $ip 1.3.6.1.2.1.2.2.1.14.${ifIndex} | awk -F "Counter32: " '{print $2}')
    ifOutErrors=$(snmpget -v 2c -c $community $ip 1.3.6.1.2.1.2.2.1.18.${ifIndex} | awk -F "Counter32: " '{print $2}')
    ifInDiscards=$(snmpget -v 2c -c $community $ip 1.3.6.1.2.1.2.2.1.13.${ifIndex} | awk -F "Counter32: " '{print $2}')
    ifOutDiscards=$(snmpget -v 2c -c $community $ip 1.3.6.1.2.1.2.2.1.19.${ifIndex} | awk -F "Counter32: " '{print $2}')
}

rnmsOpseg () {
    sucelja=$(su - postgres -c "psql rnms -c \"copy (select * from sucelja where status='up(1)' AND iftype='ethernetCsmacd(6)' order by nodeid)  to STDOUT WITH CSV HEADER;\"" | tail -n +2)
    IFS=$'\n'
    for sucelje in $sucelja; do
        id=$(echo $sucelje | awk -F , '{print $2}')
        ip=$(su - postgres -c "psql rnms -c \"copy (select ip from uredjaji where id="$id")  to STDOUT WITH CSV HEADER;\"" | tail -1)
        community=$(su - postgres -c "psql rnms -c \"copy (select community from uredjaji where id="$id")  to STDOUT WITH CSV HEADER;\"" | tail -1)
        ifName=$(echo $sucelje | awk -F , '{print $4}')
        ifIndex=$(echo $sucelje | awk -F , '{print $3}')
        preuzmiPerfPodatke && azurirajBazu && narisiGraf
    done
    unset IFS
}

interaktivniOpseg () {

    ifIndexi=$(snmpwalk -On -v2c -c $community $ip 1.3.6.1.2.1.2.2.1.1 | awk -F "\: " '{print $2}')
    for ifIndex in $ifIndexi; do
        ifName=$(snmpget -v2c -c $community $ip 1.3.6.1.2.1.31.1.1.1.1.${ifIndex} | awk -F "\: " '{print $2}' | awk -F \" '{print $2}')
        ifOperStatus=$(snmpget -m+IF-MIB -v 2c -c $community $ip 1.3.6.1.2.1.2.2.1.8.$ifIndex  | awk -F "INTEGER: " '{print $2}')
        if [[ "$ifOperStatus" == "down(2)" ]]; then
            continue
        fi
        # 10 polling interval svakih 30 sekundi
        preuzmiPerfPodatke && azurirajBazu && narisiGraf
    done
}

# TU POCINJEM
. /RNMS/bin/pomagalice && hostIP > /dev/null

if [[ "$1" == "RNMS" ]]; then
    rnms=1
    polling=$2
    rnms=1
    grafUnazad=20000
    graphDir=/RNMS/web_aplikacija/slike/perfGrafovi
    URL="http://$RNMS_IP/slike/perfGrafovi"
    rnmsOpseg
elif [[ "$1" == "na-zahtjev" ]]; then
    rnms=0
    ip=$2
    community=$3
    grafUnazad=350
    graphDir=/RNMS/web_aplikacija/slike/na-zahtjev
    URL="http://$RNMS_IP/slike/na-zahtjev"
    rm -rf /RNMS/rrdb/na-zahtjev/*
    echo "************************************************************"
    echo "Uredjaj $ip/$community - provjera performansi sucelja:"
    echo "************************************************************"
    for polling in $(seq 1 20); do
        echo "POLLING INTERVAL $polling / 20"
        interaktivniOpseg
        sleep $pollingSek
    done
fi