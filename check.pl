#!/usr/bin/perl
#Jackson Sadowski
#Directory Monitor

my $initialTime = `date +"%Y-%m-%d %T"`;
my @initialFiles = `ls -l | grep ^\- | cut -d' ' -f10`;
my @initialDirs = `ls -l | grep ^d | cut -d' ' -f9`;

chomp @initialFiles;
chomp @initialDirs;

#initializing hashes
my %files = ();
my %dirs = ();

#getting the current date of the files
foreach (@initialFiles){
   my $date = `stat -c%y $_ | cut -d. -f1 | cut -d' ' -f1-2`;
   $files{ $_ } = $date;
}

#getting the current date of the dirs
foreach (@initialDirs){
   my $date = `stat -c%y $_ | cut -d. -f1 | cut -d' ' -f1-2`;
   $dirs{ $_ } = $date;
}

#printing info
print "INITIAL = $initialTime";
while ( my ($key, $value) = each(%files) ) {
   print "FILE: $key => $value";
}

#printing files and dates
while ( my ($key, $value) = each(%dirs) ) {
   print "DIR: $key => $value";
}
