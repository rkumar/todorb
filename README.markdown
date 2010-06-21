# todo.rb

## Command-line todo manager 

This is a port of my [todoapp written in shell](http://github.com/rkumar/todoapp). That todo app is similar to the famous one by Gina Trapani, except that it added various features including sub-tasks, and notes.

I may not make this application as feature-rich as the [shell version](http://github.com/rkumar/todoapp), however I needed to do this so I stop writing command-line programs using shell (portability issues across BSD and GNU versions of all commands). The shell version used `sed` extensively.

The fun things about this app, is that I am having to write ruby code that will give me sed's functionality (subset of course). Some of the stuff is present in sed.rb and is heavily being rewritten and improved as I go along.

The TODO file output is TODO2.txt and is a plain text file. A TAB separates the task number from the Task. I use task numbers, since I may refer to tasks elsewhere. Gina's app never saved a task Id but kept showing them.

After this, I will port over my bug tracker, [bugzy.txt](http://github.com/rkumar/bugzy.txt), which uses a TAB delimited file. It's a cool app to use for bug tracking - you should try it out. I will possibly use sqlite instead of screwing around with a delimited file. 

## Features

1. multiple todo lists (per directory)
2. subtasks
3. priorities - (A) (B)
4. status - [ ], [x], [@] etc
5. tag    - @WORK
6. project - +myproj
7. component - @comp1
8. notes attached to task
9. delete task
10. archive completed tasks
11. colored and plain output
12. hide completed tasks
13. Search, filter, sort tasks

## Sample Output

       3 [ ] Add a close for status close (2010-06-14) 
         3.1 [ ] hello there new a u 3 (2010-06-15) 
             3.1.1 [ ] hello there new a u 3 (2010-06-15) 
             3.1.2 [ ] hello there new a u 3 (2010-06-15) 
             3.1.3 [ ] hello there new a u 3 (2010-06-15) 
         3.2 [ ] hello there new a u 3.2 (2010-06-15) 
             3.2.1 [ ] hello there new a u 3.2.1 (2010-06-15) 
                 3.2.1.1 [ ] hello there new a u 3.2.1.1 
                        * a note for frank (2010-06-15) 
       5 [ ] list: if dir given then show full path of TODO2.txt at end (2010-06-14) 
         5.2 [ ] start rubyforge project for todorb (2010-06-14) 
       6 [@] allow for ENV VARS such as verbose, plain, force (2010-06-15) 
         6.1 [@] what if no serial_number file? (2010-06-14) 
       7 [ ] list: search terms with - + and = @RUBY (2010-06-15) 
       8 [ ] testing out add 1 @MYTAG @RUBY (2010-06-19) 
       9 [ ] testing out another one @RUBY 
              * a note for chris 
              * a note for steve (2010-06-19) 
      11 [x] (A) move common app code to common/cmdapp 
             * refactor it also, so not so reliant on variables (2010-06-20) 
      16 [ ] (A) add aliases to subcommand (2010-06-21) 
     
     17 of 17 rows displayed from TODO2.txt 

## Copyright

Copyright (c) 2010 Rahul Kumar. See LICENSE for details.
