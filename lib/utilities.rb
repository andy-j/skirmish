require_relative 'commands'
require 'colorize'
module Utilities # various utility functions - die rolling, etc.
	module_function
	def roll_dice(number_of_dice, size_of_dice)
  		roll = 0
  		i = 0

  		until i == number_of_dice do
    			roll += rand(1..size_of_dice)
    			i += 1
  		end
 		roll
	end

	def fill_name_array(names)
  		f = File.open("names") or die "Unable to open 'names' file.".colorize(:red)
  		f.each_line {|name| names.push name}
  		f.close
	end

	def handle_input
		input = prompt_user
		if input.length.zero?
    			puts ("Please enter a valid command. A list of commands is available by typing 'commands'.").colorize(:red)
    			return
  		end

 		matches = Commands::COMMANDS.select { |c| c =~ /\A#{Regexp.escape(input.split.first)}/i }
  		command = matches.first

  		unless command.nil?
    			command[1].call $player, input
  		else
    			puts ("'#{input}' is not a valid command. A list of commands is available by typing 'commands'.").colorize(:red)
  		end
	end

	# receive input from user with optional string as prompt
	def prompt_user(prompt=String.new)
		puts prompt.colorize(:light_green)
		print "> ".colorize(:light_green)
		input = STDIN.gets.chomp
		puts()
		input.sub /\Ago\s/i, ''
	end
end