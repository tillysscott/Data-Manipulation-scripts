#!/bin/bash

#####################
# see ../ct87_13_outfiles/separate_loci_into_fasta.sh
####################

###################
#1) remove dashes if not already done in loop of previous step

for name in $(cat ../ct87_13_outfiles/unique_list.txt)
do
	seqkit fx2tab $name.fa | awk -v OFS='\t' '{gsub("-", "", $2); print}' | seqkit tab2fx > ${name}_nodash.fa
done


# 2) add number to individual.fa name ready for the task array
ls *_nodash.fa | cat -n | while read n f; do mv -n "$f" "${n}_${f}"; done

# 3) move to Daren Analysis directory
mv *_*_*_nodash.fa ~/sharedscratch/Test_2/cdDarenAnalysis/Pop_Bathycallisoma/ind_fa/
