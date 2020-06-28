#!/bin/bash
. pomagalice
kartice=$(upitBaza "select kartice.id,uredjaji.ip,kartice.entphysicalindex,kartice.entphysicalname,kartice.entphysicaldescr,kartice.entphysicalclass,kartice.entphysicalserialnum,kartice.entphysicalmodelname,kartice.status from kartice inner join uredjaji on (nodeid = uredjaji.id)")
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

echo "<p class="small"><a href="index.sh"> < RNMS početna</a></p><h1>KARTICE</h1>"
echo "<table>"
echo "<thead>"
echo "<tr>"
echo "  <th>ID</th>"
echo "  <th>IP uređaja</th>"
echo "  <th>entPhysicalIndex</th>"
echo "  <th>entPhysicalName</th>"
echo "  <th>entPhysicalDescr</th>"
echo "  <th>entPhysicalClass</th>"
echo "  <th>entPhysicalSerialNum</th>"
echo "  <th>entPhysicalModelName</th>"
echo "  <th>Status</th>"
echo " </tr>"
echo "</thead>"

for line in $kartice; do
    cardId=$(echo $line | awk -F , '{print $1}')
	nodeIP=$(echo $line | awk -F , '{print $2}')
	entPhysicalIndex=$(echo $line | awk -F , '{print $3}')
	entPhysicalName=$(echo $line | awk -F , '{print $4}')
	entPhysicalDescr=$(echo $line | awk -F , '{print $5}')
	entPhysicalClass=$(echo $line | awk -F , '{print $6}')
	entPhysicalSerialNum=$(echo $line | awk -F , '{print $7}')
	entPhysicalModelName=$(echo $line | awk -F , '{print $8}')
	status=$(echo $line | awk -F , '{print $9}');
	echo "<tr>"; 
	echo "	<td>$cardId</td>";
	echo "	<td>$nodeIP</td>";
	echo "	<td>$entPhysicalIndex</td>";
	echo "	<td>$entPhysicalName</td>";
	echo "	<td>$entPhysicalDescr</td>";
	echo "	<td>$entPhysicalClass</td>";
	echo "	<td>$entPhysicalSerialNum</td>";
    echo "	<td>$entPhysicalModelName</td>";
	echo "	<td>$status</td>";
	echo "</tr>"; 
done
echo "</table>"
echo "</html>"