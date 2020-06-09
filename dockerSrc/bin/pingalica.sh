#!/bin/bash
IP=$1
counter=0
# broj izgubljenih paketa kad cu proglasiti node nedostupnim
previse=2

pingaj () {
x=$(ping -c 1 $IP | grep loss | awk '{print $6}' | sed 's/%//g')
case $x in
		0)
				echo "dela"
		;;
		100)
##			  let "counter += 1"
				counter=$(( $counter + 1 ))
				if [ "$counter" -lt "$previse" ]
						then pingaj
				else
						echo "fakat ne dela"
		fi
		;;
esac
}

if [ ! -z $IP ]
		then pingaj
else
		echo -e "Potrebno je specificirati IP ili hostname.\nNpr. pingalica.sh 8.8.8.8"
fi
