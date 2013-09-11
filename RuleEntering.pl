#!/usr/bin/perl #-T
use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use File::Basename;

$CGI::POST_MAX = 1024 * 5000; #max file size 5mb
$CGI::DISABLE_UPLOADS = 0; #1 to disable, 0 to enable

my $query = CGI->new;

my $upload_dir = '/home/users/web/b731/ipw.baltimorebjj/public_html/cgi-bin/';

my $buttonValue = $query->param('button');
my @rules =();
my $rulesInput;

if ($buttonValue eq 'Enter Manually...'){
	#ensure temp rules is cleaned out and ready to go
	open(TEMPRULES, ">","$upload_dir/TempRules.txt");
	#always start the file with a given marker length the rest of the code depends on having this value first
	print TEMPRULES "markerLength%20\n";
	close(TEMPRULES);

	open(my $rulesInput, '<', "$upload_dir/TempRules.txt") or die "cannot open file $upload_dir/TempRules.txt";
	my $line;
	while($line = <$rulesInput>){
		push(@rules,$line);
	};
    close($rulesInput);
	
	
}elsif ($buttonValue eq 'Upload File'){
	#read from upload file into temp rules
	
	open(TEMPRULES, ">","$upload_dir/TempRules.txt");
	#binmode TEMPRULES;
	my $file = $query->param("rulefile") or error("no file selected");
	my $line;
	while ($line = <$file>){
		if (length($line)>5){
			push(@rules,$line);
			print TEMPRULES $line;
		}
	}
	close(TEMPRULES);
	
}elsif ($buttonValue eq 'Add Percentage Rule'){
	#compute the value of the new rule:
	my $namePercentage = $query->param('NamePercentage');
	my $percentageRelationship = $query->param('PercentageRelationship');
	my $percentage = $query->param('Percentage');
	$percentage/=100;
	#error checking 1 of 2
	my $comboletters = $query->param('ComboLetters');
	if ($comboletters =~ /[GATC]/){
	
		my $newRule ="";
	
		#use post data to append file
		open (ADDRULES,">>","$upload_dir/TempRules.txt");
		#binmode TEMPRULES;
		if ($namePercentage eq 'comboPercentage') {
			if (checkLetters($comboletters)==1){
				$newRule = $namePercentage.'%'.$percentageRelationship.'%'.$percentage.'%'.$comboletters;
				print ADDRULES "$newRule\n";
			}
		}else {
			$newRule = $namePercentage.'%'.$percentageRelationship.'%'.$percentage;
			print ADDRULES "$newRule\n";
		}
		#so we should be ready to print on the new line
		close(ADDRULES);
		
		
		open(my $rulesInput, '<', "$upload_dir/TempRules.txt") or die "cannot open file $upload_dir/TempRules.txt";
		my $line;
		while($line = <$rulesInput>){
			push(@rules,$line);
		};
	    close($rulesInput);
	} else {
		error("You must enter letters G A T or C");
	}
	
} elsif ($buttonValue eq 'Add Contains Rule'){
	#compute the value of the new rule:
	my $valueRelationship = $query->param('ValueRelationship');
	my $numberOfOccurances = $query->param('NumberOfOccurances');
	my $containsLetters = $query->param('ContainsLetters');
	if ($containsLetters=~ /[GATC]/){
		my $newRule ="";
	
		#use post data to append file
		open (ADDRULES,">>","$upload_dir/TempRules.txt");
		if (checkLetters($containsLetters)==1){
				$newRule = 'contains%'.$containsLetters.'%'.$valueRelationship.'%'.$numberOfOccurances;
				print ADDRULES "$newRule\n";
		}
	
		#so we should be ready to print on the new line
		close(ADDRULES);
	}else{
		error("You must enter letters G A T or C");
	}
	
	open($rulesInput, '<', "$upload_dir/TempRules.txt") or die "cannot open file $upload_dir/TempRules.txt";
	my $line;
	while($line = <$rulesInput>){
		push(@rules,$line);
	};
    close($rulesInput);
	
} elsif ($buttonValue eq 'Delete Last Rule'){
	#open file get list of rules
	open(my $rulesInput, '<', "$upload_dir/TempRules.txt") or die "cannot open file $upload_dir/TempRules.txt";
	my $line;
	while($line = <$rulesInput>){
		push(@rules,$line);
	};
    close($rulesInput);
	#delete last rule in the array
	if (scalar(@rules)!=1){
		pop(@rules);
	}
    #write over existing rules file
    open(TEMPRULES, ">","$upload_dir/TempRules.txt");
	#binmode TEMPRULES;

	foreach my $rule (@rules){
		print TEMPRULES $rule;
		#print TEMPRULES "\n";
	}
	close(TEMPRULES);
	   
} elsif ($buttonValue eq 'Change Marker Length'){
	#open file get list of rules
	open(my $rulesInput, '<', "$upload_dir/TempRules.txt") or die "cannot open file $upload_dir/TempRules.txt";
	my $line;
	while($line = <$rulesInput>){
		push(@rules,$line);
	};
    close($rulesInput);
    #find marker length rule and change it
    my $newMarkerLength = $query->param('markerLength');
    $rules[0] = 'markerLength%'.$newMarkerLength."\n";
    #write over existing rules file
    open(TEMPRULES, ">","$upload_dir/TempRules.txt");
	#binmode TEMPRULES;

	foreach my $rule (@rules){
		print TEMPRULES "$rule";
	}
	close(TEMPRULES);
} elsif ($buttonValue eq 'Save Rules'){
   my $downLoadName= 'MySearchRules.txt';
   	#open file get list of rules
	open($rulesInput, '<', "$upload_dir/TempRules.txt") or die "cannot open file $upload_dir/TempRules.txt";
	my $line;
	while($line = <$rulesInput>){
		push(@rules,$line);
	};
    close($rulesInput);
	   
}
#need to add change marker length

#variables section
my %namePercentageLabels = ('guaninePercentage' =>'Guanine Percentage',
							'adeninePercentage'=>'Adenine Percentage',
							'thyminePercentage'=>'Thymine Percentage',
							'cytosinePercentage'=>'Cytosine Percentage',
							'comboPercentage'=>'Combo Percentage');
my %percentageRelationshipLabels = ('greaterThan'=> 'Greater than', 
									'greaterThanOrEqualTo' =>'Greater than or Equal to', 
									'equalTo' => 'Equal to', 
									'lessThan'=> 'Less than',
									'lessThanOrEqualTo' => 'Less than or Equal to');
									
my %valueRelationshipLabels = ('atLeast'=>'At least', 'atMost'=>'At most','exactly'=>'Exactly');

my @percentages = [0..100];
my @numbers = [1..100];


#HTML Section
print($query->header());
print($query->start_html(-title=>'Rule Entering Section'));




print($query->h1('Current Rule List:'));
displayCurrentRulesHTML(\@rules);

print($query->p(""));
print($query->p(""));

#Marker Length Entering
print($query->h2('Change Marker Length:'));
	print($query->start_form(-action=>'RuleEntering.pl'));
	$query->print('Marker Length:');

	print $query->popup_menu(-name => 'markerLength',
 						  -values => @numbers);

	print $query->submit(-name=>'button',-value=>'Change Marker Length');
print $query->end_form;

print($query->p(""));
#Percentage Rule Entering
print($query->h2('Percentage Rules:'));
print($query->p('Enter a percentage rule:'));
print($query->start_form(-action=>'RuleEntering.pl'));

	print $query->popup_menu(-name => 'NamePercentage',
 						  -values => ['guaninePercentage','adeninePercentage','thyminePercentage','cytosinePercentage','comboPercentage'],
                          -labels => \%namePercentageLabels);

	print $query->popup_menu(-name => 'PercentageRelationship',
 						  -values => ['greaterThan', 'greaterThanOrEqualTo', 'equalTo', 'lessThan','lessThanOrEqualTo'],
                          -labels => \%percentageRelationshipLabels);

	print $query->popup_menu(-name => 'Percentage',
 						  -values => @percentages);

	$query->print('% use this field for combo letters->');
	print $query->textfield(-name =>'ComboLetters',-size =>5,-maxlength =>4); 
 						  
	$query->print('%');
	print $query->submit(-name=>'button',-value=>'Add Percentage Rule');
print $query->end_form;
print($query->p(""));

#Contains Rule Entering
print($query->h2('Contains Rules:'));
print($query->p('Enter a "contains" rule:'));
print($query->start_form(-action=>'RuleEntering.pl'));
	$query->print('Contains ');

	print $query->popup_menu(-name => 'ValueRelationship',
 						  -values => ['atLeast', 'atMost','exactly'],
                          -labels => \%valueRelationshipLabels);

	print $query->popup_menu(-name => 'NumberOfOccurances',
 						  -values => @numbers);

	print $query->textfield(-name =>'ContainsLetters',-size =>10,-maxlength =>20); 

	print $query->submit(-name=>'button',-value=>'Add Contains Rule');
print $query->end_form;
print($query->p(""));

#Delete Last Rule on the List
print($query->h2('Delete Last Rule:'));
$query->print('Click button to delete last rule on the list:');
print($query->start_form(-action=>'RuleEntering.pl'));
	print $query->submit(-name=>'button',-value=>'Delete Last Rule');
print $query->end_form;

#Save Rules to a file
print($query->h2('Save Rules:'));
$query->print('Save your rules to a file to expidite future searches.');
print($query->start_form(-action=>'FileSave.pl'));
	print $query->submit(-name=>'button',-value=>'Save Rules');
print $query->end_form;
print($query->p(""));
#Continue to next Section
print($query->h2('Continue to next section:'));
print($query->start_form(-action=>'OrganizeSelect.pl'));
	print $query->submit(-name=>'button',-value=>'Continue');
print $query->end_form;
print($query->p(""));
print $query->end_html;


#Subroutine Section
sub error{
	my $error = shift;
	print   $query->header(),
		$query->start_html(-title=>'Error'),
		$error,
		$query->end_html;
	exit(0);
}

sub displayCurrentRulesHTML{
	my @subRules = @{$_[0]};
	my @firstLine = split('%',$subRules[0]);
	my $markerLength = $firstLine[1];
	print($query->p("The length of the marker is $markerLength"));
	shift(@subRules);
	for my $eachRule(@subRules){
		displayRule($eachRule);
	}
}

sub displayRule{
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
	print($query->p("$displayString"));
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

sub checkLetters{
	my $word = $_[0];
	if ($word =~ m/[^GATC]/){
		return -1;
	}
	return 1;
}