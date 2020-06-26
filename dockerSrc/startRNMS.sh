#!/bin/sh
set -e
# za bind mount
# ako je na hostu taj dir prazan, popuni sadrzaj tog dira sa Src
# ako nije prazan onda je RNMS vec bio pokrenut i vec ima strukturu (i podatke)
if [ $(find $RNMS_PREFIX -type f | wc -l) -lt 2 ]; then cp -Rp /var/tmp/Src/* $RNMS_PREFIX/; fi


service cron start
rm -f /usr/local/apache2/logs/httpd.pid
rm -rf /var/run/postgresql/*

service postgresql start

exec httpd -DFOREGROUND "$@" 
