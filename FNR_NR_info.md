## What does FNR==NR do?
Makes it so that the segment of code only uses the first file  
`FNR` is the line number in the current file (will cycle through files in order), `NR` is the number is the total number of lines. In the first file `FNR` and `NR` will be the same, but by the time it gets to the second (or more files), `FNR` will have reset back to 1, but `NR` will still be continuing to count.  
```
awk '
  BEGIN { FS=OFS="\t" }
  {print FNR, NR}
' test/setB.fas test/test_setB.tsv
```
```
$ 1       1 # these row numbers are from file 1
$ 2       2
$ 3       3
$ 4       4
$ 5       5
$ 6       6
$ 7       7
$ 8       8
$ 1       9 # column 1 numbers from file 2, column 2 numbers are cumulative from file 1 AND 2
$ 2       10
$ 3       11
$ 4       12
```
Where test/setB.fas has 8 lines, and test/test_setB.tsv has 4 lines  
