#!/usr/bin/env bash
#edit users - change password for all users and disable other accounts

read -s -p "Enter password for all non-privileged users: " pass
echo
read -s -p "Enter password again: " pass_two
echo

while [ "$pass" != "$pass_two" ]; do
	echo "Passwords did not match. Try again."
	read -s -p "Enter password for all non-privileged users: " pass
	echo
	read -s -p "Enter password again: " pass_two
	echo
done

for user in $(awk -F":" '{if($3>=500) print $1}' /etc/passwd); do
	echo "$user:$pass" | chpasswd
done

echo "Be careful not to disable a useful/necessary account."
users=`/bin/cat /etc/passwd | grep -o '^\w*'`
for user in $users; do
	if [ "$user" == "root" ]; then
		continue
	fi
	read -p "Do you want to disable '$user' (Y/N): " answer
	answer=`echo $answer | /usr/bin/tr '[:lower:]' '[:upper:]'`
	if [ "$answer" == "Y" -o "$answer" == "YES" ]; then
		usermod $user -s /bin/nologin
	fi
done
