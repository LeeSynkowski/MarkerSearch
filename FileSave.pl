#!/usr/bin/perl #-T
use strict;
use warnings;
use CGI;
use File::Basename;
use POSIX;

my $dt = POSIX::strftime( "%H %M %S", localtime());
my $home_dir = '/home/users/web/b731/ipw.baltimorebjj/public_html/cgi-bin/';
my $fileName = "$dt"."_SavedRules.txt";
my $qdl = CGI->new;

# Comment the next line if you uncomment the above line 
open(my $DLFILE, '<', "$home_dir/TempRules.txt");

print $qdl->header(-type            => 'application/x-download',
                   -attachment      => $fileName,
                   -Content_length  => -s "$home_dir/TempRules.txt");
 
binmode $DLFILE;
print while <$DLFILE>;
close ($DLFILE);
exec ('/home/users/web/b731/ipw.baltimorebjj/public_html/cgi-bin/RuleEntering.pl');