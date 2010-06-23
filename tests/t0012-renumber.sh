#!/bin/sh
test_description="Testing out renumber "
. ./test-lib.sh


cat > TODO2.txt <<CATEOF
  4	[ ] start rubyforge project for todorb (2010-06-14)
  5	[ ] list: if dir given then show full path of TODO2.txt at end (2010-06-14)
  6	[ ] allow for ENV VARS such as verbose, plain, force (2010-06-15)
  7	[ ] list: search terms with - + and = (2010-06-15)
CATEOF

test_todo_session "Testing of renumber" <<EOF
>>> todorb list --renumber
   1 [ ] start rubyforge project for todorb (2010-06-14) 
   2 [ ] list: if dir given then show full path of TODO2.txt at end (2010-06-14) 
   3 [ ] allow for ENV VARS such as verbose, plain, force (2010-06-15) 
   4 [ ] list: search terms with - + and = (2010-06-15) 
 
 4 of 4 rows displayed from TODO2.txt 
>>> end
>>> todorb
   4 [ ] start rubyforge project for todorb (2010-06-14) 
   5 [ ] list: if dir given then show full path of TODO2.txt at end (2010-06-14) 
   6 [ ] allow for ENV VARS such as verbose, plain, force (2010-06-15) 
   7 [ ] list: search terms with - + and = (2010-06-15) 
 
 4 of 4 rows displayed from TODO2.txt 
>>> end
>>> todorb redo
Saved TODO2.txt as TODO2.txt.org
Redone numbering
>>> end
>>> todorb
   1 [ ] start rubyforge project for todorb (2010-06-14) 
   2 [ ] list: if dir given then show full path of TODO2.txt at end (2010-06-14) 
   3 [ ] allow for ENV VARS such as verbose, plain, force (2010-06-15) 
   4 [ ] list: search terms with - + and = (2010-06-15) 
 
 4 of 4 rows displayed from TODO2.txt 
>>> end

EOF
test_done
