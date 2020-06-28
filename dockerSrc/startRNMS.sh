#!/bin/bash
set -e
# za bind mount
# ako je na hostu taj dir prazan, popuni sadrzaj tog dira sa Src
# ako nije prazan onda je RNMS vec bio pokrenut i vec ima strukturu (i podatke)
if [ $(find $RNMS_PREFIX -type f | wc -l) -lt 2 ]; then
    cp -Rp /var/tmp/Src/* $RNMS_PREFIX/;
    echo >> $RNMS_PREFIX/bin/pomagalice
    export -p >> $RNMS_PREFIX/bin/pomagalice
fi
. $RNMS_PREFIX/bin/pomagalice
cp -f $RNMS_PREFIX/bin/pomagalice $RNMS_PREFIX/web_aplikacija/

service cron start
rm -f /usr/local/apache2/logs/httpd.pid
rm -rf /var/run/postgresql/*

service postgresql start
clear
cat << EOF
##################################################################################
#
#   URL ZA PRISTUP RNMS WEB SUCELJU:
#           - http://$(hostIP)
#
##################################################################################
- PRIJEDLOG:
        dodati rnms funkciju copy/pasteom u terminal
        na host serveru:
rnms () {
        if [ -z \$1 ]; then
                docker exec -it rnms /bin/bash
        else
                docker exec -i rnms \$@
        fi
}
        nakon dodavanja rnms funkcije moguće je jednostavnije pokrenuti
        bilo koju naredbu iz /RNMS/bin direktorija (kontejnera) direkno iz hosta
        npr.:
            rnms checkStatus.sh 192.168.1.1 public

EOF
exec httpd -DFOREGROUND "$@" 
