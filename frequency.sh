#!/bin/bash

# Author: Ayush Karn

# To get list of all 207 types.
TYPES=`scripts/checkpatch.pl --list-types | cut -f 2 | tail -n 207`

# To get the length of longest error type
LL=`scripts/checkpatch.pl --list-types | cut -f 2 | tail -n 207 | wc -L`

# Running checkpatch on commits from v5.7 to v5.8
scripts/checkpatch.pl -g bcf876870b95-17595 --show-types | grep -o "ERROR:.*:" | cut -d':' -f 2 > file.txt

COUNT=0

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
NC=$(tput sgr0)

cat /dev/null > COUNT.txt
function space(){
		CTR=1
		while [ $CTR -le $DIF ]
		do
        		printf "-" 
			((CTR++))
		done
}

for i in $TYPES
do
	COUNT=`grep -c "$i" file.txt`
	if [ $COUNT -gt 0 ]
	then
		let DIF=$LL-${#i}
		printf "%s %s> %d\n" "$i" "`space $DIF`" $COUNT >> COUNT.txt
	fi
	COUNT=0;
done

cat COUNT.txt | sort -nk3 -r | head -n 20