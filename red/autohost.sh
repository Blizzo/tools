#!/usr/bin/env bash
#find sites used to get packages from, then set them to 0.0.0.0 in the /etc/hosts files

#determine if redhat or debian based, then get sites based on that
if [ -f "/etc/redhat-release" ]; then
    sites="$(/usr/bin/yum repolist 2>/dev/null | fgrep '*' | awk '{print $NF}')"
elif  [ -f "/etc/debian_version" ]; then
    sites="$(/bin/grep deb /etc/apt/sources.list | grep -v '#' | awk '{print $2}' | cut -d / -f 3 | grep -oPi '\w+\.\w+$' | sort | uniq)"
else
    echo "failed host detection, not red hat or debian."
    exit -1
fi

hostsFile="/etc/hosts"
for site in "$sites"; do
    echo >> "$hostsFile"
    echo "0.0.0.0 *.${site}" >> "$hostsFile"
done
