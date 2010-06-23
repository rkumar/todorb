#!/bin/sh
test_description="Testing out copyunder "
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

test_todo_session "Testing of copyunder" <<EOF
>>> todorb copyunder 2 3
  2	[ ] what if no serial_number file? (2010-06-14)
[ ] what if no serial_number file? (2010-06-14)
Adding:
    3.1	[ ] what if no serial_number file? (2010-06-14)
>>> end
>>> todorb copyunder --delete 4 5
  4	[ ] start rubyforge project for todorb (2010-06-14)
[ ] start rubyforge project for todorb (2010-06-14)
Adding:
    5.1	[ ] start rubyforge project for todorb (2010-06-14)
>>> end
>>> todorb
   1 [ ] if no TODO file give proper message to add task (2010-06-14) 
   2 [ ] what if no serial_number file? (2010-06-14) 
   3 [ ] Add a close for status close (2010-06-14) 
     3.1 [ ] what if no serial_number file? (2010-06-14) 
   5 [ ] list: if dir given then show full path of TODO2.txt at end (2010-06-14) 
     5.1 [ ] start rubyforge project for todorb (2010-06-14) 
   6 [ ] allow for ENV VARS such as verbose, plain, force (2010-06-15) 
   7 [ ] list: search terms with - + and = (2010-06-15) 
 
 8 of 8 rows displayed from TODO2.txt 
>>> end

EOF
test_done
