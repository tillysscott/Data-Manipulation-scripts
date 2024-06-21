# Data-Manipulation-scripts
Collection of scripts for data manipulation - awk etc.   

   
### Randomly select 4 individuals  
Used in rainbow_taskarray.sh to randomly select four individuals per trench, and assemble these with rainbow  
Functions used: shuf, paste, sed
```
ls $SLURM_ARRAY_TASK_ID/*_1.1.fq.gz | shuf -n 4 | paste -s -d '~' | sed 's/~/ -1 /g' > trench$SLURM_ARRAY_TASK_ID.forward.txt
# list forward reads in folder 1, shuffle and choose 4, paste in serially (onto one line ; -s) and use '~' as delimiter, using sed replace '~' with -1 globally, generating the list format needed for job submission

sed 's/_1.1/_2.2/g' trench$SLURM_ARRAY_TASK_ID.forward.txt | sed 's/-1/-2/g'  > trench$SLURM_ARRAY_TASK_ID.reverse.txt
# using sed replace '_1.1' with '_2.2', using sed replace -1 with -2 globally
```

### Replace character strings
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

