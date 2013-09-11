use feature ':5.10';
use strict;
use warnings;

use OpenFilesSubroutines;
use DataSortSubroutines; 
use SearchRulesSubroutines;


#Open the files you will read in from and write out to
my $infileName = getInfileNameHardcoded();
my $outfileName = getOutfileNameHardcoded(); 

open INPUTFILE, "<$infileName" or die "couldn't open $infileName\n";
open OUTPUTFILE,">$outfileName" or die "couldn't open $outfileName \n"; 



#Analyze the files to see how they should be searched
my @inputFileArray = <INPUTFILE>;

displayColumnHeaders(@inputFileArray);
say "Which column(s) contain the index values?";
my @indexValuesColumns = findMultipleColumnsConsole();
for my $value (@indexValuesColumns){ #correct for array indexing
	$value -=1;
}


displayColumnHeaders(@inputFileArray);
say "Which column contains the sequence start number?";
my $sequenceStartNumberColumn = findSingleColumnConsole();
$sequenceStartNumberColumn -=1; #correct for array indexing


displayColumnHeaders(@inputFileArray);
say "Which column contains the sequence?";
my $sequenceColumn = findSingleColumnConsole();
$sequenceColumn -=1; #correct for array indexing

#find an appropriate spacing to use for the output
my $outputSpacing = findOutputSpacing(@inputFileArray,@indexValuesColumns,$sequenceColumn,$sequenceStartNumberColumn);


#Enter the rules of the search, or load previously chosen rules
say "1 - Enter the rules of the search or 2 - Load from file";
my $enterRuleOrUseFile = <STDIN>;
my $ruleFileName;
my @rules;
if ($enterRuleOrUseFile == 1){
	#Enter the rules manually
	@rules = createRulesConsole();
	
	#Give and option to save the rules
	
}elsif ($enterRuleOrUseFile == 2){
	#Pull the Rules from a file
	$ruleFileName = getRuleFileHardcoded();
	open RULEFILE, "<$ruleFileName" or die "couldn't open $ruleFileName\n";
	@rules = <RULEFILE>;
}

my $markerLength = $rules[0];
$markerLength =~ s/\D//g;
my $markerSpacing = $markerLength + 2;

splice(@rules,0,1);

#determine which rule data you would like to display
#must be in increasing order to store properly
my @ruleDisplayNumbers = findRuleDisplayNumbersConsole(@rules);
my %outputHash;
my $count = 0;
for my $eachNumber(@ruleDisplayNumbers){
	$outputHash{$eachNumber}=$count++;
}


#determine how you should sort the data
#if $sortRuleIndex = -1 we don't sort on any rule info
my $sortRuleIndex = findSortRuleIndexConsole(@rules);


#determine if you want to search the reverse compliment sequence

#my $reverseComplimentSequence = findReverseComplimentSequenceConsole();

#if reverse compliment is necessary, lets add additional rows to the input perhaps create a new reverse compliment file


#Conduct the search

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

$headerValues = $headerValues."  "."Sequence";

print(OUTPUTFILE "$headerValues \n");
    
splice(@inputFileArray,0,1);

my @finalOutput;

#search section   
for my $eachRow (@inputFileArray){
	my @currentRow =split(/\s+/,$eachRow);
		
	
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
			
			
			$outputValues = $outputValues."  ".$sequence;
			push(@finalOutput,$outputValues);
			
			$outputValues = "";
		}
		
	}
	
	
			
}

#my @sortedFinalOutput = sort(@finalOutput);
my @sortedFinalOutput = sort( {$a <=> $b;} @finalOutput);
for my $line(@sortedFinalOutput){
    print(OUTPUTFILE "$line \n");
}

close (OUTPUTFILE);
#Output the results of the search in some format