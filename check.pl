#!/usr/bin/perl
#Jackson Sadowski
#Directory Monitor

my $initialTime = `date +"%Y-%m-%d %T"`;
my @initialFiles = `ls -1 --file-type | grep -v '/' | sed s/@\$//`;
my @initialDirs = `ls -l | grep ^d | cut -d' ' -f9`;

chomp @initialFiles;
chomp @initialDirs;

#initializing hashes
my %files = ();
my %dirs = ();
my $date;

#getting the current date of the files
foreach (@initialFiles){
   $date = `stat -c%y $_ | cut -d. -f1`;
   $files{ $_ } = $date;
}

#getting the current date of the dirs
foreach (@initialDirs){
   $date = `stat -c%y $_ | cut -d. -f1`;
   $dirs{ $_ } = $date;
}

#continually checks to see if files have changes
while(1){
   my @currentFiles = `ls -1 --file-type | grep -v '/' | sed s/@\$//`;
   my @currentDirs = `ls -l | grep ^d | cut -d' ' -f9`;
   chomp @currentFiles;
   chomp @currentDirs;

   #making new hash for current files/dir
   #initializing hashes
   my %newFiles = ();
   my %newDirs = ();

   #getting the current date of the files
   foreach (@currentFiles){
      $date = `stat -c%y $_ | cut -d. -f1`;
      $newFiles{ $_ } = $date;
   }

   #getting the current date of the dirs
   foreach (@currentDirs){
      $date = `stat -c%y $_ | cut -d. -f1`;
      $newDirs{ $_ } = $date;
   }
   
   #at this point we should check if
   #the arrays of hashes are the same
   #alert if there's a change
   #log the file

   #sleeping
   sleep(2);
}
