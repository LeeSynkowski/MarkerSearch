#!/usr/bin/perl #-T
use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use File::Basename;

$CGI::POST_MAX = 1024 * 5000; #max file size 5mb
$CGI::DISABLE_UPLOADS = 0; #1 to disable, 0 to enable

my $query = CGI->new;

unless ($CGI::VERSION >=2.47){
	error('Version of CGI.pm is too old');
}

my $upload_dir = '/home/users/web/b731/ipw.baltimorebjj/public_html/cgi-bin/';

open (TEMPINDEXFILE, ">$upload_dir/TempIndexInfo.txt") or error("Can't open/create \"$upload_dir/TempIndexInfo.txt: $!");

binmode TEMPINDEXFILE;

#get the headers of the input data
open INFILE, "<TempData.txt";
my $firstLine = <INFILE>;
my @headers = split(/\s+/,$firstLine);  
	
my @indexValuesColumns = $query->param('ColumnHeaders');
my $sequenceStartNumberColumn = $query->param('SequenceStartNumber');
my $sequenceColumn = $query->param('Sequence');

my @indexValuesNumbers;
my $sequenceStartNumber;
my $sequenceColumnNumber;

for(my $i=0;$i<scalar(@headers);$i++){
	if ($sequenceStartNumberColumn eq $headers[$i]){
		$sequenceStartNumber = $i;
	}
	if ($sequenceColumn eq $headers[$i]){
		$sequenceColumnNumber = $i;
	}
	for my $val(@indexValuesColumns){
		if ($val eq $headers[$i]){
			push(@indexValuesNumbers,$i);
		}
	}
}

#created the index file which contains the index values which will be fed into the program later
for my $value(@indexValuesNumbers){
	print (TEMPINDEXFILE "$value%");
}
print (TEMPINDEXFILE "\n$sequenceStartNumber\n$sequenceColumnNumber\n");

close TEMPINDEXFILE;

print($query->header());
print($query->start_html(-title=>'Rule File Selection'));
print($query->start_form(-action=>'RuleEntering.pl',
						 -enctyple=>'multipart/form-data'));

print $query->p("Would you like to enter the rules manually, or enter a file to upload?");
print $query->p("Please select a file to analyze: <BR> <INPUT TYPE=\"FILE\" NAME=\"rulefile\"><p> <INPUT TYPE=\"submit\" NAME=\"button\" VALUE=\"Upload File\"><p>");
print $query->p("");
print $query->submit(-name=>'button',-value=>'Enter Manually...');
print $query->end_form;

print $query->end_html;