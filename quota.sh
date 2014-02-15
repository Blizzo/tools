#!/bin/bash
#Setting a disk quota for a user

read -p "Please enter a user: " USER
if [ "$USER" == "" ]; then
   echo "User invalid!"
   exit
fi

#Installing quota
sudo apt-get install quota -y

#setting the quota
#softquota/blocks/softquota/inodes
setquota $USER 0 512020 0 1000 -a
