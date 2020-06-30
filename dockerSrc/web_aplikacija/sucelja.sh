#!/bin/bash
. pomagalice
sucelja=$(upitBaza "select sucelja.id,uredjaji.ip,sucelja.ifname,sucelja.ifalias,sucelja.ifphysaddress,sucelja.iftype,sucelja.status,sucelja.nodeid,sucelja.ip_adresa,sucelja.ifspeed from sucelja inner join uredjaji on (nodeid = uredjaji.id) ORDER BY uredjaji.ip,sucelja.ifname")
IFS=$'\n'
echo "Content-Type: text/html"
echo
echo "<html>"
echo "<head>"
echo "	<meta charset="UTF-8">"
echo "	<title>RNMS sučelja</title>"
echo "	<link rel="stylesheet" href="style.css">"
echo "</head>"
echo "<body>"

echo "<p class="small"><a href="index.sh"> < RNMS početna</a></p><h1>SUČELJA</h1>"
echo "<table>"
echo "<thead>"
echo "<tr>"
echo "  <th>Uredaj</th>"
echo "  <th>Sučelje</th>"
echo "  <th>IP adresa</th>"
echo "  <th>Opis sučelja</th>"
echo "  <th>L2 adresa</th>"
echo "  <th>Tip sučelja</th>"
echo "  <th>Brzina sučelja (bps)</th>"
echo "<th>Status</th>"
echo " </tr>"
echo "</thead>"
for line in $sucelja; do 
	nodeId=$(echo $line | awk -F , '{print $8}');
	nodeIP=$(echo $line | awk -F , '{print $2}');
	ifName=$(echo $line | awk -F , '{print $3}');
	longUuid=$(echo $nodeIP-$ifName | sha1sum);
	uuid=${longUuid:0:20}
	ifAlias=$(echo $line | awk -F , '{print $4}');
	ifPhysAddress=$(echo $line | awk -F , '{print $5}');
	ifType=$(echo $line | awk -F , '{print $6}');
	status=$(echo $line | awk -F , '{print $7}');
	ipAdresa=$(echo $line | awk -F , '{print $9}');
	ifSpeed=$(echo $line | awk -F , '{print $10}');
    ifNameURLFriendly=$(echo $ifName | sed 's;\/;;g')
	echo "<tr>"; 
	echo "	<td>$nodeIP</td>";
	echo "	<td>$ifName<div class=\"popup\"><img src=\"slike/perfGrafovi/${nodeIP}_${ifNameURLFriendly}.png\"></td>";
	echo "	<td>$ipAdresa</td>";
	echo "	<td>$ifAlias</td>";
	echo "	<td>$ifPhysAddress</td>";
	echo "	<td>$ifType</td>";
	echo "	<td>$ifSpeed</td>";
	echo "	<td>$status</td>";
	echo "</tr>"; 
done
echo "</table>"
echo "</html>"
