#!/bin/bash
kartice=$(su - postgres -c "psql rnms -c \"copy (select kartice.id,uredjaji.ip as \"IP_NODEA\",kartice.entphysicalindex,kartice.entphysicalname,kartice.entphysicaldescr,kartice.entphysicalclass,kartice.entphysicalserialnum,kartice.entphysicalmodelname,kartice.status from kartice inner join uredjaji on (nodeid = uredjaji.id) )  to STDOUT WITH CSV HEADER;\"")
IFS=$'\n'
echo "Content-Type: text/html"
echo
echo "<html>"
echo "<head>"
echo " <meta charset="UTF-8">"
echo " <title>RNMS kartice</title>"
echo " <link rel="stylesheet" href="style.css">"
echo "</head>"
echo "<body>"
echo "<p class="small"><a href="index.sh"> < RNMS početna</a></p><h1>KARTICE</h1>"
echo "<table>"
echo "$(for line in $kartice; do echo "<tr>"; for milutin in $(echo $line | sed 's/,/\n/g'); do echo  "<td>"; echo $milutin; echo "</td>"; done; echo "</tr>" ; done)"
echo "</table>"
echo "</html>"

