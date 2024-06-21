# Data-Manipulation-scripts
Collection of scripts for data manipulation - awk etc.   

   
### Randomly select 4 individuals  
Used in rainbow_taskarray.sh to randomly select four individuals per trench, and assemble these with rainbow  
```
ls $SLURM_ARRAY_TASK_ID/*_1.1.fq.gz | shuf -n 4 | paste -s -d '~' | sed 's/~/ -1 /g' > trench$SLURM_ARRAY_TASK_ID.forward.txt
# list forward reads in folder 1, shuffle and randomly choose 4, paste in serially (onto one line ; -s) and use '~' as delimiter, using sed replace '~' with -1 globally, generating the list format needed for job submission
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

