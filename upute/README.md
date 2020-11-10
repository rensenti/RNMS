# RNMS docker deployment (Centos 7.x)
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

**Docker razvojna okolina:**
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
