#!/bin/bash
. pomagalice
POST=$(cat)
IFS=$'\n'
echo "Content-Type: text/html"
echo
echo "<html>"
echo "<head>"
echo " <meta charset="UTF-8">"
echo " <title>RNMS: konfiguracija nadzora usmjerničkih tablica</title>"
echo " <link rel="stylesheet" href="style.css">"
echo "</head>"
echo "<body>"
echo "<p class="small"><a href="routingOpseg.sh">< NADZOR USMJERNIČKIH TABLICA KONFIGURACIJA </a></p><h1>NADZOR USMJERNIČKIH TABLICA TRENUTNE POSTAVKE</h1>"
# prvo onemoguci svima nadzzor usmjerničkih tablica u bazi
unosBaza "update uredjaji set routing='ne'" >/dev/null 2>&1
IFS=$'&';
# zatim iz POST-a izvuci svaki node za koji treba ukljuciti nadzor usmjerničkih tablica i kreiraj dir
for line in $(echo "$POST"); do 
  id=$(echo $line | awk -F "node=" '{print $2}' | awk -F "_" '{print $1}');
  unosBaza "update uredjaji set routing='da' where id=$id" > /dev/null 2>&1
  mkdir -p "$RNMS_PREFIX/routing/$id" > /dev/null 2>&1
done;
IFS=$'\n'
echo "<p>"
echo "<div class="krugi">"
echo "<div class="term">"
routing=$(upitBaza "select uredjaji.ip from uredjaji where routing='da'")
echo "Konfiguriran nadzor usmjerničkih tablica na sljedećim uredjajima:<br><br>"
for line in $routing; do
  echo " - $line<br><br>"
done
echo "</div></div>"
echo "</html>"
unset IFS