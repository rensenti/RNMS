# RNMS docker upute
## Korisničke upute
**Preduvjeti za instalaciju RNMS Docker kontejnera:**
- Linux poslužitelj (na x86 arhitekturi testirano na CentOS 7.x, Ubuntu 18.04 i Ubuntu 20.04):
  - instaliran Docker engine 19.03.11+
  - instaliran docker-compose 
  - dostupni portovi (otvoreni na vatrozidu):
    - TCP 80
    - UDP 2055

**Primjer ispunjavanje preduvjeta za CentOS 7.x:**
```bash
# docker
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum clean all
yum repolist all
yum install -y docker-ce docker-ce-cli containerd.io
# docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
systemctl enable --now docker
```

```bash
# VATROZID
firewall-cmd --zone=public --permanent --add-service=http
firewall-cmd --zone=public --permanent --add-port=2055/udp
firewall-cmd --reload
```

Preuzeti posljednju verziju [docker-compose.yml](./docker-compose.yml) datoteke iz ovog repozitorija i spremiti na datotečni sustav poslužitelja u proizvoljni direktorij, primjer u nastavku podrazumijeva da je datoteka spremljena u direktorij `/usr/share/RNMS`:
```bash
docker-compose up -f /usr/share/RNMS/docker-compose.yml -d 
```
Ukoliko se radi o prvom pokretanju RNMS-a gornja naredba se može izvršavati nekoliko minuta jer se lokalno preuzima cijela slika kontejnera (engl. *Container Image*), no kad se izvrši - RNMS kontejner će biti podignut što je moguće verificirati s naredbom:
```bash
docker ps
```
Uz preuzimanje slike kontejnera i pokretanja instance RNMS kontejnera, gornja naredba je ujedno kreirala i lokalni direktorij `/var/opt/RNMS` sljedeće strukture:
| direktorij     | svrha                       |
| -------------- | --------------------------- |
| apache         | HTTPD Apache instalacija    |
| bin            | RNMS skripte                |
| database       | RNMS Postgres baza podataka |
| log            | RNMS logovi                 |
| rrdb           | RNMS rrdb baze podataka     |
| netflow        | RNMS nfcapd Netflow podaci  |
| web_aplikacija | RNMS web frontend           |

Sljedećom naredbom provjeriti RNMS WEB URL i pristupiti mu koristeći proizvoljni Web preglednik (testirano s Mozilla Firefox v70+)
```bash
docker logs rnms
```
Očekivani ispis na početku zaslona:
```bash
#*************************************************************************
#
#   URL ZA PRISTUP RNMS WEB SUCELJU:
#           - http://<<IP-ADRESA-HOSTA>
#
#*************************************************************************
```
