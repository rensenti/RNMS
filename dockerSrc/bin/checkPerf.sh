#!/bin/bash
#set -x
polling=$1
pollingSek=$(( $polling * 60))
heartbeat=$(( $pollingSek * 3 ))
granulacija=$(( $pollingSek / 2 ))
sucelja=$(su - postgres -c "psql rnms -c \"copy (select * from sucelja where status='up(1)' AND iftype='ethernetCsmacd(6)')  to STDOUT WITH CSV HEADER;\"" | tail -n +2)
IFS=$'\n'
for sucelje in $sucelja; do
        #echo $sucelje
        nodeId=$(echo $sucelje | awk -F , '{print $2}')
        nodeIP=$(su - postgres -c "psql rnms -c \"copy (select ip from uredjaji where id="$nodeId")  to STDOUT WITH CSV HEADER;\"" | tail -1)
        echo $nodeIP
        community=$(su - postgres -c "psql rnms -c \"copy (select community from uredjaji where id="$nodeId")  to STDOUT WITH CSV HEADER;\"" | tail -1)
        ifName=$(echo $sucelje | awk -F , '{print $4}')
        ifIndex=$(echo $sucelje | awk -F , '{print $3}')
        longUuid=$(echo $nodeIP-$ifName | sha1sum);
        uuid=${longUuid:0:20}
        baza=/var/opt/RNMS/rrdb/$uuid.rrd
        if [ ! -f "$baza" ]; then
                rrdtool create $baza --step $pollingSek \
                  DS:ifInOctets:COUNTER:$heartbeat:U:U  \
                  DS:ifOutOctets:COUNTER:$heartbeat:U:U \
                  DS:ifInErrors:COUNTER:$heartbeat:U:U  \
                  DS:ifOutErrors:COUNTER:$heartbeat:U:U \
                  DS:ifInDiscards:COUNTER:$heartbeat:U:U   \
                  DS:ifOutDiscards:COUNTER:$heartbeat:U:U \
                  RRA:AVERAGE:0.5:1:300
        fi
        ifInOctets=$(snmpget -v 2c -c $community $nodeIP 1.3.6.1.2.1.2.2.1.10.${ifIndex} | awk -F "Counter32: " '{print $2}')
        ifOutOctets=$(snmpget -v 2c -c $community $nodeIP 1.3.6.1.2.1.2.2.1.16.${ifIndex} | awk -F "Counter32: " '{print $2}')
        ifInErrors=$(snmpget -v 2c -c $community $nodeIP 1.3.6.1.2.1.2.2.1.14.${ifIndex} | awk -F "Counter32: " '{print $2}')
        ifOutErrors=$(snmpget -v 2c -c $community $nodeIP 1.3.6.1.2.1.2.2.1.18.${ifIndex} | awk -F "Counter32: " '{print $2}')
        ifInDiscards=$(snmpget -v 2c -c $community $nodeIP 1.3.6.1.2.1.2.2.1.13.${ifIndex} | awk -F "Counter32: " '{print $2}')
        ifOutDiscards=$(snmpget -v 2c -c $community $nodeIP 1.3.6.1.2.1.2.2.1.19.${ifIndex} | awk -F "Counter32: " '{print $2}')
        vrijeme=$(date +%s)
        rrdtool update $baza $vrijeme:$ifInOctets:$ifOutOctets:$ifInErrors:$ifOutErrors:$ifInDiscards:$ifOutDiscards
	if [ ! -d /var/opt/RNMS/http/sustav/grafovi ]; then mkdir -p /var/opt/RNMS/http/sustav/grafovi; fi
rrdtool graph /var/opt/RNMS/http/sustav/grafovi/$uuid.png --start -3600 -S $granulacija --width 200 --height 80 -t "$nodeIP bandwidth $ifName" -z         -c "BACK#616066" -c "SHADEA#FFFFFF" -c "SHADEB#FFFFFF"        -c "MGRID#AAAAAA" -c "GRID#CCCCCC" -c "ARROW#333333"         -c "FONT#333333" -c "AXIS#333333" -c "FRAME#333333"         -c "CANVAS#000000" -c "FONT#FFFFFF" -c "BACK#000000"    -l 0 -a PNG -v "B"          DEF:ifInOctets=$baza:ifInOctets:AVERAGE             DEF:ifOutOctets=$baza:ifOutOctets:AVERAGE     DEF:ifInErrors=$baza:ifInErrors:AVERAGE DEF:ifOutErrors=$baza:ifOutErrors:AVERAGE DEF:ifInDiscards=$baza:ifInDiscards:AVERAGE 	    DEF:ifOutDiscards=$baza:ifOutDiscards:AVERAGE         AREA:ifInOctets#00FF00:"Unutarnji promet"            AREA:ifOutOctets#0000FF:"Vanjski promet" LINE1:ifInErrors#E5003D:"Errors in" LINE2:ifOutErrors#E50008:"Erorrs out" LINE3:ifInDiscards#E54A00:"Discards in" LINE4:ifOutDiscards#E59C00:"Discards out"
done
unset IFS
