#!/bin/bash
. pomagalice
POST=$(cat)
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
echo "<p class="small"><a href="netflow.sh">< NETFLOW KONFIGURACIJA </a></p><h1>NETFLOW TRENUTNE POSTAVKE</h1>"
# prvo onemoguci svima netflow u bazi
unosBaza "update uredjaji set netflow='ne'" >/dev/null 2>&1
IFS=$'&';
# zatim iz POST-a izvuci svaki node za koji treba ukljuciti netflow
for line in $(echo "$POST"); do 
  id=$(echo $line | awk -F "node=" '{print $2}' | awk -F "_" '{print $1}');
  unosBaza "update uredjaji set netflow='da' where id=$id" > /dev/null 2>&1
  mkdir "$RNMS_PREFIX/netflow/$id" > /dev/null 2>&1
done;
IFS=$'\n'
echo "<p>"
echo "<div class="krugi">"
echo "<div class="term">"
netflow=$(upitBaza "select * from uredjaji where netflow='da'" | wc -l)
if [ $netflow -gt 0 ]; then
  $RNMS_PREFIX/bin/startNetflow.sh | sed 's/$/\<br\>\<br\>/g'
else
  echo "Trenutno nema nijednog NetFlow izvora, Netflow daemon ugasen"
  $RNMS_PREFIX/bin/startNetflow.sh > /dev/null 2>&1
fi
echo "</div></div>"
echo "</html>"
unset IFS

