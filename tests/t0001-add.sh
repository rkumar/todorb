#!/bin/sh
test_description="Testing out add "
. ./test-lib.sh




test_todo_session "Testing of add" <<EOF
>>> todorb add "Hello this is the first test"
Adding:
  1	[ ] Hello this is the first test (2009-02-13)

>>> todorb add "Hello this is the second test"
Adding:
  2	[ ] Hello this is the second test (2009-02-13)

>>> todorb add "Hello this is the 3rd test"
Adding:
  3	[ ] Hello this is the 3rd test (2009-02-13)

EOF
test_done
