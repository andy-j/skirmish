require_relative 'commands'
require 'colorize'
module Utilities # various utility functions - die rolling, etc.
	include Curses
	module_function
	def get_input
		case char = $win.getch
		
		when KEY_BACKSPACE
			$input_buffer.pop
			nil
		when 10, 13 # KEY_ENTER is numpad enter - this matches \n or \r
			input = $input_buffer.join
			$input_buffer = Array.new
			input
		when /[[:print:]]/
			$input_buffer << char
			nil
		end
	end
	def setup_screen
  		init_screen
  		cbreak
  		noecho
  		nl

  		$win = Window.new(lines - 5, 0, 0, 0)
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
		$win.setpos $win.cury, 0
		$win.deleteln
		$win.addstr(prompt + ?\s + $input_buffer.join)
	end
	def fill_name_array(names)
  		f = File.open("lib/mobiles/names") or die "Unable to open 'names' file.".colorize(:red)
  		f.each_line {|name| names.push name}
  		f.close
	end

	def handle_input(input)
		return if input.nil?
		input.chomp!
		print_line
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
end