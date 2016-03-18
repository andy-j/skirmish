# skirmish is a single-player game in the style of CircleMUD.
# This file holds the Command_History class, as well as functions for I/O, die
# rolling, and the like.
#
# Author::    Andy Mikula  (mailto:andy@andymikula.ca)
# Copyright:: Copyright (c) 2016 Andy Mikula
# License::   MIT

# This class stores the commands that have been entered by the player, so we can
# have bash-style command history.
class Command_History
  def initialize
    @history = Array.new
    @position = 0 # The current 'position' in the list of commands
  end

  # The user entered a command - store it to the list and update the pointer
  def add_command(command)
    @history.push command
    @position = @history.length - 1
  end

  # Unless we're already looking at the first item in the list, return the
  # command at the current position and decrement the 'position' pointer
  def get_previous
    unless @position == 0
      previous_command = @history[@position]
      @position -= 1
      return previous_command
    else
      return nil
    end
  end

  # Unless we're already looking at the most recent item in the list, increment
  # the 'position' pointer and return the command at the new position
  def get_next
    unless @position == @history.length - 1
      @position += 1
      next_command = @history[@position]
      return next_command
    else
      return nil
    end
  end
end

# Look for input from the player, and return it once they have pressed 'enter'.
# Otherwise, return nil
def get_input
  case char = $win.getch
    # Backspace: Remove the last character from the input buffer
    when Curses::KEY_BACKSPACE
      $input_buffer.pop
      return nil

    # Up: Look for the previous command in the command history. If something
    # exists, clear the input buffer and replace it with the last command
    when Curses::KEY_UP
      previous_command = $command_history.get_previous
      unless previous_command.nil?
        $input_buffer.clear
        previous_command.each_char { |chr|  $input_buffer.push chr }
      end
      return nil

    # Down: Look for the next command in the command history. If something
    # exists, clear the input buffer and replace it with the next command
    when Curses::KEY_DOWN
      next_command = $command_history.get_next
      unless next_command.nil?
        $input_buffer.clear
        next_command.each_char { |chr|  $input_buffer.push chr }
      end
      return nil

    # Tab: See if there's a command that will match to what's currently in the
    # input buffer. If there is, clear the buffer and replace with the command.
    # If not, do nothing.
    when 9
      possible_commands = $commands.select { |c| c =~ /\A#{Regexp.escape($input_buffer.join)}/i }
      # TODO: Look for a space in the buffer instead of this horribe hack.
      # We don't want to tab-complete the argument to a command
      unless possible_commands.nil? or possible_commands.first.nil?
        $input_buffer.clear
        possible_commands.first.first.each_char { |chr|  $input_buffer.push chr }
      end
      return nil

    # Enter: Add the input buffer to the command history, and return the input
    # as a string
    when 10 || 13
      input = $input_buffer.join
      $input_buffer.clear
      $command_history.add_command input
      return input

    # Any printable character: Add the character to the input buffer
    when /[[:print:]]/
      $input_buffer << char
      return nil
  end
end

# Curses screen setup and color pair definitions
def setup_screen
  Curses.init_screen
  Curses.start_color
  Curses.cbreak
  Curses.noecho
  Curses.nl

  # Color pairs. Arguments: color_number, foreground color, background color
  Curses.init_pair 1, Curses::COLOR_GREEN, Curses::COLOR_BLACK
  Curses.init_pair 2, Curses::COLOR_CYAN, Curses::COLOR_BLACK
  Curses.init_pair 3, Curses::COLOR_WHITE, Curses::COLOR_BLACK

  # Set up the window to fill the whole terminal
  $win = Curses::Window.new(0, 0, 0, 0)
  # Set the initial color to green on black
  $win.color_set(1)
  # Allow the screen to scroll, and allow the terminal to scroll as well
  $win.scrollok true
  $win.idlok true
  # Allow capture of non-alpha key inputs (arrows, enter, etc.)
  $win.keypad = true
end

# Find a command to invoke based on input from a character.
def handle_input(input)
  if input.nil?
    return
  end

  input.chomp!

  # Print functions clear the current line, so if we're handling input, we need
  # to move down a few lines so we can see what we entered on our screen.
  $win.addstr("\n\n")

  if input.length == 0
    print_line("Please enter a valid command. A list of commands is available by typing 'commands'.\n")
    return nil
  end

  # See if we can find a command key that matches the first word of the input
  matches = $commands.select { |c| c =~ /\A#{Regexp.escape(input.split.first)}/i }
  command = matches.first

  unless command.nil?
    # We have a match! Call the method associated with the command
    return command[1].call($player, input)
  else
    print_line("\"#{input}\" is not a valid command. A list of commands is available by typing 'commands'.\n")
  end
end

# Show a prompt to the player
def show_prompt(prompt=">")
  $win.color_set(3)
  $win.setpos($win.cury, 0)
  $win.deleteln
  $win.addstr(prompt + " " + $input_buffer.join)
  $win.color_set(1)
end

# Print a line to the screen.
def print_line(line = "", color = :green)
  case color
  when :green
    $win.color_set(1)
  when :cyan
    $win.color_set(2)
  when :white
    $win.color_set(3)
  end

  $win.setpos($win.cury, 0)
  $win.deleteln
  $win.addstr(line + "\n")

  $win.color_set(1)
end

# Roll number_of_dice with size_of_dice sides, and return the result
def roll_dice(number_of_dice, size_of_dice)
  roll = 0

  (1..number_of_dice).each{ roll += rand(1..size_of_dice) }

  return roll
end
