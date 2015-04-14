#!/usr/bin/env python
#Jackson Sadowski
#Pen Testing
#Email Scraper

from collections import OrderedDict
import urllib2
import sys
import re

#all the final emails
finalEmails = []

#grabs the content of the page
def getPageContent(url):   
   try:
      response = urllib2.urlopen(url)
      html = response.read()   
      print "Crawling " + str(url)
      return html
   #handling any error
   except:
      print "Error: URL couldn't be reached."
      return ""

#finds the urls on the page
def findUrls(html, site):
   urls = []
   matches = re.findall('<a href="[a-zA-Z0-9\.:/]+', html)

   for m in matches:
      fixed = m[9:]
      if fixed != "javascript:" and fixed != "/":
         if site in fixed:
            urls.append(fixed)
         if fixed[:1] == "/":
            urls.append(site + fixed)
   
   return urls

#regexing to find all the emails
def findEmail(html):
   emails = re.findall('[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+', html)
   
   #adding emails to list
   for addr in emails:
      finalEmails.append(addr)

#writing all of the emails to a file
def writeToFile(emailList):
   emailSet = list(set(emailList))
   fh = open('emails.txt', 'w')

   if len(sys.argv) > 2:
      for item in range(0, int(sys.argv[2])):
         fh.write(item)
         fh.write("\n")
   else:
      for item in emailSet:
         fh.write(item)
         fh.write("\n")
   
   fh.close()

def main():
   args = sys.argv
   if len(args) < 2:
      print "USAGE: scrape.py URL [Number of Emails]"
      sys.exit(1)

   print "Starting scraper..."
   domain = args[1]
   
   pageContent = getPageContent(domain)
   urls = findUrls(pageContent, domain)

   for url in urls:
      content = getPageContent(url)
      findEmail(content)

   writeToFile(finalEmails)
main()
