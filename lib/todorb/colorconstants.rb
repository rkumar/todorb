#!/usr/bin/env ruby 

# Color constants so we can print onto console using print or puts
# @example 
# string = "hello ruby"
# puts " #{RED}#{BOLD}#{UNDERLINE}#{string}#{CLEAR}"
#
# http://wiki.bash-hackers.org/scripting/terminalcodes
# ripped off highline gem
module ColorConstants

  # Embed in a String to clear all previous ANSI sequences.  This *MUST* be 
  # done before the program exits!
  # 
  CLEAR      = "\e[0m"
  # An alias for CLEAR.
  RESET      = CLEAR
  NORMAL      = CLEAR
  # Erase the current line of terminal output.
  ERASE_LINE = "\e[K"
  # Erase the character under the cursor.
  ERASE_CHAR = "\e[P"
  # The start of an ANSI bold sequence.
  BOLD       = "\e[1m"
  # The start of an ANSI dark sequence.  (Terminal support uncommon.)
  DARK       = "\e[2m"
  DIM        = DARK
  # The start of an ANSI underline sequence.
  UNDERLINE  = "\e[4m"
  # An alias for UNDERLINE.
  UNDERSCORE = UNDERLINE
  # The start of an ANSI blink sequence.  (Terminal support uncommon.)
  BLINK      = "\e[5m"
  # The start of an ANSI reverse sequence.
  REVERSE    = "\e[7m"
  # The start of an ANSI concealed sequence.  (Terminal support uncommon.)
  CONCEALED  = "\e[8m"

  # added from http://understudy.net/custom.html
  BOLD_OFF       = "\e[22m"
  UNDERILNE_OFF  = "\e[24m"
  BLINK_OFF      = "\e[25m"
  REVERSE_OFF    = "\e[27m"

  # Set the terminal's foreground ANSI color to black.
  BLACK      = "\e[30m"
  # Set the terminal's foreground ANSI color to red.
  RED        = "\e[31m"
  # Set the terminal's foreground ANSI color to green.
  GREEN      = "\e[32m"
  # Set the terminal's foreground ANSI color to yellow.
  YELLOW     = "\e[33m"
  # Set the terminal's foreground ANSI color to blue.
  BLUE       = "\e[34m"
  # Set the terminal's foreground ANSI color to magenta.
  MAGENTA    = "\e[35m"
  # Set the terminal's foreground ANSI color to cyan.
  CYAN       = "\e[36m"
  # Set the terminal's foreground ANSI color to white.
  WHITE      = "\e[37m"

  # Set the terminal's background ANSI color to black.
  ON_BLACK   = "\e[40m"
  # Set the terminal's background ANSI color to red.
  ON_RED     = "\e[41m"
  # Set the terminal's background ANSI color to green.
  ON_GREEN   = "\e[42m"
  # Set the terminal's background ANSI color to yellow.
  ON_YELLOW  = "\e[43m"
  # Set the terminal's background ANSI color to blue.
  ON_BLUE    = "\e[44m"
  # Set the terminal's background ANSI color to magenta.
  ON_MAGENTA = "\e[45m"
  # Set the terminal's background ANSI color to cyan.
  ON_CYAN    = "\e[46m"
  # Set the terminal's background ANSI color to white.
  ON_WHITE   = "\e[47m"

end
