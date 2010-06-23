#!/bin/sh
test_description="Testing out add_opt "
. ./test-lib.sh




test_todo_session "Testing of add_opt" <<EOF
>>> todorb add --project rbcurse --component Table --priority A "test with colored data"
Adding:
  1	[ ] (A) +rbcurse @Table test with colored data (2009-02-13)
>>> end
>>> todorb add --project rbcurse --component Textarea --priority B "test with tabular data"
Adding:
  2	[ ] (B) +rbcurse @Textarea test with tabular data (2009-02-13)
>>> end
>>> todorb add --project rbcurse --component Textarea --priority C "test with jumbled data"
Adding:
  3	[ ] (C) +rbcurse @Textarea test with jumbled data (2009-02-13)
>>> end
>>> todorb
[33m[1m   1 [ ] (A) +rbcurse @Table test with colored data (2009-02-13) [0m
[37m[1m   2 [ ] (B) +rbcurse @Textarea test with tabular data (2009-02-13) [0m
[32m[1m   3 [ ] (C) +rbcurse @Textarea test with jumbled data (2009-02-13) [0m
 
 3 of 3 rows displayed from TODO2.txt 
>>> end
>>> todorb add --project todorb "cleanup of code"
Adding:
  4	[ ] +todorb cleanup of code (2009-02-13)
>>> end
>>> todorb list --project rbcurse
[33m[1m   1 [ ] (A) +rbcurse @Table test with colored data (2009-02-13) [0m
[37m[1m   2 [ ] (B) +rbcurse @Textarea test with tabular data (2009-02-13) [0m
[32m[1m   3 [ ] (C) +rbcurse @Textarea test with jumbled data (2009-02-13) [0m
 
 3 of 4 rows displayed from TODO2.txt 
>>> end
>>> todorb list --component Textarea
[37m[1m   2 [ ] (B) +rbcurse @Textarea test with tabular data (2009-02-13) [0m
[32m[1m   3 [ ] (C) +rbcurse @Textarea test with jumbled data (2009-02-13) [0m
 
 2 of 4 rows displayed from TODO2.txt 
>>> end
>>> todorb list --priority A
[33m[1m   1 [ ] (A) +rbcurse @Table test with colored data (2009-02-13) [0m
 
 1 of 4 rows displayed from TODO2.txt 
>>> end
>>> todorb list --priority [A-C]
[33m[1m   1 [ ] (A) +rbcurse @Table test with colored data (2009-02-13) [0m
[37m[1m   2 [ ] (B) +rbcurse @Textarea test with tabular data (2009-02-13) [0m
[32m[1m   3 [ ] (C) +rbcurse @Textarea test with jumbled data (2009-02-13) [0m
 
 3 of 4 rows displayed from TODO2.txt 
>>> end
>>> todorb pri D 4
   4 : [ ] +todorb cleanup of code (2009-02-13) 
 [32m  4 : [ ] (D) +todorb cleanup of code (2009-02-13) [0m
Changed priority of 1 task/s
>>> end
>>> todorb list --priority [A-C]
[33m[1m   1 [ ] (A) +rbcurse @Table test with colored data (2009-02-13) [0m
[37m[1m   2 [ ] (B) +rbcurse @Textarea test with tabular data (2009-02-13) [0m
[32m[1m   3 [ ] (C) +rbcurse @Textarea test with jumbled data (2009-02-13) [0m
 
 3 of 4 rows displayed from TODO2.txt 
>>> end
>>> todorb list
[33m[1m   1 [ ] (A) +rbcurse @Table test with colored data (2009-02-13) [0m
[37m[1m   2 [ ] (B) +rbcurse @Textarea test with tabular data (2009-02-13) [0m
[32m[1m   3 [ ] (C) +rbcurse @Textarea test with jumbled data (2009-02-13) [0m
[36m[1m   4 [ ] (D) +todorb cleanup of code (2009-02-13) [0m
 
 4 of 4 rows displayed from TODO2.txt 
>>> end

EOF
test_done
