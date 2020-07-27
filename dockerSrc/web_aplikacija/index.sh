#!/bin/bash
. pomagalice
neOKuredjaja=$(upitBaza "select count(distinct uredjaji.ip) from uredjaji where status like 'nije OK%'")
neOKsucelja=$(upitBaza "select count(distinct sucelja.id) from sucelja where status like 'down%'")
brojSucelja=$(upitBaza "select count(distinct sucelja.id) from sucelja")
brojUredjaja=$(upitBaza "select count(distinct uredjaji.ip) from uredjaji")
statusPoll=$(crontab -l | grep Status | grep -v '#' | awk -F '*' '{print $2}' | grep -Po '\d*')
perfPoll=$(crontab -l | grep Perf | grep -v '#' | awk -F '*' '{print $2}' | grep -Po '\d*')
suceljaPerf=$(find $RNMS_PREFIX/rrdb | grep -vc zahtjev)
netflowExporters=$(upitBaza "select count(distinct uredjaji.ip) from uredjaji where netflow='da'")
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
echo "    <a href="checkStatus.html">-> SNMP: provjera statusa</a><br>"
echo "    <a href="checkPerf.html">-> SNMP: provjera performansi</a><br>"
echo "    <a href="routingOpseg.sh">-> SNMP: nadzor usmjerničkih tablica</a><br>"
echo "    <a href="netflowOpseg.sh">-> NETFLOW konfiguracija: prikupljač</a><br><br>"
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
