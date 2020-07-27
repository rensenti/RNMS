#!/bin/bash
. pomagalice
uredjaji=$(upitBaza "select uredjaji.id,uredjaji.ip,uredjaji.hostname,uredjaji.snmp,uredjaji.netflow from uredjaji ORDER BY uredjaji.id")
IFS=$'\n'
echo "Content-Type: text/html"
echo
echo "<html>"
echo "<head>"
echo " <meta charset="UTF-8">"
echo " <title>RNMS uređaji</title>"
echo " <link rel="stylesheet" href="style.css">"
echo "</head>"
echo "<body>"
echo "<p class="small"><a href="index.sh">< RNMS početna</a></p><h1>NETFLOW KONFIGURACIJA</h1>"
echo "<section id="forma">"
echo "<div class="container">"
echo "<form class="forma" action="configureNetflow.sh" method="post">"

 echo "<table>" 
 echo "<thead>"
 echo " <tr>"
 echo "  <th>Node ID</th>"
 echo "  <th>Node IP</th>"
 echo "  <th>Hostname</th>"
 echo "  <th>SNMP</th>"
 echo "  <th>NetFlow</th>"
 echo " </tr>"
 echo "</thead>"

for line in $uredjaji; do
	nodeId=$(echo $line | awk -F , '{print $1}')
	nodeIP=$(echo $line | awk -F , '{print $2}')
	nodeHostname=$(echo $line | awk -F , '{print $3}')
	SNMP=$(echo $line | awk -F , '{print $4}')
	netflow=$(echo $line | awk -F , '{print $5}')
	echo "<tr>";
	#echo "<td><a href="reconfigure.sh%20${nodeId}" class="table">$nodeIP</a></td>";
	echo "<td>$nodeId</td>"
	echo "<td>$nodeIP</td>";
	echo "<td>$nodeHostname</td>";
	echo "<td>$SNMP</td>";
	if [ "$netflow" == "da" ]; then
		echo "<td> <input type="checkbox" id="netflow" name="node" value="${nodeId}_${nodeIP}_${netflow} checked"></td>";
	else
		echo "<td> <input type="checkbox" id="netflow" name="node" value="${nodeId}_${nodeIP}_${netflow}"></td>";
	fi
	echo "</tr>";
done
echo "</table>"
echo "<button name="Potvrdi" type="submit" class="submit">POTVRDI</button>"
echo "</form>"
echo "</div>"
echo "</section>"
echo "</html>"
unset IFS
