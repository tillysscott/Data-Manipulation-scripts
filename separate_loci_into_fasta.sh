#!/bin/bash


#########################################
#NOTES and the making of this script
#########################################
# separate ipyrad .loci into fasta files
## do within a for loop with list of all unique sequence ID's
#name="R100_TON-6793"

#grep "$name" ct87_13.loci | awk -v OFS='\t' '{ print $1, $2 }' | seqkit tab2fx | awk '/^>/{$0=$0"_"(++i)}1' > $name.fa
#grep lines with ID| change space separator to tab | convert to fasta | add sequential numbers to headers > write output
## this works 

# make list of unique individuals in .loci file
#grep -v "//" ct87_13.loci | awk -v OFS='\t' '{ print $1}' | sort | uniq > unique_list.txt
#grep lines without '//' (separator) | print first column | sort into order, with same next to each other | keep first instance of each string > output

#wc -l unique_list.txt #97 which is correct/expected

# remove dashes from .fa s as these represent indels and I am interested in the individuals 'true' sequence
# seqkit fx2tab $name.fa | awk -v OFS='\t' '{gsub("-", "", $2); print}' | seqkit tab2fx > ${name}_nodash.fa
# change to column format| globally sub "-" in column 2 (sequence) with "", print both columns | convert back to .fa

###########################################
### Script
###########################################

### in command line run
#conda activate seqkit

### prepare necessary files and directories
#### done on 08/05/24
#mkdir Johanna_fas
#grep -v "//" ct87_13.loci | awk -v OFS='\t' '{ print $1}' | sort | uniq > unique_list.txt

for name in $(cat unique_list.txt)
do
	grep "$name" ct87_13.loci | awk -v OFS='\t' '{ print $1, $2 }' | seqkit tab2fx | awk '/^>/{$0=$0"_"(++i)}1' > $name.fa
	seqkit fx2tab $name.fa | awk -v OFS='\t' '{gsub("-", "", $2); print}' | seqkit tab2fx > ${name}_nodash.fa
	mv $name.fa ../Johanna_fas/
done
