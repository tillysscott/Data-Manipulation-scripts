#!/bin/bash


module load seqtk
PATH=$PATH:~/sharedscratch/apps/datamash-1.3/

export species="Parhyale_hawaiensis"
# calculate the length of the genome sequence in the FASTA
allLen=`seqtk comp ${species}.fa | datamash sum 2`;
# calculate the length of the N sequence in the FASTA
nLen=`seqtk comp ${species}.fa | datamash sum 9`;

# tabulate repeats per subfamily with total bp and proportion of genome masked
# info on what the below code does HERE:
#cat 05_full_out/${species}.full_mask.out | tail -n +4 | # print .out starting at line 4 (start of table)
#	awk -v OFS="\t" '{ print $6, $7, $11 }' | #print coluns 6 7 and 11, begin and end positions and repeat class/family
#	awk -F '[\t/]' -v OFS="\t" '{ if (NF == 3) print $3, "NA", $2 - $1 +1; else print $3, $4, $2 - $1 +1 }' |
#	#if there are 3 cols, print: $3, NA, and length. If 4 cols print $3, $4, and length. This deals with TEs that have a class, superfamil and family
#	datamash -sg 1,2 sum 3 | #sort and group by $1 then $2, then sum $3
#		grep -v "\?" | #grep lines that don't have a ? Abyssorchomene doesn't have any
#		awk -v OFS="\t" -v genomeLen="${allLen}" '{ print $0, $3 / genomeLen }' \ #create v(ariable) genomeLen, print all rows ($0), calculate %
#       	> 05_full_out/${species}.full_mask.tabulate

#awk -F field separator set as tab
#awk -v assign value?
#OFS set output field separator 
#NF is a predefined variable whose value is the number of fields in the current record

#step 1 : manually fix orders in .tabulate file

#step 2 : calculate bp per order and % sequence
cat 05_full_out/${species}.full_mask.tabulate | awk -v OFS="\t" '{ print $1, $2, $3 }' | 
	datamash -sg 1 sum 3 | grep -v "\?" | 
	awk -v OFS="\t" -v genomeLen="${allLen}" '{ print $0, ($2 / genomeLen)*100 }' \
	> 05_full_out/${species}_orders.full_mask.tabulate
