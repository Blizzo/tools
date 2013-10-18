#ssh.sh - for box with ssh service on it
#hardens the ssh config file

#disable root login 
sshfile="/etc/ssh/sshd_config"
mv $sshfile $sshfile.backup
num=`cat $sshfile | grep "PermitRootLogin" -n | cut -f1 -d:`
sed '${num}d' $sshfile
echo "" >> $sshfile
echo "PermitRootLogin no" >> $sshfile
echo "" >> $sshfile


