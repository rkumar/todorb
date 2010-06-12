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
include ColorConstants
require 'common/sed'
include Sed

PRI_A = YELLOW + BOLD
PRI_B = WHITE  + BOLD
PRI_C = GREEN  + BOLD
PRI_D = CYAN  + BOLD
VERSION = "1.0"
DATE = "2010-06-10"
APPNAME = $0
AUTHOR = "rkumar"

class Todo
  def initialize options, argv
 
    @options = options
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
    @archive_path = "archive.txt" # should take path of todo and put there TODO:
    @todo_delim = "\t"
    @appname = File.basename( Dir.getwd ) #+ ".#{$0}"
    t = Time.now
    @now = t.strftime("%Y-%m-%d %H:%M:%S")
    @today = t.strftime("%Y-%m-%d")
    @verbose = @options[:verbose]
    #@actions = %w[ list add pri priority depri tag del delete status redo note archive help]
    @actions = {}
    @actions["list"] = "List all tasks.\n\t --hide-numbering --renumber"
    @actions["add"] = "Add a task. \n\t #{$0} add <TEXT>\n\t --component C --project P --priority X add <TEXT>"
    @actions["pri"] = "Add priority to task. \n\t #{$0} pri <ITEM> [A-Z]"
    @actions["priority"] = "Same as pri"
    @actions["depri"] = "Remove priority of task. \n\t #{$0} depri <ITEM>"
    @actions["delete"] = "Delete a task. \n\t #{$0} delete <ITEM>"
    @actions["del"] = "Same as delete"
    @actions["status"] = "Change the status of a task. \n\t #{$0} status <STAT> <ITEM>\n\t<STAT> are closed started pending unstarted hold next"
    @actions["redo"] = "Renumbers the todo file starting 1"
    @actions["note"] = "Add a note to an item. \n\t #{$0} note <ITEM> <TEXT>"
    @actions["archive"] = "archive closed tasks to archive.txt"
    @actions["help"] = "Display help"


    # TODO config
    # we need to read up from config file and update
  end
  # menu MENU
  def run
    @action = @argv[0] || @todo_default_action
    @action = @action.downcase
    @action.sub!('priority', 'pri')
    @action.sub!(/^del$/, 'delete')


    @argv.shift
    if @actions.include? @action
      send(@action, @argv)
    else
      help @argv
    end
  end
  def help args
    #puts "Actions are #{@actions.join(", ")} "
    @actions.each_pair { |name, val| puts "#{name}\t#{val}" }
  end
  def add args
    if args.empty?
      print "Enter todo: "
      STDOUT.flush
      text = gets.chomp
      if text.empty?
        exit 1
      end
      Kernel.print("You gave me '#{text}'")
    else
      text = args.join " "
      Kernel.print("I got '#{text}'")
    end
    # convert actual newline to C-a. slash n's are escapes so echo -e does not muck up.
    text.tr! "\n", ''
    Kernel.print("Got '#{text}'\n")
    item = _get_serial_number
    paditem = _paditem(item)
    print "item no is:#{paditem}:\n"
    priority = @options[:priority] ? " (#{@options[:priority]})" : ""
    project  = @options[:project]  ? " +#{@options[:project]}"   : ""
    component  = @options[:component]  ? " @#{@options[:component]}"   : ""
    newtext="#{paditem}#{@todo_delim}[ ]#{priority}#{project}#{component} #{text} (#{@today})"
    puts "Adding"
    puts newtext
    File.open(@todo_file_path, "a") { | file| file.puts newtext }

  end
  ##
  # reads serial_number file, returns serialno for this app
  # and increments the serial number and writes back.
  def _get_serial_number
    require 'fileutils'
    appname = @appname
    filename = "/Users/rahul/serial_numbers"
    h = {}
    File.open(filename).each { |line|
      #sn = $1 if line.match regex
      x = line.split ":"
      h[x[0]] = x[1].chomp
    }
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
    filename = "/Users/rahul/serial_numbers"
    _backup filename
    change_row filename, pattern, "#{appname}:#{number}"
  end
  def _backup filename=@todo_file_path
    require 'fileutils'
    FileUtils.cp filename, "#{filename}.org"
  end
  ##
  # for historical reasons, I pad item to 3 spaces in text file.
  # It used to help me in printing straight off without any formatting in unix shell
  def _paditem item
    return sprintf("%3s", item)
  end
  def populate
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
  def list args
    populate
    grep if @options[:grep]
    sort if @options[:sort]
    renumber if @options[:renumber]
    colorize # << currently this is where I print !! Since i colorize the whole line
    puts 
    puts " #{@ctr} of #{@total} rows displayed from #{@todo_file_path} "

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
  # @ example:
  # pri A 5 6 7
  # pri 5 6 7 A
  # pri A 5 6 7 B 1 2 3
  # pri 5 6 7 A 1 2 3 B

  def pri args
    populate
    changeon = nil
    items = []
    prior = nil
    item = nil
    ## if the first arg is priority then following items all have that priority
    ## if the first arg is item/s then wait for priority and use that
    if args[0] =~ /^[A-Z]$/ 
      changeon = :ITEM
    elsif args[0] =~ /^[0-9]+$/
      changeon = :PRI
    else
      puts "ERROR! "
      exit 1
    end
    puts "args 0 is #{args[0]} "
    args.each do |arg| 
      if arg =~ /^[A-Z]$/ 
        prior = arg #$1
        if changeon == :PRI
          puts " changing previous items #{items} to #{prior} "
          items.each { |i| _pri(i, prior) }
          items = []
        end
      elsif arg =~ /^[0-9]+$/
        item = arg #$1
        if changeon == :ITEM
          puts " changing #{item} to #{prior} "
          _pri(item, prior)
        else
          items << item
        end
      else
        puts "ERROR in arg :#{arg}:"
      end
    end
    save_array
  end
  ##
  # Reove the priority of a task
  #
  # @param [Array] items to deprioritize
  # @return 
  public
  def depri(args)
    populate
    puts "depri got #{args} "
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
  end
  ## 
  # saves the task array to disk
  def save_array
    File.open(@todo_file_path, "w") do |file| 
      @data.each { |row| file.puts "#{row[0]}\t#{row[1]}" }
    end
  end
  ## 
  # change priority of given item to priority in array
  private
  def _pri item, pri
    paditem = _paditem(item)
    @data.each { |row| 
      if row[0] == paditem
        puts " #{row[0]} : #{row[1]} "
        if row[1] =~ /\] (\([A-Z]\) )/
          row[1].sub!(/\([A-Z]\) /,"")
        end
        row[1].sub!(/\] /,"] (#{pri}) ")
        puts " #{RED}#{row[0]} : #{row[1]} #{CLEAR}"
        return true
      end
    }
    puts " #{RED} no such item #{item}  #{CLEAR} "
    return false

  end
  ##
  # Appends a tag to task
  #
  # @param [Array] items and tag, or tag and items
  # @return 
  public
  def tag(args)
    puts "tags args #{args} "
    items_first = items_first? args
    items = []
    tag = nil
    args.each do |arg| 
      if arg =~ /^[a-zA-Z]/ 
        tag = arg
      elsif arg =~ /^[0-9]+$/
        items << arg
      end
    end
    #items.each { |i| change_row }
    change_file @todo_file_path do |line|
      item = line.match(/^ *([0-9]+)/)
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
  public
  def delete(args)
    puts "delete with #{args} "
    delete_row @todo_file_path do |line|
      #puts "line #{line} "
      item = line.match(/^ *([0-9]+)/)
      #puts "item #{item} "
      if args.include? item[1]
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
    end
  end
  ##
  # Change status of given items
  #
  # @param [Array, #include?] items to delete
  # @return [true, false] success or fail
  public
  def status(args)
    stat, items = _separate args
    status, newstatus = _resolve_status stat
    if status.nil?
      print_red "Status #{stat} is invalid!"
      exit 1
    end
    change_items(items, /(\[.\])/, "[#{newstatus}]")
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
  def _separate args
    tag = nil
    items = []
    args.each do |arg| 
      if arg =~ /^[a-zA-Z]/ 
        tag = arg
      elsif arg =~ /^[0-9]+$/
        items << arg
      end
    end
    return tag, items
  end
  ##
  # Renumber while displaying
  #
  # @return [true, false] success or fail
  private
  def renumber
    @data.each_with_index { |row, i| 
      paditem = _paditem(i+1)  
      row[0] = paditem
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
    change_items args do |item, line|
      m = line.match(/^ */)
      indent = m[0]
      puts line if @verbose
      # we place the text before the date, adding a C-a and indent
      # At printing the C-a is replaced with a newline and some spaces
      ret = line.sub!(/ (\([0-9]{4})/," #{indent}* #{text} "+'\1')
      print_red line if @verbose
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
  ##
  # For given items, ...
  #
  # @param [Array, #include?] items to delete
  # @return [true, false] success or fail
  public
  def CHANGEME(args)
  end
  ##
  # yields lines from file that match the given item
  # We do not need to now parse and match the item in each method
  def change_items args, pattern=nil, replacement=nil
    change_file @todo_file_path do |line|
      item = line.match(/^ *([0-9]+)/)
      if args.include? item[1]
        if pattern
          puts line if @verbose
          line.sub!(pattern, replacement)
          print_red line if @verbose
        else
          yield item[1], line
        end
      end
    end
  end
  ##
  # Redoes the numbering in the file.
  # Useful if the numbers have gone high and you want to start over.
  def redo args
    ctr = 1
    require 'fileutils'
    FileUtils.cp @todo_file_path, "#{@todo_file_path}.org"
    puts "Saved #{@todo_file_path} as #{@todo_file_path}.org"
    change_file @todo_file_path do |line|
      paditem = _paditem ctr
      line.sub!(/^ *[0-9]+/, paditem)
      ctr += 1
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
    when "u","uns","unst","unstart","unstarted" 
      status="unstarted"
      newstatus = " "
    end
    #puts " after #{status} "
    #newstatus=$( echo $status | sed 's/^start/@/;s/^pend/P/;s/^close/x/;s/hold/H/;s/next/1/;s/^unstarted/ /' )
    return status, newstatus
  end

  def self.main args
    begin
      # http://www.ruby-doc.org/stdlib/libdoc/optparse/rdoc/classes/OptionParser.html
      require 'optparse'
      options = {}
      options[:verbose] = false
      options[:colorize] = true

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
        }
        opts.on("-p", "--priority A-Z",  "priority code for add or list") { |v|
          options[:priority] = v
        }
        opts.on("-C", "--component COMPONENT",  "component name for add or list") { |v|
          options[:component] = v
        }
        opts.on("--force", "force delete or add without prompting") do |v|
          options[:force] = v
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
        opts.on("--show-all", "show all tasks (incl closed)") do |v|
          options[:show_all] = v
        end

        opts.separator ""
        opts.separator "Common options:"

        opts.on_tail("-d DIR", "--dir DIR", "Use TODO file in this directory") do |v|
          require 'FileUtils'
          dir = File.expand_path v
          if File.directory? dir
            options[:dir] = dir
            FileUtils.cd dir
          else
            puts "#{RED}#{v}: no such directory #{CLEAR}"
            exit 1
          end
        end
        # No argument, shows at tail.  This will print an options summary.
        # Try it and see!
        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
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

      #options[:file] ||= "rbcurse/TODO2.txt"
      options[:file] ||= "TODO2.txt"
      if options[:verbose]
        p options
        print "ARGV: " 
        p args #ARGV 
      end
      #raise "-f FILENAME is mandatory" unless options[:file]

      todo = Todo.new(options, args)
      todo.run
    ensure
    end
  end # main
end # class Todo

Todo.main(ARGV) if __FILE__ == $0
