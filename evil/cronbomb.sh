#!/usr/bin/env bash
bomb= # this will be your bomb you want in the crontab
echo "@reboot $bomb"|crontab
