#!/bin/sh
test_description="Testing out list "
. ./test-lib.sh


cat > TODO2.txt <<CATEOF
  1	[x] if no TODO file give proper message to add task (2010-06-14)
  2	[x] what if no serial_number file? (2010-06-14)
  3	[x] Add a close for status close (2010-06-14)
    3.1	[ ] hello there new a u 3 (2010-06-15)
        3.1.1	[ ] hello there new a u 3 (2010-06-15)
        3.1.2	[ ] hello there new a u 3 (2010-06-15)
        3.1.3	[ ] hello there new a u 3 (2010-06-15)
    3.2	[ ] hello there new a u 3.2 (2010-06-15)
        3.2.1	[ ] hello there new a u 3.2.1 (2010-06-15)
            3.2.1.1	[ ] hello there new a u 3.2.1.1 (2010-06-15)
  4	[ ] start rubyforge project for todorb (2010-06-14)
  5	[ ] list: if dir given then show full path of TODO2.txt at end (2010-06-14)
  6	[ ] allow for ENV VARS such as verbose, plain, force (2010-06-15)
  7	[ ] list: search terms with - + and = (2010-06-15)
CATEOF

test_todo_session "Testing of list" <<EOF
>>> todorb
     3.1 [ ] hello there new a u 3 (2010-06-15) 
         3.1.1 [ ] hello there new a u 3 (2010-06-15) 
         3.1.2 [ ] hello there new a u 3 (2010-06-15) 
         3.1.3 [ ] hello there new a u 3 (2010-06-15) 
     3.2 [ ] hello there new a u 3.2 (2010-06-15) 
         3.2.1 [ ] hello there new a u 3.2.1 (2010-06-15) 
             3.2.1.1 [ ] hello there new a u 3.2.1.1 (2010-06-15) 
   4 [ ] start rubyforge project for todorb (2010-06-14) 
   5 [ ] list: if dir given then show full path of TODO2.txt at end (2010-06-14) 
   6 [ ] allow for ENV VARS such as verbose, plain, force (2010-06-15) 
   7 [ ] list: search terms with - + and = (2010-06-15) 
 
 11 of 14 rows displayed from TODO2.txt 
>>> end
>>> todorb list --show-all --no-color
   1 [x] if no TODO file give proper message to add task (2010-06-14) 
   2 [x] what if no serial_number file? (2010-06-14) 
   3 [x] Add a close for status close (2010-06-14) 
     3.1 [ ] hello there new a u 3 (2010-06-15) 
         3.1.1 [ ] hello there new a u 3 (2010-06-15) 
         3.1.2 [ ] hello there new a u 3 (2010-06-15) 
         3.1.3 [ ] hello there new a u 3 (2010-06-15) 
     3.2 [ ] hello there new a u 3.2 (2010-06-15) 
         3.2.1 [ ] hello there new a u 3.2.1 (2010-06-15) 
             3.2.1.1 [ ] hello there new a u 3.2.1.1 (2010-06-15) 
   4 [ ] start rubyforge project for todorb (2010-06-14) 
   5 [ ] list: if dir given then show full path of TODO2.txt at end (2010-06-14) 
   6 [ ] allow for ENV VARS such as verbose, plain, force (2010-06-15) 
   7 [ ] list: search terms with - + and = (2010-06-15) 
 
 14 of 14 rows displayed from TODO2.txt 
>>> end

EOF
test_done
