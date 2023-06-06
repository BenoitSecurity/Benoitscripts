#!/bin/bash

# download and install zabbix proxy

wget https://repo.zabbix.com/zabbix/6.4/ubuntu-arm64/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu20.04_all.deb
dpkg -i zabbix-release_6.4-1+ubuntu20.04_all.deb
apt update

# install sqlite

apt install zabbix-proxy-sqlite3 -y

sleep 5

# install zabbix agent

apt install zabbix-agent -y

sleep 5

# aanmaken encryptie key

mkdir /home/zabbix/
cd /home/zabbix
openssl rand -hex 32 > secret.psk
chown zabbix:zabbix secret.psk
chmod 640 secret.psk

# Verplaatsen config script 

mv /home/administrator/zabbix_agentd.conf /etc/zabbix/ 
mv /home/administrator/zabbix_proxy.conf /etc/zabbix/

# Starten zabbix proxy

systemctl enable zabbix-proxy
systemctl restart zabbix-proxy

# Starten zabbix agent

systemctl enable zabbix-agent
systemctl restart zabbix-agent

# Weergeven psk key

cat /home/zabbix/secret.psk
