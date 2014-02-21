#!/usr/bin/env bash
#MAKE SURE ALL THE TXT FILES ARE CORRECT
#BEFORE RUNNING THIS SCRIPT
#must be run as root
#Text files needed:
#iptables.sh - will be a script containing the iptables rules you want
#
#parameters
#first param $1 - name of interface
####################################################################################
#THINGS TO CHECK ######################################
#if setting immutable flag to /boot and making it read only screws up box. if not, do dat in dis

#if not 1 param
if [ $# -ne 1 ]
   then 
      set "eth0"
      echo "expected name of main interface, but automatically assumed to be 'eth0'"
fi

#setting the net int down
/bin/ifconfig down $1

outfile=info.txt #set output file

#cronjobs aka blowjob
/usr/bin/crontab -r #remove crontabs

/bin/chown root:root /etc/cron* -R
/bin/chmod o= /etc/cron* -R
/bin/mv /etc/crontab /etc/.crontab.bak
/usr/bin/chattr +i -R /etc/cron*
/usr/bin/chattr +i /etc/.crontab.bak

/bin/chown root:root /usr/bin/crontab
/bin/chmod o= /usr/bin/crontab
/usr/bin/chattr +i /usr/bin/crontab

/bin/chown root:root /etc/anacrontab
/bin/chmod o= /etc/anacrontab
/usr/bin/chattr +i /etc/anacrontab

/bin/chown root:root /usr/sbin/anacron
/bin/chmod o= /usr/sbin/anacron
/usr/bin/chattr +i /usr/sbin/anacron

/bin/chown root:root /etc/anacrontab
/bin/mv /etc/anacrontab /etc/.anacrontab.bak
/usr/bin/chattr +i /etc/anacrontab

#edit sudoers
/bin/mv /etc/sudoers /etc/.sudoers.bak
echo " " > /etc/sudoers
/bin/chmod 000 /etc/sudoers
/usr/bin/chattr +i /etc/sudoers

#calling iptables script to set all the ip tables rules
./iptables.sh &
echo "`pwd`/iptables.sh " | /bin/cat /etc/rc.local > /etc/rc.local

function fix_repo {
	if [ ! -e $2 ]; then
		return 1
	fi
	if [ "$1" == "apt" ]; then
		/bin/mv /etc/apt/sources.list /etc/apt/sources.list.bak
		echo "INSERT REPO LINE HERE" > /etc/apt/sources.list
		/usr/bin/chattr +i /etc/apt/sources.list
		/usr/bin/chattr +i /etc/apt
	elif [ "$1" == "yum" ]; then
		repos=`ls /etc/yum.repos.d`
		for f in $repos; do
			/bin/mv $f $f.bak
		done
		echo "INSERT REPO LINE HERE" > /etc/yum.repos.d/default.repo
		/usr/bin/chattr +i /etc/yum.repos.d/default.repo
		/usr/bin/chattr +i /etc/yum.repos.d
	elif [ "$1" == "emerge" ]; then
		echo "$1 fix_repo feature not yet implemented"
	fi
}

#determine distro to get package manage and int config location
if [ -f /etc/redhat-release ] ; then
	pkmgr=`/usr/bin/yum`
	sys_netconfig="/etc/sysconfig/network-scripts/ifcfg-$1"
	fix_repo yum repos.txt # do repo stuff
elif [ -f /etc/debian_version ] ; then
	pkmgr=`/usr/bin/apt-get`
	sys_netconfig="/etc/network/interfaces"
	fix_repo apt repos.txt # do repo stuff
elif [ -f /etc/gentoo_version ]; then #possible might need this too: -f /etc/gentoo-release
	pkmgr=`/usr/bin/emerge`
	/bin/ln -s /etc/init.d/net.lo /etc/init.d/net.$1 #create link so system recognizes net.lo file. needed for manual net config
	sys_netconfig="/etc/conf.d/net"
	#still need to figure out
	fix_repo emerge repos.txt # do repo stuff
elif [ -f /etc/slackware-version ]; then
	pkmgr=`/usr/bin/which installpkg`
	sys_netconfig="/etc/rc.d/rc.inet1.conf"
	fix_repo apt repos.txt # do repo stuff
else
	echo "OS/distro not detected...using debian defaults..." >&2
	pkmgr=`/usr/bin/apt-get` #if can't find OS, just use apt-get and hope for best
	sys_netconfig="/etc/network/interfaces"
	fix_repo apt repos.txt # do repo stuff
fi

#set static ip address, gateway and DNS
/bin/ifconfig $1 <IP_ADDR> netmask <NET_MASK>
/bin/route add default gw <GATEWAY_IP>
echo "nameserver 8.8.8.8" > /etc/resolv.conf
#echo "nameserver <TEAM_DNS_SRVR>" >> /etc/resolv.conf


#set hosts file location and do hosts file securing
hosts="/etc/hosts"

/bin/cp $hosts $hosts.backup
echo "127.0.0.1       localhost" > $hosts
echo "127.0.1.1       `hostname`" >> $hosts
/usr/bin/chattr +i $hosts
/bin/chmod 600 $hosts

#put the interface back up ifconfig up $1
/bin/ifconfig up $1

#upgrading and updating everything
$pkmgr update & disown &> .updateinfo.txt
$pkmgr upgrade -y & disown &> .upgradeinfo.txt

#makes the jail. if /var/jail taken, somewhat random directory attempted to be made in hopes it doesn't exist
if [ ! -e /var/jail ]; then
	./jail_maker.sh -s /var/jail &
elif [ ! -e /var/jm_jail_5186 ]; then
	./jail_maker.sh -s /var/jm_jail_5186 &
else
	echo "jail not made. must pick a new directory" >&2
fi

#Make Sure No Non-Root Accounts Have UID Set To 0
echo "Accounts with UID = 0" >> $outfile
echo `/bin/awk -F: '($3 == "0") {print}' /etc/passwd` >> $outfile
echo "" >> $outfile

#all listening ports
echo "All the ports that you're listening on" >> $outfile
echo `/usr/bin/lsof -nPi | /bin/grep -iF listen` >> $outfile
echo "" >> $outfile

#finding all of the world-writeable files
echo "All of the world-writable files" >> $outfile
/usr/bin/find / -xdev -type d \( -perm -0002 -a ! -perm -1000 \) -print >> $outfile
echo "" >> $outfile

#finding all of the no owner files
echo "All of the no owner files" >> $outfile
/usr/bin/find / -xdev \( -nouser -o -nogroup \) -print >> $outfile
echo "" >> $outfile

#backup important files and directories
/bin/tar -cf /root/.notes.tar /boot /bin /sbin /etc /var /root /home /lib /usr &>.backup_info.txt

#rename certain executables and chattr them
/bin/mv /usr/bin/gcc /usr/bin/gccz
/usr/bin/chattr +i /usr/bin/gccz
/bin/mv /usr/bin/reboot /usr/bin/rebootz
/usr/bin/chattr +i /usr/bin/rebootz
/bin/mv /sbin/shutdown /sbin/shutdownz
/usr/bin/chattr +i /sbin/shutdownz

#prompt for ssh box
read -p "is this an ssh box (Y/N): " answer
answer=`echo $answer | /usr/bin/tr '[:lower:]' '[:upper:]'`
if [ "$answer" == "Y" ]; then
	./ssh.sh &
fi

#prompt for web box
#web.sh does not exist yet
read -p "is this a web box (Y/N): " answer
answer=`echo $answer | /usr/bin/tr '[:lower:]' '[:upper:]'`
if [ "$answer" == "Y" ]; then
	./web.sh &
fi



