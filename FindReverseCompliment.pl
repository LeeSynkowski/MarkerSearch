my $infileName = "NeuronSequences.txt";

open INPUTFILE, "<$infileName" or die ;
open OUTPUTFILE, ">NeuronSequencesReverseCompliment.txt" or die;

my @inputArray = <INPUTFILE>;

close INPUTFILE;
print OUTPUTFILE $inputArray[0];

shift(@inputArray);

foreach my $line(@inputArray){
	my @lineElements = split(/\s+/,$line);
	my $sequence = $lineElements[7];
	$sequence = findReverseCompliment($sequence);
	$lineElements[7] = $sequence;
	my $finalLine = join('     ',@lineElements);
	print OUTPUTFILE "$finalLine\n";
}

close OUTPUTFILE;

sub findReverseCompliment{
	my $ret = reverse($_[0]);
	$ret =~ tr/ACGT/TGCA/;
	return $ret; 
}