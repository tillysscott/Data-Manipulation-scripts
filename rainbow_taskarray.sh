#!/bin/bash

#SBATCH -a 1-10
#SBATCH --time=24:00:00
#SBATCH --mem 40G


######################################################################
# task array to randomly select four individuals per trench, 
# and assemble them with rainbow
######################################################################

#paths are set out to be run from 'clean' directory

echo "this is the slurm report of $SLURM_ARRAY_TASK_ID"
echo "trenches are in alphabetical order"
echo "1 = Atacama, 2 = Java, 3 = Kermadec, 
4 = New Hebrides Trench, 5 = Puerto Rico, 
6 = San Cristobal, 7 = Santa Cruz, 
8 = South Sandwich, 9 = Tonga, 10 = WZFZ"


# add rainbow app to path
PATH=$PATH:~/sharedscratch/apps/rainbow_2.0.4


# generate list input files for rainbow
ls $SLURM_ARRAY_TASK_ID/*_1.1.fq.gz | shuf -n 4 | paste -s -d '~' | sed 's/~/ -1 /g' > trench$SLURM_ARRAY_TASK_ID.forward.txt
sed 's/_1.1/_2.2/g' trench$SLURM_ARRAY_TASK_ID.forward.txt | sed 's/-1/-2/g'  > trench$SLURM_ARRAY_TASK_ID.reverse.txt

# run the three rainbow steps
rainbow cluster -1 $(cat trench$SLURM_ARRAY_TASK_ID.forward.txt)  -2 $(cat trench$SLURM_ARRAY_TASK_ID.reverse.txt) > trench$SLURM_ARRAY_TASK_ID.rbcluster.out
rainbow div -i trench$SLURM_ARRAY_TASK_ID.rbcluster.out -o trench$SLURM_ARRAY_TASK_ID.rbdiv.out
rainbow merge -i trench$SLURM_ARRAY_TASK_ID.rbdiv.out -o trench$SLURM_ARRAY_TASK_ID.rbasm.out -a -N500

#extract the best assembly in fasta format
module load perl
perl ~/sharedscratch/apps/rainbow_2.0.4/select_best_rbcontig.pl trench$SLURM_ARRAY_TASK_ID.rbasm.out  > trench$SLURM_ARRAY_TASK_ID.rb.fa

#AT END
## when all successfully completed
#mkdir ../rainbow_4pertrench
#mv trench* ../rainbow_4pertrench/
