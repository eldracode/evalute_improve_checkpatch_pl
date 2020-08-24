# Some stats

I wrote a bash script to run checkpatch.pl on commits from v5.7 to v5.8 (Total 17595 commits) and find 20 categories that occur the most.

Script can be used to find warnings and checks after tweaking a bit.


```bash
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
	COUNT=`grep -c "$i" newfile.txt`
	if [ $COUNT -gt 0 ]
	then
		let DIF=$LL-${#i}
		printf "%s %s> %d\n" "$i" "`space $DIF`" $COUNT >> COUNT.txt
	fi
	COUNT=0;
done

cat COUNT.txt | sort -nk3 -r | head -n 20

```
#### Screenshot

* For errors

![freq](Images/5.png)


* For warnings

![warning](Images/7.png)

* For checks

![check](Images/6.png)


### Analysis

I did my analysis over some errors I found with checkpatch.
Almost everytime I found that checkpatch is correct.

But in some cases I found it to be Ambiguous, like 
If the authors' changes are not erroneous according to kernel style
but the line next to it (which is there in diff but not added by author) is
erroneous, then too checkpatch shows error in patch/commit.
(Actually, I am doubtful on this, don't know if this error is expected to occur or not)

Example commits: 

* [004ed42638f4](https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/commit/?h=linux-5.8.y&id=004ed42638f4) : FSF_MAILING_LIST error.

* [41022d35ddf2](https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/commit/?id=41022d35ddf219361f33b59034cc67430a6a590f) : OPEN_BRACE error.