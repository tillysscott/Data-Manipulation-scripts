# Data-Manipulation-scripts
Collection of scripts for data manipulation - awk etc.   
21/06/24 GONE THROUGH SCRIPTS UP TO AND INCLUDING TEST2/DarenAnalysis/00_repclassifier_cdhitLib - DEFINITELY INCLUDE MANUAL CPG CALCS AND MANUAL DAREN CALCULATIONS AND TE PREDICTION CALCULATIONS FILTERING

## Data manipulation
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
### Cut a string at the first instance of an underscore
`cut -d_ -f1`  
For example:  
```
sample=$(basename "$(dirname "$faa")" | cut -d_ -f1)
# make a variable called "sample"
					# keep the directory path to the faa, whilst removing the faa filename from the end of the path
		# keep the last/highest directory name
										# cut using _ as the separator and keep the first field
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
Also see: 

### if else and pattern matching
```
if [[ "$GTDBTK_DATA_PATH" =~ "/uoa/scratch/shared/Soil_Microbiology_Group/Training/Metagenomics/databases/GTDB-Tk_r220" ]] && [[ "$GTDB_DATA_PATH" =~ "/uoa/scratch/shared/Soil_Microbiology_Group/Training/Metagenomics/databases/GTDB-Tk_r220" ]]; then
  echo "Paths to GTDB match, METABOLIC is ready to use"
else
  exit
fi
```
This tests if the strings GTDBTK_DATA_PATH and GTDB_DATA_PATH (`&&`) exactly match the regrex pattern (path to GTDB-Tk_r220 in this case). More info on pattern matching is here: https://www.baeldung.com/linux/regex-inside-if-clause

### Use three variables to grep rows into files
Used in bas_genes.sh to get the positions of the BAS genes predicted.  
  
`for tag in $(cat genes.txt); do cat ../$tag.filtered_hits.faa | grep "^>" | awk '{print $1}' | sed 's/>//g' > $tag.filtered_hits.txt; done`  
-  This extracts the headers of faa files into a list, one per gene (e.g. adc), in the format 325603E__CHOJCPMP_00215 (ID_geneID)
  
```
for tag in $(cat genes.txt) 
do 
    while IFS= read -r line; do
         indiv="${line%%__*}"
         gene="${line##*__}" 
         
         grep "${gene}" ../../../Prokka/${indiv}_prokka1.14.6/${indiv}_*.gff | awk -F '\t' -v NUM=$indiv -v TAG=$tag -v OFS='\t' '{print $0, NUM, TAG}' >> $tag.filtered_hits.gff 
    done < $tag.filtered_hits.txt
done
```
Loop through the 5 gene names (e.g. adc) and do;  
`while IFS= read -r line; do` This means  
- `while` → repeat for each line in the input file
- `IFS=` → sets the Internal Field Separator to empty which prevents trimming of leading/trailing whitespace
- `read -r line` → reads one line at a time into a variable called line. `-r` avoids interpreting backslashes (\) as escape characters
Then extract the individual ID: `indiv="${line%%__*}"`. `%%` → remove the longest match from the end (deals with multiple sets of underscrores). `__*` → means “double underscore + anything after it". This line therefore removes "__CHOJCPMP_00215", keeping "325603E".  
Then extract the Prokka gene ID: `gene="${line##*__}"`. `##` remove the longest match from the start. `*__` means "double underscore and anything before it".  
And grep the gene ID in the individual's Prokka gff, placing it in a new gff, placing it in a new gff alongside the individual ID and gene name (e.g. adc).  
Whilst performing the "while" statement, use the individualID__gene_ID lines in filtered_hits.txt.  
Done.   

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
### starts or ends of lines:
```
grep "^>" file.fasta # grep lines that start with ">"
ls | grep "\.gz$" # grep lines that end with ".gz", the "." must be escaped
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

### Add an extra column to a table with a sample tag
Run a for loop that runs through sample numbers, use to print the table with the sample numbers in the first column  
`-F` sets the field separator, in this case, tab.  
`-v` sets the variable, in this case, `$num`, which was inherited from the for loop.  
`$0` prints the whole table.  
```
for num in {1..20}
do
	grep "transposase" Prokka/${num}E_prokka1.14.6/${num}E_*.gff | awk -F '\t' -v NUM=$num '{print NUM, $0}' >> Prokka/transposase_grep.tsv
done
```
### Perform pattern matching
List true/false based on the presence of "circular=true" in fasta header lines for multiple samples  
```
$ for num in {01..20}; do circ=$(grep "^>" ${num}_*.fasta | awk '{print ($0 ~ /circular=true/) ? "true" : "false"}' | paste -sd " "); echo $num $circ; done
01 false
02 true true
03 false false false true false
```
- `for num in {01..20}` set up a for loop for sequential numbers
- `circ=$(*)` create a variable based on a sh expression
- `grep ">" ${num}_*.fasta` get fasta header lines
- `awk '{print ($0 ~ /circular=true/) ? "true" : "false"}'` Using all of the line, if that line contains the pattern (circular=true) print "true", else print "false"
- `paste -sd " "` serialise into one line (`-s`) and use space as delimiter (`-d " "`)
- `echo $num $circ` print the number and the true/false pattern

## Moving files
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
#### How to transfer data from Maxwell directly to the team drive  
- All outputs have been tar zipped. Read below for description of these outputs  
- First log into Maxwell (or Macleod) as normal  
- Navigate to the directory you want to transfer to or from  
- On the command line do: 
```
smbclient '\\uoa.abdn.ac.uk\global' -D 'CLSM\CGEBM\Bioinformatics Unit\CGEBM Projects Bfx\<any project folder> 
```
Example: `smbclient '\\uoa.abdn.ac.uk\global' -D 'CLSM\CGEBM\Bioinformatics Unit\CGEBM Projects Bfx\CGEBMP424A Stefan Marika Targetted RNAseq Nanopore Xenopus tropicalis\Ongoing\' `
- Note: It doesn't have to be just CLSM\CGEBM etc, it can be any folder in the drive that YOU HAVE ACCESS TO
- Enter your password - this would be your password for your university email
- Once entered, you will now be in the team drive
- Next run the follow commands:
```
recurse on
prompt off
```
- To transfer a folder from the team drive to Maxwell use:
`mget <folder_name_or_path>`
- To transfer a single file from the team drive to Maxwell use:
- Change into the folder holding desired file: `cd <path/to/folder>`
`get myfile.fasta`
- To transfer a folder to the team drive from Maxwell, use:
`mput <folder_in_maxwell>`
- To transfer a single file to the team drive from Maxwell, use:
`put myfile.fasta`
- Once finished, exit smbclient with `exit`
- For more information: https://uoa.freshservice.com/support/solutions/articles/577518
```
#### Moving data between clusters 
1. compress the file `tar -cvzf data.tar.gz data`
2. create md5checksum `md5sum data.tar.gz`
3. copy files from your HPC account to another HPC/HPC account
`rsync -auvh --progress path/to/source_folder <user>@login.hpc.cam.ac.uk:path/to/target_folder`  
4. copy files from another HPC/HPC account to your HPC directory  
`rsync -auvh --progress <user>@login.hpc.cam.ac.uk:path/to/source_folder path/to/target_folder` 

## Random bits of useful code I didn't know when I started
```
seff $jobid # see how much memory etc. a slurm job used
scancel $jobid #cancel slurm job
squeue --m # see my running slurm jobs
ctrl-C # cancels most things
readlink -f file #get real location of symbloic linked file
source /opt/software/uoa/apps/miniconda3/latest/etc/profile.d/conda.sh #source miniconda3 installation inside bash scripts
unset PYTHONPATH #sometimes the HPC will take the local python version rather than the conda environement version, use this to force it to use conda version. Pychopper requies python v.3.10, and local copy was v.3.9
srun --pty /bin/bash #to get off of the head node to run interactive prompts
salloc -c 16 --mem=64G  # running it as an interactive job
srun --pty bash
```
### Setting up slurm environment to use conda
1. ` module load miniconda3` load miniconda3, this is already on Maxwell
2. `conda init bash` make  conda available everytime we connect
3. `source ~/.bashrc` and then we are set

## Markdown tips:
- help page: [here](https://code.visualstudio.com/docs/languages/markdown)  
    - Use pop up bubble choose plain text or mark down link
    - put 4 spaces before dash for more indent  
- To inset and image write exclamition point, square brackets containing image description, normal brackets containing the path to the image. All with no spaces  
![image desc](./Markdown_images/Screenshot%202025-06-03%20102209.png)  
- To insert a link: square brackets with link description, normal brackets with link. All with no spaces  
[text description of link](#how-to-transfer-data-from-maxwell-directly-to-the-team-drive)
- ctrl + shift + v for md preview
- drag tab to right to open preview side-by-side window
- right click on window, open in brower then save as pdf to export this document
