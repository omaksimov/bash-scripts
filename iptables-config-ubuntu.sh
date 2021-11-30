#!/bin/bash
#Netfilter configuration on Ubuntu endpoints
#Installing iptables-persistent to save configuration
apt update
apt install -y iptables-persistent
#Allowing ssh conntections to local host
iptables -A INPUT -p tcp --dport ssh -j ACCEPT
#Allowing to ping local host
iptables -A INPUT -p icmp -j ACCEPT
#Changing policy for all INPUT and FORWARD traffic to DROP
iptables -P INPUT DROP
iptables -P FORWARD DROP
#Allowing INPUT traffic for RELATED and ESTABLISHED connections
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
#Allowing DNS responses
iptables -A INPUT -p tcp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --dport 53 -j ACCEPT
#Allowing rsync connections
#iptables -A INPUT -p tcp --dport 873 -j ACCEPT
#Saving configuration
netfilter-persistent save