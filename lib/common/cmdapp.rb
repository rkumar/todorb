#!/usr/bin/env ruby -w
=begin
  * Name          : cmdapp.rb
  * Description   : some basic command line things
  *               : Moving some methods from todorb.rb here
  * Author        : rkumar
  * Date          : 2010-06-20 11:18 
  * License       :
    Same as Ruby's License (http://www.ruby-lang.org/LICENSE.txt)

=end
require 'common/sed'

ERRCODE = 1

module Cmdapp

  ## 
  # external dependencies:
  #  @app_default_action - action to run if none specified
  #  @app_file_path - data file we are backing up, or reading into array
  #  @app_serial_path - serial_number file
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
    @action = @argv[0] || @app_default_action
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
    ret = 0 if ret != ERRCODE
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

  ##
  # reads serial_number file, returns serialno for this app
  # and increments the serial number and writes back.
  def _get_serial_number
    require 'fileutils'
    appname = @appname
    filename = @app_serial_path || "serial_numbers"
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
    filename = @app_serial_path || "serial_numbers"
    _backup filename
    change_row filename, pattern, "#{appname}:#{number}"
  end

  def _backup filename=@app_file_path
    require 'fileutils'
    FileUtils.cp filename, "#{filename}.org"
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
  def print_red text
    message "#{RED}#{text}#{CLEAR}"
  end
  def print_green text
    message "#{GREEN}#{text}#{CLEAR}"
  end

  ##
  # load data into array as item and task
  # @see save_array to write
  def load_array
    #return if $valid_array
    $valid_array = false
    @data = []
    File.open(@app_file_path).each do |line|
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

    File.open(@app_file_path, "w") do |file| 
      @data.each { |row| file.puts "#{row[0]}\t#{row[1]}" }
    end
  end


end