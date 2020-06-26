#!/bin/sh
set -e
# za bind mount
# ako je na hostu taj dir prazan, popuni sadrzaj tog dira sa Src
# ako nije prazan onda je RNMS vec bio pokrenut i vec ima strukturu (i podatke)
if [ $(find $RNMS_PREFIX -type f | wc -l) -lt 2 ]; then cp -Rp /var/tmp/Src/* $RNMS_PREFIX/; fi
sucelje=$(ip route | grep default | grep -Po 'dev\s\w+');
RNMS_IP=$(ip route | grep -P "$sucelje.*src" | head -1 | awk -F "src " '{print $2}' | awk '{print $1}')
export RNMS_IP

service cron start
rm -f /usr/local/apache2/logs/httpd.pid
rm -rf /var/run/postgresql/*

service postgresql start
clear
cat << EOF
#*************************************************************************
#
#   URL ZA PRISTUP RNMS WEB SUCELJU:
#           - http://$RNMS_IP
#
#*************************************************************************
EOF
exec httpd -DFOREGROUND "$@" 