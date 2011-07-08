#!/bin/bash
#
#################################
# The Ultimate Plesk script     #
#################################
#                               #
#     ***   BETA   ***          #
#                               #
###############################################################
###############################################################
#
#  Written by: Derek Creason
#  
##################################### 
# This script will provide a menu of
# options for common issues on plesk 
# servers 
#
#
# Changelog:
#          - changes, and updates
#          * Issue needs to be addressed 
#
#
#
# 5/31/11  - Built Main Menu Selection
# 6/01/11  - Built Main Menu Function
#          - Menu1 function complete and functional         
#          - Menu10 function complete and functional
#          - Menu2 function coded. Tested as good on local box.
#          * Menu2 function needs to be tested on plesk server.  should work just fine.
#          - Menu3 function coded.
#          * Menu3 needs to be tested and function end changed to "Return to Main menu?"
#          * Need to add logging to various parts of the script.  where?
#          - Menu4 function coded. 
#          * Menu4 needs to be tested. Possibly logging added.  should work fine.
#          - Menu5 function coded.
#          * Menu5 needs to be tested.                             
#          - Menu6 function coded and tested as good.
#	   - Menu7 fucntion coded.
#	   * Menu7 needs to be tested on a plesk box.
#          - Menu8 function coded.
#          - Menu8 tested and working correctly. would like to make it more complex.
#          - Menu9 function has been coded. 
#          * Menu9 needs to be tested on a plesk box. It should work. 
#
# 6/3/11   -Added Os detection to main menu and Menu1 so as to distinguish to check selinux vs apparmor
#          -Updated script exit code 
#          -Verified that Menu9 code should work to open Passive Ports, add IP Tables rule, and 
#           and restart xinetd on both CentOS and Ubuntu
#
# 6/13/11  -Added dns and IP lookup to menu2 function.
#          -Added Menu10  Dns and IP lookup info to Main Menu as well.
#          -Added Menu11 DDOS checker / Netstat info fucntion.
#
# 6/14/11  -Added Menu12 Large Dir function
#
# 6/22/11  -Added functionality to Menu11 Netstat ifno
#
# 7/6/11  -Set blacklist checker to filter out internal IP addresses.
#
#################################################################


# Define colors

BLUE="\e[0;34m"
RED="\e[0;31m"
GREEN="\e[1;32m"
YELLOW="\e[0;33m"
REDBACK="\e[1;41m"
DARKRED="\e[0;31m"
WHITE="\e[1;29m"
GRAY="\e[1;30m"
NORMAL="\e[0m"
SPACE="\e[45G"
STATUSCOL="\e[60G"

#
#
##################################################################################
#
##################################################################################
#  Start of Menu1 Function code.              Basic server info
#


function Menu1 {

# This function will pull basic plesk server info including the following:
#  Hostname
#  OS and 32 or 64 bit architechture
#  Partitions and Disk usage
#  Plesk Backup disk usage
#  Total processes and defunct processes if applicable
#  Memory Usage
#  SELINUX Status or Apparmor status
#  All Users currently logged in
#  Current # of connections to web server
#  Active MYSQL processes 
#
# This is from Derek's original pleskserverinfo.sh script.

clear
hostname=`hostname`
echo -e "###################################################################"
echo -e "    ${GREEN}   $hostname has the following info:${NORMAL}         "
echo -e "###################################################################\n"
echo -e "# ${RED}OS & 32 vs 64 bit and kernel version info:${NORMAL}"
echo -e "`lsb_release -si` `lsb_release -sr` "
echo -e "`uname -a`\n"
echo -e "# ${RED}Partitions and Disk Space usage:${NORMAL}\n"
echo -e " `df -h` \n"
echo -e "# ${RED}Plesk backups current disk usage:${NORMAL}"
echo -e " `du -sh /var/lib/psa/dumps/`\n"
processes=`ps -e | cut -d" " -f1 | wc -l`
defunct=`ps -e | grep defunct`
numbdefunct=`ps -e | grep defunct | wc -l`
echo -e "#${RED} Processes:${NORMAL}"
echo -e "$hostname has $processes processes running and $numbdefunct defunct processes.\n"
       if [ "$numbefunct" > "0" ]; then
        echo -e " Defunct processes are:\n"
        echo -e " $defunct\n"
       fi
echo -e "# ${RED}Memory Info for $hostname:${NORMAL}"
echo -e "`free -m`\n"
OS=`lsb_release -si`
	if [ "$OS" = "CentoOS" ]; then
	echo -e " `sestatus`\n"
	else if [ "$OS" = "Ubuntu" ]; then
	echo -e " \n Apparmor Status:"
	echo -e " `/etc/init.d/apparmor status`\n"
	fi
	fi 
echo -e "# ${RED}Users logged in:${NORMAL}\n"
echo -e "`w`\n"
echo -e "# ${RED}Current connections to Web server${NORMAL}\n"
echo -e "`netstat -anp | grep :80 | wc -l` \n"
echo -e "# ${RED}MYSQL Process List:${NORMAL}"
echo -e "`mysqladmin -u admin -p\`cat /etc/psa/.psa.shadow\` processlist`\n\n\n"
echo -e " ${GREEN}Would you like to Return to the main Menu? ${YELLOW}[y|n]${NORMAL}\n"
read -e answer
     if [ "$answer" = "y" ]; then
	MainMenu
     else
	clear 
	echo -e "\n${GREEN}Thank you for using the ${RED}Ultimate Plesk Script${GREEN}. Enjoy your server.${NORMAL} \n"
	exit
     fi

}
 
#
#  End of Menu1 function code 
###########################################################################
#
###########################################################################
#  Start of Menu2 function code            List Domains, Emails, and FTP Passwords 
#

function Menu2 {
# This function will list the following information from a Plesk Server:
# Domains configured on server
# All Email addresses and passwords
# All Ftp users and passwords
clear
echo -e "##########################################"
echo -e "#        Below are the Domains           #" 
echo -e "#     configured on this server          #"
echo -e "##########################################"
ls /var/www/vhosts/
echo -e "\n\n"
echo -e "##########################################"
echo -e "#    Below are the email addresses       #"
echo -e "#            on this server              #"
echo -e "##########################################"
echo -e "\n"
mysql -u admin -p`cat /etc/psa/.psa.shadow` psa -e "SELECT accounts.id, mail.mail_name, accounts.password, domains.name FROM domains LEFT JOIN mail ON domains.id = mail.dom_id LEFT JOIN accounts ON mail.account_id = accounts.id"
echo -e "\n"
echo -e "##########################################"
echo -e "#      Below are the ftp users           #"
echo -e "#           on this server               #"
echo -e "##########################################"
mysql -u admin -p`cat /etc/psa/.psa.shadow` psa -e "select s.login,s.home,a.password from sys_users s,accounts a where a.id=s.account_id ORDER BY s.home"
echo -e "\n${GREEN}Would you like to look up DNS and IP information for a domain?${YELLOW} [y|n]${NORMAL}"
read domanswer
	if [ "$domanswer" = "y" ]; then
	echo -e "What is the Domain Name? "
	read domain
	echo -e "\n-----------------------------------------------------"
	echo -e " $domain has the following information:"
	echo -e "-----------------------------------------------------\n"
	whois $domain | grep 'Name Server:'
	echo -e  "\n"
	whois $domain | grep 'Registrar:'
	echo  -e "\n"
	whois $domain | grep 'Status:'
	echo " "
	whois $domain | grep 'Expiration Date:'
	echo " "
	host $domain | grep 'has address'
	ip=`host $domain | grep 'has address' | cut -d " " -f4`
	echo " "
	echo " $ip IP address is owned by: `whois $ip | grep OrgName: | cut -d" " -f2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19`"
	echo " "
	echo "----------------------------------------------------"
	echo " $domain's MX records:"
	echo "----------------------------------------------------"
	echo " "
	host $domain | grep 'is handled by' | sort

echo -e "\n ${GREEN} Would you like to look up DNS info for another Domain? ${YELLOW} [y|n] ${NORMAL} "
read answer
        if [ "$answer" = "y" ]; then
        Menu10
        else
         echo -e "\n${RED} Returning to Main Menu in 2 seconds.${NORMAL}"
        sleep 2
        MainMenu
        fi
else
         echo -e "\n${RED} Returning to Main Menu in 2 seconds.${NORMAL}"
        sleep 2
        MainMenu
        fi




}

#
# End of Menu2 function code
###########################################################################################
#
###########################################################################################
# Start of Menu3 function code       Permissions fixer for domains
#

function Menu3 {
# This function will run Tylers Permissions Fixer script for domains on Plesk.
#
# Comments directly from Tylers script below:
#
# Tyler Rushton | trushton.com | 02.11
# Perfect Plesk permissions will modify your domain's directory permissions to maintain
# the FTP user when apache is upload or modifying files. This will allow the domain to
# continue to run as an Apache module opposed to FastCGI inside Plesk.
#
clear
PS3="Select domain: "
echo '===================================='
echo 'Perfect Plesk permissions generator.'
echo '===================================='
mypass=$(cat /etc/psa/.psa.shadow)
domains=(`mysql -uadmin -p$mypass -n psa -Bse "select name from domains where htype='vrt_hst';"`)
select domain in ${domains[@]} Exit
do
[[ "${domain}" == "" ]] && echo 'Invalid choice, exiting.' && MainMenu
[[ "${domain}" == "Exit" ]] && echo 'Exiting.' && MainMenu
user=$(/usr/local/psa/bin/domain -i $domain|grep 'FTP Login:'|awk '{print $NF}')
echo 'Changing file ownership to' $user'.'
chmod 755 /var/www/vhosts/$domain/httpdocs
echo -n "Would you like to display what files are being modified? Type display to list files. Press enter to skip: "
read -e showarray
chownarray=(`find /var/www/vhosts/$domain/httpdocs -not -user $user`)
        y=0
if [ "$showarray" = "display" ]
        then
                for (( i=1; i<=${#chownarray[@]}; i++ ))
                do
                        echo ${chownarray[${y}]}
                        let "y = $y +1"
                done
fi
        echo ${chownarray[${y}]} >> /root/modifiedpermissions.txt
        echo ${#chownarray[@]} 'modified files logged to /root/modifiedpermissions.txt'
chown -R $user:psacln /var/www/vhosts/$domain/httpdocs
echo 'Updating file ownership for' $domain 'complete.'
echo 'Updating file permissions.'
chmod -R g+w /var/www/vhosts/$domain/httpdocs
chmodarray=(`find /var/www/vhosts/$domain/httpdocs -type d`)
        x=0
                for (( i=1; i<=${#chmodarray[@]}; i++ ))
                do  
                        chmod g+s ${chmodarray[${x}]}
                        let "x = $x + 1"
                done
echo  ${#chmodarray[@]} 'directories and' ${#chownarray[@]} 'files have been perfected for' $domain'.'
exit
done


}

#
#  End of Menu3 function Code.
#######################################################################################
#
#######################################################################################
#  Start of Menu4 function Code.   MYSQL DB backup
#


function Menu4 {
clear
echo -e "\n # Attempting to backup all mysql Databases....\n"
echo -e "Please be patient. This may take a moment.\n"
mysql -u admin -p`cat /etc/psa/.psa.shadow` -disable local relay -e 'show databases;' | while read db ; do mysqldump -u admin -p`cat /etc/psa/.psa.shadow` $db > $db.sql ; echo ..$db [DONE] ; done
echo -e "\n If there were no errors then:" 
echo -e " Databases backed up to current directory.\n"

echo -e " ${GREEN}Would you like to Return to the main Menu? ${YELLOW}[y|n]${NORMAL}\n"
read -e answer
     if [ "$answer" = "y" ]; then
        MainMenu
     else
        echo -e "${GREEN}Thank you for using the ${RED}Ultimate Plesk Script${GREEN}. Enjoy your server.${NORMAL} \n"
        exit
     fi
}


#
# End of Menu4 function code.
########################################################################################
#
########################################################################################
# Start of Menu5 function code.     FTP password Reset
#

function Menu5 {
clear
echo -e "\n${RED}!!!ATTENTION!!!      !!!ATTENTION!!!     !!!ATTENTION!!!${NORMAL}"
echo -e "This will reset all the FTP passwords to randomly generated passwords.\n"
echo -e "Are you sure you wish to continue? ${YELLOW} [y|n]${NORMAL}"
read -e answer
	if [ "$answer" = "y" ]; then
	for i in $(mysql -NB psa -uadmin -p`cat /etc/psa/.psa.shadow` -e 'select login from sys_users;'); do export PSA_PASSWD="$(openssl rand 12 -base64)"; /usr/local/psa/admin/bin/usermng --set-user-passwd --user=$i; echo "$i: $PSA_PASSWD" >> ftp_passwords; done
	echo -e " New ftp passwords can be viewed in file ftp_passwords located in the current directory.\n"
	else
	MainMenu
	fi 

echo -e " ${GREEN}Would you like to Return to the main Menu? ${YELLOW}[y|n]${NORMAL}\n"
read -e answer
     if [ "$answer" = "y" ]; then
        MainMenu
     else
       clear
        echo -e "\n${GREEN}Thank you for using the ${RED}Ultimate Plesk Script${GREEN}. Enjoy your server.${NORMAL} \n"
        exit
     fi


}

#
# End of Menu5 function code.
#######################################################################################
#
#######################################################################################
# Start of Menu6 function code.    IP blacklist checker
#

function Menu6 {
# This will check the servers IP address(es) against common blacklists.
clear
echo -e "This will check the servers IP addresses against common blacklists.\n"
echo -e "${BLUE}The server has the following IP addresses on it: (excludes 10.x.x.x and 192.168.x.x)\n${RED}"
ifconfig | grep "inet addr:" | awk {'print $2'} | cut -d ":" -f2 | grep -v 127.0.0.1 | grep -v 10. | grep -v 192.168
echo -e "\n${GREEN}Do you want to scan the IP addresses listed? ${YELLOW}[y|n]${NORMAL}"
read -e ans
	if [ "$ans" = "y" ]; then
	ifconfig | grep "inet addr:" | awk {'print $2'} | cut -d ":" -f2 | grep -v 127.0.0.1 | grep -v 192.168 | grep -v 10. | while read -a ip; do blacklist $ip; done
	else 
	echo -e "\n${RED}Wow! Aren't these some neat IP addresses?${NORMAL}\n"
	echo -e "When you are done staring at them,"
	echo -e "Press y to return to MainMenu."
	read -e a 
		if [ "$a" = "y" ]; then
		MainMenu
		else
		echo -e "\n You couldn't even press the right key."
		echo -e "\n Exiting script due to user error.\n"
	        exit
		fi
	fi

echo -e "\n ${GREEN}Would you like to Return to the main Menu? ${YELLOW}[y|n]${NORMAL}\n"
read -e answer
     if [ "$answer" = "y" ]; then
        MainMenu
     else
        clear
        echo -e "\n${GREEN}Thank you for using the ${RED}Ultimate Plesk Script${GREEN}. Enjoy your server.${NORMAL} \n"
        exit
     fi

}


#
# End of Menu6 function code.
#######################################################################################
#
#######################################################################################
# Start of Menu7 function code.         Kill off non root users
#

function Menu7 {
clear
echo -e "${RED}ATTENTION!!!${NORMAL}"
echo -e "This will log out all logged in users except root!
echo -e "Any unsaved work users are working on will be lost!
echo -e "Are you sure you wish to continue? ${YELLOW} [y|n]${NORMAL}"
read -e answer
        if [ "$answer" = "y" ]; then
	who -u | grep -vE "^root " | kill `awk '{print $6}'`
	echo -e "\nAll other users killed off.\n"
	echo -e "\n ${GREEN}Would you like to Return to the main Menu? ${YELLOW}[y|n]${NORMAL}\n"
	read -e answer
    	 if [ "$answer" = "y" ]; then
        MainMenu
     	else
        clear
        echo -e "\n${GREEN}Thank you for using the ${RED}Ultimate Plesk Script${GREEN}. Enjoy your server.${NORMAL} \n"
        exit
     	fi

	else 
        MainMenu
	fi
}

#
# End of Menu7 function code.
######################################################################################
#
#####################################################################################
# Start of Menu8 function code.       Kill Multiple processes
#

function Menu8 {
# This function will kill off multiple processes
clear
ps -e
echo -e "\n${DARKRED}Above is the output of ps -e.${NORMAL} \nTo kill off a process or multiple processes"
echo -e "of the same name please input the  name of the process(es)."
echo -e "\n You may have to scroll up to see it all."
echo -e "\n E.g. ${BLUE}apache2 ${NORMAL}"
echo -e "\n ${GREEN}Do you wish to kill some processes? ${YELLOW}[y|n]${NORMAL}"
	read -e b
	if [ "$b" = "y" ]; then
echo -e "\n\n${GREEN}What is the name of the process(es) you wish to kill? ${RED}Type \"cancel\" if you changed your mind.${NORMAL}"
read -e answer
	if [ "$answer" = "cancel" ]; then
	echo -e "\n${RED} Returning to Main Menu in 2 seconds.${NORMAL}"
	sleep 2
	MainMenu
	else
ps -e | grep "$answer" | awk {'print $1'} | while read -a pid; do kill -9 $pid; done
echo -e "\n$answer processes killed."
	fi
echo -e "\n${GREEN} Would you like to Return to the main Menu? ${YELLOW}[y|n]${NORMAL}\n"
read -e answer
     if [ "$answer" = "y" ]; then
        MainMenu
     else
        clear
        echo -e "\n${GREEN}Thank you for using the ${RED}Ultimate Plesk Script${GREEN}. Enjoy your server.${NORMAL} \n"
        exit
     fi
else
echo -e "\n${RED} Returning to Main Menu in 2 seconds.${NORMAL}"
sleep 2
MainMenu
fi



}

#
# End of Menu8 function code.
########################################################################################
#
########################################################################################
# Start of Menu9 function code.                 Enable Passive Ports for FTP
#

function Menu9 {
#This will enable passive ports for proftpd
clear
echo -e "   ${RED}!!!    PROFTPD ONLY  !!!      !!!      PROFTPD ONLY  !!!   ${NORMAL}  " 
echo -e " \n# Currently supports ${YELLOW}CentOS${NORMAL} and${YELLOW} Ubuntu${NORMAL}.\n"
echo -e "This will attempt to open passive ports in the proftpd.conf file\n"
echo -e "It will also add a temporary rule to iptables to open the ports.\n"
echo -e "Please add a permanent firewall rule otherwise the ports will be closed after a reboot.\n"
echo -e "${GREEN}Do you wish to enable Passive Ports? ${YELLOW} [y|n]${NORMAL}\n" 
	read -e c
	if [ "$c" = "y" ]; then
echo PassivePorts 60000 65000 >> /etc/proftpd.conf
iptables -I INPUT -p tcp -m tcp --dport 60000:65000 -j ACCEPT
sleep 1
/etc/init.d/xinetd restart 
sleep 1
echo -e "\n\n If no errors were reported above then Passive Ports have been opened. \n\nPlease transfer files responsibily."

echo -e "\n${GREEN} Would you like to Return to the main Menu? ${YELLOW}[y|n]${NORMAL}"
read -e answer
     if [ "$answer" = "y" ]; then
        MainMenu
     else
        clear
        echo -e "\n${GREEN}Thank you for using the ${RED}Ultimate Plesk Script${GREEN}. Enjoy your server.${NORMAL} \n"
        exit
     fi
        else
	echo -e "\n${RED} Returning to Main Menu in 2 seconds.${NORMAL}"
	sleep 2
	MainMenu
	fi


}



#
# End of Menu9 function code.
#######################################################################################
#
#######################################################################################
#  start of blacklist function code
#

function blacklist {
# Taken from Justyns blacklist checker script

set -o nounset                              # Treat unset variables as an error
 
[ $# -ne 1 ]&&{ 
printf "Usage %s [%s]\n" "$0" "IP Address"
exit 1
}
 
STATUSCOL="\e[30G"
NORMAL="\e[0m"
RED="\e[0;31m"
GREEN="\e[0;32m"
YELLOW="\e[0;33m"
oldIFS=$IFS
blacklists="b.barracudacentral.org
spam.dnsbl.sorbs.net
xbl.spamhaus.org
dnsbl-1.uceprotect.net
dnsbl.sorbs.net
sbl.spamhaus.org
multi.surbl.org
bl.spamcop.net
dnsbl-2.uceprotect.net
dnsbl-3.uceprotect.net
cbl.abuseat.org
ips.backscatterer.org
bl.blocklist.de"
 
IFS=.
IP=( $1 )
RIP="${IP[3]}.${IP[2]}.${IP[1]}.${IP[0]}"
IFS=${oldIFS}
 
echo "Checking ${1} against blacklists..."
for BL in ${blacklists}; do
	echo -ne "${BL} ${STATUSCOL}["
	result=$(dig +short "${RIP}.${BL}")
	if [ "${result}" == "" ]; then
		echo -e "${GREEN}No${NORMAL}]"
	else
		echo -e "${RED}Yes${NORMAL} (${YELLOW}${result}${NORMAL})]"
	fi
done
}



#
# End of blacklist function code
################################################################################################
#
################################################################################################
#  Begining of Menu 10 function code                 DNS and IP lookup info
#

function Menu10 {
# This function will allow you to look up dns and IP info for a domain including the following.
# 
# Domains name servers
# Domains registrar
# Domains status
# Domains IP address it is resolving to
# Who owns that IP address
# Domains mx records

clear
echo "What is the Domain Name? "
read domain
echo " "
echo "-----------------------------------------------------"
echo " $domain has the following information:"
echo "-----------------------------------------------------"
echo " "
whois $domain | grep 'Name Server:'
echo " "
whois $domain | grep 'Registrar:'
echo " "
whois $domain | grep 'Status:'
echo " "
whois $domain | grep 'Expiration Date:'
echo " "
host $domain | grep 'has address'
ip=`host $domain | grep 'has address' | cut -d " " -f4`
echo " "
echo " $ip IP address is owned by: `whois $ip | grep OrgName: | cut -d" " -f2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19`"
echo " "
echo "----------------------------------------------------"
echo " $domain's MX records:"
echo "----------------------------------------------------"
echo " "
host $domain | grep 'is handled by' | sort
echo " "

echo -e "\n ${GREEN} Would you like to look up DNS info for another Domain? ${YELLOW} [y|n] ${NORMAL} "
read answer
	if [ "$answer" = "y" ]; then
	Menu10
	else
	 echo -e "\n${RED} Returning to Main Menu in 2 seconds.${NORMAL}"
        sleep 2
        MainMenu
        fi
}

#
#    End of Menu 10 Code
################################################################################################
#
################################################################################################
#   Begining of Menu 11 code                DDOS checker / Netstat info
#

function Menu11 {
clear
echo -e "${GRAY}##########################################################${NORMAL}"
echo -e "${GREEN}         DDOS checker / Netstat info Menu "
echo -e "${GRAY}##########################################################${NORMAL}"
echo -e "\n${GRAY}##########################################################${NORMAL}"
echo -e "${GREEN}  Please Make a selection from the following menu:${Normal}"
echo -e "${GRAY}##########################################################\n"
echo -e "${GRAY}##########################################################"
echo -e "#  ${RED} 1.${GREEN}  Show number of connections per IP address${GRAY}        #"
echo -e "#  ${RED} 2.${GREEN}  Show IP's with more than 10 connections open${GRAY}     #"
echo -e "#  ${RED} 3.${GREEN}  Graph # of open connections per host${GRAY}             #"
echo -e "#  ${RED} 4.${GREEN}  Drop IP's with 100 or more connections${GRAY}           #"
echo -e "#  ${RED} 5.${GREEN}  Summarize the # of open connections by state${GRAY}     #"
echo -e "#  ${RED} 6.${GREEN}  Return to Main Menu.${GRAY}                             #"
echo -e "#  ${RED} 7.${GREEN}  Exit Ultimate Plesk script.${GRAY}                      #"
echo -e "##########################################################${NORMAL}"
echo -e "\n  Make your ${YELLOW}choice:${NORMAL}"
read -e choice

case "$choice" in
	1 )   netstat -anp |grep 'tcp\|udp' | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -n 
	 	echo -e "\n${GREEN} Would you like to return to the DDOS checker menu?${NORMAL} "
		read answer
		if [ "$answer" = "y" ]; then
		Menu11
		else
		  echo -e "\n${RED} Returning to Main Menu in 2 seconds.${NORMAL}"
        	  sleep 2
        	  MainMenu
       		 fi
	

		;;
	2 )    netstat -nat | grep ":80" | awk -F: '{print $8}' | sort | uniq -c | sort -n | awk '{ if ( $1 > 10) print $2 ; }'
		echo -e "\n${GREEN} Would you like to return to the DDOS checker menu?${NORMAL} "
                read answer
                if [ "$answer" = "y" ]; then
                Menu11
                else
                  echo -e "\n${RED} Returning to Main Menu in 2 seconds.${NORMAL}"
                  sleep 2
                  MainMenu
                 fi

		;;

	3 )  netstat -an | grep ESTABLISHED | awk '{print $5}' | awk -F: '{print $1}' | sort | uniq -c | awk '{ printf("%s\t%s\t",$2,$1) ; for (i = 0; i < $1; i++) {printf("*")}; print "" }'

		echo -e "\n${GREEN} Would you like to return to the DDOS checker menu?${NORMAL} "
                read answer
                if [ "$answer" = "y" ]; then
                Menu11
                else
                  echo -e "\n${RED} Returning to Main Menu in 2 seconds.${NORMAL}"
                  sleep 2
                  MainMenu
                 fi

 		;;

	4 ) 
		echo -e " ${RED} !!! WARNING !!! ${NORMAL}"
		echo -e " \n This will add temporary rules to the firewall and kill "
		echo -e " potentially legitimate open connections."
		echo -e "\n ${RED}PLEASE USE WITH CAUTION: ${NORMAL}"
		echo -e "\n Would you like to continue and drop IP's with 100 or more connections? ${YELLOW} [y|n] ${NORMAL}"
		read spaceship
		if [ "$spaceship" = "y" ]; then 
		 netstat -nat | egrep ":80|:443" | awk -F: '{print $8}' | sort | uniq -c | sort -n | awk '{ if ( $1 > 100) print $2 ; }' | xargs -n1 echo iptables -I INPUT -j DROP -s
		echo -e " \n Connections dropped."
		echo -e "\n${GREEN} Would you like to return to the DDOS checker menu?${NORMAL} "
                read answer
                if [ "$answer" = "y" ]; then
                Menu11
                else
                  echo -e "\n${RED} Returning to Main Menu in 2 seconds.${NORMAL}"
                  sleep 2
                  MainMenu
                 fi
		else 
		echo -e "\n${RED} Returning to DDOS checker / Netstat menu in 2 seconds. ${NORMAL}"
		sleep 2
		Menu11
		fi

		;;

	5 )
		 netstat -nt | awk '{print $6}' | sort | uniq -c | sort -n -k 1 -r 
		echo -e "\n${GREEN} Would you like to return to the DDOS checker menu?${NORMAL} "
                read answer
                if [ "$answer" = "y" ]; then
                Menu11
                else
                  echo -e "\n${RED} Returning to Main Menu in 2 seconds.${NORMAL}"
                  sleep 2
                  MainMenu
                 fi



		;;
	6 ) 
		echo -e "\n${RED} Returning to Main Menu in 2 seconds.${NORMAL}"
                  sleep 2
                  MainMenu
		;;

	7 )  

	clear
	echo -e "\n${GREEN}Thank you for using the ${RED}Ultimate Plesk Script${GREEN}. Enjoy your server.${NORMAL} \n"
        exit  ;;

esac
}



#
# End of Menu 11 function code                         DDOS checker / Netstat Menu
################################################################################################
#
################################################################################################
# Beginning of Menu12 function code                 dir larger than 100 MB
#

function Menu12 {
#Finds all directories containing more than 99MB of files, and prints them in human readable format.
# The directories sizes do not include their subdirectories, 
#so it is very useful for finding any single directory with a lot of large files.

clear 
echo -e "Printing all directories containing more than 99MB of files.\n"
echo -e "${RED} NOTE: This may take a few minutes depending on drive size.\n\n Requires Perl be installed.\n${NORMAL}"
du -hS / | perl -ne '(m/\d{3,}M\s+\S/ || m/G\s+\S/) && print'

echo -e "\n${GREEN} Would you like to Return to the main Menu? ${YELLOW}[y|n]${NORMAL}"
read -e answer
     if [ "$answer" = "y" ]; then
        MainMenu
     else
        clear
        echo -e "\n${GREEN}Thank you for using the ${RED}Ultimate Plesk Script${GREEN}. Enjoy your server.${NORMAL} \n"
        exit
     fi
}


#
# End of Menu12  function code                      dir larger than 100 MB
################################################################################################
#
################################################################################################
# Space for Future functions to be added
#





#
#######################################################################################
#
#######################################################################################
# Start of MainMenu function code.
#

function MainMenu {
clear
echo -e "  ${GRAY}###########################################${NORMAL}"
echo -e "    ${GREEN} Welcome to the ${RED}Ultimate${GREEN} Plesk Script:"
echo -e "  ${GRAY}###########################################${NORMAL}\n\n"
echo -e " ${GREEN}Please Make a selection from the following menu.${Normal}\n\n"
echo -e "${GRAY}#####################################################"
echo -e "#                                                   #"
echo -e "#  ${RED} 1.${GREEN}  Show basic server info${GRAY}                      #"
echo -e "#  ${RED} 2.${GREEN}  List domains, emails, ftp users on server${GRAY}   #"
echo -e "#  ${RED} 3.${GREEN}  Run \"Domain Permissions Fixer\" script${GRAY}       #"
echo -e "#  ${RED} 4.${GREEN}  Backup all Mysql DB's${GRAY}                       #"
echo -e "#  ${RED} 5.${GREEN}  Reset all ftp passwords to random${GRAY}           #"
echo -e "#  ${RED} 6.${GREEN}  Check IPs against blacklists${GRAY}                #"
echo -e "#  ${RED} 7.${GREEN}  Log out all logged in users except root${GRAY}     #"
echo -e "#  ${RED} 8.${DARKRED}  Kill${GREEN} Multiple processes${GRAY}                     #"
echo -e "#  ${RED} 9.${GREEN}  Enable Passive FTP Ports${GRAY}                    #"
echo -e "#  ${RED} 10.${GREEN} DNS and IP info lookup${GRAY}                      #"
echo -e "#  ${RED} 11.${GREEN} DDOS checker / Netstat info${GRAY}                 #"
echo -e "#  ${RED} 12.${GREEN} Show directories larger than 100MB${GRAY}          #"
echo -e "#  ${RED} 13.${GREEN} Exit script${GRAY}                                 #"
echo -e "#                                                   #"
echo -e "# ${YELLOW}Note: Currently only supports CentOS and Ubuntu.${GRAY}  #"
echo -e "# ${YELLOW}      FreeBSD can ${DARKRED}DIE!!${GRAY}                           #"
echo -e "#####################################################${NORMAL}\n"
echo -e " Your current OS is:${GREEN} `lsb_release -si` `lsb_release -sr` ${NORMAL}\n"
echo -e "  Make your ${YELLOW}choice:${NORMAL}"
read -e choice

case "$choice" in
	1 ) Menu1  ;;
	2 ) Menu2  ;;
	3 ) Menu3  ;;
	4 ) Menu4  ;;
	5 ) Menu5  ;;
	6 ) Menu6  ;;
	7 ) Menu7  ;;
	8 ) Menu8  ;;
	9 ) Menu9  ;;
	10 ) Menu10 ;;
	11 ) Menu11 ;;
	12 ) Menu12 ;;
	13 ) 
	clear
        echo -e "\n${GREEN}Thank you for using the ${RED}Ultimate Plesk Script${GREEN}. Enjoy your server.${NORMAL} \n"
	exit  ;;
esac

}
	

#
###############################################
#  Program Starts Here:
###############################################
#

MainMenu
