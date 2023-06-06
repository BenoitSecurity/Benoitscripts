#!/bin/bash

# download and install zabbix proxy

wget https://repo.zabbix.com/zabbix/6.4/ubuntu-arm64/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu20.04_all.deb
dpkg -i zabbix-release_6.4-1+ubuntu20.04_all.deb
apt update

# install sqlite

apt install zabbix-proxy-sqlite3 -y
