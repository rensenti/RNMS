# RNMS
RNMS je pokazni NMS sustav baziran na Open-Source software (OSS) alatima i aplikacijama. Dostupan je kao Docker kontejner na x86_x64 i armv7 platformama. **Nije za produkcijsko korištenje**.  Svrha iza razvoja ja bila kreirati vrlo bazični NMS sustav pomoću shell skripti koristeći isključivo OSS aplikacije dostupne u repozitorijima većine Linux distribucija i u tom procesu nešto naučiti. Sadrži nemale količine sigurnosnih kompromisa i ne-elegantnog koda. :)
## Tablica sadržaja

## Dijagram RNMS sustava (Docker kontejner)
```
            +------------------------+
            |RNMS (DOCKER KONTEJNER) |
            +------------------------+---------------------------------------------------------------------------------+
            |                                               +----------------------------+                             |
            |                                               |RNMS BAZE PODATAKA:         |                             |
            |           +-----------------+                 | * PostgreSQL (konf/status) |                             |
            |   +------->   APACHE HTTP   |    +------------> * RRDtool (performanse)    <-------------+               |
            +   |       |     SERVER      |    |            | * nfcapd (NetFlow)         |             |               |
                |       +-------^---------+    |            +----------------------------+             |               |
        web     |               |              |                                                       |               |
    +-----------+               |     +--------v--------------------+     +----------------------------v------------+  |
    v                           |     |  RNMS SHELL SKRIPTE ZA:     |     | RNMS FUNKCIJE:                          |  |
korisnik                        +<---->   * GENERIRANJE HTML-A      |     | (SHELL-SKRIPTE)                         |  |
    ^                           |     |   * POZIVANJE RNMS FUNKCIJA <----->   * OTKRIVANJE MREŽE                    |  |
    +-----------+               |     |                             |     |   * PROVJERA STATUSA                    |  |
      terminal  |               |     +-----------------------------+     |   * PROVJERA PERFORMANSI                |  |
                |        +------v----+                                    |   * PROVJERA USMJERNIČKIH TABLICA       |  |
            +   +-------->BASH SHELL <------------------------------------>   * NETFLOW ANALIZA                     |  |
            |            +-----------+                                    | (Nmap, Net-SNMP, RRDtool, nfcapd/nfdump)|  |
            |                                                             +-----------------------------------------+  |
            |                                                                                                          |
            +----------------------------------------------------------------------------------------------------------+
```
## Upogonjavanje RNMS-a
- preduvjet je instaliran Docker engine na x86_64 ili armv7 računalu
- otvoreni TCP 80 i UDP 2055 portovi na računalu

Pokretanje RNMS-a:

x86-64:
```bash
mkdir /var/opt/RNMS
docker run -dit --name rnms -e TZ="Europe/Zagreb" --network host --mount type=bind,source=/var/opt/RNMS,target=/RNMS rdebeuc/rnms:x86-64-latest
```

armv7:
```bash
mkdir /var/opt/RNMS
docker run -dit --name rnms -e TZ="Europe/Zagreb" --network host --mount type=bind,source=/var/opt/RNMS,target=/RNMS rdebeuc/rnms:armv7-latest
```