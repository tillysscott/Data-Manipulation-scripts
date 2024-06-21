#!/bin/bash

## add numeric counters to fq.gz files for slurm array later
ls *_1.1.fq.gz | cat -n | while read n f; do mv -n "$f" "$n.$f"; done
# list forward fastq files, read and add line numbers making two columns, n=line number & f=file name, while read variables n and f, do, rename $f to $n.$f using move (-n stops files being overwritten), done


## for loop to gunzip fastq files, convert fastq to fasta and move to a new directory
for ind in $(cat file_list.txt) 
do 
	gunzip ${ind}_1.1.fq.gz
	gunzip ${ind}_2.2.fq.gz
	sed -n '1~4s/^@/>/p;2~4p' ${ind}_1.1.fq > ${ind}_1.1.fa
	sed -n '1~4s/^@/>/p;2~4p' ${ind}_2.2.fq > ${ind}_2.2.fa
	mv ${ind}_1.1.fa ~/sharedscratch/apps/TERAD/
	mv ${ind}_2.2.fa ~/sharedscratch/apps/TERAD/
done
