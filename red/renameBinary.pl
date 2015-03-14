#!/usr/bin/perl
#Rename binaries to random strings

$binaryDir = 'rundir/binaries';
@chars = (a..z, A..Z, 0..9);

@binaries = `ls $binaryDir/`;

foreach (@binaries){
   chomp $_;
   $rstr = join '', map { @chars[rand @chars] } 1 .. 8;

   print "$_ changed to $rstr\n";
   system("mv $binaryDir/$_ $binaryDir/$rstr");
}

