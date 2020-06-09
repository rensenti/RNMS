#!/bin/bash
POST_STRING=$(cat)

changeCron () {
tmpCrontab=/tmp/crontab
tmpCrontab2=/tmp/crontab2
case $1 in
	status)
		crontab -l > $tmpCrontab;
		grep -v Status $tmpCrontab > $tmpCrontab2;
		echo "*/$getInterval * * * * /opt/RNMS/bin/checkStatus.sh > /var/opt/RNMS/log/checkStatus.log 2>&1" >> $tmpCrontab2;
		crontab $tmpCrontab2
		status=$(crontab -l)
	;;
	perf)
		crontab -l > $tmpCrontab;
		grep -v Perf $tmpCrontab > $tmpCrontab2;
		echo "*/$getInterval * * * * /opt/RNMS/bin/checkPerf.sh $getInterval\ >> /var/opt/RNMS/log/checkPerf.log 2>&1" >> $tmpCrontab2;
		crontab $tmpCrontab2
		status=$(crontab -l)
	;;
esac

}

# iz HTTP POSTa izvuci interval za fault ili perf
faultOrPerf=$(echo $POST_STRING | awk -F = '{print $1}')
getInterval=$(echo $POST_STRING | awk -F = '{print $2}' | awk -F "&" '{print $1}')
if [[ "$faultOrPerf" == "intervalFault" ]]; then
	if [[ "$getInterval" != "nazahtjev" ]];then
		kurac="status - $faultOrPerf"
		changeCron status
	else
		status=$(/opt/RNMS/bin/checkStatus.sh)
	fi
else
	if [[ "$getInterval" != "nazahtjev" ]];then
		kurac="perf - $faultOrPerf"
		changeCron perf
	else
                status=$(/opt/RNMS/bin/checkPerf.sh 5)
	fi
fi

echo "Content-Type: text/html"
echo
echo "<html>"
echo "<head>"
echo " <meta charset="UTF-8">"
echo " <title>RNMS main</title>"
echo " <link rel="stylesheet" href="style.css">"
echo "</head>"
echo "<body>"
echo "<p class="small"><a href="index.sh">< RNMS početna</a></p><h1>RNMS - konfiguracija intervala</h1>"
echo "<p>"
echo "<div class="krugi">"
echo "<div class="term">"
echo -e "$status" | sed 's/$/<br><br><br>/g'
echo "</div></div>"

