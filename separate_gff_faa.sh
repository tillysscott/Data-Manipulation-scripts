#!/bin/bash

# This code will separate the genome assembly and the gff and faa files from Prokka into individual files for each contig. 
# This is needed for CRISPRCasFinder to work properly with multi-contig assemblies.

# load seqkit
source /opt/software/uoa/apps/miniconda3/latest/etc/profile.d/conda.sh
conda activate seqkit

# set up individual (ind) variable
#ind=1
for ind in $(cat multi_contig_inds.txt)
do

# make directory
mkdir $ind

# sort out the genome assembly, making one fasta per contig 
awk -v IND=$ind  'BEGIN {n_seq=1;} /^>/ {if(n_seq%1==0){file=sprintf("%s_%d.fa",IND,n_seq);} print >> file; n_seq++; next;} { print >> file; }' < ../../../assemblies/${ind}_*.fasta
mv ${ind}_*.fa $ind

# sort out the gff files, making one gff per contig
awk -v IND="$ind" '
/^##FASTA/ { exit }

/^#/ {
    header = header $0 "\n"
    next
}
!seen[$1]++ {
    printf "%s", header > IND "/" IND "_" $1 ".gff"
}
{
    print >> IND "/" IND "_" $1 ".gff"
}
' ../../Prokka/${ind}E_prokka1.14.6/${ind}_*.gff
	## This command will exit when it reaches is ##FASTA lines. Print the hashtagged header lines to a new file. Gather 
	## up the gff entries for that contig. Work through each of the contigs in numerical order

# sort out the faa, making one faa file per contig
## Make a look up table of gene IDs and the contig they are on
awk '$3=="CDS"' ../../Prokka/${ind}E_prokka1.14.6/${ind}_*.gff | awk '{print $1, $9}' | awk 'BEGIN {FS=";"} {print $1}' | sed 's/ID=//g' | awk -v OFS='\t' '{print $2, $1}' > $ind/${ind}_lookup.tsv
        ## Get coding sequences only, get the contig and descriptor columns, using ; as the field separation 
	## only keep everything before the first ;, remove "ID=", rearrange column 1 and 2 with tab as the separator
    ## NB: this will only work if ID=XXXXX is the first field in the descriptor column. If it is not, then the awk command will need to be changed to get the correct field.

## Make the faa files
cut -f2 $ind/${ind}_lookup.tsv | sort -u |
while read contig; do
    seqkit grep \
        -f <(awk -v c="$contig" '$2==c{print $1}' $ind/${ind}_lookup.tsv) \
        ../../Prokka/${ind}E_prokka1.14.6/${ind}_*.faa \
        > "${ind}/${ind}_${contig}.faa"
done
        ## Take the contig column of the lookup.tsv, sort into uniq contig names, while each unique contig 
	## name (calling the variable "contig") do, seqkit grep sequences using a file (-f) containing the 
	## sequence IDs, the file is made inside the <> using awk to only get sequence IDs from that contig, 
	## put the output into a new faa.
done
