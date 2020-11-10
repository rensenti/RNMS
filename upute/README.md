# RNMS docker deployment
**Preduvjeti za instalaciju/pokretanje**:
- instaliran Docker engine
- otvoreni TCP 80 i UDP 2055 portovi na vatrozidu
- pristup Internetu

> koraci u nastavku prikazuju primjer zadovoljavanja svih preduvjeta za upogonjavanje RNMS-a na CentOS 7.x poslužitelju

**Instalacija docker + docker-compose sa svim preduvjetima:**
```bash
yum clean all && yum -y update
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum clean all
yum repolist all
yum install -y docker-ce docker-ce-cli containerd.io
curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
systemctl enable --now docker
```

**Upogonjavanje RNMS-a**

Vatrozid promjene:
```
# provjera zadane zone na lokalnom vatrozidu
firewall-cmd --get-default-zone
# očekivani ispis: public, ako nije public, onda korigirati zonu (--zone) sukladno ispisu u donjim naredbama
# omogućavanje dolaznog TCP 80 prometa
firewall-cmd --permanent --zone=public --add-service=http
# omogućavanje dolaznog UDP 2055 prometa
firewall-cmd --permanent --zone=public  --add-port=2055/udp
# primjena pravila
firewall-cmd --reload
```

Pokretanje RNMS-a:
x86-64:
```bash
mkdir /var/opt/RNMS
docker run -dit --name rnms -e TZ="Europe/Zagreb" --network host --mount type=bind,source=/var/opt/RNMS,target=/RNMS rdebeuc/rnms:x86-64-latest
```
------
**Docker razvojna okolina:**

Koraci za uspostavljanje lokalne razvojne okoline:
```bash
cd /usr/share
mkdir RNMS
cd RNMS
yum -y install git
# lokalna git konfiguracija (da se zna tko radi promjene)
git config --global user.name "rensenti"
git config --global user.email "rene@njahaha.net"
# kreiraj lokalni repozitorij
git init
# spoji lokalni repozitorij na vanjski GitHub repozitorij
git remote add origin https://github.com/rensenti/RNMS.git
# verifikacija
git remote -v
# konfiguriraj da ne trazi GitHub username i password svaki put (za push/pull akcije) 
git config --global credential.helper store
# ...nastavno na gornju naredbu, odraditi neku push/pull akciju da se GitHub kredencijali zapisu lokalno
git pull origin master # npr. pull cijeli vanjski repozitorij  (branch master) u lokalni
```
