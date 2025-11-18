#!/bin/bash

##################################
# Take the output of RepeatMasker, run as a task array with one array per individual, filter TE hits keeping only those that start at the start and/or end at the end of the loci, and then calculate the percentage of loci (contigs) with a repeat, and the percentage of repeat loci with a repeat order.
# individuals are named 1:97, listed in numbers.txt
##################################

# there is a steep drop off in the number of TE that start after position 1 (104-->18-->12) and end before position 0 (157-->33) in the RADseq
# curves of counts are plotted in Maxwell_1/MinION/Pop_Bathy_TEprediciton/Start_at_start_end_at_end_counts.xlsx : evidences that cut offs ok.
## tail -n +4 2/05_full_out/2.full_mask.out | awk '{print $6}' | sort | uniq -c
## tail -n +4 2/05_full_out/2.full_mask.out | sed 's/(//g'| sed 's/)//g' | awk '{print $8}' | sort | uniq -c

# count data
for num in $(cat numbers.txt)
do
	cat $num/05_full_out/$num.full_mask.out | tail -n +4 | sed 's/[()]//g' | awk '$6 == 1 || $8 == 0' > $num/05_full_out/$num.full_mask.or.out
	ls $num/$num_*.fa >> name_or.txt
	grep -c ">" $num/$num_*.fa >> total_loci_or.txt
	grep "LINE" $num/05_full_out/$num.full_mask.or.out | awk '{print $5}' | sort | uniq | wc -l >> LINE_or.txt
	grep "SINE" $num/05_full_out/$num.full_mask.or.out | awk '{print $5}' | sort | uniq | wc -l >> SINE_or.txt
	grep "LTR" $num/05_full_out/$num.full_mask.or.out | awk '{print $5}' | sort | uniq | wc -l >> LTR_or.txt
	grep "DNA" $num/05_full_out/$num.full_mask.or.out | awk '{print $5}' | sort | uniq | wc -l >> DNA_or.txt
	grep "RC" $num/05_full_out/$num.full_mask.or.out | awk '{print $5}' | sort | uniq | wc -l >> RC_or.txt
	grep "Crypton" $num/05_full_out/$num.full_mask.or.out | awk '{print $5}' | sort | uniq | wc -l >> Crypton_or.txt
	grep "Maverick" $num/05_full_out/$num.full_mask.or.out | awk '{print $5}' | sort | uniq | wc -l >> Maverick_or.txt
	grep "Unknown" $num/05_full_out/$num.full_mask.or.out | awk '{print $5}' | sort | uniq | wc -l >> Unknown_or.txt
	tail -n +4 $num/05_full_out/$num.full_mask.or.out | grep -v "Simple" | grep -v "Low" | awk '{print $5}' | sort | uniq | wc -l >> TE_or.txt
	grep "Penelope" $num/05_full_out/$num.full_mask.or.out | awk '{print $5}' | sort | uniq | wc -l >> Penelope_or.txt
	grep "DIRS" $num/05_full_out/$num.full_mask.or.out | awk '{print $5}' | sort | uniq | wc -l >> DIRS_or.txt
	tail -n +4 $num/05_full_out/$num.full_mask.or.out | grep -v "Simple" | grep -v "Low" | awk '{print $5}' > $num/05_full_out/$num.list_TE_or.txt
	grep "Simple_repeat" $num/05_full_out/$num.full_mask.out | awk '{print $5}' > $num/05_full_out/$num.list_simplerep.txt
	grep "Low_complexity" $num/05_full_out/$num.full_mask.out | awk '{print $5}'  > $num/05_full_out/$num.list_lowcomp.txt
	cat $num/05_full_out/$num.list_TE_or.txt $num/05_full_out/$num.list_simplerep.txt $num/05_full_out/$num.list_lowcomp.txt | sort | uniq | wc -l >> total_repeats_or.txt
	cat $num/05_full_out/$num.list_simplerep.txt $num/05_full_out/$num.list_lowcomp.txt | sort | uniq | wc -l >> total_simple_repeats.txt
done

# combine data
#outside of loop
paste name_or.txt \
	total_loci_or.txt \
	LINE_or.txt \
	SINE_or.txt \
	LTR_or.txt \
	DNA_or.txt \
	RC_or.txt \
	Maverick_or.txt \
	Crypton_or.txt \
	Unknown_or.txt \
	Low_complexity.txt \
	Simple_repeat.txt \
	TE_or.txt \
	Penelope_or.txt \
	DIRS_or.txt \
	total_repeats_or.txt \
	total_simple_repeats.txt > all_data_or.txt

# percentage of all loci that contain a TE order
awk '{print $1, (($3-$14)/$2)*100, ($4/$2)*100, ($14/$2)*100 , (($5-$15)/$2)*100, ($15/$2)*100 , (($6-$8-$9)/$2)*100, ($7/$2)*100, ($8/$2)*100, ($9/$2)*100, ($10/$2)*100, ($11/$2)*100, ($12/$2)*100, ($13/$2)*100, (($17)/$2)*100, (($16)/$2)*100 }' \
	all_data_or.txt > te_over_loci_or.tbl

echo file LINE SINE Penelope LTR DIRS TIR Helitron Maverick Crypton Unknown Low_complexity Simple_repeat Total_TE Total_SR Total_Repeats > header_or.txt

cat header_or.txt te_over_loci_or.tbl > Percentage_Loci_Matrix_or.tbl

# percentage of total contigs with a repeat that contain a repeat order
awk '{print $1, (($3-$14)/($16))*100, ($4/($16))*100, ($14/($16))*100, (($5-$15)/($16))*100, ($15/($16))*100, (($6-$8-$9)/($16))*100, ($7/($16))*100, ($8/($16))*100, ($9/($16))*100, ($10/($16))*100, ($11/($16))*100, ($12/($16))*100, ($13/($16))*100, (($17)/($16))*100 }' \
        all_data_or.txt > percent_of_repeats_or.tbl

cat header_or.txt percent_of_repeats_or.tbl > Percent_Total_Reapeat_Matrix_or.tbl

# percent of total contigs with a TE that contain a TE order
awk '{print $1, (($3-$14)/($13))*100, ($4/($13))*100, ($14/($13))*100, (($5-$15)/($13))*100, ($15/($13))*100, (($6-$8-$9)/($13))*100, ($7/($13))*100, ($8/($13))*100, ($9/($13))*100, ($10/($13))*100}' \
        all_data_or.txt > te_over_te_or.tbl

echo file LINE SINE Penelope LTR DIRS TIR Helitron Maverick Crypton Unknown > headerTE_or.txt

cat headerTE_or.txt te_over_te_or.tbl > Percent_TEorder_TE_or.tbl
