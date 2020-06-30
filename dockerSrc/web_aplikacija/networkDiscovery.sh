#!/bin/bash
. pomagalice
POST_STRING=$(cat)
# iz HTTP POSTa izvuci parametar za discovery skriptu
raspon=$(echo $POST_STRING | sed 's/range=/ /g' | sed 's/&subnet=/\//g' | sed 's/community=//' | sed 's/\&/,/g' | sed 's/,START\=//g')
# pokreni discovery skriptu
IFS=$'\n'
rm -f /tmp/networkDisco

# opisi sto se desava
echo "Content-Type: text/html"
echo
echo "<html>"
echo "<head>"
echo " <meta charset="UTF-8">"
echo " <title>RNMS main</title>"
echo " <link rel="stylesheet" href="style.css">"
echo "</head>"
echo "<body>"
echo "<p class="small"><a href="index.sh">< RNMS početna</a></p><h1>RNMS - otkrivanje mreže inicirano</h1>"
echo "<p>"
echo "<div class="krugi">"
echo "<div class="term">"
#echo -e "$disco" | sed 's/$/<br>/g'
echo
$RNMS_PREFIX/bin/networkDiscovery.sh $raspon 2>&1 |  grep -v awk | sed 's/$/\<br\>\<br\>/g'
echo "</html>"
