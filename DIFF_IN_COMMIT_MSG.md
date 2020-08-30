## Analysis of DIFF_IN_COMMIT_MSG errors

Upon analyzing 10 commits, I found a similar pattern. So there are generally
2 type of issues in all the commits.


 #### Type 1


* **commit bab1a501e658 ("tools arch x86: Sync the msr-index.h copy with the kernel sources")**

> what lines in the commit message did checkpatch.pl complain about?

Line #22

> what is the pattern in the commit message?

   `@@ -10,6 +10,7 @@`

> does patch(1) really stumble over that pattern?

No

> if no, why not?

The patch is actually not standard format to apply patch for `git am` .

```
  --- before	2020-04-01 12:11:14.789344795 -0300
  +++ after	2020-04-01 12:11:56.907798879 -0300
```
this is output of GNU Diff which is different from format of `git format-patch`. 

> how would this pattern need to be provided to patch(1) so that it 
would stumble over it?

If we convert the diff to standart format then it will confuse `git am`.

> can we change checkpatch.pl to not raise an error for such a 
situation? So, only raise an error when the pattern would really make 
patch stumble on it?

Yes, we can check if the diff in commit description is in standard format 
of a patch. We can give a warning to encourage no use of diffs.


#### Type 2

* **commit 6b3e0e2e0461 ("perf tools: Support CAP_PERFMON capability")**

> what lines in the commit message did checkpatch.pl complain about?

Line #28

> what is the pattern in the commit message?

   `diff --git a/libcap/include/uapi/linux/capability.h b/libcap/include/uapi/linux/capability.h`

> does patch(1) really stumble over that pattern?

No

> if no, why not?

The diff in commit description has 2 spaces before the diff, so it didn't
interfare with real diff.

> how would this pattern need to be provided to patch(1) so that it 
would stumble over it?

If we remove those 2 spaces before every line in diff, then it will give error 
with `git am`.

```shell
$ git am 0001-perf-tools-Support-CAP_PERFMON-capability.patch

Applying: perf tools: Support CAP_PERFMON capability
error: corrupt patch at line 7
Patch failed at 0001 perf tools: Support CAP_PERFMON capability
hint: Use 'git am --show-current-patch=diff' to see the failed patch
When you have resolved this problem, run "git am --continue".
If you prefer to skip this patch, run "git am --skip" instead.
To restore the original branch and stop patching, run "git am --abort".

```

> can we change checkpatch.pl to not raise an error for such a 
situation? So, only raise an error when the pattern would really make 
patch stumble on it?

Yes, we can check if the diff in commit description is in standard format 
of a patch. We can give a warning to encourage no use of diffs.


#### Conclusion

- If the patch has diff in commit description and also has spaces before it, it gives error `DIFF_IN_COMMIT_MSG`.

- But if a patch has diff without trailing spaces then it checkpatch will
give `CORRUPTED_PATCH` error and patch won't apply either (check `git am` output above). 
(It won't give `DIFF_IN_COMMIT_MSG` in this case)

- We can add a warn instead of error if we encounter diff, as the diff is not 
going to apply anyway. 

- My conclusion might change if I analyze more commits, right now it's based on
commits between v5.7 and v5.8.