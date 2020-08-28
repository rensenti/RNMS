#!/bin/bash
. pomagalice
azurirajBazu () {
    if [ $rnms -eq 1 ]; then
        pollingSek=$(( $polling * 60))
        baza=/RNMS/rrdb/$id-$ip/$ifNameURLFriendly.rrdb
    else
        pollingSek=10
        baza=/RNMS/rrdb/na-zahtjev/${ip}_${ifNameURLFriendly}.rrdb
    fi
    heartbeat=$(( $pollingSek * 3 ))
    if [ ! -f "$baza" ]; then
        mkdir -p $baza && rmdir $baza # :)
        rrdtool create $baza \
            --step $pollingSek \
                DS:ifHCInOctets:COUNTER:$heartbeat:U:U \
                DS:ifHCOutOctets:COUNTER:$heartbeat:U:U \
                DS:sviDolazniPaketi:COUNTER:$heartbeat:U:U \
                DS:sviOdlazniPaketi:COUNTER:$heartbeat:U:U \
                DS:ifInErrors:COUNTER:$heartbeat:U:U \
                DS:ifOutErrors:COUNTER:$heartbeat:U:U \
                DS:ifInDiscards:COUNTER:$heartbeat:U:U \
                DS:ifOutDiscards:COUNTER:$heartbeat:U:U \
                DS:ifSpeed:GAUGE:$heartbeat:U:U \
                RRA:AVERAGE:0.5:1:300
    fi
    rrdtool update $baza $vrijeme:$ifHCInOctets:$ifHCOutOctets:$sviDolazniPaketi:$sviOdlazniPaketi:$ifInErrors:$ifOutErrors:$ifInDiscards:$ifOutDiscards:$ifSpeed
    echo " -sucelje ${ifName} (index $ifIndex):"
    echo "   -kreirana ili azurirana RRDTOOL baza podataka: $baza"
}

narisiGraf () {
    if [ ! -d $graphDir ]; then
        mkdir -p $graphDir;
    fi
    graf=$graphDir/${ip}_${ifNameURLFriendly}.png
    granulacija=$(( $pollingSek / 2 ))
    rrdtool graph \
            $graf \
            --start -${grafUnazad} \
            -S $granulacija \
            --width 450 \
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
            -v "bajtovi u sekundi" \
            DEF:ifHCInOctets=$baza:ifHCInOctets:AVERAGE \
            DEF:ifHCOutOctets=$baza:ifHCOutOctets:AVERAGE \
            DEF:ifSpeed=$baza:ifSpeed:MAX \
            CDEF:bitsIn=ifHCInOctets,8,* \
            CDEF:bitsOut=ifHCOutOctets,8,* \
            CDEF:postotakIn=bitsIn,ifSpeed,/,100,* \
            CDEF:postotakOut=bitsOut,ifSpeed,/,100,* \
            LINE1:ifHCInOctets#FFFFFF:"Dolazni promet" \
            GPRINT:ifHCInOctets:LAST:"SAD\\: %5.2lf %s" \
            GPRINT:postotakIn:LAST:"Iskoristenost veze\\: %3.4lf " \
            LINE2:ifHCOutOctets#00FF00:"Odlazni promet" \
            GPRINT:ifHCOutOctets:LAST:"SAD\\: %5.2lf %s" \
            GPRINT:postotakOut:LAST:"Iskoristenost veze\\: %3.4lf " > /dev/null 2>&1
    echo "   -kreiran ili azuriran RRDTOOL graf: $URL/${ip}_${ifNameURLFriendly}.png"

    graf=$graphDir/${ip}_${ifNameURLFriendly}_paketi.png
    rrdtool graph \
            $graf \
            --start -${grafUnazad} \
            -S $granulacija \
            --width 450 \
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
            -v "paketi po sekundi" \
            DEF:sviDolazniPaketi=$baza:sviDolazniPaketi:AVERAGE \
            DEF:sviOdlazniPaketi=$baza:sviOdlazniPaketi:AVERAGE \
            DEF:ifInErrors=$baza:ifInErrors:AVERAGE \
            DEF:ifOutErrors=$baza:ifOutErrors:AVERAGE \
            DEF:ifInDiscards=$baza:ifInDiscards:AVERAGE \
            DEF:ifOutDiscards=$baza:ifOutDiscards:AVERAGE \
            LINE1:sviDolazniPaketi#FFFFFF:"Dolazni paketi" \
            GPRINT:sviDolazniPaketi:LAST:"SAD\\: %6.1lf" \
            GPRINT:sviDolazniPaketi:MIN:"MIN\\: %6.1lf" \
            GPRINT:sviDolazniPaketi:MAX:"MAKS\\: %6.1lf" \
            LINE2:sviOdlazniPaketi#00FF00:"Odlazni paketi" \
            GPRINT:sviOdlazniPaketi:LAST:"SAD\\: %6.1lf" \
            GPRINT:sviOdlazniPaketi:MIN:"MIN\\: %6.1lf" \
            GPRINT:sviOdlazniPaketi:MAX:"MAKS\\: %6.1lf" \
            LINE3:ifInErrors#E5003D:"Errors dolazno" \
            GPRINT:ifInErrors:LAST:"SAD\\: %6.1lf" \
            GPRINT:ifInErrors:MIN:"MIN\\: %6.1lf" \
            GPRINT:ifInErrors:MAX:"MAKS\\: %6.1lf" \
            LINE4:ifOutErrors#E50008:"Erorrs odlazno" \
            GPRINT:ifOutErrors:LAST:"SAD\\: %6.1lf" \
            GPRINT:ifOutErrors:MIN:"MIN\\: %6.1lf" \
            GPRINT:ifOutErrors:MAX:"MAKS\\: %6.1lf" \
            LINE5:ifInDiscards#E54A00:"Discards dolazno" \
            GPRINT:ifInDiscards:LAST:"SAD\\: %6.1lf" \
            GPRINT:ifInDiscards:MIN:"MIN\\: %6.1lf" \
            GPRINT:ifInDiscards:MAX:"MAKS\\: %6.1lf" \
            LINE6:ifOutDiscards#E59C00:"Discards odlazno" \
            GPRINT:ifOutDiscards:LAST:"SAD\\: %6.1lf" \
            GPRINT:ifOutDiscards:MIN:"MIN\\: %6.1lf" \
            GPRINT:ifOutDiscards:MAX:"MAKS\\: %6.1lf" > /dev/null 2>&1
    echo "   -kreiran ili azuriran RRDTOOL graf: $URL/${ip}_${ifNameURLFriendly}_paketi.png"


 }

preuzmiPerfPodatke () {
    vrijeme=$(date +%s)
    # DOLAZNI
    ifHCInOctets=$(snmpget -m all -v 2c -c $community $ip ifHCInOctets.${ifIndex} | awk -F "Counter64: " '{print $2}')
    ifHCInUcastPkts=$(snmpget -m all -v 2c -c $community $ip ifHCInUcastPkts.${ifIndex} | awk -F "Counter64: " '{print $2}')
    ifHCInMulticastPkts=$(snmpget -m all -v 2c -c $community $ip ifHCInMulticastPkts.${ifIndex} | awk -F "Counter64: " '{print $2}')
    ifHCInBroadcastPkts=$(snmpget -m all -v 2c -c $community $ip ifHCInBroadcastPkts.${ifIndex} | awk -F "Counter64: " '{print $2}')
    sviDolazniPaketi=$(( $ifHCInUcastPkts + $ifHCInMulticastPkts + $ifHCInBroadcastPkts ))
    # ODLAZNI
    ifHCOutOctets=$(snmpget -m all -v 2c -c $community $ip ifHCOutOctets.${ifIndex} | awk -F "Counter64: " '{print $2}')
    ifHCOutUcastPkts=$(snmpget -m all -v 2c -c $community $ip ifHCOutUcastPkts.${ifIndex} | awk -F "Counter64: " '{print $2}')
    ifHCOutMulticastPkts=$(snmpget -m all -v 2c -c $community $ip ifHCOutMulticastPkts.${ifIndex} | awk -F "Counter64: " '{print $2}')
    ifHCOutBroadcastPkts=$(snmpget -m all -v 2c -c $community $ip ifHCOutBroadcastPkts.${ifIndex} | awk -F "Counter64: " '{print $2}')
    sviOdlazniPaketi=$(( $ifHCOutUcastPkts + $ifHCOutMulticastPkts + $ifHCOutBroadcastPkts ))
    # GRIJEŠKE
    ifInErrors=$(snmpget -v 2c -c $community $ip 1.3.6.1.2.1.2.2.1.14.${ifIndex} | awk -F "Counter32: " '{print $2}')
    ifOutErrors=$(snmpget -v 2c -c $community $ip 1.3.6.1.2.1.2.2.1.20.${ifIndex} | awk -F "Counter32: " '{print $2}')
    ifInDiscards=$(snmpget -v 2c -c $community $ip 1.3.6.1.2.1.2.2.1.13.${ifIndex} | awk -F "Counter32: " '{print $2}')
    ifOutDiscards=$(snmpget -v 2c -c $community $ip 1.3.6.1.2.1.2.2.1.19.${ifIndex} | awk -F "Counter32: " '{print $2}')
    # OSTALO
    ifSpeed=$(snmpget -m all -v2c -c $community $ip ifSpeed.${ifIndex} | awk -F "Gauge32: " '{print $2}' | head -1)
}

rnmsOpseg () {
    sucelja=$(upitBaza "select * from sucelja where status='up(1)' AND (iftype='ethernetCsmacd(6)' OR iftype='ieee80211(71)' OR iftype='bridge(209)' OR iftype='propPointToPointSerial(22)') order by nodeid")
    IFS=$'\n'
    for sucelje in $sucelja; do
        id=$(echo $sucelje | awk -F , '{print $2}')
        ip=$(upitBaza "select ip from uredjaji where id=$id")
        community=$(upitBaza "select community from uredjaji where id=$id")
        ifName=$(echo $sucelje | awk -F , '{print $4}')
        ifNameURLFriendly=$(echo $ifName | sed 's;\/;;g')
        ifIndex=$(echo $sucelje | awk -F , '{print $3}')
        preuzmiPerfPodatke && azurirajBazu && narisiGraf
    done
    unset IFS
}

interaktivniOpseg () {
    ifIndexi=$(snmpwalk -On -v2c -c $community $ip 1.3.6.1.2.1.2.2.1.1 | awk -F "\: " '{print $2}')
    for ifIndex in $ifIndexi; do
        ifName=$(snmpget -v2c -c $community $ip 1.3.6.1.2.1.31.1.1.1.1.${ifIndex} | awk -F "\: " '{print $2}' | awk -F \" '{print $2}')
        ifNameURLFriendly=$(echo $ifName | sed 's;\/;;g')
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

if [ -z $1 ] || [ "$1" == "RNMS" ]  || [ "$1" == "rnms" ]; then
    # npr.
    # checkPerf.sh RNMS 5
    rnms=1
    if [ -z $2 ]; then
        polling=5
    else
        polling=$2
    fi
    rnms=1
    grafUnazad=20000
    graphDir=/RNMS/web_aplikacija/slike/perfGrafovi
    URL="http://$RNMS_IP/slike/perfGrafovi"
    rnmsOpseg
elif [[ "$1" == "na-zahtjev" ]]; then
    # npr.
    # checkPerf.sh na-zahtjev 192.168.1.1 public
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