# skirmish is a single-player game in the style of CircleMUD.
# This file holds the Command_History class, as well as functions for I/O, die
# rolling, and the like.
#
# Author::    Andy Mikula  (mailto:andy@andymikula.ca)
# Coauthor::  Zachary Perlmutter (mailto:zrp200@gmail.com)
# Copyright:: Copyright (c) 2016 Andy Mikula
# License::   MIT
require_relative 'commands'
require_relative 'command_history'
require 'colorize'
module Utilities # various utility functions - die rolling, etc.
	include Curses
	module_function
	def get_input
  		case char = $win.getch
    		when KEY_BACKSPACE # Remove the last character from the input buffer
      			$input_buffer.pop
      			nil
   		when KEY_UP # Look for the previous command in the command history. If something exists, clear the input buffer and replace with the last command
      			previous_command = $command_history.get_previous
      			unless previous_command.nil?
        			$input_buffer.clear
        			previous_command.each_char { |chr|  $input_buffer.push chr }
      			end
      			nil
    		when KEY_DOWN # Look for the next command in the command history. If something exits, clear the input buffer and replace it with the next command.
      			next_command = $command_history.get_next
      			unless next_command.nil?
        			$input_buffer.clear
        			next_command.each_char { |chr|  $input_buffer.push chr }
      			end
      			nil
    		when 9  # Tab: See if there's a command that will match to what's currently in the input buffer. If there is, clear the buffer and replace with the command. If not, do nothing.
      			possible_commands = Commands::COMMANDS.select { |c| c =~ /\A#{Regexp.escape($input_buffer.join)}/i }
      			# We don't want to tab-complete the argument to a command
      			# TODO: look for a space in the buffer instead of this horribe hack.
      			unless possible_commands.nil? or possible_commands.first.nil?
        			$input_buffer.clear
        			possible_commands.first.first.each_char { |chr|  $input_buffer.push chr }
      			end
      			nil
    		when 10, 13   # Enter: Add the input buffer to the command history, and return the input as a string
      			input = $input_buffer.join
      			$input_buffer.clear
      			$command_history.add_command input
      			input
    		when /[[:print:]]/  # add printable characters to our input buffer
      			$input_buffer << char
      			nil
  		end
	end
	def setup_screen
  		init_screen
  		start_color
  		cbreak
  		noecho
  		nl

  		init_pair(1, COLOR_GREEN, COLOR_BLACK)
  		init_pair(2, COLOR_CYAN, COLOR_BLACK)
  		init_pair(3, COLOR_WHITE, COLOR_BLACK)

  		$win = Window.new(0, 0, 0, 0)
  		$win.color_set 1 # Set the initial color to green on black
  		$win.scrollok true # Allow the screen to scroll
  		$win.idlok true # Allow the terminal to scroll
  		$win.keypad = true # Allow capture of non-alpha key inputs
	end
			
	def roll_dice(number, size)
  		roll = 0
		(1..number).each {roll += rand(1..size) }
 		roll
	end
	def show_prompt(prompt=?>)
  		$win.color_set 3
  		$win.setpos($win.cury, 0)
  		$win.deleteln
  		$win.addstr(prompt + " " + $input_buffer.join)
  		$win.color_set 1
	end
	def fill_name_array(names)
  		f = File.open("lib/mobiles/names") or die "Unable to open 'names' file.".colorize(:red)
  		f.each_line {|name| names.push name}
  		f.close
	end

	def handle_input(input)
		return if input.nil?
		input.chomp!
		$win.addstr ?\n * 2
		if input.length.zero?
    			print_line("Please enter a valid command. A list of commands is available by typing 'commands'.\n").colorize(:red)
    			return
  		end

 		matches = Commands::COMMANDS.select { |c| c =~ /\A#{Regexp.escape(input.split.first)}/i }
  		command = matches.first

  		unless command.nil?
    			command[1].call $player, input # We have a match! Call the method associated with the command
  		else print_line("'#{input}' is not a valid command. A list of commands is available by typing 'commands'.\n").colorize(:red)
  		end
	end

	# receive input from user with optional string as prompt
	def prompt_user(prompt=?>)
		$win.addstr(prompt + ?\s)
		$win.getstr
	end
	def print_line(line = "", color = :green)
  		$win.color_set (
			case color
  			when :green then 1
  			when :cyan then 2
  			when :white then 3
  			end
		)
  		$win.setpos $win.cury, 0
  		$win.deleteln
  		$win.addstr line + ?\n"

  		$win.color_set 1
	end
end
