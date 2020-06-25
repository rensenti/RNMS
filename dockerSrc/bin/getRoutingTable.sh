# IZ IANA-RTPROTO-MIB
# IANAipRouteProtocol ::= TEXTUAL-CONVENTION
#    SYNTAX      INTEGER {
#                 other     (1),  -- not specified
#                 local     (2),  -- local interface
#                 netmgmt   (3),  -- static route
#                 icmp      (4),  -- result of ICMP Redirect

#                         -- the following are all dynamic
#                         -- routing protocols

#                 egp        (5),  -- Exterior Gateway Protocol
#                 ggp        (6),  -- Gateway-Gateway Protocol
#                 hello      (7),  -- FuzzBall HelloSpeak
#                 rip        (8),  -- Berkeley RIP or RIP-II
#                 isIs       (9),  -- Dual IS-IS
#                 esIs       (10), -- ISO 9542
#                 ciscoIgrp  (11), -- Cisco IGRP
#                 bbnSpfIgp  (12), -- BBN SPF IGP
#                 ospf       (13), -- Open Shortest Path First
#                 bgp        (14), -- Border Gateway Protocol
#                 idpr       (15), -- InterDomain Policy Routing
#                 ciscoEigrp (16), -- Cisco EIGRP
#                 dvmrp      (17), -- DVMRP
#                 rpl        (18)  -- RPL [RFC-ietf-roll-rpl-19]
#                }

getRouting () {
tmpRouting=/tmp/routing
snmpwalk -m all -v 2c -c $community $ip .1.3.6.1.2.1.4.21 > $tmpRouting
routing=$(grep RouteDest $tmpRouting | awk -F "IpAddress: " '{print $2}');
for mreza in $routing; do
        ifindex=$(grep "ipRouteIfIndex.${mreza} " $tmpRouting | awk -F "INTEGER: " '{print $2}');
        for interface in $ifindex; do
                sucelje=$(snmpget -m all -v 2c -c $community $ip .1.3.6.1.2.1.2.2.1.2.${interface} | awk -F "STRING: " '{print $2}');
        done;
        maska=$(grep Mask.${mreza} $tmpRouting | awk -F "IpAddress: " '{print $2}');
        nextHop=$(grep NextHop.${mreza} $tmpRouting | awk -F "IpAddress: " '{print $2}');
        if [[ "$nextHop" == "0.0.0.0" ]]; then
                echo "odredisna mreza $mreza/${maska} ----[preko]---> ${nextHop} (sucelje: ${sucelje})";
        else
                echo "odredisna mreza $mreza/${maska} ----[preko]---> sucelja: ${sucelje}";
        fi
done;
}

getRoutingCIDR () {
tmpCidr=/tmp/routingCidr
snmpwalk -m all -v 2c -c $community $ip .1.3.6.1.2.1.4.24.4 > $tmpCidr
routing=$(grep RouteDest $tmpCidr | awk -F "IpAddress: " '{print $2}');
cat << EOF
Codes: L - local, C - connected, S - static, R - RIP, M - mobile, B - BGP
       D - EIGRP, EX - EIGRP external, O - OSPF, IA - OSPF inter area
       N1 - OSPF NSSA external type 1, N2 - OSPF NSSA external type 2
       E1 - OSPF external type 1, E2 - OSPF external type 2
       i - IS-IS, su - IS-IS summary, L1 - IS-IS level-1, L2 - IS-IS level-2
       ia - IS-IS inter area, * - candidate default, U - per-user static route
       o - ODR, P - periodic downloaded static route, H - NHRP, l - LISP,
       N - ne znam stvarno
       a - application route
       + - replicated route, % - next hop override

EOF
for mreza in $routing; do
    if [[ "$mreza" == "0.0.0.0" ]]; then
        nextHop=$(grep "ipCidrRouteNextHop.${mreza}" $tmpCidr | awk -F "IpAddress: " '{print $2}')
        echo -e "Default gateway je $nextHop \n"
        continue
    fi
    ifindex=$(grep "ipCidrRouteIfIndex.${mreza}" $tmpCidr | awk -F "INTEGER: " '{print $2}')
    for interface in $ifindex; do
        sucelje=$(snmpget -m all -v 2c -c $community $ip .1.3.6.1.2.1.2.2.1.2.${interface} | awk -F "STRING: " '{print $2}')
    done
    maska=$(grep "ipCidrRouteMask.${mreza}" $tmpCidr | awk -F "IpAddress: " '{print $2}')
    nextHop=$(grep "ipCidrRouteNextHop.${mreza}" $tmpCidr | awk -F "IpAddress: " '{print $2}')
    tipRute=$(grep "ipCidrRouteProto.${mreza}" $tmpCidr | awk -F "INTEGER: " '{print $2}')
    if [[ "$tipRute" == "netmgmt(3)" ]]; then
        tipRute="S"
    elif [[ "$tipRute" == "local(2)" ]]; then
        tipRute="C"
    elif [[ "$tipRute" == "ospf(13)" ]]; then
        tipRute="O"
    elif [[ "$tipRute" == "icmp(4)" ]]; then
        tipRute="N"
    elif [[ "$tipRute" == "rip(8)" ]]; then
        tipRute="R"
    elif [[ "$tipRute" == "ciscoEigrp(16)" ]]; then
        tipRute="D"
    elif [[ "$tipRute" == "bgp(14)" ]]; then
        tipRute="B"
    fi
   
    if [[ "$maska" == "255.255.255.255" && "$tipRute" == "C" ]]; then
        tipRute="L"
    fi

    # IZLISTAJ
    if [[ "$nextHop" == "0.0.0.0" ]]; then
        echo "$tipRute: $mreza/${maska} je direktno spojena mreza preko sucelja: ${sucelje}"
    else
        echo "$tipRute: $mreza/${maska} via ${nextHop} $( if [ ! -z $sucelje ]; then echo sucelje: ${sucelje} ; fi )"
    fi
done
}

ip=$1
community=$2
getRoutingCIDR
