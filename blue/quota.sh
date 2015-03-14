#!/usr/bin/env bash
#Setting a disk quota for a user

#Installing quota
sudo apt-get install quota -y &

while [ true ]; do
   read -p "Please enter a user (leave blank to exit): " USER

   if [ "$USER" == "" ]; then
      echo "No user given. Bye!"
      exit 0
   fi

   #setting the quota
   #softquota/blocks/softquota/inodes
   setquota $USER 0 512020 0 1000 -a
done
