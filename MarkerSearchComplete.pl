#!/usr/bin/perl #-T
use strict;
use warnings;
use CGI;

my $home_dir = '/home/users/web/b731/ipw.baltimorebjj/public_html/cgi-bin/';

my $query = CGI->new();

print($query->header());
print($query->start_html(-title=>'Marker Search Complete'));
print $query->p('Your Marker Search is complete! Please click the button below to download you resuls as a text file.');
print($query->start_form(-action=>'DownLoadResults.pl'));
	print $query->submit(-name=>'button',-value=>'DownLoad Results');
print $query->end_form;

print $query->end_html;
