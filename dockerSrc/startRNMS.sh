#!/bin/bash
set -e
# za bind mount
# ako je na hostu taj dir prazan, popuni sadrzaj tog dira sa Src
# ako nije prazan onda je RNMS vec bio pokrenut i vec ima strukturu (i podatke)
if [ $(find $RNMS_PREFIX -type f | wc -l) -lt 2 ]; then
	cp -Rp /var/tmp/Src/* $RNMS_PREFIX/;
	export -p >> $RNMS_PREFIX/bin/pomagalice
fi
. $RNMS_PREFIX/bin/pomagalice

service cron start
rm -f /usr/local/apache2/logs/httpd.pid
rm -rf /var/run/postgresql/*

service postgresql start
clear
cat << EOF
#*************************************************************************
#
#   URL ZA PRISTUP RNMS WEB SUCELJU:
#           - http://$(hostIP)
#
#*************************************************************************
EOF
exec httpd -DFOREGROUND "$@" 
