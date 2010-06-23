#!/bin/sh
test_description="Testing out grep "
. ./test-lib.sh


cat > TODO2.txt <<CATEOF
  1	[ ] if no TODO file give proper message to add task (2010-06-14)
  2	[ ] what if no serial_number file? (2010-06-14)
  3	[ ] Add a close for status close (2010-06-14)
  4	[ ] start rubyforge project for todorb (2010-06-14)
  5	[ ] list: if dir given then show full path of TODO2.txt at end (2010-06-14)
  6	[ ] allow for ENV VARS such as verbose, plain, force (2010-06-15)
  7	[ ] list: search terms with - + and = (2010-06-15)
  8	[ ] (A) +rbcurse @Table test with colored data (2010-06-23)
  9	[ ] (B) +rbcurse @Textarea enter tabular data (2010-06-23)
CATEOF

test_todo_session "Testing of grep" <<EOF
>>> todorb list --grep 'rb|ruby'
   4 [ ] start rubyforge project for todorb (2010-06-14) 
   6 [ ] allow for ENV VARS such as verbose, plain, force (2010-06-15) 
[33m[1m   8 [ ] (A) +rbcurse @Table test with colored data (2010-06-23) [0m
[37m[1m   9 [ ] (B) +rbcurse @Textarea enter tabular data (2010-06-23) [0m
 
 4 of 9 rows displayed from TODO2.txt 
>>> end
>>> todorb list --grep 'rb|ruby' --renumber
   1 [ ] start rubyforge project for todorb (2010-06-14) 
   2 [ ] allow for ENV VARS such as verbose, plain, force (2010-06-15) 
[33m[1m   3 [ ] (A) +rbcurse @Table test with colored data (2010-06-23) [0m
[37m[1m   4 [ ] (B) +rbcurse @Textarea enter tabular data (2010-06-23) [0m
 
 4 of 9 rows displayed from TODO2.txt 
>>> end

EOF
test_done
