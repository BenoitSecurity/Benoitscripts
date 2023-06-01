#! /usr/bin/bash

# Download ONX Benoit

wget https://raw.githubusercontent.com/BenoitSecurity/scripts/main/onxbenoit.sh?token=GHSAT0AAAAAACDJF5IFQD5ZCPSVNULPRDYWZDYVVRA && sudo chmod +x ./onxbenoit.sh

# Download conf scripts zabbix

wget https://raw.githubusercontent.com/BenoitSecurity/scripts/main/zabbix_agentd.conf?token=GHSAT0AAAAAACDJF5IF3QARVWHSO7MSQRHCZDYVWTA
wget https://raw.githubusercontent.com/BenoitSecurity/scripts/main/zabbix_proxy.conf?token=GHSAT0AAAAAACDJF5IESQSFZGW6QV2J4I56ZDYVXBQ

# Download Zabbix installatie file

wget https://raw.githubusercontent.com/BenoitSecurity/scripts/main/zabbix_install_arm.sh?token=GHSAT0AAAAAACDJF5IFPLWWQXPBKHV5TEAYZDYVX2Q

# Download Watool

wget https://raw.githubusercontent.com/optimanetworks/onx/main/config/watool.sh && sudo chmod +x ./watool.sh && sudo ./watool.sh