#!/bin/sh
test_description="Testing out status "
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

test_todo_session "Testing of status" <<EOF
>>> todorb close 2
 [32m  2 : [x] what if no serial_number file? (2010-06-14) [0m
Changed 1 task/s
>>> end
>>> todorb
   1 [ ] if no TODO file give proper message to add task (2010-06-14) 
   3 [ ] Add a close for status close (2010-06-14) 
   4 [ ] start rubyforge project for todorb (2010-06-14) 
   5 [ ] list: if dir given then show full path of TODO2.txt at end (2010-06-14) 
   6 [ ] allow for ENV VARS such as verbose, plain, force (2010-06-15) 
   7 [ ] list: search terms with - + and = (2010-06-15) 
 
 6 of 7 rows displayed from TODO2.txt 
>>> end
>>> todorb open 2
 [32m  2 : [ ] what if no serial_number file? (2010-06-14) [0m
Changed 1 task/s
>>> end
>>> todorb
   1 [ ] if no TODO file give proper message to add task (2010-06-14) 
   2 [ ] what if no serial_number file? (2010-06-14) 
   3 [ ] Add a close for status close (2010-06-14) 
   4 [ ] start rubyforge project for todorb (2010-06-14) 
   5 [ ] list: if dir given then show full path of TODO2.txt at end (2010-06-14) 
   6 [ ] allow for ENV VARS such as verbose, plain, force (2010-06-15) 
   7 [ ] list: search terms with - + and = (2010-06-15) 
 
 7 of 7 rows displayed from TODO2.txt 
>>> end
>>> todorb close 2 4
 [32m  2 : [x] what if no serial_number file? (2010-06-14) [0m
 [32m  4 : [x] start rubyforge project for todorb (2010-06-14) [0m
Changed 2 task/s
>>> end
>>> todorb status start 3 7
 [32m  3 : [@] Add a close for status close (2010-06-14) [0m
 [32m  7 : [@] list: search terms with - + and = (2010-06-15) [0m
Changed 2 task/s
>>> end
>>> todorb
   1 [ ] if no TODO file give proper message to add task (2010-06-14) 
   3 [@] Add a close for status close (2010-06-14) 
   5 [ ] list: if dir given then show full path of TODO2.txt at end (2010-06-14) 
   6 [ ] allow for ENV VARS such as verbose, plain, force (2010-06-15) 
   7 [@] list: search terms with - + and = (2010-06-15) 
 
 5 of 7 rows displayed from TODO2.txt 
>>> end
>>> todorb list --show-all
   1 [ ] if no TODO file give proper message to add task (2010-06-14) 
   2 [x] what if no serial_number file? (2010-06-14) 
   3 [@] Add a close for status close (2010-06-14) 
   4 [x] start rubyforge project for todorb (2010-06-14) 
   5 [ ] list: if dir given then show full path of TODO2.txt at end (2010-06-14) 
   6 [ ] allow for ENV VARS such as verbose, plain, force (2010-06-15) 
   7 [@] list: search terms with - + and = (2010-06-15) 
 
 7 of 7 rows displayed from TODO2.txt 
>>> end

EOF
test_done
