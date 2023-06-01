#! /usr/bin/bash

# Download ONX Benoit

wget https://raw.githubusercontent.com/BenoitSecurity/Benoitscripts/main/onxbenoit.sh && sudo chmod +x ./onxbenoit.sh

# Download conf scripts zabbix

wget https://raw.githubusercontent.com/BenoitSecurity/Benoitscripts/main/zabbix_agentd.conf
wget https://raw.githubusercontent.com/BenoitSecurity/Benoitscripts/main/zabbix_proxy.conf

# Download Zabbix installatie file

wget https://raw.githubusercontent.com/BenoitSecurity/Benoitscripts/main/zabbix_install_arm.sh && sudo chmod +x ./zabbix_install_arm.sh

# Download Watool

wget https://raw.githubusercontent.com/optimanetworks/onx/main/config/watool.sh && sudo chmod +x ./watool.sh
