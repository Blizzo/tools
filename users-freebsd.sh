#!/usr/bin/env bash
#edit users - change password for all users and disable other accounts

read -p -s "Enter password for all non-privileged users: " pass
users=`/bin/cat /etc/passwd | grep -o '^\w*'`
for user in $users; do
	echo "$pass" | pw usermod $user -h 0
done

echo "Be careful not to disable a useful/necessary account."
for user in $users; do
	if [ "$user" == "root" ]; then
		continue
	fi
	read -p "Do you want to disable '$user' (Y/N): " answer
	answer=`echo $answer | /usr/bin/tr '[:lower:]' '[:upper:]'`
	if [ "$answer" == "Y" -o "$answer" == "YES" ]; then
		pw usermod $user -m -s /usr/sbin/nologin
	fi
done