#!/bin/bash

# General vaiables defined by default
# ===================================
relnr=0
script="/home/zabbix"
conf_path="/etc/zabbix"
server="zabbix.benoit.be"
no_confirmation=true
osv="z1"
urlv=""
unpackv=""

declare -A data
readarray downloads< <(cat ./downloads.txt)
for d in "${downloads[@]}"
do
	key=$(echo $d | cut -d@ -f1)
	value=$(echo $d | cut -d@ -f2)
	data[${key}]=${value}
done

# we are using hostnamectl to determine operating os and system architecture
# the sed command at the end removes the space at the beginning
os_detect=$(hostnamectl | grep Operating | cut -d: -f2 | cut -d' ' -f3 | cut -d. -f1)
architecture=$(hostnamectl | grep Architecture | cut -d: -f2 | sed -e 's/^[[:space:]]*//')

# ===================================

### Colors ###
ESC=$(printf '\033') RESET="${ESC}[0m" BLACK="${ESC}30m" RED="${ESC}[31m"
GREEN="${ESC}[32m" YELLOW="${ESC}[33m" BLUE="${ESC}[34m" MAGENTA="${ESC}[35m"
CYAN="${ESC}[36m" WHITE="${ESC}[37m" DEFAULT="${ESC}[39m"

### Color functions ###
greenprint() { printf "${GREEN}%s${RESET}\n" "$1";}
blueprint() { printf "${BLUE}%s${RESET}\n" "$1";}
redprint() { printf "${RED}%s${RESET}\n" "$1";}
yellowprint() { printf "${YELLOW}%s${RESET}\n" "$1";}
magentaprint() { printf "${MAGENTA}%s${RESET}\n" "$1";}
cyanprint() { printf "${CYAN}%s${RESET}\n" "$1";}

####################################################################################

wait_for_keypress(){
	read -p "###### => press enter to continue <= ######"
}

fn_overview(){
	clear;
	# check the status of the proxy
	systemctl status zabbix-proxy 1> /dev/null 2> /dev/null
	if [[ ${?} -eq 4 ]]; then
		local proxy="not found"
	else
		local proxy="$(systemctl status zabbix-proxy 2> /dev/null | grep Active: | sed -e 's/^[[:space:]]*//')"
	fi
	# check the status of the agent
	systemctl status zabbix-agent 1> /dev/null 2> /dev/null
	if [[ ${?} -eq 4 ]]; then
		local agent="not found"
	else
		local agent="$(systemctl status zabbix-agent 2> /dev/null | grep Active: | sed -e 's/^[[:space:]]*//')"
	fi
	# check the config file of the proxy
	cat /etc/zabbix/zabbix_proxy.conf 1> /dev/null 2> /dev/null
	if [[ ${?} -eq 1 ]]; then
		local proxyConf="not found"
	else
		local proxyConf="$(cat /etc/zabbix/zabbix_proxy.conf 2> /dev/null | grep Hostname | cut -d= -f2)"
	fi
	# check the config file of the agent
	cat /etc/zabbix/zabbix_agentd.conf 1> /dev/null 2> /dev/null
	if [[ ${?} -eq 1 ]]; then
		local agentConf="not found"
	else
		local agentConf="$(cat /etc/zabbix/zabbix_agentd.conf 2> /dev/null | grep Hostname | cut -d= -f2)"
	fi

	cat ./artwork.txt
	echo "$(cyanprint '+=========== PARAMETERS ============+')"
	echo -n "$(cyanprint '+ relation number = ')"
	echo "$(yellowprint ${relnr})"
	echo -n "$(cyanprint '+ script path     = ')"
	echo "$(yellowprint ${script})"
	echo -n "$(cyanprint '+ config path     = ')"
	echo "$(yellowprint ${conf_path})"
	echo -n "$(cyanprint '+ server url      = ')"
	echo "$(yellowprint ${server})"
	echo -n "$(cyanprint '+ os version found= ')"
	echo "${os_detect}"
	echo -n "$(cyanprint '+ architecture    = ')"
	echo "${architecture}"
	echo -n "$(cyanprint '+ using osv       = ')"
	echo "${osv}"
	echo -n "$(cyanprint '+ status proxy    = ')"
	echo "${proxy}"
	echo -n "$(cyanprint '+ status agent    = ')"
	echo "${agent}"
	echo -n "$(cyanprint '+ conf proxy (should be '${relnr}') = ')"
	echo "${proxyConf}"
	echo -n "$(cyanprint '+ conf agent (should be '${relnr}') = ')"
	echo "${agentConf}"
	echo "$(cyanprint '+===================================+')"
}

determine_sys(){
	if [[ ${architecture} -ne "x86-64"  ]]; then
		# arm system
		case ${os_detect} in

		20)
			osv="a20";urlv="url_20_arm";unpackv="unpack_20_arm";;
		21)
			osv="a20";urlv="url_20_arm";unpackv="unpack_20_arm";;
		22)
			osv="a22";urlv="url_22_arm";unpackv="unpack_22_arm";;
		23)
			osv="a22";urlv="url_22_arm";unpackv="unpack_22_arm";;
		24)
			osv="a22";urlv="url_22_arm";unpackv="unpack_22_arm";;
		*)
			osv="z0";;

		esac

	else
		# intel x86 system
		case ${os_detect} in

		18)
			osv="x18";urlv="url_18_x86";unpackv="unpack_18_x86";;
		19)
			osv="x18";urlv="url_18_x86";unpackv="unpack_18_x86";;
		20)
			osv="x20";urlv="url_20_x86";unpackv="unpack_20_x86";;
		21)
			osv="x20";urlv="url_20_x86";unpackv="unpack_20_x86";;
		22)
			osv="x22";urlv="url_22_x86";unpackv="unpack_22_x86";;
		23)
			osv="x22";urlv="url_22_x86";unpackv="unpack_22_x86";;
		24)
			osv="x22";urlv="url_22_x86";unpackv="unpack_22_x86";;
		*)
			osv="z0";;

		esac
	fi
}

create_proxy_conf(){
	if [[ ${relnr} -ne 0 ]]; then
		echo -ne "
# domain or ip of the zabbix server
Server=${server}
# unique name of the proxy
Hostname=${relnr}

# default location
LogFile=/var/log/zabbix/zabbix_proxy.log
# 0 means no file rotation, file will keep growing?
LogFileSize=64
# default location
PidFile=/run/zabbix/zabbix_proxy.pid
# default
SocketDir=/run/zabbix
# default location
SNMPTrapperFile=/var/log/snmptrap/snmptrap.log
Timeout=4

# path to the SQLite database
DBName=/tmp/zabbix_proxy64.db
# user for the zabbix database
DBUser=zabbix

# default location
FpingLocation=/usr/bin/fping
Fping6Location=/usr/bin/fping6
# default
LogSlowQueries=3000
# default
StatsAllowedIP=127.0.0.1
# TLS PSK encryption settings
TLSConnect=psk
TLSAccept=psk
TLSPSKIdentity=${relnr}
TLSPSKFile=${script}/secret.psk
" > zabbix_proxy.conf
	echo "zabbix_proxy.conf is successfully created"
	else
		echo "please set parameters first!"
	fi
	sleep 0.5

	# send both output and error to /dev/null and use the return value
	ls ${conf_path} 1> /dev/null 2> /dev/null
	# in case the directory does not exist, it will return 2
	if [[ $? -eq 2 ]]; then
		sudo mkdir ${conf_path}
	fi

	sudo mv zabbix_proxy.conf ${conf_path}/zabbix_proxy.conf

	wait_for_keypress

}

create_agent_conf(){
	if [[ ${relnr} -ne 0 ]]; then
		echo -ne "
# default location
PidFile=/run/zabbix/zabbix_agentd.pid
# default location
LogFile=/var/log/zabbix/zabbix_agentd.log
# 0 means no file rotation, file will keep growing?
LogFileSize=64

# ip address of the zabbix agent as seen from the proxy - PASSIVE MODE
Server=127.0.0.1
# ip address of the zabbix agent as seen from the proxy - ACTIVE MODE
ServerActive=127.0.0.1

# unique name to define the host of the agent
Hostname=${relnr}

# default location
Include=/etc/zabbix/zabbix_agentd.d/*.conf

# what scripts are available for remote execution
UserParameter=camera.isReachable[*],.${script}/pingCamera.sh $1
UserParameter=camera.isServiceActive[*],.${script}/checkService.sh $1
UserParameter=storage.checkDisks,.${script}/checkDisks.sh
UserParameter=storage.checkDisk[*],.${script}/checkDisk.sh $1

# in what directory should the scripts be placed
#UserParameterDir=/home/zabbix
" > zabbix_agentd.conf
	echo "zabbix_agentd.conf is successfully created"
	else
		echo "please set parameters first!"
	fi
	sleep 1

	# send both output and error to /dev/null and use the return value
	ls ${conf_path} 1> /dev/null 2> /dev/null
	# in case the directory does not exist, it will return 2
	if [[ $? -eq 2 ]]; then
		sudo mkdir ${conf_path}
	fi

	sudo mv zabbix_agentd.conf ${conf_path}/zabbix_agentd.conf

	wait_for_keypress

}

install_proxy(){
	#run the command for the url
	ls zabbix*.deb*
	if [[ $? -eq 2 ]]; then
		${data[${urlv}]}
		echo "$(yellowprint 'download done')"
	else
		echo "$(yellowprint 'package *.deb already present, skipping download...')"
	fi
	
	wait_for_keypress

	${data[${unpackv}]}
	echo "$(yellowprint 'done')"
	wait_for_keypress

	${data[command]}
	echo "$(yellowprint 'done')"
	wait_for_keypress

	sudo ${data[install_proxy]}
	echo "$(yellowprint 'done')"
	wait_for_keypress
}

install_agent(){
	#run the command for the url
	ls *.deb*
	if [[ $? -eq 2 ]]; then
		${data[${urlv}]}
		echo "$(yellowprint 'download done')"
	else
		echo "$(yellowprint 'package *.deb already present, skipping download...')"
	fi

	wait_for_keypress

	${data[${unpackv}]}
	echo "$(yellowprint 'done')"
	wait_for_keypress

	${data[command]}
	echo "$(yellowprint 'done')"
	wait_for_keypress

	sudo ${data[install_agent]}
	echo "$(yellowprint 'done')"
	wait_for_keypress
	
}

copy_scripts(){
	echo "copy scripts selected"
	sleep 2

}

create_psk_file(){
	# send both output and error to /dev/null and use the return value
	ls ${script} 1> /dev/null 2> /dev/null

	# in case the directory does not exist, it will return 2
	if [[ $? -eq 2 ]]; then
		sudo mkdir ${script}
	fi

	sudo openssl rand -hex 32 | sudo tee ${script}/secret.psk >/dev/null

	wait_for_keypress
}

restart_proxy(){
	sudo ${data[start_proxy]}
	wait_for_keypress
}

set_autostart_proxy(){
	sudo ${data[enable_proxy]}
	wait_for_keypress
}

uninstall_proxy(){
	sudo systemctl stop zabbix-proxy;
	sudo ${data[uninstall_proxy]}
	wait_for_keypress
}

restart_agent(){
	sudo ${data[start_agent]}
	wait_for_keypress
}

set_autostart_agent(){
	sudo ${data[enable_agent]}
	wait_for_keypress
}

uninstall_agent(){
	sudo systemctl stop zabbix-agent;
	sudo ${data[uninstall_agent]}
	wait_for_keypress
}

initialize(){
	clear;
	# check if sudo is active for the script
	ls /root 1> /dev/null 2> /dev/null
	if [[ ${?} -eq 2 ]]; then
		read -p "please run 'sudo ./menu.sh' to use this installer ==> press enter to continue";
		exit 0
	fi
	echo ""
	echo "$(cyanprint '+=========== SET RELNR ============+')"
	echo ""
	read -p "please provide the relation/customer number> " relnr
	clear;
}

submenu_parameters(){
	fn_overview
	echo -ne "
	$(yellowprint 'SET-PARAMETERS')
	$(yellowprint '++++++++++++++')
	$(greenprint '1 set relation number')
	$(yellowprint '+')
	$(greenprint '2 set default script path')
	$(yellowprint '+')
	$(greenprint '3 set configuration path')
	$(yellowprint '+')
	$(greenprint '4 set server url')
	$(yellowprint '+')
	$(magentaprint '9 return to MAIN MENU')
	$(yellowprint '+++')
	Choose an option: "

	read -r answer
	case $answer in
	1)
		echo ""
		read -p "RELNR> " relnr
		submenu_parameters;;
	2)
		echo ""
		read -p "SCRIPT_PATH> " script
		submenu_parameters;;
	3)
		echo ""
		read -p "CONF_PATH> " conf_path
		submenu_parameters;;
	4)
		echo ""
		read -p "ZABBIX_SERVER> " server
		submenu_parameters;;
	9)
		mainmenu;;
	0)
		exit 0;;
	*)
		echo ""
		echo "invalid option selected"
		sleep 0.5
		submenu_parameters;;
	esac
}

submenu_proxy(){
	fn_overview
	echo -ne "
	$(greenprint 'ZABBIX PROXY')
	$(greenprint '++++++++++++++')
	$(yellowprint '1 download / unpack / update / install')
	$(greenprint '+')
	$(yellowprint '2 create zabbix_proxy.conf in ') ${conf_path}
	$(greenprint '+')
	$(yellowprint '3 create secret.psk in') ${script}
	$(greenprint '+')
	$(yellowprint '4 restart the service for zabbix-proxy')
	$(greenprint '+')
	$(yellowprint '5 set zabbix-proxy service to autostart ON')
	$(greenprint '+')
	$(redprint '8 REMOVE zabbix-proxy completely')
	$(greenprint '+')
	$(magentaprint '9 return to MAIN MENU')
	$(greenprint '+++')
	Choose an option: "

	read -r answer
	case $answer in
	1)
		echo ""
		install_proxy;
		submenu_proxy;;
	2)
		echo ""
		create_proxy_conf;
		submenu_proxy;;
	3)
		echo ""
		create_psk_file;
		submenu_proxy;;
	4)
		echo ""
		restart_proxy;
		submenu_proxy;;
	5)
		echo ""
		set_autostart_proxy;
		submenu_proxy;;
	8)
		echo ""
		uninstall_proxy;
		submenu_proxy;;
	9)
		mainmenu;;
	0)
		exit 0;;
	*)
		echo ""
		echo "invalid option selected"
		sleep 0.5
		submenu_proxy;;
	esac
}


submenu_agent(){
	fn_overview
	echo -ne "
	$(greenprint 'ZABBIX AGENT')
	$(greenprint '++++++++++++++')
	$(yellowprint '1 download / unpack / update / install')
	$(greenprint '+')
	$(yellowprint '2 create zabbix_agentd.conf in ') ${conf_path}
	$(greenprint '+')
	$(yellowprint '4 restart the service for zabbix-agent')
	$(greenprint '+')
	$(yellowprint '5 set zabbix-agent service to autostart ON')
	$(greenprint '+')
	$(redprint '8 REMOVE zabbix-agent completely')
	$(greenprint '+')
	$(magentaprint '9 return to MAIN MENU')
	$(greenprint '+++')
	Choose an option: "

	read -r answer
	case $answer in
	1)
		echo ""
		install_agent;
		submenu_agent;;
	2)
		echo ""
		create_agent_conf;
		submenu_agent;;
	3)
		echo ""
		submenu_agent;;
	4)
		echo ""
		restart_agent;
		submenu_agent;;
	5)
		echo ""
		set_autostart_agent;
		submenu_agent;;
	8)
		echo ""
		uninstall_agent;
		submenu_agent;;
	9)
		mainmenu;;
	0)
		exit 0;;
	*)
		echo ""
		echo "invalid option selected"
		sleep 0.5
		submenu_agent;;
	esac
}

submenu_scripts(){
	fn_overview
	echo -ne "
	$(cyanprint 'SCRIPTS')
	$(cyanprint '+++++++')
	$(greenprint '1) create all scripts in ') ${script}
	$(cyanprint '+')
	$(magentaprint '9) return to MAIN MENU')
	$(cyanprint '+++')
	Choose an option: "

	read -r answer
	case $answer in
	1)
		echo ""
		create_scripts;
		submenu_scripts;;
	2)
		echo ""
		submenu_scripts;;
	3)
		echo ""
		submenu_scripts;;
	4)
		echo ""
		submenu_scripts;;
	5)
		echo ""
		submenu_scripts;;
	8)
		echo ""
		submenu_scripts;;
	9)
		mainmenu;;
	0)
		exit 0;;
	*)
		echo ""
		echo "invalid option selected"
		sleep 0.5
		submenu_scripts;;
	esac
}


mainmenu(){
	fn_overview
	echo -ne "
	$(magentaprint 'MAIN MENU')
	$(magentaprint '+++++++++')
	$(yellowprint '1 SET-PARAMETERS')
	$(magentaprint '+')
	$(greenprint '2 zabbix proxy')
	$(magentaprint '+')
	$(greenprint '3 zabbix agent')
	$(magentaprint '+')
	$(cyanprint '4 script files')
	$(magentaprint '+')
	$(redprint '0 Exit')
	$(magentaprint '+++')
	Choose an option: "
	
	read -r answer
	case $answer in
	1)
		submenu_parameters;
		sleep 0.5
		clear
		mainmenu;;
	2)
		submenu_proxy;
		sleep 0.5
		clear
		mainmenu;;
	3)
		submenu_agent;
		sleep 0.5
		clear
		mainmenu;;
	4)
		submenu_scripts;
		sleep 0.5
		clear
		mainmenu;;
	5)
		mainmenu;;
	6)
		mainmenu;;
	7)
		mainmenu;;
	8)
		mainmenu;;
	9)
		mainmenu;;
	0)
		echo "bye bye"
		exit 0;;
	*)
		echo "invalid option selected"
		sleep 0.5
		clear
		mainmenu;;
	esac

}

determine_sys;
initialize;

mainmenu;

