## bilješke
**TODO**
- /RNMS/bin
    - obrisati pingalica.sh
- za routing se cini da je ipCidr deprecated, treba vidjeti inetCidr
    - deprecated ne znači obsolete tako da se ipCidr još uvijek koristi
    - brzom pretragom nisam pronašao nijedan uređaj koji podržava inetCidr 


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
