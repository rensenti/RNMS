## bilješke
**TODO**
- /RNMS/bin
    - obrisati pingalica.sh
- za routing se cini da je ipCidr deprecated, treba vidjeti inetCidr
    - deprecated ne znači obsolete tako da se ipCidr još uvijek koristi
    - brzom pretragom nisam pronašao nijedan uređaj koji podržava inetCidr 

### Objašnjenje NetFlow input_snmp odnosno output_snmp 0
REF: https://www.plixer.com/blog/interface-0-what-does-it-mean-to-you/

Interface 0 or Interface “null” can occur within a couple of the following scenarios.
- Multicast traffic
- Conversation denied by ACL rule
- **Packets are destined for the router itself**
- Conversation is dropped by QoS
- Router misconfiguration
- IOS bug

### Općenito input_snmp vs output_snmp VS ingress vs egress flow
Moje shvaćanje je da su ingress/input i egress/output traffic termini koji se koriste u kontekstu nekog mrežnog čvora i vežu se za njegova sučelja.

Ja -> ping -> tebe
(ja ----> R1 eth1 -----> R1 eth2 -----> ti)
R1 na eth1 prima moj ICMP paket (taj paket je ingress ICMP promet), i routea/switcha ga na eth2 (sad je to egress ICMP promet na sučelju eth2) da bi paket došao kod tebe. Dakle, mrežni čvor ima ingress i egress promet samo s jednim paketom. Tvoj echo reply će biti primljen na R1 eth2 (ingress) i biti proslijeđen na R1 eth1 (egress) da bih ga ja dobio.

Evo primjera kako se ingress/egress promet mijenja ovisno o kontekstu sučelja. Ovo je Plešeov WiFi/CP whatevz. Oprez: RNMS u nastavku:
- sučelje ETH1 je link prema Internetu
- sučelje ETH5 je link prema SNT_guest mreži lokalno
- http://10.16.68.119/details.sh?id=1
- http://10.16.68.119/slike/perfGrafovi/10.16.97.159_eth1.png ---- [ako ne radi link](http://njahaha.net/screenshots/2020_06_30_11_51_21.png)
- http://10.16.68.119/slike/perfGrafovi/10.16.97.159_eth5.png ---- [ako ne radi link](http://njahaha.net/screenshots/2020_06_30_11_52_23.png)

Dakle, iz prekrasnih RNMS grafova je vidljivo da se ingress i egress promet zrcale ovisno o kontekstu sučelja.

S obzirom da bi svaki flow trebao imati vrijednost input_snmp i output_snmp (ping iz primjera gore kao input_snmp koristi eth1, a kao output_snmp eth2, a drugi flow (reply) obrnuto) onda bi se trebao moći izračunati volume in i volume out na svakom interfaceu i utilizacija...

Sve ovo i dalje nema veze s ip flow egress na netflow v9 i ipfix, koji unose i atribut direction. Direction atribut omogućava kompleksne netflow scenarije (upali ingress samo ovdje, a egress samo ondje) s ciljem (pretpostavljam) u konačnici manje količine exportanih flowova i opterećenja mrežne opreme...

**Vulgaris priča Netflow v5, v9 i ipfix (samo ip flow ingress)**
ETH1 ima konfiguriran ip flow ingress
ETH2 ima konfiguriran ip flow ingress
- ETH1 - će collectoru proslijediti prvi flow (ja ping tebe) koji će sadržavati input_snmp eth1 i output_snmp eth2
- ETH2 - će collectoru proslijediti drugi flow (tvoj odgovor na moj ping) koji će sadržavati input_snmp eth2 i output_snmp eth1

**Kompleksnija pri;a za Netflow v9 i ipfix (i ip flow ingress i egress na odabranim sučeljima)**
ETH1 ima konfiguriran ip flow ingress i ip flow egress
ETH2 uopće nema ip flow konfu i niš ne exporta
- ETH1 će proslijediti prvi flow s direction ingress, a za odgovor (drugi flow) će isto tako ETH1 proslijediti flow (s adekvatnim input_snmp i output_snmp), ali će direction biti egress

U ovoj situaciji ETH2 uopće nema konfiguriran netflow export pa ne bismo vidjeli njegov ingress flow. Zato tu uskače ETH1 koji uz ip flow ingress ima konfan i ip flow egress.

> Za raspravu, out_bytes polje će uvijek biti prazno ako je flow ingress, dakle nema veze s output_snmp sučeljem...:
> http://njahaha.net/screenshots/2020_07_01_22_46_20.png

BTW, na Elastiflow ne postoje input_bytes ili output_bytes polja, Rob ih transfomira u vulgaris bytes...

Onaj tko je imenovao sva ta polja kao da se trudio biti maksimalno nekonzistentan. Dakle, svaki flow ima input_snmp i output_snmp kao sučelja, ali ovisno o tome je li flow ingress ili egress, imat će ili input_bytes ili output_bytes polje....


### Korištenje SNMP translate primjer
**Prikaz cijelog MIB stabla (kojeg je snmpcmd svjestan na temelju svih MIB modula koje može pročitati -m all) u formatu s imenima i OID-ima**
```
snmptranslate -m all -Tl
```

**Iz tog stabla u tom formatu izvuci samo varijablu snmpTargetAddrExtTable**
```
snmptranslate -m all -Tl | grep snmpTargetAddrExtTable
.iso(1).org(3).dod(6).internet(1).snmpV2(6).snmpModules(3).snmpCommunityMIB(18).snmpCommunityMIBObjects(1).snmpTargetAddrExtTable(2)
.iso(1).org(3).dod(6).internet(1).snmpV2(6).snmpModules(3).snmpCommunityMIB(18).snmpCommunityMIBObjects(1).snmpTargetAddrExtTable(2).snmpTargetAddrExtEntry(1)
.iso(1).org(3).dod(6).internet(1).snmpV2(6).snmpModules(3).snmpCommunityMIB(18).snmpCommunityMIBObjects(1).snmpTargetAddrExtTable(2).snmpTargetAddrExtEntry(1).snmpTargetAddrTMask(1)
.iso(1).org(3).dod(6).internet(1).snmpV2(6).snmpModules(3).snmpCommunityMIB(18).snmpCommunityMIBObjects(1).snmpTargetAddrExtTable(2).snmpTargetAddrExtEntry(1).snmpTargetAddrMMS(2)
```
**Sad kad je OID poznat, prikaži MIB koji opisuje tu varijablu**
```
snmptranslate -m all .1.3.6.1.6.3.18.1.2
SNMP-COMMUNITY-MIB::snmpTargetAddrExtTable
```
**Opis te varijable s -Td parametrom**
```
snmptranslate -m all -Td .1.3.6.1.6.3.18.1.2
SNMP-COMMUNITY-MIB::snmpTargetAddrExtTable
snmpTargetAddrExtTable OBJECT-TYPE
  -- FROM       SNMP-COMMUNITY-MIB
  MAX-ACCESS    not-accessible
  STATUS        current
  DESCRIPTION   "The table of mask and mms values associated with the

         snmpTargetAddrTable.

         The snmpTargetAddrExtTable augments the
         snmpTargetAddrTable with a transport address mask value
         and a maximum message size value.  The transport address
         mask allows entries in the snmpTargetAddrTable to define
         a set of addresses instead of just a single address.
         The maximum message size value allows the maximum
         message size of another SNMP entity to be configured for
         use in SNMPv1 (and SNMPv2c) transactions, where the
         message format does not specify a maximum message size."
::= { iso(1) org(3) dod(6) internet(1) snmpV2(6) snmpModules(3) snmpCommunityMIB(18) snmpCommunityMIBObjects(1) 2 }
```
**Opis te varijable s -Td parametrom (funkcionira i u ovom formatu)**
```
snmptranslate -m all -Td SNMP-COMMUNITY-MIB::snmpTargetAddrExtTable
SNMP-COMMUNITY-MIB::snmpTargetAddrExtTable
snmpTargetAddrExtTable OBJECT-TYPE
  -- FROM       SNMP-COMMUNITY-MIB
  MAX-ACCESS    not-accessible
  STATUS        current
  DESCRIPTION   "The table of mask and mms values associated with the

         snmpTargetAddrTable.

         The snmpTargetAddrExtTable augments the
         snmpTargetAddrTable with a transport address mask value
         and a maximum message size value.  The transport address
         mask allows entries in the snmpTargetAddrTable to define
         a set of addresses instead of just a single address.
         The maximum message size value allows the maximum
         message size of another SNMP entity to be configured for
         use in SNMPv1 (and SNMPv2c) transactions, where the
         message format does not specify a maximum message size."
::= { iso(1) org(3) dod(6) internet(1) snmpV2(6) snmpModules(3) snmpCommunityMIB(18) snmpCommunityMIBObjects(1) 2 }
```
