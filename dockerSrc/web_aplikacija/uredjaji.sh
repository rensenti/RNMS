#!/bin/bash
. pomagalice
uredjaji=$(upitBaza "select uredjaji.ip,uredjaji.hostname,uredjaji.systemname,uredjaji.snmp,deviceprofile.proizvodjac,deviceprofile.model,uredjaji.status,deviceprofile.kategorija,uredjaji.netflow,uredjaji.id from uredjaji left join deviceprofile on (uredjaji.tipuredjaja = deviceprofile.oid) ORDER BY deviceprofile.proizvodjac")
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

echo "<p class="small"><a href="index.sh"> < RNMS početna</a></p><h1>UREĐAJI</h1>"
echo "<table>"
#echo "$(for line in $uredjajiSNMP; do echo "<tr>"; for milutin in $(echo $line | sed 's/,/\n/g'); do echo  "<td>"; echo $milutin; echo "</td>"; done; echo "</tr>" ; done)"
#echo "$(for line in $uredjaji; do echo "<tr>"; for milutin in $(echo $line | sed 's/,/\n/g'); do echo  "<td>"; echo $milutin; echo "</td>"; done; echo "</tr>" ; done)"

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

for line in $uredjaji; do
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
	#echo "<td><form action="details.sh" method="post"><button type="submit" name="nodeId" value="$nodeId" class="skrivena_forma">$nodeIP</button></form></td>"
	echo "<td><a href="details.sh?id=${nodeId}" class="table">$nodeIP</a></td>"
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
echo "</html>"
unset IFS
