Terminologija
REF:
- https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/netflow/configuration/xe-16/nf-xe-16-book/cfg-nflow-data-expt-xe.html
- **https://www.cisco.com/en/US/technologies/tk648/tk362/technologies_white_paper09186a00800a3db9.html**

- **Export Packet**: paket kojeg je kreirao NetFlow uređaj i proslijedio export destinaciji
    - **Packet header**: prvi dio Export Packeta, osnovne informacije o paketu (verzija, broj flow recorda/zapisa u paketu, seq broj koji omogućuje detekciju izgubljenih paketa i ostalo - podrobnije objašnjeno u 'Packet header')
    - **FlowSet**: drugi dio Export Packeta, generički termin za kolekciju recorda (zapisa) koji mogu biti tipa template (predložak) ili podatak (data)
        - **TEMPLATE**:
            - Template Flowset: kolekcija jednog ili više **template recorda**
                - Template record: definira format data recorda ovog ili budućih export paketa (template record ne mora nužno odgovarati formatu data recorda svih zapisa unutar data recorda, Collector/Export destinacija mora cacheirati template record i raščlanjivati data record na temelju važećeg template recorda - a to može zaključiti na temelju template id-a)
                    - Template ID: jednoznačno označuje konkretni template record, jedinstven je na razini uređaja (dakle, u slučaju više flow exportera ne mora biti jedinstven stoga Collector treba uzeti u obzir i Template ID i Source IP adresu exportera za ispravno uparivanje podataka)
        - **DATA**:
            - Data Flowset: kolekcija jednog ili više **data recorda**
                - Data record: konkretni podaci o konkretnom flowu na uređaju koji je kreirao Export packet, Data FlowSet ID se mapira na Template ID
    - **Options template**: specijalni template zapis koji opisuje format podataka NetFlow procesa na exporteru
    - **Options data record**: specijalni data record koji sadrži podatke o Netflow procesu na exporteru (rezervirani template id)

    Isti export paket može sadržavati i Template FlowSet i Data FlowSetove

**Packet Header**
| Svojstvo         | Vrijednost                                                                                                                                       |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| Version          | Verzija NetFlow zapisa, 0x0009 predstavlja NetFlow v9                                                                                            |
| Count            | Broj ukupnih setova podataka o toku (broj predložaka i broj podataka o   toku)                                                                   |
| Uptime           | Vrijeme u milisekundama otkad se uređaj (senzor) upalio                                                                                          |
| Unix Seconds     | Milisekunde od 1.1.1970 (UTC) – predstavlja točno vrijeme                                                                                        |
| Package Sequence | Brojač (kao u SNMP-u – vrijednost koja se povećava) broja izvezenih paketa. Ovo polje može poslužiti za prepoznavanje ima li izgubljenih paketa. | 
| Source ID        | 32-bitna vrijednost koja jednoznačno označava  NetFlow instancu na senzor uređaju                                                                |

