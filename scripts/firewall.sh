#!/bin/bash

### Declaracion de arrays ###

declare -a TCP_IN
declare -a TCP_IN_SOURCE
declare -a TCP_IN_DEST

declare -a UDP_IN
declare -a UDP_IN_SOURCE
declare -a DUP_IN_DEST

declare -a TCP_OUT
declare -a TCP_OUT_DEST

declare -a UDP_OUT
declare -a UDP_OUT_DEST

### PUERTOS ###
DNS=53
FTP=21
FTP_DATA=20
FTP_PASSIVE=45000:45500
HTTP=80
HTTPS=443
NTP=123
NRPE=5666
SSH=22

### IPs ###
IP_LOCAL_1='192.168.1.230'
IP_LOCAL_2='10.0.0.1'
NAGIOS_1='50.50.50.50'
NAGIOS_2='60.60.60.60'
ALL='0.0.0.0/0'

### Permitir trafico ###

ICMP='YES'
NAT='YES'
FORWARD='YES'

### Servicios TCP que corren en el servidor (input) ###
TCP_IN=(${DNS} ${HTTP} ${SSH})
TCP_IN_SOURCE=(${ALL} ${ALL} ${ALL})
TCP_IN_DEST=(${ALL} ${ALL} ${ALL})

### Servicios UDP que corren en el servidor (input) ###
UDP_IN=()
UDP_IN_SOURCE=()
UDP_IN_DEST=()

### Servicios TCP a los que accede el servidor (output) ###
TCP_OUT=(${SSH})
TCP_OUT_DEST=(${ALL})

### Servicios UDP a los que accede el servidor (output) ###
UDP_OUT=()
UDP_OUT_DEST=()

### FLUSH de reglas ###
iptables -F
iptables -X
iptables -Z
iptables -t nat -F

### Politica por defecto ###
#iptables -P INPUT DROP
#iptables -P OUTPUT DROP
#iptables -P FORWARD DROP

if [ $ICMP == 'YES' ]; then
	iptables -A INPUT -p icmp -j ACCEPT
	iptables -A OUTPUT -p icmp -j ACCEPT
	iptables -A FORWARD -p icmp -j ACCEPT
	fi
if [ $FORWARD == 'YES']; then
	echo 1 > /proc/sys/net/ipv4/ip_forward
	fi

if [ $NAT == 'YES' ]; then
	iptables -t nat -A POSTROUTING -s '10.0.0.0/8' -o eth0 -j MASQUERADE
	fi

### TCP INPUT  ###
CONT1=${#TCP_IN[@]}
#echo $CONT1
for (( i=0 ; i<$CONT1 ; i=i+1 )); do
#	echo ${TCP_IN[i]}
#	echo ${TCP_IN_SOURCE[i]}
#	echo ${TCP_IN_DEST[i]}
iptables -A INPUT -p tcp -s ${TCP_IN_SOURCE[i]} -d ${TCP_IN_DEST[i]} --dport ${TCP_IN[i]} -m state --state NEW,ESTABLISHED -j ACCEPT
done

### UDP INPUT  ###
CONT2=${#UDP_IN[@]}
for (( i=0 ; i<$CONT2 ; i=i+1 )); do
#        echo ${UDP_IN[i]}
#        echo ${UDP_IN_SOURCE[i]}
#        echo ${UDP_IN_DEST[i]}
iptables -A INPUT -p udp -s ${UDP_IN_SOURCE[i]} -d ${UDP_IN_DEST[i]} --dport ${UDP_IN[i]} -j ACCEPT
done

### TCP OUTPUT  ###
CONT3=${#TCP_OUT[@]}
#echo $CONT3
for (( i=0 ; i<$CONT3 ; i=i+1 )); do
#        echo ${TCP_OUT[i]}
#        echo ${TCP_OUT_SOURCE[i]}
#        echo ${TCP_OUT_DEST[i]}
iptables -A OUTPUT -p tcp -d ${TCP_OUT_DEST[i]} --dport ${TCP_OUT[i]} -m state --state NEW,ESTABLISHED -j ACCEPT
done

### UDP OUTPUT  ###
CONT4=${#UDP_OUT[@]}
for (( i=0 ; i<$CONT4 ; i=i+1 )); do
#        echo ${UDP_OUT[i]}
#        echo ${UDP_OUT_SOURCE[i]}
#        echo ${UDP_OUT_DEST[i]}
iptables -A OUTPUT -p udp -d ${UDP_OUT_DEST[i]} --dport ${UDP_IN[i]} -j ACCEPT
done

/etc/init.d/networking restart
