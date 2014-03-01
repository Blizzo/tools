#!/bin/bash

yum install java-1.6.0-openjdk
which java
/usr/bin/java
cd
mkdir Minecraft
cd Minecraft
wget http://minecraft.net/download/minecraft_server.jar
chmod +x minecraft_server.jar
yum install screen
screen
java -Xmx1024M -Xms1024M -jar minecraft_server.jar noguiscreen -r
