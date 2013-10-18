#ssh.sh - for box with ssh service on it
#hardens the ssh config file

#store sshd config file location and back it up before changing it
sshfile="/etc/ssh/sshd_config"
mv $sshfile $sshfile.backup

#disable root login
num=`cat $sshfile | grep "PermitRootLogin" -n | cut -f1 -d:`
sed '${num}d' $sshfile
echo "" >> $sshfile
echo "PermitRootLogin no" >> $sshfile
echo "" >> $sshfile


