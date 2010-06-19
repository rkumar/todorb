#!/usr/bin/env ruby -w
=begin
  * Name:          todorb.rb
  * Description:   a command line todo list manager
  * Author:        rkumar
  * Date:          2010-06-10 20:10 
  * License:       GPL

=end
require 'rubygems'
#require 'csv'
require 'common/colorconstants'
require 'common/sed'
include ColorConstants
include Sed

PRI_A = YELLOW + BOLD
PRI_B = WHITE  + BOLD
PRI_C = GREEN  + BOLD
PRI_D = CYAN  + BOLD
VERSION = "2.0"
DATE = "2010-06-10"
APPNAME = $0
AUTHOR = "rkumar"
TABSTOP = 4 # indentation of subtasks
ERRCODE = 1

class Todo
  # This class is responsible for all todo task related functionality.
  #
  # == Create a file
  # Adding a task is the first operation.
  #     $ todorb add "Create a project in rubyforge"
  #     $ todorb add "Update Rakefile with project name"
  # The above creates a TODO2.txt file and a serial_number file.
  #
  # == List tasks
  # To list open/unstarted tasks:
  #     $ todorb 
  # To list closed tasks also:
  #     $ todorb --show-all
  #
  # If you are located elsewhere, give directory name:
  #     $ todorb -d ~/
  #
  # == Close a task (mark as done)
  #     $ todorb status close 1
  # 
  # == Add priority
  #     $ todorb pri A 2
  #
  # For more:
  #     $ todorb --help
  #     $ todorb --show-actions
  #
  # == TODO:
  # CLEANUP: add method for extract_item from line since scattered everywhere DONE, to use
  # CLEANUP: add method for checking if string matches an item: is_item?
  #
  def initialize options, argv
 
    @options = options
    @aliases = {}
    @argv = argv
    @file = options[:file]
    ## data is a 2 dim array: rows and fields. It contains each row of the file
    # as an array of strings. The item number is space padded.
    @data = []
    init_vars
  end
  def init_vars
    @todo_default_action = "list"
    @todo_file_path = @options[:file] || "TODO2.txt"
    #@todo_serial_path = File.expand_path("~/serial_numbers")
    @todo_serial_path = "serial_numbers"
    @archive_path = "todo_archive.txt" 
    @todo_delim = "\t"
    @appname = File.basename( Dir.getwd ) #+ ".#{$0}"
    # in order to support the testing framework
    t = Time.now
    ut = ENV["TODO_TEST_TIME"]
    t = Time.at(ut.to_i) if ut
    @now = t.strftime("%Y-%m-%d %H:%M:%S")
    @today = t.strftime("%Y-%m-%d")
    @verbose = @options[:verbose]
    $valid_array = false
    # menu MENU
    #@actions = %w[ list add pri priority depri tag del delete status redo note archive help]
    @actions = {}
    @actions["list"] = "List all tasks.\n\t --hide-numbering --renumber"
    @actions["listsub"] = "List all tasks.\n\t --hide-numbering --renumber"
    @actions["add"] = "Add a task. \n\t #{$0} add <TEXT>\n\t --component C --project P --priority X add <TEXT>"
    @actions["pri"] = "Add priority to task. \n\t #{$0} pri <ITEM> [A-Z]"
    @actions["priority"] = "Same as pri"
    @actions["depri"] = "Remove priority of task. \n\t #{$0} depri <ITEM>"
    @actions["delete"] = "Delete a task. \n\t #{$0} delete <ITEM>"
    @actions["del"] = "Same as delete"
    @actions["status"] = "Change the status of a task. \n\t #{$0} status <STAT> <ITEM>\n\t<STAT> are open closed started pending hold next"
    @actions["redo"] = "Renumbers the todo file starting 1"
    @actions["note"] = "Add a note to an item. \n\t #{$0} note <ITEM> <TEXT>"
    @actions["tag"] = "Add a tag to an item/s. \n\t #{$0} tag <ITEMS> <TEXT>"
    @actions["archive"] = "archive closed tasks to archive.txt"
    @actions["copyunder"] = "Move first item under second (as a subtask). aka cu"

    @actions["help"] = "Display help"
    @actions["addsub"] = "Add a task under another . \n\t #{$0} add <TEXT>\n\t --component C --project P --priority X add <TEXT>"

    # adding some sort of aliases so shortcuts can be defined
    @aliases["open"] = ["status","open"]
    @aliases["close"] = ["status","closed"]
    @aliases["cu"] = ["copyunder"]

    @copying = false # used by copyunder when it calls addsub
    # TODO: config
    # we need to read up from config file and update
  end
  ##
  # check whether this action is mapped to some alias and *changes*
  # @action and @argv if true.
  # @param [String] action asked by user
  # @param [Array] rest of args on command line
  # @return [Boolean] whether it is mapped or not.
  #
  def check_aliases action, args
    ret = @aliases[action]
    if ret
      a = ret.shift
      b = [*ret, *args]
      @action = a
      @argv = b
      #puts " #{@action} ; argv: #{@argv} "
      return true
    end
    return false
  end
  ## 
  # runs method after checking if valid or alias.
  # If not found prints help.
  # @return [0, ERRCODE] success 0.
  def run
    @action = @argv[0] || @todo_default_action
    @action = @action.downcase
    @action.sub!('priority', 'pri')
    @action.sub!(/^del$/, 'delete')


    ret = 0
    @argv.shift
    if @actions.include? @action
      ret = send(@action, @argv)
    else
      # check aliases
      if check_aliases @action, @argv
        ret = send(@action, @argv)
      else
        help @argv
        ret = ERRCODE
      end
    end
    ret ||= 0
    return ret
  end
  def help args
    puts "Actions are "
    @actions.each_pair { |name, val| puts "#{name}\t#{val}" }
    puts " "
    puts "Aliases are "
    @aliases.each_pair { |name, val| puts "#{name}:\t#{val.join(' ')}" }
    0
  end
  def add args
    if args.empty?
      print "Enter todo: "
      STDOUT.flush
      text = gets.chomp
      if text.empty?
        exit ERRCODE
      end
      Kernel.print("You gave me '#{text}'") if @verbose
    else
      text = args.join " "
      Kernel.print("I got '#{text}'") if @verbose
    end
    # convert actual newline to C-a. slash n's are escapes so echo -e does not muck up.
    text.tr! "\n", ''
    Kernel.print("Got '#{text}'\n") if @verbose
    item = _get_serial_number
    die "Could not get a new item number" if item.nil?
    paditem = _paditem(item)
    verbose "item no is:#{paditem}:\n" 
    priority = @options[:priority] ? " (#{@options[:priority]})" : ""
    project  = @options[:project]  ? " +#{@options[:project]}"   : ""
    component  = @options[:component]  ? " @#{@options[:component]}"   : ""
    newtext="#{paditem}#{@todo_delim}[ ]#{priority}#{project}#{component} #{text} (#{@today})"
    File.open(@todo_file_path, "a") { | file| file.puts newtext }
    puts "Adding:"
    puts newtext

    0
  end
  ##
  # reads serial_number file, returns serialno for this app
  # and increments the serial number and writes back.
  def _get_serial_number
    require 'fileutils'
    appname = @appname
    filename = @todo_serial_path
    h = {}
    # check if serial file existing in curr dir. Else create
    if File.exists?(filename)
      File.open(filename).each { |line|
        #sn = $1 if line.match regex
        x = line.split ":"
        h[x[0]] = x[1].chomp
      }
    end
    sn = h[appname] || 1
    # update the sn in file
    nsn = sn.to_i + 1
    # this will create if not exists in addition to storing if it does
    h[appname] = nsn
    # write back to file
    File.open(filename, "w") do |f|
      h.each_pair {|k,v| f.print "#{k}:#{v}\n"}
    end
    return sn
  end
  ##
  # After doing a redo of the numbering, we need to reset the numbers for that app
  def _set_serial_number number
    appname = @appname
    pattern = Regexp.new "^#{appname}:.*$"
    filename = @todo_serial_path
    _backup filename
    change_row filename, pattern, "#{appname}:#{number}"
  end
  ##
  # add a subtask
  # @param [Array] 1. item under which to place, 2. text
  # @return 
  # @example:
  #    addsub 1 "A task"   
  #       => will get added as 1.1 or 1.2 etc
  #    addsub 1.3 "a task"
  #       => will get added as 1.3.x
  def addsub args
    under = args.shift
    text = args.join " "
    exit unless text
    #puts "under #{under} text: #{text} "
    lastlinect = nil
    lastlinetext = nil
    # look for last item below given task (if there is)
    egrep( [@todo_file_path], Regexp.new("#{under}\.[0-9]+	")) do |fn,ln,line|
      lastlinect = ln
      lastlinetext = line
      puts line
    end
    if lastlinect
      verbose "Last line found #{lastlinetext} " 
      m = lastlinetext.match(/\.([0-9]+)	/)
      lastindex = m[1].to_i
      # check if it has subitems, find last one only for linecount
      egrep( [@todo_file_path], Regexp.new("#{under}\.#{lastindex}\.[0-9]+	")) do |fn,ln,line|
        lastlinect = ln
      end
      lastindex += 1
      item = "#{under}.#{lastindex}"
    else
      # no subitem found, so this is first
      item = "#{under}.1"
      # get line of parent
      found = nil
      egrep( [@todo_file_path], Regexp.new("#{under}	")) do |fn,ln,line|
        lastlinect = ln
        found = true
      end
      die "Task #{under} not found" unless found
    end
    die "Could not determine which line to insert under" unless lastlinect
    verbose "item is #{item} ::: line #{lastlinect} " 

    # convert actual newline to C-a. slash n's are escapes so echo -e does not muck up.
    text.tr! "\n", ''
    Kernel.print("Got '#{text}'\n") if @verbose
    paditem = _paditem(item)
    print "item no is:#{paditem}:\n" if @verbose
    priority = @options[:priority] ? " (#{@options[:priority]})" : ""
    project  = @options[:project]  ? " +#{@options[:project]}"   : ""
    component  = @options[:component]  ? " @#{@options[:component]}"   : ""
    level = (item.split '.').length
    indent = " " * (TABSTOP * (level-1))
    newtext=nil
    if @copying
      newtext="#{indent}#{item}#{@todo_delim}#{text}"
    else
      newtext="#{indent}#{paditem}#{@todo_delim}[ ]#{priority}#{project}#{component} #{text} (#{@today})"
    end
    raise "Cannot insert blank text. Programmer error!" unless newtext
    _backup
    puts "Adding:"
    puts newtext
    insert_row(@todo_file_path, lastlinect, newtext)
  end
  def _backup filename=@todo_file_path
    require 'fileutils'
    FileUtils.cp filename, "#{filename}.org"
  end
  def check_file filename=@todo_file_path
    File.exists?(filename) or die "#{filename} does not exist in this dir. Use 'add' to create an item first."
  end
  def die text
    $stderr.puts text
    exit ERRCODE
  end
  # prints messages to stderr
  # All messages should go to stderr.
  # Keep stdout only for output which can be used by other programs
  def message text
    $stderr.puts text
  end
  # print to stderr only if verbose set
  def verbose text
    message(text) if @options[:verbose]
  end
  # print to stderr only if verbose set
  def warning text
    print_red("WARNING: #{text}") 
  end
  ##
  # for historical reasons, I pad item to 3 spaces in text file.
  # It used to help me in printing straight off without any formatting in unix shell
  def _paditem item
    return sprintf("%3s", item)
  end
  ##
  # populates array with open tasks (or all if --show-all)
  # DO NOT USE in conjunction with save_array since this is only open tasks
  # Use load_array with save_array
  def populate
    $valid_array = false # this array object should not be saved
    check_file
    @ctr = 0
    @total = 0
    #CSV.foreach(@file,:col_sep => "\t") do |row|    # 1.9 2009-10-05 11:12 
    File.open(@file).each do |line|
      row = line.chomp.split "\t"
      @total += 1
      if @options[:show_all]
        @data << row
        @ctr += 1
      else
        unless row[1] =~ /^\[x\]/ 
          @data << row
          @ctr += 1
        end
      end
    end
  end
  ##
  # filters output based on project and or component and or priority
  def filter
    project = @options[:project]
    component = @options[:component]
    priority = @options[:priority]
    if project
      r = Regexp.new "\\+#{project}"
      @data = @data.select { |row| row[1] =~ r }
    end
    if component
      r = Regexp.new "@#{component}"
      @data = @data.select { |row| row[1] =~ r }
    end
    if priority
      r = Regexp.new "\\(#{priority}\\)"
      @data = @data.select { |row| row[1] =~ r }
    end
  end
  def list args
    populate
    grep if @options[:grep]
    filter if @options[:filter]
    sort if @options[:sort]
    renumber if @options[:renumber]
    colorize # << currently this is where I print !! Since i colorize the whole line
    puts " " 
    puts " #{@data.length} of #{@total} rows displayed from #{@todo_file_path} "
    return 0
  end
  def print_todo
    @ctr = 0
    @data.each { |row|  
      unless row[1] =~ /^\[x\]/ 
        puts " #{row[0]} | #{row[1]} " #unless row[1] =~ /^\[x\]/
        @ctr += 1
      end
    }
  end
  def each
    @data.each { |row|  
        yield row
    }
  end
  def active_tasks
    @ctr = 0
    @data.each { |row|  
      unless row[1] =~ /^\[x\]/ 
        yield row
        @ctr += 1
      end
    }
  end
  ##
  # colorize each line, if required.
  # However, we should put the colors in some Map, so it can be changed at configuration level.
  #
  def colorize
    colorme = @options[:colorize]
    @data.each do |r| 
      if @options[:hide_numbering]
        string = "#{r[1]} "
      else
        string = " #{r[0]} #{r[1]} "
      end
      if colorme
        m=string.match(/\(([A-Z])\)/)
        if m 
          case m[1]
          when "A", "B", "C", "D"
            pri = self.class.const_get("PRI_#{m[1]}")
            #string = "#{YELLOW}#{BOLD}#{string}#{CLEAR}"
            string = "#{pri}#{string}#{CLEAR}"
          else
            string = "#{NORMAL}#{GREEN}#{string}#{CLEAR}"
            #string = "#{BLUE}\e[6m#{string}#{CLEAR}"
            #string = "#{BLUE}#{string}#{CLEAR}"
          end 
        else
          string = "#{NORMAL}#{string}#{CLEAR}"
        end
      end # colorme
      ## since we've added notes, we convert C-a to newline with spaces
      # so it prints in next line with some neat indentation.
      string.gsub!('', "\n        ")
      #string.tr! '', "\n"
      puts string
    end
  end
  def sort
    @data.sort! { |a,b| b[1] <=> a[1] }
  end
  def grep
    r = Regexp.new @options[:grep]
    #@data = @data.grep r
    @data = @data.find_all {|i| i[1] =~ r }
  end
  ##
  # Adds or changes priority for a task
  #
  # @param [Array] priority, single char A-Z, item or items
  # @return 
  # @example:
  # pri A 5 6 7
  # pri 5 6 7 A
  # -- NO LONGER this complicated system  pri A 5 6 7 B 1 2 3
  # -- NO LONGER this complicated system  pri 5 6 7 A 1 2 3 B

  # 2010-06-19 15:21 total rewrite, so we fetch item from array and warn if absent.
  def pri args
    errors = 0
    ctr = 0
    #populate # populate removed closed task so later saving will lose tasks
    load_array
    ## if the first arg is priority then following items all have that priority
    ## if the first arg is item/s then wait for priority and use that
    prior, items = _separate args, /^[A-Z]$/ 
    total = items.count
    die "#{@action}: priority expected [A-Z]" unless prior
    die "#{@action}: items expected" unless items
    verbose "args 0 is #{args[0]}. pri #{prior} items #{items} "
    items.each do |item| 
      row = get_item(item)
      if row
        puts " #{row[0]} : #{row[1]} "
        # remove existing priority if there
        if row[1] =~ /\] (\([A-Z]\) )/
          row[1].sub!(/\([A-Z]\) /,"")
        end
        ret = row[1].sub!(/\] /,"] (#{prior}) ")
        if ret
          puts " #{GREEN}#{row[0]} : #{row[1]} #{CLEAR}"
          ctr += 1
        else
          die "Error in sub(): #{row}.\nNothing saved. "
        end
      else
        errors += 1
        warning "#{item} not found."
      end
    end

    message "#{errors} error/s" if errors > 0
    if ctr > 0
      puts "Changed priority of #{ctr} task/s"
      save_array 
      return 0 
    end
    return ERRCODE
  end
  ##
  # Remove the priority of a task
  #
  # @param [Array] items to deprioritize
  # @return 
  def depri(args)
    new_change_items args, /\([A-Z]\) /,""
  end
  public
  def _depri(args)
    load_array
    puts "depri got #{args} " if @verbose 
    args.each { |item|  
    
    }
    each do |row|
      item = row[0].sub(/^[ -]*/,'')
      if args.include? item
        if row[1] =~ /\] (\([A-Z]\) )/
          puts row[1]
          row[1].sub!(/\([A-Z]\) /,"")
          puts "#{RED}#{row[1]}#{CLEAR}"
        end
      end
    end
    save_array 
  end
  ##
  # load data into array as item and task
  # @see save_array to write
  def load_array
    #return if $valid_array
    $valid_array = false
    @data = []
    File.open(@todo_file_path).each do |line|
      row = line.chomp.split "\t"
      @data << row
    end
    $valid_array = true
  end
  ## 
  # saves the task array to disk
  # Please use load_array to load, and not populate
  def save_array
    raise "Cannot save array! Please use load_array to load" if $valid_array == false

    File.open(@todo_file_path, "w") do |file| 
      @data.each { |row| file.puts "#{row[0]}\t#{row[1]}" }
    end
  end
  ## 
  # change priority of given item to priority in array
  # @ deprecated now DELETE TODO:
  private
  def _pri item, pri
    paditem = _paditem(item)
    rx = Regexp.new "\s+#{item}$"
    @data.each { |row| 
      if row[0] =~ rx
        puts " #{row[0]} : #{row[1]} "
        if row[1] =~ /\] (\([A-Z]\) )/
          row[1].sub!(/\([A-Z]\) /,"")
        end
        row[1].sub!(/\] /,"] (#{pri}) ")
        puts " #{GREEN}#{row[0]} : #{row[1]} #{CLEAR}"
        return true
      end
    }
    puts " #{RED} no such item #{item}  #{CLEAR} "
    return false

  end
  ##
  # Appends a tag to task
  # FIXME: check with subtasks
  #
  # @param [Array] items and tag, or tag and items
  # @return 
  def tag(args)
    tag, items = _separate args
    #new_change_items items do |item, row|
      #ret = row[1].sub!(/ (\([0-9]{4})/, " @#{tag} "+'\1')
      #ret
    #end
    new_change_items(items, / (\([0-9]{4})/, " @#{tag} "+'\1')
  end
  public
  def oldtag(args)
    puts "tags args #{args} "
    items_first = items_first? args
    items = []
    tag = nil
    args.each do |arg| 
      if arg =~ /^[a-zA-Z]/ 
        tag = arg
      elsif arg =~ /^[0-9\.]+$/
        items << arg
      end
    end
    #items.each { |i| change_row }
    change_file @todo_file_path do |line|
      item = line.match(/^ *([0-9\.]+)/)
      if items.include? item[1]
        puts "#{line}" if @verbose
        line.sub!(/$/, " @#{tag}")
        puts "#{RED}#{line}#{CLEAR} " if @verbose
      end
    end
  end
  ##
  # deletes one or more items
  #
  # @param [Array, #include?] items to delete
  # @return 
  # FIXME: if invalid item passed I have no way of giving error 
  public
  def delete(args)
    puts "delete with #{args} " if @verbose 
    _backup
    lines = _read @todo_file_path
    args.each { |item| 
      ans = "N"
      rx = regexp_item item # Regexp.new(" +#{item}#{@todo_delim}")
      lines.delete_if { |line|
        flag = line =~ rx
        puts " #{item} : #{line} : #{flag} " if flag
        if flag
          if @options[:force]
            true
          else
            puts line
            print "Do you wish to delete (Y/N): "
            STDOUT.flush
            ans = STDIN.gets.chomp
            ans =~ /[Yy]/
          end
        end
      }
      if ans =~ /[Yy]/ && @options[:recursive]
        puts "recursive"
        #rx = Regexp.new("^\s*-\s*#{item}[\d\.]+#{@todo_delim}")
        rx = Regexp.new("\s+#{item}\.") # #{@todo_delim}")
        lines.delete_if { |line|
          flag = line =~ rx
          puts " rec #{item} : #{line} : #{flag} " if flag
          if flag
            if @options[:force]
              true
            else
              puts line
              print "Do you wish to delete (Y/N): "
              STDOUT.flush
              ans = STDIN.gets.chomp
              ans =~ /[Yy]/
            end
          end
        }
      end
    } # args.each
    _write @todo_file_path, lines
    0
  end
  ##
  # Change status of given items
  #
  # @param [Array, #include?] items to change status of
  # @return [true, false] success or fail
  public
  def status(args)
    stat, items = _separate args #, /^[a-zA-Z]/ 
    verbose "Items: #{items} : stat #{stat} "
    status, newstatus = _resolve_status stat
    if status.nil?
      die "Status #{stat} is invalid!"
    end
    # this worked fine for single items, but not for recursive changes 
    #ctr = change_items(items, /(\[.\])/, "[#{newstatus}]")
    totalitems = []
    #ret = line.sub!(/(\[.\])/, "[#{newstatus}]")
    load_array
    items.each { |item| 
      a = get_item_subs item
      if a
        a.each { |e| 
          totalitems << e[0].strip
        }
      else
        # perhaps I should pass item into total and let c_i handle error message
        warning "No tasks found for #{item}"
      end
    }
    new_change_items(totalitems, /(\[.\])/, "[#{newstatus}]")
    0
  end
  def oldstatus(args)
    stat, items = _separate args #, /^[a-zA-Z]/ 
    verbose "Items: #{items} : stat #{stat} "
    status, newstatus = _resolve_status stat
    if status.nil?
      die "Status #{stat} is invalid!"
    end
    # this worked fine for single items, but not for recursive changes 
    #ctr = change_items(items, /(\[.\])/, "[#{newstatus}]")
    total = items.count
    ctr = 0
    errors = 0
    erritems = []
    change_file @todo_file_path do |line|
      f = line.split @todo_delim
      item = f[0].sub!(/\s*/, '')
      if items.include? item
        items.delete item
        ret = line.sub!(/(\[.\])/, "[#{newstatus}]")
        if ret
          ctr += 1 
          verbose "Changed #{item} " 
        else
          errors += 1
          erritems << item
          warning "Failed to change #{item}: #{line}"
        end
      else
        # check if line matches a subtask, then change
        if item_matches_subtask? args, item
          items.delete item
          ret = line.sub!(/(\[.\])/, "[#{newstatus}]")
          if ret
            ctr += 1 
            verbose "Changed #{item} " 
          else
            errors += 1
            erritems << item
            warning "Failed to change #{item}: #{line}"
          end
        end
      end
    end
    puts "Changed status of #{ctr} tasks"
    if !items.empty?
      message "The following tasks were not found #{items}"
    end
    if !erritems.empty?
      message "The following tasks were not updated due to error in sub() #{erritems}"
    end
    return ERRCODE if errors > 0 or ctr == 0
    return 0 if total == ctr
    return ERRCODE
    #change_items items do |item, line|
      #puts line if @verbose
      #line.sub!(/(\[.\])/, "[#{newstatus}]")
      #puts "#{RED}#{line}#{CLEAR}" if @verbose
    #end
  end
  ##
  # separates args into tag or subcommand and items
  # This allows user to pass e.g. a priority first and then item list
  # or item list first and then priority. 
  # This can only be used if the tag or pri or status is non-numeric and the item is numeric.
  def _separate args, pattern=nil #/^[a-zA-Z]/ 
    tag = nil
    items = []
    args.each do |arg| 
      if arg =~ /^[0-9\.]+$/
        items << arg
      else
        tag = arg
        if pattern
          die "#{@action}: #{arg} appears invalid." if arg !~ pattern
        end
      end
    end
    items = nil if items.empty?
    return tag, items
  end
  ##
  # Renumber while displaying
  # @return [true, false] success or fail
  private
  def renumber
    ## this did not account for subtasks
    #@data.each_with_index { |row, i| 
      #paditem = _paditem(i+1)  
      #row[0] = paditem
    #}
    ## this accounts for subtasks
    ctr = 0
    @data.each_with_index { |row, i| 
      # main task, increment counter
      if row[0] =~ /^ *[0-9]+$/
        ctr += 1
        paditem = _paditem(ctr)  
        row[0] = paditem
      else
        # assume its a subtask, just change the outer number
        row[0].sub!(/[0-9]+\./, "#{ctr}.")
      end
    }
  end
  ##
  # For given items, add a note
  #
  # @param [Array, #include?] items to add note to, note
  # @return [true, false] success or fail
  public
  def note(args)
    _backup
    text = args.pop
    new_change_items args do |item, row|
      m = row[0].match(/^ */)
      indent = m[0]
      ret = row[1].sub!(/ (\([0-9]{4})/," #{indent}* #{text} "+'\1')
      ret
    end
  end
  ##
  # Archive all items
  #
  # @param none (ignored)
  # @return [true, false] success or fail
  public
  def archive(args=nil)
    filename = @archive_path
    file = File.open(filename, "a") 
    ctr = 0
    delete_row @todo_file_path do |line|
      if line =~ /\[x\]/
        file.puts line
        ctr += 1
        puts line if @verbose
        true
      end
    end
    file.close
    puts "Archived #{ctr} tasks."
  end
  # Copy given item under second item
  #
  # @param [Array] 2 items, move first under second
  # @return [Boolean] success or fail
  public
  def copyunder(args)
    if args.nil? or args.count != 2
      die "copyunder expects only 2 args: from and to item, both existing"
    end
    from = args[0]
    to = args[1]
    # extract item from
    lastlinetext = nil
    rx = regexp_item from
    egrep( [@todo_file_path], rx) do |fn,ln,line|
      lastlinect = ln
      lastlinetext = line
      puts line
    end
    # removing everything from start to status inclusive
    lastlinetext.sub!(/^.*\[/,'[').chomp!
    puts lastlinetext
    @copying = true
    addsub [to, lastlinetext]
    # remove item number and status ? 
    # give to addsub to add.
    # delete from
    delete_item from
    # take care of data in addsub (if existing, and also /
  end
  ##
  # Get row for given item or nil.
  #
  # @param [String] item to retrieve
  # @return [Array, nil] success or fail
  # Returns row from @data as String[2] comprising item and rest of line.
  public
  def get_item(item)
    raise "Please load array first!" if @data.empty?
    verbose "get_item got #{item}."
    #rx = regexp_item(item)
    rx = Regexp.new("^ +#{item}$")
    @data.each { |row|
      verbose "    get_item read #{row[0]}."
      return row if row[0] =~ rx
    }
    # not found
    return nil
  end
  ## 
  # list task and its subtasks
  #  just testing this out
  def listsub(args)
    load_array
    args.each { |item|  
      a = get_item_subs item
      puts "for #{item} "
      a.each { |e| puts " #{e[0]} #{e[1]} " }
    }
    0
  end
  # get item and its subtasks
  # (in an attempt to make recursive changes cleaner)
  # @param item (taken from command line)
  # @return [Array, nil] row[] objects
  def get_item_subs(item)
    raise "Please load array first!" if @data.empty?
    verbose "get_item got #{item}."
    #rx = regexp_item(item)
    rx = Regexp.new("^ +#{item}$")
    rx2 = Regexp.new("^ +#{item}\.")
    rows = []
    @data.each { |row|
      verbose "    get_item read #{row[0]}."
      if row[0] =~ rx
        rows << row 
        rx = rx2
      end
    }
    return nil if rows.empty?
    return rows
  end
  ##
  # For given items, search replace or yield item and row[]
  #
  # @param [Array, #each] items to change
  # @yield item, row[] - split of line on tab.
  # @return [0, ERRCODE] success or fail
  public
  def new_change_items items, pattern=nil, replacement=nil
    ctr = errors = 0
    #tag, items = _separate args
    # or items = args
    die "#{@action}: items expected" unless items
    total = items.count
    load_array
    items.each do |item| 
      row = get_item(item)
      if row
        if pattern
          puts " #{row[0]} : #{row[1]} " if @verbose 
          ret = row[1].sub!(pattern, replacement)
          if ret
            puts " #{GREEN}#{row[0]} : #{row[1]} #{CLEAR}"
            ctr += 1
          else
            # this is since there could be a programmer error.
            die "Possible error in sub() - No replacement: #{row[0]} : #{row[1]}.\nNothing saved. "
          end
        else
          puts " #{row[0]} : #{row[1]} " if @verbose 
          ret = yield item, row
          if ret
            ctr += 1 
            puts " #{GREEN}#{row[0]} : #{row[1]} #{CLEAR}"
          end
        end
      else
        errors += 1
        warning "#{item} not found."
      end
    end
    message "#{errors} error/s" if errors > 0
    if ctr > 0
      puts "Changed #{ctr} task/s"
      save_array 
      return 0 
    end
    return ERRCODE
  end
  ## does a straight delete of an item, no questions asked
  # internal use only.
  def delete_item item
    filename=@todo_file_path
    d = _read filename
    d.delete_if { |row| line_contains_item?(row, item) }
    _write filename, d
  end
  def line_contains_item? line, item
    rx = regexp_item item
    return line.match rx
  end
  def row_contains_item? row, item
    rx = Regexp.new("^ +#{item}")
    return row[0].match rx
  end
  # return a regexp for an item to do matches on - WARNING INCLUDES TAB
  def regexp_item item
    Regexp.new("^ +#{item}#{@todo_delim}")
  end
  def extract_item line
      item = line.match(/^ *([0-9\.]+)/)
      return nil if item.nil?
      return item[1]
  end
  ##
  # yields lines from file that match the given item
  # We do not need to now parse and match the item in each method
  def change_items args, pattern=nil, replacement=nil
    changed_ctr = 0
    change_file @todo_file_path do |line|
      item = line.match(/^ *([0-9\.]+)/)
      puts "got item: #{item[1]} " if @verbose 
      if args.include? item[1]
        if pattern
          puts line if @verbose
          ret = line.sub!(pattern, replacement)
          changed_ctr += 1 if ret
          print_red line if @verbose
        else
          yield item[1], line
        end
      end
    end
    return changed_ctr
  end
  ##
  # Redoes the numbering in the file.
  # Useful if the numbers have gone high and you want to start over.
  def redo args
    #require 'fileutils'
    #FileUtils.cp @todo_file_path, "#{@todo_file_path}.org"
    _backup
    puts "Saved #{@todo_file_path} as #{@todo_file_path}.org"
    #ctr = 1
    #change_file @todo_file_path do |line|
      #paditem = _paditem ctr
      #line.sub!(/^ *[0-9]+/, paditem)
      #ctr += 1
    #end
    ctr = 0
    change_file @todo_file_path do |line|
      if line =~ /^ *[0-9]+\t/
        ctr += 1
        paditem = _paditem ctr
        line.sub!(/^ *[0-9]+\t/, "#{paditem}#{@todo_delim}")
      else
        # assume its a subtask, just change the outer number
        line.sub!(/[0-9]+\./, "#{ctr}.")
      end
    end
    _set_serial_number ctr
    puts "Redone numbering"
  end
  ##
  # does this command start with items or something else
  private
  def items_first?(args)
    return true if args[0] =~ /^[0-9]+$/
    return false
  end
  def print_red line
    puts "#{RED}#{line}#{CLEAR}"
  end
  private
  def _resolve_status stat
    status = nil
    #puts " got #{stat} "
    case stat
    when "@","sta","star","start","started"
          status="start"
          newstatus = "@"
    when "P","pen","pend","pending"
          status="pend"
          newstatus = "P"
    when "x","clo","clos","close","closed"
          status="close"
          newstatus = "x"
    when "1","next"
      status="next"
      newstatus = "1"
    when "H","hold" 
      status="hold"
      newstatus = "H"
    when "u","uns","unst","unstart","unstarted","open" 
      status="unstarted"
      newstatus = " "
    end
    #puts " after #{status} "
    #newstatus=$( echo $status | sed 's/^start/@/;s/^pend/P/;s/^close/x/;s/hold/H/;s/next/1/;s/^unstarted/ /' )
    return status, newstatus
  end
  ##
  # given some items, checks given line to see if it contains subtasks of given items
  # if item is 3.1, does line contain 3.1.x 3.1.x.x etc or not
  # @example
  #     [1, 2, 3, 3.1, 3.1.1, 3.2, 3.3 ... ], "3.1.1"
  def item_matches_subtask? items, item
    items.each { |e| 
      rx = Regexp.new "#{e}\."
      m = item.match rx
      return true if m
    }
    return false
  end
  ##     [1, 2, 3, 3.1, 3.1.1, 3.2, 3.3 ... ], " 3.1.1\t[ ] some task"

  def self.main args
    ret = nil
    begin
      # http://www.ruby-doc.org/stdlib/libdoc/optparse/rdoc/classes/OptionParser.html
      require 'optparse'
      options = {}
      options[:verbose] = false
      options[:colorize] = true
      # adding some env variable pickups, so you don't have to keep passing.
      showall = ENV["TODO_SHOW_ALL"]
      if showall
        options[:show_all] = (showall == "0") ? false:true
      end
      plain = ENV["TODO_PLAIN"]
      if plain
        options[:colorize] = (plain == "0") ? false:true
      end

      OptionParser.new do |opts|
        opts.banner = "Usage: #{$0} [options] action"

        opts.separator ""
        opts.separator "Specific options:"


        opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
          options[:verbose] = v
        end
        opts.on("-f", "--file FILENAME", "CSV filename") do |v|
          options[:file] = v
        end
        opts.on("-P", "--project PROJECTNAME", "name of project for add or list") { |v|
          options[:project] = v
          options[:filter] = true
        }
        opts.on("-p", "--priority A-Z",  "priority code for add or list") { |v|
          options[:priority] = v
          options[:filter] = true
        }
        opts.on("-C", "--component COMPONENT",  "component name for add or list") { |v|
          options[:component] = v
          options[:filter] = true
        }
        opts.on("--force", "force delete or add without prompting") do |v|
          options[:force] = v
        end
        opts.on("--recursive", "operate on subtasks also for delete, status") do |v|
          options[:recursive] = v
        end
        opts.separator ""
        opts.separator "List options:"

        opts.on("--[no-]color", "--[no-]colors",  "colorize listing") do |v|
          options[:colorize] = v
          options[:color_scheme] = 1
        end
        opts.on("-s", "--sort", "sort list on priority") do |v|
          options[:sort] = v
        end
        opts.on("-g", "--grep REGEXP", "filter list on pattern") do |v|
          options[:grep] = v
        end
        opts.on("--renumber", "renumber while listing") do |v|
          options[:renumber] = v
        end
        opts.on("--hide-numbering", "hide-numbering while listing ") do |v|
          options[:hide_numbering] = v
        end
        opts.on("--[no-]show-all", "show all tasks (incl closed)") do |v|
          options[:show_all] = v
        end

        opts.separator ""
        opts.separator "Common options:"

        opts.on_tail("-d DIR", "--dir DIR", "Use TODO file in this directory") do |v|
          require 'FileUtils'
          dir = File.expand_path v
          if File.directory? dir
            options[:dir] = dir
            # changing dir is important so that serial_number file is the current one.
            FileUtils.cd dir
          else
            die "#{RED}#{v}: no such directory #{CLEAR}"
          end
        end
        # No argument, shows at tail.  This will print an options summary.
        # Try it and see!
        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit 0
        end

        opts.on_tail("--show-actions", "show actions ") do |v|
          todo = Todo.new(options, ARGV)
          todo.help nil
          exit 0
        end

        opts.on_tail("--version", "Show version") do
          puts "#{APPNAME} version #{VERSION}, #{DATE}"
          puts "by #{AUTHOR}. This software is under the GPL License."
          exit 0
        end
      end.parse!(args)

      options[:file] ||= "TODO2.txt"
      if options[:verbose]
        p options
        print "ARGV: " 
        p args #ARGV 
      end
      #raise "-f FILENAME is mandatory" unless options[:file]

      todo = Todo.new(options, args)
      ret = todo.run
    ensure
    end
  return ret
  end # main
end # class Todo

if __FILE__ == $0
  exit Todo.main(ARGV) 
end
