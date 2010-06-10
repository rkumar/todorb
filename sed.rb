#!/usr/bin/env ruby -w
#*************************************************************
# Sed like operations - just change row and delete row
# While converting some shell scripts in which i have used
# sed extensively, I need this kind of functionality
#
#*************************************************************
##
# changes one or more rows based on pattern and replacement
# Also if replacement is not given, expects a block and yields
# matching lines to it

module Sed
def change_row filename, pattern, replacement = nil
  d = _read filename
  d.each { |row|
    if row =~ pattern
      if replacement
        row.gsub!( pattern, replacement)
      else
        yield row
      end
    end
  }
  _write filename, d
end
def change_file filename
  d = _read filename
  d.each { |row|
    yield row
  }
  _write filename, d
end
##
# deletes on more rows based on a pattern
# Also takes a block and yields each row to it
def delete_row filename, pattern = nil
  d = _read filename
  if pattern
    d.delete_if { |row| row =~ pattern }
  else
    d.delete_if { |row| yield row }
  end
  _write filename, d
end
##
# read the given filename into an array
def _read filename
  d = []
  File.open(filename).each { |line|
    d << line
  }
  return d
end
## 
# write the given array to the filename
def _write filename, array
  File.open(filename, "w") do |file| 
    array.each { |row| file.puts row }
  end
end
end # module

if __FILE__ == $0
  include Sed
  filename = "tmp.txt"
  change_row filename, /_10_/ do |row|
    row.sub!(/_10_/,"10")
  end
  change_row filename, /\+13\+/, "13"
  delete_row(filename,/XXX/)
  delete_row(filename) do |line|
    line =~ /junk/
  end
end
