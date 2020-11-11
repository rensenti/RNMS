## RNMS funkcije

Komponente RNMS sustava:
- APACHE HTTPD server - prikaz RNMS web sučelja (instalacijska putanja /RNMS/apache)
- PostgreSQL Server - baza podataka s podacima o mrežnom inventaru i statusima pojedinih elemenata (putanja /RNMS/database)
- nfcapd - daemon odgovoran za prikupljanje NetFlow podataka (putanja /RNMS/netflow/$id_uredjaja/)
- nfdump - aplikacija za prikaz NetFlow podataka (statistika i agregacija)
- nmap - aplikacija za otkrivanje mreže
- net-snmp-tools - set low-level SNMP utilitya koje koriste skripte u /RNMS/bin direktoriju
- rrdool - baza podataka za vremenske serije (prikladno za performance podatke) i odgovorna za grafiranje tih performance podataka kroz RNMS web sučelje
- RNMS skripte:
  - /RNMS/bin - koriste gornje alate/aplikacije za ostvarivanje funkcionalnosti
  - /RNMS/web_aplikacija - skripte za generiranje web sučelja i upravljanje funkcionalnostima

Funkcije:
- otkrivanje mreže (nmap + SNMP) i učitvanje u PSQL bazu podataka
  - skripta /RNMS/bin/networkDiscovery.sh
    - pokretanje kroz naredbeni redak ili RNMS web sučelje
    - primjer:
      - `/RNMS/bin/networkDiscovery.sh 10.13.37.2/32,public`
- SNMP provjera statusa:
  - skripta /RNMS/bin/checkStatus.sh
    - pokretanje kroz naredbeni redak ili RNMS web sučelje
    - primjer:
      - `/RNMS/bin/checkStatus.sh 10.88.88.10 public`
- SNMP provjera performansi:
  - skripta /RNMS/bin/checkPerf.sh
    - pokretanje kroz naredbeni redak ili RNMS web sučelje
    - primjer:
       - `/RNMS/bin/checkPerf.sh na-zahtjev 10.16.97.159 public`
- SNMP provjera usmjerničkih tablica
  - skripta /RNMS/bin/getRoutingTable.sh
    - pokretanje kroz naredbeni redak ili RNMS web sučelje
    - primjer:
       - `/RNMS/bin/getRoutingTable.sh 10.16.97.159 public`
- NetFlow prikupljanje i prikaz podataka:
  - skripta za upravljanje /RNMS/bin/controlNetflow.sh
  - pokretanje i prikaz isključivo kroz RNMS web sučelje:
  - primjer:
    - http://rnms.snt.corp/netflowOpseg.sh
    - http://rnms.snt.corp/details.sh?id=1&vrijeme=120&top=20