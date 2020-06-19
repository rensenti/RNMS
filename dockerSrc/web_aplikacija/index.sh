#!/bin/bash
neOKuredjaja=$(su - postgres -c "psql rnms -c \"copy (select count(distinct uredjaji.ip) from uredjaji where status like 'notOK%') TO STDOUT WITH CSV HEADER;\"" | grep -Po '\d*')
neOKsucelja=$(su - postgres -c "psql rnms -c \"copy (select count(distinct sucelja.id) from sucelja where status like 'down%') TO STDOUT WITH CSV HEADER;\"" | grep -Po '\d*')
sucelja=$(su - postgres -c "psql rnms -c \"copy (select sucelja.id,uredjaji.ip as \"IP_NODEA\",sucelja.ifname,sucelja.ifalias,sucelja.ifphysaddress,sucelja.iftype from sucelja inner join uredjaji on (nodeid = uredjaji.id) )  to STDOUT WITH CSV HEADER;\"")
brojSucelja=$(su - postgres -c "psql rnms -c \"copy (select count(distinct sucelja.id) from sucelja) TO STDOUT WITH CSV HEADER;\"" | grep -Po '\d*')
brojUredjaja=$(su - postgres -c "psql rnms -c \"copy (select count(distinct uredjaji.ip) from uredjaji) TO STDOUT WITH CSV HEADER;\"" | grep -Po '\d*')
statusPoll=$(crontab -l | grep Status | grep -v '#' | awk -F '*' '{print $2}' | grep -Po '\d*')
perfPoll=$(crontab -l | grep Perf | grep -v '#' | awk -F '*' '{print $2}' | grep -Po '\d*')
suceljaPerf=$(ls /RNMS/rrdb/*rrd | wc -l)
netflowExporters=$(su - postgres -c "psql rnms -c \"copy (select count(distinct uredjaji.ip) from uredjaji where netflow='da') TO STDOUT WITH CSV HEADER;\"" | grep -Po '\d*')
IFS=$'\n'
echo "Content-Type: text/html"
echo
echo "<html>"
echo "<head>"
echo " <meta charset="UTF-8">"
echo " <title>RNMS main</title>"
echo " <link rel="stylesheet" href="style.css">"
echo "</head>"
echo "<body>"
echo "<h1>RNMS - početna</h1>"
echo "<p></p>"
echo "<div class="krugi">"
echo "<div class="circle2"><p class="small">Broj uređaja:<br><br>$brojUredjaja</p></div>"
echo "<div class="circle2"><p class="small">Broj sučelja:<br><br>$brojSucelja</p></div>"
echo "<div class="circle3"><p class="small">Broj neOK sučelja:<br><br>$neOKsucelja</p></div>"
echo "<div class="circle3"><p class="small">Broj neOK uređaja:<br><br>$neOKuredjaja</p></div>"
echo "<div class="perf"><p class="stats">"
echo "RNMS statisticki podaci:<br>"
echo "• SNMP Fault polling interval (min): $statusPoll<br>"
echo "• SNMP Perf polling interval (min): $perfPoll<br>-----<br>"
echo "• Broj SNMP performance polled sučelja: $suceljaPerf<br>------<br>"
echo "• Broj NetFlow sensora (krajnjih uređaja): $netflowExporters<br><br>"
echo "</div><br><br><br><br></div>"
echo "<div class="funkcije">"

echo "  <p>FUNKCIJE</p>"
echo "    <a href="discovery.html">-> OTKRIVANJE MREŽE</a><br><br>"
echo "    <a href="checkStatus.html">-> SNMP konfiguracija: provjera statusa</a><br>"
echo "    <a href="checkPerf.html">-> SNMP konfiguracija: provjera performansi</a><br><br>"
echo "    <a href="netflow.sh">-> NETFLOW konfiguracija: prikupljač</a><br><br>"
echo "    <a href="brisi.sh">*** RESET RNMS **</a><br>OPREZNO - brisanje svih baza podataka"
echo "<p><hr></p>"
echo "  <p>MREŽNI INVENTAR</p>"
echo "  <a href="uredjaji.sh">-> UREĐAJI</a><br><br>"
echo "  <a href="sucelja.sh">-> SUČELJA</a><br><br>"
echo "  <a href="kartice.sh">-> KARTICE</a>"

echo "</div>"
echo "</body>"
echo "</html>"
unset IFS
