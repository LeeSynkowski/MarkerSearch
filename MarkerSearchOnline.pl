#!/usr/bin/perl #-T
use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use File::Basename;

my $query = CGI->new;

my $upload_dir = '/home/users/web/b731/ipw.baltimorebjj/public_html/cgi-bin/';


open INDEXFILE, "<$upload_dir/TempIndexInfo.txt";

my $line = <INDEXFILE>;
my @indexValuesColumns = split('%',$line);

$line = <INDEXFILE>;
chomp($line);
my $sequenceStartNumberColumn = $line;

$line = <INDEXFILE>;
chomp($line);
my $sequenceColumn = $line;

close INDEXFILE;







open(my $rulesInput, '<', "$upload_dir/TempRules.txt") or die "cannot open file $upload_dir/TempRules.txt";
my @rules = ();
while($line = <$rulesInput>){
	push(@rules,$line);
};
close($rulesInput);
	
my @lengthArray = split('%',$rules[0]);
my $markerLength = $lengthArray[1];
my $markerSpacing = $markerLength + 2;

shift(@rules);


my @ruleDisplayNumbers = $query->param('DisplayRules');
my %outputHash;
my $count = 0;
for my $eachNumber(@ruleDisplayNumbers){
	$outputHash{$eachNumber}=$count++;
}

my $sortRuleIndex = $query->param('SortRuleNumber');
my $reverseComplimentSequence = $query->param('IncludeReverseCompliment');


open INPUTFILE, "<$upload_dir/TempData.txt";
my @inputFileArray = <INPUTFILE>;
#find an appropriate spacing to use for the output
my $outputSpacing = 20;



#Search Starts Here ______________________________________________________________________

#get the headers

#write the column headers to file and then remove that line from the array
my $numberOfIndexValues = @indexValuesColumns;

my @headerRow = split(/\s+/,$inputFileArray[0]);
my $headerValues = "";

#insert the outputed sort index here if applicable
if ($sortRuleIndex!=-1){
	$headerValues = $headerValues.sprintf("%-${outputSpacing}s",findRuleHeader($sortRuleIndex,\@rules));
}

for (my $i=0;$i<$numberOfIndexValues;$i++){
	$headerValues = $headerValues.sprintf("%-${outputSpacing}s",$headerRow[$indexValuesColumns[$i]]);
}

$headerValues = $headerValues.sprintf("%-${markerSpacing}s","Marker");
	
if ($sequenceStartNumberColumn>-1){
	$headerValues = $headerValues.sprintf("%-${outputSpacing}s","Marker Location");
	$headerValues = $headerValues.sprintf("%-${outputSpacing}s","Sequence Start Number");
}

#insert the outputed rules info here if applicable
for my $ruleDisplayValue(@ruleDisplayNumbers){
	$headerValues = $headerValues.sprintf("%-${outputSpacing}s",findRuleHeader($ruleDisplayValue,\@rules));
}

#removing the sequence in the output
#$headerValues = $headerValues."  "."Sequence";


    
shift(@inputFileArray);

my @finalOutput;

#search section   

#debugging
#my $i=0;

for my $eachRow (@inputFileArray){
	my @currentRow =split(/\s+/,$eachRow);	

	#debugging
	#print(OUTPUTFILE "section 1 $i sequence column $sequenceColumn\n");
	
	my $indexValues = "";
	my $outputValues = "";
	
	for (my $i=0;$i<$numberOfIndexValues;$i++){
		$indexValues = $indexValues.sprintf("%-${outputSpacing}s",$currentRow[$indexValuesColumns[$i]]);
	}
		
	my $sequence = $currentRow[$sequenceColumn];
	$sequence =~ tr/a-z/A-Z/;
	

	
	my $sequenceStartNumber;
	my $reverseSequenceStartNumber;
	
	if ($sequenceStartNumberColumn>-1){
		$sequenceStartNumber = $currentRow[$sequenceStartNumberColumn];
	}
	
	for (my $sequenceIndex=0;$sequenceIndex<(length($sequence)-$markerLength);$sequenceIndex++){
		my $currentMarker = substr($sequence,$sequenceIndex,$markerLength);
		my $currentMarkerLocation = 0;
		
			
		if ($sequenceStartNumberColumn>-1){
			$currentMarkerLocation = $sequenceStartNumber + $sequenceIndex;
		}
		
		my @rulesOutput;
		my $metRules = 1;
		for my $eachRule(@rules){
			if (followsRule($eachRule,$currentMarker)!=1){
				$metRules = -1;
			}
			push(@rulesOutput,getRuleResult($eachRule,$currentMarker));			

		}
		
		
		
		if ($metRules==1){
			#insert the outputed sort index here if applicable (add before the index values)
			###################################################
			if ($sortRuleIndex!=-1){
				$outputValues = $outputValues.sprintf("%-${outputSpacing}s",getRuleResult($rules[$sortRuleIndex],$currentMarker));
			}
			
			$outputValues = $outputValues.$indexValues.sprintf("%-${markerSpacing}s",$currentMarker);
					
			if ($sequenceStartNumberColumn>-1){
				$outputValues = $outputValues.sprintf("%-${outputSpacing}s",$currentMarkerLocation);
				$outputValues = $outputValues.sprintf("%-${outputSpacing}s",$currentRow[$sequenceStartNumberColumn]);
			}
			#insert the outputed rules info here if applicable
			for my $ruleOutputValue(@ruleDisplayNumbers){
				$outputValues = $outputValues.sprintf("%-${outputSpacing}s",$rulesOutput[$ruleOutputValue]);
			}
			
			#removing sequence from the output
			#$outputValues = $outputValues."  ".$sequence;
			$outputValues = $outputValues;
			push(@finalOutput,$outputValues);			
			#print(OUTPUTFILE "$outputValues\r\n");
			$outputValues = "";
		}
		
	}
	
	#debugging
	#$i++;		
}

#my @sortedFinalOutput = sort( {$a <=> $b;} @finalOutput); #numberical
my @sortedFinalOutput = sort { lc($a) cmp lc($b) } @finalOutput; #alphabetical

open OUTPUTFILE,">$upload_dir/OutputData.txt";
print(OUTPUTFILE "$headerValues \r\n");
for my $line(@sortedFinalOutput){
    print(OUTPUTFILE "$line \r\n");
}
close (OUTPUTFILE);

print($query->header());
print($query->start_html(-title=>'Marker Search Complete'));
print $query->h2("Marker Search Complete");
print $query->p('Your Marker Search is complete! Please click the button below to download you resuls as a text file.');
print($query->start_form(-action=>'DownLoadResults.pl'));
	print $query->submit(-name=>'button',-value=>'Download Results');
print $query->end_form;
print $query->p("");
print $query->a({-href=>"http://www.baltimorebjj.com/cgi-bin/demo.html"}, "Return to Marker Search Start");
print $query->end_html;





#Subroutine Section ___________________________________________________________________________

sub followsRule{
	my $rule = $_[0];
	my $sequence = $_[1];
	my @ruleComponents = split("%",$rule);
	
	if ($ruleComponents[0] eq "guaninePercentage"){
		
		my $guaninePercentage = countAllOccurences($sequence,"G") / length($sequence);
		return meetsBooleanCondition($guaninePercentage,$ruleComponents[1],$ruleComponents[2]);
		
	} elsif ($ruleComponents[0] eq "adeninePercentage"){
				
		my $adeninePercentage = countAllOccurences($sequence,"A") / length($sequence);
		return meetsBooleanCondition($adeninePercentage,$ruleComponents[1],$ruleComponents[2]);
		
	} elsif ($ruleComponents[0] eq "thyminePercentage"){
		
		my $thyminePercentage = countAllOccurences($sequence,"T") / length($sequence);
		return meetsBooleanCondition($thyminePercentage,$ruleComponents[1],$ruleComponents[2]);
		
	} elsif ($ruleComponents[0] eq "cytosinePercentage"){

		my $cytosinePercentage= countAllOccurences($sequence,"C") / length($sequence);
		return meetsBooleanCondition($cytosinePercentage,$ruleComponents[1],$ruleComponents[2]);
		
	} elsif ($ruleComponents[0] eq "comboPercentage"){
			
		my $comboPercentage = 0;
		
		if (index($ruleComponents[3],"G")!=-1){
			$comboPercentage += countAllOccurences($sequence,"G") / length($sequence);
		}
		if (index($ruleComponents[3],"A")!=-1){
			$comboPercentage += countAllOccurences($sequence,"A") / length($sequence);
		}
		if (index($ruleComponents[3],"T")!=-1){
			$comboPercentage += countAllOccurences($sequence,"T") / length($sequence);
			
		}
		if (index($ruleComponents[3],"C")!=-1){
			$comboPercentage += countAllOccurences($sequence,"C") / length($sequence);
		}
		
        return meetsBooleanCondition($comboPercentage,$ruleComponents[1],$ruleComponents[2]);
		
	} elsif ($ruleComponents[0] eq "contains"){
		my $occurences = countAllOccurences($sequence,$ruleComponents[1]);
		if ($ruleComponents[2] eq "atLeast"){
			return meetsBooleanCondition($occurences,"greaterThanOrEqualTo",$ruleComponents[3]);
		} elsif ($ruleComponents[2] eq "atMost"){
			return meetsBooleanCondition($occurences,"lessThanOrEqualTo",$ruleComponents[3]);
		} elsif ($ruleComponents[2] eq "exactly"){
			return meetsBooleanCondition($occurences,"equalTo",$ruleComponents[3]);
		}
	}
	return -1;
}


#Counts all occurences of a given string within a larger string
#Call it as countAllOccurences(string to look through,string to find)
#returns number of times string occurs
sub countAllOccurences{
  my $string = $_[0];
  my $char = $_[1];
  my $offset = 0;
  my $count = 0;

  my $result = index($string, $char, $offset);

  while ($result != -1) {
    $count++;
    $offset = $result + 1;
    $result = index($string, $char, $offset);
  }
  return $count;
}


#Tests if the given numbers match a given boolean condition, spelled out at a string.  Returns 1 if true, -1 otherwise
#call as meetsBooleanCondition(first number, condition as string, second number)
sub meetsBooleanCondition{
	my $firstNumber = $_[0];
	my $condition = $_[1];
	my $secondNumber = $_[2];
	
	if ($condition eq "greaterThan"){
		if ($firstNumber>$secondNumber){
			return 1;
		}
		
	} elsif ($condition eq "greaterThanOrEqualTo"){
		if ($firstNumber>=$secondNumber){
			return 1;
		}
		
	} elsif ($condition eq "equalTo"){
		if ($firstNumber==$secondNumber){
			return 1;
		}
		
	} elsif ($condition eq "lessThan"){
		if ($firstNumber<$secondNumber){
			return 1;
		}
		
	} elsif ($condition eq "lessThanOrEqualTo"){
	    if ($firstNumber<$secondNumber){
			return 1;
		}
	} 
	
	return -1;
}

#takes a rule and the currrent marker and returns the appropriate data 
#getRuleResult(rule,marker);
sub getRuleResult{
	my $rule = $_[0];
	my $sequence = $_[1];
	my @ruleComponents = split("%",$rule);
	
	if ($ruleComponents[0] eq "guaninePercentage"){
		
		return countAllOccurences($sequence,"G") / length($sequence);
		
	} elsif ($ruleComponents[0] eq "adeninePercentage"){
				
		return countAllOccurences($sequence,"A") / length($sequence);
		
	} elsif ($ruleComponents[0] eq "thyminePercentage"){
		
		return countAllOccurences($sequence,"T") / length($sequence);
		
	} elsif ($ruleComponents[0] eq "cytosinePercentage"){

		return countAllOccurences($sequence,"C") / length($sequence);
		
	} elsif ($ruleComponents[0] eq "comboPercentage"){
			
		my $comboPercentage = 0;
		
		if (index($ruleComponents[3],"G")!=-1){
			$comboPercentage += countAllOccurences($sequence,"G") / length($sequence);
		}
		if (index($ruleComponents[3],"A")!=-1){
			$comboPercentage += countAllOccurences($sequence,"A") / length($sequence);
		}
		if (index($ruleComponents[3],"T")!=-1){
			$comboPercentage += countAllOccurences($sequence,"T") / length($sequence);
			
		}
		if (index($ruleComponents[3],"C")!=-1){
			$comboPercentage += countAllOccurences($sequence,"C") / length($sequence);
		}
		
        return $comboPercentage;
		
	} elsif ($ruleComponents[0] eq "contains"){
		
		return countAllOccurences($sequence,$ruleComponents[1]);
	}	
	
}


#translates stored rule value to appropriate rule header string
sub findRuleHeader{
	my $ruleNumber = $_[0];
	my @rules = @{$_[1]};
	my $desiredRule = $rules[$ruleNumber];
	my @ruleComponents = split("%",$desiredRule);
	
	if ($ruleComponents[0] eq "guaninePercentage"){
		
		return "Guanine Percentage";
		
	} elsif ($ruleComponents[0] eq "adeninePercentage"){
				
		return "Adenine Percentage";
		
	} elsif ($ruleComponents[0] eq "thyminePercentage"){
		
		return "Thymine Percentage"
		
	} elsif ($ruleComponents[0] eq "cytosinePercentage"){

		return "Cytosine Percentage"
		
	} elsif ($ruleComponents[0] eq "comboPercentage"){
			
        return "Combo Percentage";
		
	} elsif ($ruleComponents[0] eq "contains"){
		return $ruleComponents[1]." Count";
	}
}