#!/bin/sh
test_description="Testing out show_actions "
. ./test-lib.sh




test_todo_session "Testing of show_actions" <<EOF
>>> todorb --show-actions
Commands are:
   list : List tasks.	 --show-all and others
   add : Add a task.
   pri : Add priority to task. 
   depri : Remove priority of task. 
	 todorb depri <TASK>
   delete : Delete a task. 
	 todorb delete <TASK>
   status : Change the status of a task. 	<STATUS> are open closed started pending hold next
   redo : Renumbers the todo file starting 1
   note : Add a note to a task.
   tag : Add a tag to an item/s. 
   archive : archive closed tasks to archive.txt
   copyunder : Move first task under second (as a subtask). aka cu
   addsub : Add a task under another.

Aliases: 
   a - add
   p - pri
   del - delete
   cu - copyunder
   open - ["status", "open"]
   close - ["status", "closed"]


See '/opt/local/bin/todorb help COMMAND' for more information on a specific command.
>>> end

EOF
test_done
