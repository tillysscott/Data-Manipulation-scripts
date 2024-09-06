# Data-Manipulation-scripts
Collection of scripts for data manipulation - awk etc.   
21/06/24 GONE THROUGH SCRIPTS UP TO AND INCLUDING TEST2/DarenAnalysis/00_repclassifier_cdhitLib - DEFINITELY INCLUDE MANUAL CPG CALCS AND MANUAL DAREN CALCULATIONS
   
### Randomly select 4 individuals  
Used in rainbow_taskarray.sh to randomly select four individuals per trench, and assemble these with rainbow  
```
ls $SLURM_ARRAY_TASK_ID/*_1.1.fq.gz | shuf -n 4 | paste -s -d '~' | sed 's/~/ -1 /g' > trench$SLURM_ARRAY_TASK_ID.forward.txt
# list forward reads in folder 1, shuffle and randomly choose 4, paste in serially (onto one line ; -s) and use '~' as delimiter, using sed replace '~' with -1 globally, generating the list format needed for job submission
```
### Counting
Options  
```
grep -c ">" fasta.fa # grep (grab) and count lines that include ">" character
wc -l # word count lines, also counts characters, words, and other. see wc --help
sort | uniq -c # sort list (-k to specify column (-k 2)), count unique instances
```
### Replace character strings
Used in rainbow_taskarray.sh to generate reverse read input list from forward read list  
Using sed:
```
sed 's/find/replace/g' file
# find = string to find
# replace = string to replace
# g = globally within file
```
Within vim:
```
:%s/find/replace/g
# find = string to find
# replace = string to replace
# g = globally within file
```
To find and replace special characters within either, slash out character ("\char"):   
```
head test.txt
$ change/this/path

sed 's/\//./g' test.txt # '\/' is read as a normal forward slash
$ change.this.path

sed 's/\//\t/g' test.txt # '\t' is read a tab
$ change  this    path
```
### Convert fastq to fasta
Used in prep_for_TERAD.sh  
```
sed -n '1~4s/^@/>/p;2~4p' ${ind}_1.1.fq > ${ind}_1.1.fa
```

### Download genomes from NCBI
Find NCBI genome page, vist FTP, copy link address of .fasta
```
wget copliedlinkaddress
```
### Prepare input files for slurm task array
Used in final_prep.sh and prep_for_TERAD.sh
```
ls *_nodash.fa | cat -n | while read n f; do mv -n "$f" "${n}_${f}"; done
# list fasta files, read and add line numbers making two columns, n=line number & f=file name, while read variables n and f, do, rename $f to $n.$f using move (-n stops files being overwritten), done
```
### Add species code to fasta header
```
conda activate seqkit

head Parhyale_hawaiensis-families.fa
$ >ltr-1_family-1#LTR/Unknown [ Type=LTR, Final Multiple Alignment Size = 2 ]
$ TGTGATAGCCGGTCTTTCCTTATGCCTGTGTATGTATACGATAGTAACTT

# add species code to header: genSpeVer_
cat Parhyale_hawaiensis-families.fa | seqkit fx2tab | awk '{ print "parHaw5_"$0 }' | seqkit tab2fx > Parhyale_hawaiensis-families.prefix.fa
## take fasta, put header and sequence on one tab separated line, print "parHaw5_" and all columns, covert tab to fasta file
```
### Moving files
```
# Compress the directory/data
tar -cvzf data.tar.gz data
# Create md5sum string
md5sum data.tar.gz
# After transfer check md5string
md5sum data.tar.gz
# expand the file
tar -xvzf data.tar.gz
```

## Grep
### separate TE library into known and unknown libraries
Used in separate_TE_lib.sh
```
conda activate seqkit
export species="amphipod"

cat ${species}.fa | seqkit fx2tab | grep -v "Unknown" | seqkit tab2fx > ${species}.known.fa
take fasta, convert to tab separated format, grab (grep) lines that don't include the term "unknown", convert from tab to fasta format, output to .known.fa

cat ${species}.fa | seqkit fx2tab | grep "Unknown" | seqkit tab2fx > ${species}.unknown.fa
take fasta, convert to tab separated format, grab (grep) lines that include the term "unknown", convert from tab to fasta format, output to .unknown.fa
```

## AWK
### Work in blocks between '//' features to print data
Used in Marius_separate_loci_into fasta  
```
awk 'BEGIN{l=1}$1=="//"{l++} $1!="//"{i=$1; s=$2; print ">Locus"l"\n"s >> i".fasta"; print l >> i".loci.txt"}' ct87_13.loci

#awk 
# BEGIN{l=1}$1=="//"{l++} <--- must set up the block design \
	# L=1 , column 1 == "//", generate series? \
	# starting number for L is 1
# If $1 does not equal "//" then i=$1 and s=$2, print " >Locus L(variable made at start), new line, s (variable)" \
	#put into i(variable).fasta 
# Also print L into file i.loci.txt
# use file ct87_13.loci
```

### Add sequential numbers to fasta headers
Used in separate_loci_into_fasta.sh
```
awk '/^>/{$0=$0"_"(++i)}1' file.fa > file2.fa
```

### Remove '-' from multi individual alignment
Used in separate_loci_into_fasta.sh
```
head file.tab
$ >locus_1	ATGATAATATATAT---GGGGGGCCCCCCCCCC

awk -v OFS='\t' '{gsub("-", "", $2); print}' file.tab | head
$ >locus_1	ATGATAATATATATGGGGGGCCCCCCCCCC
```
### Do maths:
#### Percent of sequence from TE
Used in Daren_8B_mancalc.sh and Daren_8C_mancalc2.sh
#### CpG observed/expected

