# Implementation of player commands. Each command must accept two arguments - a
# character object and the original input string, even if they don't use it.

# move the character in the specified direction
def cmd_move_character(character, direction)
  new_location = $world.get_destination(character.location,
	case direction
		when /\An/i then 0
		when /\Ae/i then 1
		when /\As/i then 2
		when /\Aw/i then 3
		when /\Au/i then 4
 		when /\Ad/i then 5
	end
	)
  unless new_location.nil?
    character.location = new_location
    cmd_look(character, nil)
  else
    puts "You can't go that way!".colorize(:green)
  end
end

# display room name and description to character
def cmd_look(character, keyword)
  puts $world.get_room_name(character.location).colorize(:light_blue)
  puts $world.get_room_description(character.location).colorize(:green)
end

# quit! maybe save something sometime in the future?
def cmd_quit(character, input)
  unless input =~ /quit/i
    puts "You must type the entire word 'quit' to quit."
  else
    puts "Sorry to see you go!".colorize(:green)
    return "quit"
  end
end
