#!/bin/sh
test_description="Testing out add "
. ./test-lib.sh




test_todo_session "Testing of add" <<EOF
>>> todorb add "Add test cases for all operations"
Adding:
  1	[ ] Add test cases for all operations (2009-02-13)
>>> end
>>> todorb add "Add complete date when closing"
Adding:
  2	[ ] Add complete date when closing (2009-02-13)
>>> end

EOF
test_done
