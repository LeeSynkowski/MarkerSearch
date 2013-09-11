#!/usr/bin/perl #-T
use strict;
use warnings;
use CGI;

use File::Basename;


my $upload_dir = '/home/users/web/b731/ipw.baltimorebjj/public_html/cgi-bin/';

my $query = CGI->new;

#Open file of rules and create a % with the appropriate headers
my @rules=();
open(my $rulesInput, '<', "$upload_dir/TempRules.txt") or die "cannot open file $upload_dir/TempRules.txt";
my $line;
while($line = <$rulesInput>){
	push(@rules,$line);
};
close($rulesInput);
shift(@rules);

my @ruleStrings = ();
foreach my $rule(@rules){
	my $ruleString = getRuleString($rule);
	push (@ruleStrings,$ruleString);
}

my @ruleNumbers = [0..(scalar(@ruleStrings)-1)];

my %ruleLabels = {};

for (my $i=0;$i!=scalar(@ruleStrings);$i++){
	$ruleLabels{"$i"}=$ruleStrings[$i];
}

$ruleLabels{'-1'}='Do not sort.';

#display the html, its a form
print($query->header());
print($query->start_html(-title=>'Data Selection Section'));

print($query->start_form(-action=>'MarkerSearchOnline.pl'));
print $query->h2("Sort Selection");
print $query->p("Which rule would you like to sort by:");                                
print $query->radio_group(-name=>'SortRuleNumber',-values=>[0..(scalar(@ruleStrings)-1),-1],-linebreak=>'true',-labels=>\%ruleLabels);
              
print $query->p("");
print $query->h2("Report Data");
print $query->p("Which rule data would you like to include include in the final report:");
print $query->checkbox_group(-name=>'DisplayRules',-values=>[0..(scalar(@ruleStrings)-1)],-linebreak=>'true',-labels=>\%ruleLabels);

print $query->submit(-name=>'OrganizeSubmit',-value=>'Continue');

print $query->end_form;

print $query->end_html;


sub getRuleString{
	my $rule = $_[0];
	my @ruleComponents = split("%",$rule);
	my $displayString ="";
	
	if ($ruleComponents[0] eq "guaninePercentage"){
		$displayString = 'Guanine Percentage ';
		$displayString = $displayString.translate($ruleComponents[1]);
		my $percentage = $ruleComponents[2] * 100;
		$displayString = $displayString." $percentage percent";
		
	} elsif ($ruleComponents[0] eq "adeninePercentage"){
		$displayString = 'Adenine Percentage ';
		$displayString = $displayString.translate($ruleComponents[1]);
		my $percentage = $ruleComponents[2] * 100;
		$displayString = $displayString." $percentage percent";	
		
	} elsif ($ruleComponents[0] eq "thyminePercentage"){
		$displayString = 'Thymine Percentage ';
		$displayString = $displayString.translate($ruleComponents[1]);
		my $percentage = $ruleComponents[2] * 100;
		$displayString = $displayString." $percentage percent";
		
	} elsif ($ruleComponents[0] eq "cytosinePercentage"){
		$displayString = 'Cytosine Percentage ';
		$displayString = $displayString.translate($ruleComponents[1]);
		my $percentage = $ruleComponents[2] * 100;
		$displayString = $displayString." $percentage percent";
		
	} elsif ($ruleComponents[0] eq "comboPercentage"){
		$displayString = 'Combination Percentage of '."$ruleComponents[3] ";
		$displayString = $displayString.translate($ruleComponents[1]);
		my $percentage = $ruleComponents[2] * 100;
		$displayString = $displayString." $percentage percent";
		
	} elsif ($ruleComponents[0] eq "contains"){
		$displayString = "Contains ".translate($ruleComponents[2])." $ruleComponents[3] ";
		$displayString = $displayString." $ruleComponents[1]";
	}
	return $displayString;
}




sub translate{
	if ($_[0] eq "greaterThan"){
		return " greater than ";
	} elsif ($_[0] eq "greaterThanOrEqualTo"){
		return " greater than or equal to ";
	} elsif ($_[0] eq "equalTo"){
		return " equal to ";
	} elsif ($_[0] eq "lessThan"){
		return " less than ";
	} elsif ($_[0] eq "lessThanOrEqualTo"){
		return " less than or equal to ";
	} elsif ($_[0] eq "atLeast"){
		return " at least ";
	} elsif ($_[0] eq "atMost"){
		return " at most ";
	}elsif ($_[0] eq "exactly"){
		return " exactly ";
	}
	return "";
}