Dijagram RNMS sustava (Docker kontejner)
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
