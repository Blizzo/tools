#!/usr/bin/env bash
#startup script for freebsd
#MAKE SURE ALL THE TXT FILES ARE CORRECT
#BEFORE RUNNING THIS SCRIPT
#must be run as root
#Text files needed:
#ipfw.sh - will be a script containing the iptables rules you want

IP_ADDR=10.2.3.3
NETMASK=255.255.255.240
GATEWAY=10.2.3.0
TEAM_DNS_SRV=10.2.3.1

#if not 1 param
if [ $# -ne 1 ]
   then 
      set "em0"
      echo "expected name of main interface, but automatically assumed to be 'em0'"
fi

/sbin/ifconfig $1 down

def backup()
{
	test -d /root/stuff || mkdir /root/stuff
	cd /root/stuff
	dirs="boot bin sbin etc var root home lib usr lib64"
	for dir in $dirs; do
		/bin/tar -cjf $dir.tar.bz /$dir
		/bin/tar -rf ../notes.tar stuff/$dir.tar.bz
	done
}

outfile=info.txt #set output file

#cronjobs aka blowjob - remove cron for all users
users=`/bin/cat /etc/passwd | grep -o '^\w*'`
for user in $users; do
        crontab -r -u $user
done &> /dev/null

#destroy cron and anacron completely
/bin/chown root:wheel /etc/crontab
/bin/chmod o= /etc/crontab
/bin/mv /etc/crontab /etc/.crontab.bak
/bin/chflags schg /etc/.crontab.bak
/bin/chmod o= /usr/bin/crontab

/bin/chown root:wheel /usr/bin/crontab
/bin/chmod o= /usr/bin/crontab
/bin/chflags schg /usr/bin/crontab

if [ test -e "/etc/anacrontab" ]; then
	/bin/chown root:wheel /etc/anacrontab
	/bin/chmod o= /etc/anacrontab
	/bin/chflags schg /etc/anacrontab

	/bin/chown root:wheel /usr/sbin/anacron
	/bin/chmod o= /usr/sbin/anacron
	/bin/chflags schg /usr/sbin/anacron

	/bin/chown root:wheel /etc/anacrontab
	/bin/mv /etc/anacrontab /etc/.anacrontab.bak
	/bin/chflags schg /etc/anacrontab
fi

#handle filez
/bin/chmod ugo= /usr/bin/rlogin
/bin/chmod ugo= /usr/bin/rsh
/bin/chmod o= /usr/bin/at
/bin/chmod o= /usr/bin/atq
/bin/chmod o= /usr/bin/atrm
/bin/chmod o= /usr/bin/batch
/bin/chmod o= /etc/fstab
/bin/chmod o= /etc/ftpusers
/bin/chmod o= /etc/group
/bin/chmod o= /etc/hosts
/bin/chmod o= /etc/hosts.allow
/bin/chmod o= /etc/hosts.equiv
/bin/chmod o= /etc/hosts.lpd
/bin/chmod o= /etc/inetd.conf
/bin/chmod o= /etc/login.access
/bin/chmod o= /etc/login.conf
/bin/chmod o= /etc/newsyslog.conf
/bin/chmod o= /etc/rc.conf
/bin/chmod o= /etc/ssh/sshd_config
/bin/chmod o= /etc/sysctl.conf
/bin/chmod o= /etc/syslog.conf
/bin/chmod o= /etc/ttys

#firewall stuff
/usr/bin/service ipfw start
/bin/cp /etc/rc.conf /etc/rc.conf.bak
./ipfw.sh
echo "firewall_enable=\"YES\"" > /etc/rc.conf
echo "firewall_type=\"client\"" >> /etc/rc.conf
echo "firewall_script=\"`pwd`/ipfw.sh\"" >> /etc/rc.conf
echo "firewall_logging=\"YES\"" >> /etc/rc.conf

#other startup stuff
echo "ipv6_enable=\"NO\"" >> /etc/rc.conf
echo "inetd_enable=\"NO\"" >> /etc/rc.conf
echo "sendmail_enable=\"NONE\"" >> /etc/rc.conf
echo "portmap_enable=\"NO\"" >> /etc/rc.conf
echo "clear_tmp_enable=\"YES\"" >> /etc/rc.conf
echo "syslogd_flags=\"-ss\"" >> /etc/rc.conf
echo "icmp_drop_redirect=\"YES\"" >> /etc/rc.conf

#stop usually unnecessary services
services="cron cups samba smbd inetd portmap rsync rlogin"
for service in $services; do
	/usr/sbin/service $service stop
	echo "/usr/sbin/service $service stop" >> /usr/local/etc/rc.d/services.sh
done
chmod u+x /usr/local/etc/rc.d/services.sh

#set static ip address, gateway and DNS
/sbin/ifconfig $1 $IP_ADDR netmask $NETMASK
/sbin/route add default $GATEWAY
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf
#echo "nameserver $TEAM_DNS_SRV" >> /etc/resolv.conf

#add to startup file
echo "ifconfig_$1=\"$IP_ADDR netmask $NETMASK\"" >> /etc/rc.conf
echo "default_router=\"$GATEWAY\"" >> /etc/rc.conf

#hosts file mgmt
hosts="/etc/hosts"

/bin/chflags noschg $hosts
/bin/cp $hosts $hosts.backup
echo "127.0.0.1       localhost" > $hosts
/bin/chown root:wheel $hosts
/bin/chmod 600 $hosts
/bin/chflags schg $hosts

#remove all users but root from wheel group
users=`/bin/cat /etc/passwd | grep -o '^\w*'`
for user in $users; do
        pw groupmod wheel -d $user
done &> /dev/null

#edit sudoers
if [ test -e "/usr/local/etc/sudoers" ]; then
	/bin/mv /usr/local/etc/sudoers /usr/local/etc/.sudoers.bak
	echo " " > /usr/local/etc/sudoers
	/bin/chown root:wheel /usr/local/etc/sudoers
	/bin/chmod 000 /usr/local/etc/sudoers
	/bin/chflags schg /usr/local/etc/sudoers
fi

#bring networking back up
/sbin/ifconfig $1 up

#update
/usr/sbin/freebsd-update fetch install &disown &>.updateinfo.txt

#make chrooted jail for ssh


#Make Sure No Non-Root Accounts Have UID Set To 0
echo "Accounts with UID = 0" >> $outfile
echo `/usr/bin/awk -F: '($3 == "0") {print}' /etc/passwd` >> $outfile
echo "" >> $outfile

#all listening ports
echo "All the ports that you're listening on" >> $outfile
echo `/usr/bin/netstat -na | /usr/bin/grep -iF listen` >> $outfile
echo "" >> $outfile

#finding all of the world-writeable files
echo "All of the world-writable files" >> $outfile
echo `/usr/bin/find / -xdev -type d \( -perm -0002 -a ! -perm -1000 \) -print` >> $outfile &disown

#backup important files and directories
backup &>.backup_info.txt &disown

#rename certain executables and chattr them
/bin/mv /usr/bin/gcc /usr/bin/zgcc
/bin/chflags schg /usr/bin/zgcc
/bin/mv /sbin/reboot /sbin/zreboot
/bin/chflags schg /sbin/zreboot
/bin/mv /sbin/shutdown /sbin/zshutdown
/bin/chflags schg /sbin/zshutdown



