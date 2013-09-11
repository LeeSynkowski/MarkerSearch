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

my $filename_characters = 'a-zA-Z0-9_.-';

my $file = $query->param("file") or error("no file selected");

#parse for correct filename
my ($filename,undef,$ext) = fileparse($file,qr{\..*});

#append extension
$filename .= $ext;

#change spaces to underscores
$filename =~ tr/ /_/;

$filename =~ s/[^$filename_characters]//g;

#satisfy taint checking
if ($filename =~ /^([$filename_characters]+)$/) {
	$filename = $1;
} else {
	error('The filename is not valid');
}

my $upload_filehandle = $query->upload("file");

open (UPLOADFILE, ">$upload_dir/TempData.txt");

binmode UPLOADFILE;
my $line;
my @inputFileArray;


while ( $line = <$upload_filehandle> ) {
	push(@inputFileArray,$line);
	print (UPLOADFILE $line);
}

close UPLOADFILE;

# Data Selection Section ------------------------------------------------------------------------

print($query->header());
print($query->start_html(-title=>'Data Selection Section'));
print($query->start_form(-action=>'RuleUpload.pl'));

my $firstLine = $inputFileArray[0];
my @headers = split(/\s+/,$firstLine);
               
print $query->h2("Check Column Headers");
print $query->p("Here are the column headers. THE SEQUENCE MUST BE IN THE RIGHT MOST COLUMN.");
print $query->p("Please ensure that each column header is correct, and click on radio button next to the sequence column.");                               
print $query->radio_group(-name=>'Sequence',-values=>[@headers]);
print $query->p("");
pop(@headers);

print $query->h2("Output Columns");
print $query->p("Select columns you would like to include in the output:");
print $query->checkbox_group(-name=>'ColumnHeaders',
                                -values=>[@headers]);
print $query->p("");                 

print $query->h2("Sequence Start Number");                               
print $query->p("Which column contains the sequence start number?");                                
print $query->radio_group(-name=>'SequenceStartNumber',-values=>[@headers,"Not Present"]);
print $query->p("");   

print $query->p("");
print $query->submit(-name=>'DataSubmit',-value=>'Submit and Continue...');

print $query->end_form;

print $query->end_html;

# Subroutine Section ---------------------------------------------------------------------------

#-----Upload Error Handling Subroutine

sub error{
	my $error = shift;
	print   $query->header(),
		$query->start_html(-title=>'Error'),
		$error,
		$query->end_html;
	exit(0);
}