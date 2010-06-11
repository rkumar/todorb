# todo.rb

## Command-line todo manager 

This is a port of my [todoapp written in shell](http://github.com/rkumar/todoapp). That todo app is similar to the famous one by Gina Trapani, except that it added various features including sub-tasks, and notes.

I may not make this application as feature-rich as the [shell version](http://github.com/rkumar/todoapp), however I needed to do this so I stop writing command-line programs using shell (portability issues across BSD and GNU versions of all commands). The shell version used `sed` extensively.

The fun things about this app, is that I am having to write ruby code that will give me sed's functionality (subset of course). Some of the stuff is present in sed.rb and is heavily being rewritten and improved as I go along.

The TODO file output is TODO2.txt and is a plain text file. A TAB separates the task number from the Task. I use task numbers, since I may refer to tasks elsewhere. Gina's app never saved a task Id but kept showing them.

The shell version, todoapp, allowed for any levels of sub-tasks. I have not yet added that, I may.

I also may fork this and make a YAML file, so that the format is standard, especially when having sub-tasks.
After this, I will port over my bug tracker, [bugzy.txt](http://github.com/rkumar/bugzy.txt), which uses a TAB delimited file. It's a cool app to use for bug tracking - you should try it out. I will possibly use sqlite instead of screwing around with a delimited file. 

## Copyright

Copyright (c) 2010 Rahul Kumar. See LICENSE for details.
