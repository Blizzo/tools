#MAKE SURE ALL THE TXT FILES ARE CORRECT
#BEFORE RUNNING THIS SCRIPT
#Text files needed:
#iptables.sh - will be a script containing the iptables rules you want
#netconfig.txt - containing the interface config
#
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
ifconfig down $1

outfile=info.txt

#cronjobs aka blowjob
crontab -r

#getting all the ip tables rules
./iptables.sh

#set static ip address and do network interface config stuff
netconfig="/etc/network/interfaces"

cp $netconfig $netconfig.backup
cat netconfig.txt > $netconfig

#set hosts file location and do hosts file stuff
hosts="/etc/hosts"

cp $hosts $hosts.backup
echo "127.0.0.1       localhost" > $hosts
echo "127.0.1.1       `hostname`" >> $hosts
chattr +i $hosts
chmod 600 $hosts

#linux kernel hardening - /etc/sysctl.conf - ask buie/joe

#disk quotas

#put the interface back up
ifconfig up $1

#upgrading and updating everything
apt-get update &
apt-get upgrade -y &

#makes the jail
./jail_maker.sh -s /var/jail &

#Make Sure No Non-Root Accounts Have UID Set To 0
echo "Accounts with UID = 0" >> $outfile
echo `awk -F: '($3 == "0") {print}' /etc/passwd` >> $outfile
echo "" >> $outfile

#echo the sudoers file
echo "What is in the sudoers file"
cat /etc/sudoers >> $outfile

#all listening ports
echo "All the ports that you're listing on" >> $outfile
echo `lsof -nPi | grep -iF listen` >> $outfile
echo "" >> $outfile

#finding all of the world-writeable files
echo "All of the world-writable files" >> $outfile
find /dir -xdev -type d \( -perm -0002 -a ! -perm -1000 \) -print >> $outfile
echo "" >> $outfile

#finding all of the no owner files
echo "All of the no owner files" >> $outfile
find /dir -xdev \( -nouser -o -nogroup \) -print >> $outfile
echo "" >> $outfile

#prompt for ssh box
read -p "is this an ssh box (Y/N): " answer
answer=`echo $answer | tr '[:lower:]' '[:upper:]'`
if [ "$answer" == "Y" ]; then
	./ssh.sh &
fi

#prompt for web box




