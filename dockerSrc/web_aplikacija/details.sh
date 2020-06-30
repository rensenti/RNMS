#!/bin/bash
. pomagalice
# ako je QUERY_STRING prazan izvuci id uredjaja iz POST
# ako nije onda iz prvog parametra
if [ -z $QUERY_STRING ]; then
    id=$(cat | awk -F "=" '{print $2}')
else
    id=$(echo $QUERY_STRING | awk -F "&" '{print $1}' | awk -F = '{print $2}')
fi
uredjaj=$(upitBaza "select uredjaji.ip,uredjaji.hostname,uredjaji.systemname,uredjaji.snmp,deviceprofile.proizvodjac,deviceprofile.model,uredjaji.status,deviceprofile.kategorija,uredjaji.netflow,uredjaji.id from uredjaji left join deviceprofile on (uredjaji.tipuredjaja = deviceprofile.oid) where uredjaji.id="$id" ORDER BY deviceprofile.proizvodjac")
sucelja=$(upitBaza "select sucelja.id,uredjaji.ip,sucelja.ifname,sucelja.ifalias,sucelja.ifphysaddress,sucelja.iftype,sucelja.status,sucelja.nodeid,sucelja.ip_adresa from sucelja inner join uredjaji on (nodeid = uredjaji.id) where sucelja.nodeid="$id" ORDER BY uredjaji.ip,sucelja.ifname")
IFS=$'\n'
echo "Content-Type: text/html"
echo
echo "<html>"
echo "<head>"
echo " <meta charset="UTF-8">"
echo " <title>RNMS detalji (${id})</title>"
echo " <link rel="stylesheet" href="style.css">"
echo "</head>"
echo "<body>"

echo "<p class="small"><a href="uredjaji.sh"> < RNMS uređaji</a></p><h1>DETALJI o uređaju - id:$id</h1>"
echo "<table>"

 echo "<thead>"
 echo " <tr>"
 echo "  <th>IP adresa</th>"
 echo "  <th>Hostname</th>"
 echo "  <th>Systemname</th>"
 echo "  <th>SNMP</th>"
 echo "  <th>NetFlow</th>"
 echo "  <th>Kategorija</th>"
 echo "  <th>Proizvođač</th>"
 echo "  <th>Model</th>"
 echo "  <th>Status</th>"
 echo " </tr>"
 echo "</thead>"

for line in $uredjaj; do
    nodeId=$(echo $line | awk -F , '{print $10}')
    nodeIP=$(echo $line | awk -F , '{print $1}')
    nodeHostname=$(echo $line | awk -F , '{print $2}')
    nodeSystemname=$(echo $line | awk -F , '{print $3}')
    SNMP=$(echo $line | awk -F , '{print $4}')
    status=$(echo $line | awk -F , '{print $7}')
    kategorija=$(echo $line | awk -F , '{print $8}')
    proizvodjac=$(echo $line | awk -F , '{print $5}')
    model=$(echo $line | awk -F , '{print $6}')
    netflow=$(echo $line | awk -F , '{print $9}')
    echo "<tr>";
    #echo "<td><a href="reconfigure.sh%20${nodeId}" class="table">$nodeIP</a></td>";
    echo "<td>$nodeIP</td>";
    echo "<td>$nodeHostname</td>";
    echo "<td>$nodeSystemname</td>";
    echo "<td>$SNMP</td>";
    echo "<td>$netflow</td>";
    echo "<td>$kategorija</td>";
    echo "<td>$proizvodjac</td>";
    echo "<td>$model</td>";
    echo "<td>$status</td>";
    echo "</tr>";
done
echo "</table>"
echo "<h3>Sučelja</h3>"
echo "<table>"
echo "<thead>"
echo "<tr>"
echo "  <th>Sučelje</th>"
echo "  <th>IP adresa</th>"
echo "  <th>Opis sučelja</th>"
echo "  <th>L2 adresa</th>"
echo "  <th>Tip sučelja</th>"
echo "  <th>Status</th>"
echo "</tr>"
echo "</thead>"
for line in $sucelja; do
    ifName=$(echo $line | awk -F , '{print $3}');
    # longUuid=$(echo $nodeIP-$ifNamef | sha1sum);
    # uuid=${longUuid:0:20}
    ifAlias=$(echo $line | awk -F , '{print $4}');
    ifPhysAddress=$(echo $line | awk -F , '{print $5}');
    ifType=$(echo $line | awk -F , '{print $6}');
    status=$(echo $line | awk -F , '{print $7}');
    ipAdresa=$(echo $line | awk -F , '{print $9}');
    ifNameURLFriendly=$(echo $ifName | sed 's;\/;;g')
    echo "<tr>";
    echo "  <td>$ifName<div class=\"popup\"><img src=\"slike/perfGrafovi/${nodeIP}_${ifNameURLFriendly}.png\>"</td>";
    echo "  <td>$ipAdresa</td>";
    echo "  <td>$ifAlias</td>";
    echo "  <td>$ifPhysAddress</td>";
    echo "  <td>$ifType</td>";
    echo "  <td>$status</td>";
    echo "</tr>";
done
echo "</table>"

echo "<h3>NetFlow podaci</h3>"
echo "<div class="krugi">"
if [ "$netflow" == "da" ]; then
    prije15min=$(date -d "-15 minutes" +%Y/%m/%d.%H:%M:%S)
    sad=$(date +%Y/%m/%d.%H:%M:%S)
    vrijemenskaDimenzija="${prije15min}-${sad}"
    echo "<b>Statistika o suceljima</b>:<br><br>DOLAZNA SUČELJA:<br><br>"
    echo "<table>"
    echo "<thead>"
    echo "<tr>"
    echo "  <th>Početni flow</th>" # ts
    echo "  <th>Posljednji flow</th>" # te
    echo "  <th>Trajanje</th>" # td
    echo "  <th>Protokol</th>" # pr
    echo "  <th>Ulazno sučelje</th>" # val
    echo "  <th>Broj tokova</th>" # fl
    echo "  <th>Postotak tokova</th>" # flP
    echo "  <th>Broj paketa</th>" # ipkt
    echo "  <th>Postotak paketa</th>" # ipktP
    echo "  <th>Byte</th>" # ibyt
    echo "  <th>Postotak byte</th>" # ibytP
    echo "  <th>Broj paketa u sekundi</th>" # ipps
    echo "  <th>Bit po sekundi (bps)</th>" # ipbs
    echo "  <th>Byte po paketu</th>" # ibpp
    echo "</tr>"
    echo "</thead>"
    IFS=$'\n';
    for line in $(nfdump -R $RNMS_PREFIX/netflow/${id} -s inif -t $vrijemenskaDimenzija -o csv | head -n-4); do
        ifIndex=$(echo $line | awk -F , '{print $5}');
        ifName=$(upitBaza "select ifname from sucelja where ifindex='$ifIndex' and nodeid='$id'");
        if [ ! -z $ifName ]; then
            echo "<tr>"
            echo "$line" | sed "s/,$ifIndex,/,$ifName,/g" | sed 's/,/<\/td><td>/g' | sed 's/^/<td>/g';
            echo "</tr>"
        fi;
    done
    unset IFS;
    echo "</table>"
    echo "ODLAZNA SUČELJA:<br><br>"
    echo "<table>"
    echo "<thead>"
    echo "<tr>"
    echo "  <th>Početni flow</th>" # ts
    echo "  <th>Posljednji flow</th>" # te
    echo "  <th>Trajanje</th>" # td
    echo "  <th>Protokol</th>" # pr
    echo "  <th>Izlazno sučelje</th>" # val
    echo "  <th>Broj tokova</th>" # fl
    echo "  <th>Postotak tokova</th>" # flP
    echo "  <th>Broj paketa</th>" # opkt
    echo "  <th>Postotak paketa</th>" # opktP
    echo "  <th>Byte</th>" # obyt
    echo "  <th>Postotak byte</th>" # obytP
    echo "  <th>Broj paketa u sekundi</th>" # opps
    echo "  <th>Bit po sekundi (bps)</th>" # opbs
    echo "  <th>Byte po paketu</th>" # obpp
    echo "</tr>"
    echo "</thead>"
    IFS=$'\n';
    for line in $(nfdump -R $RNMS_PREFIX/netflow/${id} -s outif -t $vrijemenskaDimenzija -o csv | head -n-4); do
        ifIndex=$(echo $line | awk -F , '{print $5}');
        ifName=$(upitBaza "select ifname from sucelja where ifindex='$ifIndex' and nodeid='$id'");
        if [ ! -z $ifName ]; then
            echo "<tr>"
            echo "$line" | sed "s/,$ifIndex,/,$ifName,/g" | sed 's/,/<\/td><td>/g' | sed 's/^/<td>/g';
            echo "</tr>"
        fi;
    done
    unset IFS;
    echo "</table>"
    #echo $(nfdump -R $RNMS_PREFIX/netflow/${id}/ -s if | sed 's/$/\<br\>\<br\>/g' | grep -Pv 'Sys|processed')
    echo "<br><br>"
    echo "<div class="netflow">"
    echo "<b>Statistika o protokolima</b>:<br><br>"
    echo $(nfdump -R $RNMS_PREFIX/netflow/${id}/ -s proto -t $vrijemenskaDimenzija |  sed 's/$/\<br\>\<br\>/g')
else
    echo "Za navedeni uredjaj trenutno nema NetFlow podataka<br><br>"
fi
  
echo "</div>"
echo "</html>"
unset IFS