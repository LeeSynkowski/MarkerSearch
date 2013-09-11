#!/usr/bin/perl #-T
use strict;
use warnings;
use CGI;
use File::Basename;
use POSIX;

my $home_dir = '/home/users/web/b731/ipw.baltimorebjj/public_html/cgi-bin/';
my $DateTime = strftime "%F %T",localtime$^T;
my $downLoadName= 'MarkerSearchResults'.$DateTime.'.txt';
my $qdl = CGI->new;

# Comment the next line if you uncomment the above line 
open(my $DLFILE, '<', "$home_dir/OutputData.txt") or die;

print $qdl->header(-type            => 'application/x-download',
                   -attachment      => $downLoadName,
                   -Content_length  => -s "$home_dir/OutputData.txt");
 
binmode $DLFILE;
print while <$DLFILE>;
close ($DLFILE);
