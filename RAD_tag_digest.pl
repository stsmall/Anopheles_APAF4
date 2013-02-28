use strict;
 
die "needs commandline arguments 'perl oldskool.pl FILENAME --option'\n",
"where --option is either '--size MIN MAX' or '--rad SIZE'\n" unless $ARGV[1] && $ARGV[0];
 
open FILE, "<$ARGV[0]" or die "can't open the file, bozo!\n";
 
my $csome=0; 
my $counter=0;
my $piece="";
 
while(<FILE>){
 
 
	if ( $_=~m/^\>/ ){ $csome++; } #change csomes each time you see a ">" in the genome sequence
	else{
		chomp $_;	
 
		#concatenate each line
		$piece.=$_;
 
		#if piece has the cutsite
		if($piece=~m/GCAGC\w{8}/){
			#define $cut as everything up to the cutsite		
			$piece=~m/(\w*GCAGC\w{8})?(\w+)/;	
			my $cut = $1; $piece=$2;
 
			#if using the size selection option, prints out digested regions that are <MAX and >MIN in size
			if( $ARGV[1] eq "--size"){  
				print ">", $csome, "_", $counter, "_", length($cut), "\n$cut\n" if length($cut) < $ARGV[3] && length($cut) > $ARGV[2];
			}	
			#if using the RAD option, adds a barcode AAATTTCCCGGG to both ends and write SIZE of sequence from each end to file
			elsif( $ARGV[1] eq "--rad"){
				my $size=$ARGV[2];
				#this if required because maq fails if the region is smaller than 2*distance
				if (length($cut)< $size && length($cut)>0 ){
					my $x = $size/2 > $size - 2*length($cut) ? $size/2 : $size - 2*length($cut);
					print ">", $csome, "_", $counter, "_", length($cut), "_all\nAAATTTCCCGGG";  
					print $cut;
					for( 1 .. $x){ print "X"; }; 
					print $cut, "AAATTTCCCGGG\n";
				}
				elsif( length($cut)>0 ){
					print ">", $csome, "_", $counter, "_", length($cut), "_start\nAAATTTCCCGGG", substr($cut, 0, $size), "\n";
					print ">", $csome, "_", $counter, "_", length($cut), "_end\n", substr($cut, -$size, $size), "AAATTTCCCGGG\n";
				}
			}	
			#keep track of where we are in the genome
			$counter+=length($cut);	
		}
	}
}
