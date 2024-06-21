#!/bin/bash

#####################
#Convert an ipyrad .loci output into a fasta file per individual, where loci are named consistently across all individuals
####################

awk 'BEGIN{l=1}$1=="//"{l++} $1!="//"{i=$1; s=$2; print ">Locus"l"\n"s >> i".fasta"; print l >> i".loci.txt"}' ct87_13.loci

#awk 
# BEGIN{l=1}$1=="//"{l++} <--- must set up the block design \
	# L=1 , column 1 == "//", generate series? \
	# starting number for L is 1
# If $1 does not equal "//" then i=$1 and s=$2, print " >Locus L(variable made at start), new line, s (variable)" \
	#put into i(variable).fasta 
# Also print L into file i.loci.txt
# use file ct87_13.loci
