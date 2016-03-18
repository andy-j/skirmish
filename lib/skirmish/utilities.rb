require_relative 'commands'
require_relative 'command_history'
require 'colorize'
module Utilities # various utility functions - die rolling, etc.
	include Curses
	module_function
	def get_input
  		case char = $win.getch
    		when KEY_BACKSPACE
      			$input_buffer.pop
      			nil
   		when KEY_UP
      			last_command = $command_history.get_last
      			unless last_command.nil?
        			$input_buffer.clear
        			last_command.join.each_char { |chr|  $input_buffer.push chr }
      			end
      			nil
    		when KEY_DOWN
      			next_command = $command_history.get_next
      			unless next_command.nil?
        			$input_buffer.clear
        			next_command.join.each_char { |chr|  $input_buffer.push chr }
      			end
      			nil
    		when 9  # tab
      			possible_commands = Commands::COMMANDS.select { |c| c =~ /\A#{Regexp.escape($input_buffer.join)}/i }
      			# TODO: look for a space in the buffer instead of this horribe hack.
      			unless possible_commands.nil? or possible_commands.first.nil?
        			$input_buffer.clear
        			possible_commands.first.first.each_char { |chr|  $input_buffer.push chr }
      			end
      			nil
    		when 10, 13   # KEY_ENTER is numpad enter - this matches \n or \r
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
  		$win.color_set 1
  		$win.scrollok true
  		$win.idlok true
  		$win.keypad = true
	end
			
	def roll_dice(number_of_dice, size_of_dice)
  		roll = 0
  		i = 0

  		until i == number_of_dice do
    			roll += rand(1..size_of_dice)
    			i += 1
  		end
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
    			command[1].call $player, input
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
