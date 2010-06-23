#!/bin/sh
test_description="Testing out addsub "
. ./test-lib.sh


cat > TODO2.txt <<CATEOF
  1	[ ] if no TODO file give proper message to add task (2010-06-14)
  2	[ ] what if no serial_number file? (2010-06-14)
  3	[ ] Add a close for status close (2010-06-14)
  4	[ ] start rubyforge project for todorb (2010-06-14)
  5	[ ] list: if dir given then show full path of TODO2.txt at end (2010-06-14)
  6	[ ] allow for ENV VARS such as verbose, plain, force (2010-06-15)
  7	[ ] list: search terms with - + and = (2010-06-15)
CATEOF

test_todo_session "Testing of addsub" <<EOF
>>> todorb addsub 1 "create serial_number file"
Adding:
    1.1	[ ] create serial_number file (2009-02-13)
>>> end
>>> todorb
   1 [ ] if no TODO file give proper message to add task (2010-06-14) 
     1.1 [ ] create serial_number file (2009-02-13) 
   2 [ ] what if no serial_number file? (2010-06-14) 
   3 [ ] Add a close for status close (2010-06-14) 
   4 [ ] start rubyforge project for todorb (2010-06-14) 
   5 [ ] list: if dir given then show full path of TODO2.txt at end (2010-06-14) 
   6 [ ] allow for ENV VARS such as verbose, plain, force (2010-06-15) 
   7 [ ] list: search terms with - + and = (2010-06-15) 
 
 8 of 8 rows displayed from TODO2.txt 
>>> end
>>> todorb addsub 1 "reset serial file when doing redo"
Adding:
    1.2	[ ] reset serial file when doing redo (2009-02-13)
>>> end
>>> todorb addsub 1.1 "update serial file"
Adding:
        1.1.1	[ ] update serial file (2009-02-13)
>>> end
>>> todorb
   1 [ ] if no TODO file give proper message to add task (2010-06-14) 
     1.1 [ ] create serial_number file (2009-02-13) 
         1.1.1 [ ] update serial file (2009-02-13) 
     1.2 [ ] reset serial file when doing redo (2009-02-13) 
   2 [ ] what if no serial_number file? (2010-06-14) 
   3 [ ] Add a close for status close (2010-06-14) 
   4 [ ] start rubyforge project for todorb (2010-06-14) 
   5 [ ] list: if dir given then show full path of TODO2.txt at end (2010-06-14) 
   6 [ ] allow for ENV VARS such as verbose, plain, force (2010-06-15) 
   7 [ ] list: search terms with - + and = (2010-06-15) 
 
 10 of 10 rows displayed from TODO2.txt 
>>> end
>>> todorb close 1
 [32m  1 : [x] if no TODO file give proper message to add task (2010-06-14) [0m
 [32m    1.1 : [x] create serial_number file (2009-02-13) [0m
 [32m        1.1.1 : [x] update serial file (2009-02-13) [0m
 [32m    1.2 : [x] reset serial file when doing redo (2009-02-13) [0m
Changed 4 task/s
>>> end
>>> todorb list --show-all
   1 [x] if no TODO file give proper message to add task (2010-06-14) 
     1.1 [x] create serial_number file (2009-02-13) 
         1.1.1 [x] update serial file (2009-02-13) 
     1.2 [x] reset serial file when doing redo (2009-02-13) 
   2 [ ] what if no serial_number file? (2010-06-14) 
   3 [ ] Add a close for status close (2010-06-14) 
   4 [ ] start rubyforge project for todorb (2010-06-14) 
   5 [ ] list: if dir given then show full path of TODO2.txt at end (2010-06-14) 
   6 [ ] allow for ENV VARS such as verbose, plain, force (2010-06-15) 
   7 [ ] list: search terms with - + and = (2010-06-15) 
 
 10 of 10 rows displayed from TODO2.txt 
>>> end

EOF
test_done
