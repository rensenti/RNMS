Dijagram RNMS sustava (Docker kontejner)
```
             RNMS (DOCKER KONTEJNER)
            +---------------------------------------------------------------------------------------------------------------------+
            |                                                      +----------------------------+                                 |
            |                                                      |RNMS BAZE PODATAKA:         |                                 |
            |                                                      | * PostgreSQL (konf/status) |                                 |
            |                                         +--------->  | * RRDtool (performanse)    | <-----------+                   |
            |           +-----------------+           |            | * nfcapd (NetFlow)         |             |                   |
            |   +-----> |   APACHE HTTP   |           |            +----------------------------+             |                   |
                |       |     SERVER      |           |                                                       |                   |
                |       +-------+---------+           |                                                       |                   |
        web     |               ^                     v                                                       v                   |
    +-----------+               |             +-------+---------------------+        +------------------------+----------------+  |
    v                           |             |  RNMS SHELL SKRIPTE ZA:     |        | RNMS FUNKCIJE:                          |  |
korisnik                        +<----------> |   * GENERIRANJE HTML-A      | <----> | (SHELL SKRIPTE)                         |  |
    ^                           |             |   * POZIVANJE RNMS FUNKCIJA |        |   * OTKRIVANJE MREŽE                    |  |
    +-----------+               |             |                             |    +-> |   * PROVJERA STATUSA                    |  |
      terminal  |               v             +-----------------------------+    |   |   * PROVJERA PERFORMANSI                |  |
                |        +------+----+                                           |   |   * PROVJERA USMJERNIČKIH TABLICA       |  |
                +----->  |BASH SHELL |                                           |   |   * NETFLOW ANALIZA                     |  |
                         +------+----+                                           |   | (Nmap, Net-SNMP, RRDtool, nfcapd/nfdump)|  |
            |                   |                                                |   +-----------------------------------------+  |
            |                   +------------------------------------------------+                                                |
            |                                                                                                                     |
            +---------------------------------------------------------------------------------------------------------------------+
```
