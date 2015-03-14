#!/usr/bin/env bash
#MAKE SURE ALL THE TXT FILES ARE CORRECT
#BEFORE RUNNING THIS SCRIPT
#must be run as root
#must change root password first! must!
#Text files needed:
#iptables.sh - will be a script containing the iptables rules you want
#parameters
#first param $1 - name of interface
####################################################################################
#MAKE SURE YOU SET YOUR IP ADDRESS, MASK, and GATEWAY
#ALSO CHECK IPTABLES SCRIPT BEFORE RUNNING, OR YOUR LIFE WILL BE bad

IP_ADDR=10.150.100.20
NETMASK=255.255.254.0
GATEWAY=10.150.100.254
TEAM_DNS_SRV=10.2.3.1

#if not 1 param
if [ $# -ne 1 ]
   then
      set "eth0"
      echo "expected name of main interface, but automatically assumed to be 'eth0'"
fi

backup()
{
        test -d /root/stuff || mkdir /root/stuff
        cd /root/stuff
        dirs="boot bin sbin etc var root home lib usr lib64"
        for dir in $dirs; do
                /bin/tar -cjf $dir.tar.bz /$dir
                /bin/tar -rf ../notes.tar $dir.tar.bz
        done
}

#setting the net int down
/sbin/ifconfig $1 down

outfile=info.txt #set output file

#backup important files and directories and fork before starting everything else
backup &>.backup_info.txt &disown

#cronjobs aka blowjob - remove cron for all users
users=`/bin/cat /etc/passwd | grep -o '^\w*'`
for user in $users; do
        crontab -r -u $user
done &> /dev/null

#destroy cron and anacron completely
/bin/chown root:root /etc/cron* -R
/bin/chmod o= /etc/cron* -R
/bin/mv /etc/crontab /etc/.crontab.bak
#/usr/bin/chattr +i -R /etc/cron* installing some stuff needs this
/usr/bin/chattr +i /etc/.crontab.bak

/bin/chown root:root /usr/bin/crontab
/bin/chmod o= /usr/bin/crontab
/usr/bin/chattr +i /usr/bin/crontab

/usr/bin/chattr -i /etc/anacrontab
/bin/chown root:root /etc/anacrontab
/bin/chmod o= /etc/anacrontab
/usr/bin/chattr +i /etc/anacrontab

/bin/chown root:root /usr/sbin/anacron
/bin/chmod o= /usr/sbin/anacron
/usr/bin/chattr +i /usr/sbin/anacron

/bin/chown root:root /etc/anacrontab
/bin/mv /etc/anacrontab /etc/.anacrontab.bak
/usr/bin/chattr +i /etc/anacrontab

#calling iptables script to set all the ip tables rules and add to startup
./iptables.sh &
test -e /etc/rc.local && /bin/cp /etc/rc.local /etc/rc.local
echo "`pwd`/iptables.sh " > /etc/rc.local

#stop usually unnecessary services
services="cron crond cups samba smbd inetd portmap rsync rlogin"
for service in $services; do
	/usr/bin/env service $service stop
	echo "/usr/bin/env service $service stop" >> /etc/rc.local
done

#determine distro to get package manage and int config location
if [ -f /etc/redhat-release ] ; then
	pkmgr='/usr/bin/yum'
	#sys_netconfig="/etc/sysconfig/network-scripts/ifcfg-$1"
elif [ -f /etc/debian_version ] ; then
	pkmgr='/usr/bin/apt-get'
	#sys_netconfig="/etc/network/interfaces"
elif [ -f /etc/gentoo_version ]; then #possible might need this too: -f /etc/gentoo-release
	pkmgr='/usr/bin/emerge'
	/bin/ln -s /etc/init.d/net.lo /etc/init.d/net.$1 #create link so system recognizes net.lo file. needed for manual net config
	#sys_netconfig="/etc/conf.d/net"
elif [ -f /etc/slackware-version ]; then
	pkmgr='/usr/bin/which installpkg'
	#sys_netconfig="/etc/rc.d/rc.inet1.conf"
else
	echo "OS/distro not detected...using debian defaults..." >&2
	pkmgr='/usr/bin/apt-get' #if can't find OS, just use apt-get and hope for best
	#sys_netconfig="/etc/network/interfaces"
fi

#set static ip address, gateway and DNS
/sbin/ifconfig $1 $IP_ADDR netmask $NETMASK
/sbin/route add default gw $GATEWAY
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf
#echo "nameserver $TEAM_DNS_SRV" >> /etc/resolv.conf

#set hosts file location and do hosts file securing
hosts="/etc/hosts"

/usr/bin/chattr -i $hosts
/bin/cp $hosts $hosts.backup
echo "127.0.0.1       localhost" > $hosts
echo "127.0.1.1       `hostname`" >> $hosts
/bin/chown root:root $hosts
/bin/chmod 600 $hosts
/usr/bin/chattr +i $hosts

#remove all users from the root group except for root. and some services possibly
users=`/bin/cat /etc/passwd | grep -o '^\w*'`
for user in $users; do
        usermod -R root $user
done &> /dev/null

#edit sudoers
/bin/mv /etc/sudoers /etc/.sudoers.bak
echo > /etc/sudoers
/bin/chown root:root /etc/sudoers
/bin/chmod 000 /etc/sudoers
/usr/bin/chattr +i /etc/sudoers

#put the interface back up ifconfig up $1
/sbin/ifconfig $1 up

#upgrading and updating everything
bash -c "$pkmgr update -y && $pkmgr upgrade -y" &>.updateinfo.txt &disown

#Make Sure No Non-Root Accounts Have UID Set To 0
echo "Accounts with UID = 0" >> $outfile
echo `/usr/bin/awk -F: '($3 == "0") {print}' /etc/passwd` >> $outfile
echo >> $outfile

#all listening ports
echo "All the ports that you're listening on" >> $outfile
echo `/usr/bin/lsof -nPi | /bin/grep -iF listen` >> $outfile
echo >> $outfile

#finding all of the world-writeable files
echo "All of the world-writable files" >> $outfile
echo `/usr/bin/find / -xdev -type d \( -perm -0002 -a ! -perm -1000 \) -print` >> $outfile &disown
echo >> $outfile

#find all suid bit files and remove suid bit if it seems like the binary doesn't need it
#is not tested, needs more binaries to be added to the check in the if statement!
badFiles=`/usr/bin/find / -type f \( -perm -04000 -o -perm -02000 \)`
for file in $badFiles; do
	if [ "`/bin/grep -iP '.*passwd.*|su|ping|.*mount.*|crontab'`" = "" ]; then
		/bin/chmod u-s "$file"
		echo "got rid of suid bit on '$file'" >> $outfile
	fi
done

# #finding all of the no owner files
# echo "All of the no owner files" >> $outfile
# /usr/bin/find / -xdev \( -nouser -o -nogroup \) -print >> $outfile
# echo "" >> $outfile

#rename certain executables and chattr them
/bin/mv /usr/bin/gcc /usr/bin/zgcc
/usr/bin/chattr +i /usr/bin/zgcc
/bin/mv /sbin/reboot /sbin/zreboot
/usr/bin/chattr +i /sbin/zreboot
/bin/mv /sbin/shutdown /sbin/zshutdown
/usr/bin/chattr +i /sbin/zshutdown

#makes the jail. if /var/jail taken, somewhat random directory attempted to be made in hopes it doesn't exist
if [ ! -e /var/jail ]; then
	./jail_maker.sh -s /var/jail
else
	let first="$RANDOM % 100"
	let second="$RANDOM % 100"
	./jail_maker.sh -s /var/jail_${first}-${second}
fi
