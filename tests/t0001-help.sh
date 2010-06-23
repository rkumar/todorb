#!/bin/sh
test_description="Testing out help "
. ./test-lib.sh




test_todo_session "Testing of help" <<EOF
>>> todorb help
Usage:  [options] [subcommand [options]]
Todo list manager
    -v, --[no-]verbose               Run verbosely
    -f, --file FILENAME              CSV filename
    -d, --dir DIR                    Use TODO file in this directory
        --show-actions               show actions 
        --version                    Show version
    -h, --help                       Show this message

Common Usage:
        todorb add "Text ...."
        todorb list
        todorb pri 1 A
        todorb close 1 

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
   priority - pri
   del - delete
   cu - copyunder
   open - ["status", "open"]
   close - ["status", "closed"]


See '/opt/local/bin/todorb help COMMAND' for more information on a specific command.
>>> end
>>> todorb --help
Usage:  [options] [subcommand [options]]
Todo list manager
    -v, --[no-]verbose               Run verbosely
    -f, --file FILENAME              CSV filename
    -d, --dir DIR                    Use TODO file in this directory
        --show-actions               show actions 
        --version                    Show version
    -h, --help                       Show this message

Common Usage:
        todorb add "Text ...."
        todorb list
        todorb pri 1 A
        todorb close 1 

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
   priority - pri
   del - delete
   cu - copyunder
   open - ["status", "open"]
   close - ["status", "closed"]


See '/opt/local/bin/todorb help COMMAND' for more information on a specific command.
>>> end

EOF
test_done
