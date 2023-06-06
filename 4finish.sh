#!/bin/bash

# download and install zabbix proxy

# Verplaatsen config script 

cp /home/administrator/zabbix_agentd.conf /etc/zabbix/
cp /home/administrator/zabbix_proxy.conf /etc/zabbix/

# PSK key genereren

mkdir /home/zabbix/
cd /home/zabbix
openssl rand -hex 32 > secret.psk
chown zabbix:zabbix secret.psk
chmod 640 secret.psk

# Starten Zabbix proxy

systemctl enable zabbix-proxy
systemctl restart zabbix-proxy

# Starten Zabbix agent
systemctl enable zabbix-agent
systemctl restart zabbix-agent

# Weergeven psk key

cat /home/zabbix/secret.psk