#!/bin/sh
set -e
service cron start

rm -f /usr/local/apache2/logs/httpd.pid
rm -rf /var/run/postgresql/*

service postgresql start

exec httpd -DFOREGROUND "$@" 
