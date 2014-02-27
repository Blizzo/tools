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

#if not 1 param
if [ $# -ne 1 ]
   then 
      set "em0"
      echo "expected name of main interface, but automatically assumed to be 'eth0'"
fi

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
lines=`/bin/cat /etc/passwd | grep -o '^\w*'`
for line in $lines; do
        crontab -r -u $line
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

	/bin/chown root:root /usr/sbin/anacron
	/bin/chmod o= /usr/sbin/anacron
	/bin/chflags schg /usr/sbin/anacron

	/bin/chown root:wheel /etc/anacrontab
	/bin/mv /etc/anacrontab /etc/.anacrontab.bak
	/bin/chflags schg /etc/anacrontab
fi

#handle filez
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





