#!/bin/bash

#conda activate seqkit

export species="amphipod"

cat ${species}.fa | seqkit fx2tab | grep -v "Unknown" | seqkit tab2fx > ${species}.known.fa
echo Known library generated: ${species}.fa.known

cat ${species}.fa | seqkit fx2tab | grep "Unknown" | seqkit tab2fx > ${species}.unknown.fa
echo Unknown library generated: ${species}.fa.unknown


# quantify number of classified elements
echo Number of classified elements
grep -c ">" ${species}.known.fa
# quantify number of unknown elements
echo Number of unknown elements
grep -c ">" ${species}.unknown.fa
# quantify number of total elements
echo Number of total elements
grep -c ">" ${species}.fa

## Check that known + unknown seqs = total elements ##
