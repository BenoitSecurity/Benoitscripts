#! /usr/bin/bash

# Download ONX Benoit

wget https://raw.githubusercontent.com/BenoitSecurity/Benoitscripts/main/1onxbenoit.sh && sudo chmod +x ./1onxbenoit.sh

# Download conf scripts zabbix

wget https://raw.githubusercontent.com/BenoitSecurity/Benoitscripts/main/zabbix_agentd.conf
wget https://raw.githubusercontent.com/BenoitSecurity/Benoitscripts/main/zabbix_proxy.conf

# Download Zabbix installatie file

wget https://raw.githubusercontent.com/BenoitSecurity/Benoitscripts/main/2proxy_install_arm.sh && sudo chmod +x ./2proxy_install_arm.sh
wget https://raw.githubusercontent.com/BenoitSecurity/Benoitscripts/main/3agent_install_arm.sh && sudo chmod +x ./3agent_install_arm.sh
wget https://raw.githubusercontent.com/BenoitSecurity/Benoitscripts/main/4finish.sh && sudo chmod +x ./4finish.sh

# Download Watool

wget https://raw.githubusercontent.com/optimanetworks/onx/main/config/watool.sh && sudo chmod +x ./watool.sh
