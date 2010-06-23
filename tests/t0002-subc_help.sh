#!/bin/sh
test_description="Testing out subc_help "
. ./test-lib.sh




test_todo_session "Testing of subc_help" <<EOF
>>> todorb list --help
Usage: list [options]
List tasks.	 --show-all and others
    -P, --project PROJECTNAME        name of project for add or list
    -p, --priority A-Z               priority code for add or list
    -C, --component COMPONENT        component name for add or list
        --[no-]color, --[no-]colors  colorize listing
    -s, --sort                       sort list on status,priority
        --reverse                    sort list on status,priority reversed
    -g, --grep REGEXP                filter list on pattern
        --renumber                   renumber while listing
        --hide-numbering             hide-numbering while listing 
        --[no-]show-all              show all tasks (incl closed)
        --show-arch                  show all tasks adding archived ones too
>>> end
>>> todorb help list
Usage: list [options]
List tasks.	 --show-all and others
    -P, --project PROJECTNAME        name of project for add or list
    -p, --priority A-Z               priority code for add or list
    -C, --component COMPONENT        component name for add or list
        --[no-]color, --[no-]colors  colorize listing
    -s, --sort                       sort list on status,priority
        --reverse                    sort list on status,priority reversed
    -g, --grep REGEXP                filter list on pattern
        --renumber                   renumber while listing
        --hide-numbering             hide-numbering while listing 
        --[no-]show-all              show all tasks (incl closed)
        --show-arch                  show all tasks adding archived ones too
>>> end

EOF
test_done
