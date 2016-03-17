require_relative "utilities"
# Implementation of player commands. Each command must accept two arguments - a
# character object and the original input string.
module Commands
	# List of commands that can be used in the game.
	module_function
	# move the character in the specified direction
	def move_character(character, direction)
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
    			look character
  		else
    			print_line "You can't go that way!".colorize(:red)
  		end
	end
	# list the available exits from the room the player is currently in
	def list_exits(character, input=nil)
  		exits = $world.get_exits(character.location)

		exits_list = "[ Exits: "
		exits_list << exits.shift.to_s << ?\s until exits.empty?
		exits_list << "]\n"
  
		print_line exits_list
	end

	# list the commands available to the player
	def list_commands(character, input=nil)
  		commands = COMMANDS.keys
  		
		print_line commands.join(?\s)
		print_line
	end

	# display room name and description to character
	def look(character, keyword=nil)
  		print_line $world.get_room_name(character.location)
  		print_line $world.get_room_description(character.location)
  		list_exits character
	end
	# show player's statistics
	def stats(character, input=nil)

 		feet = character.height / 12
  		inches = character.height % 12
		print ("Your name is %s. You are %d'%d\" tall and you weigh %d lbs." %
  		[character.name, feet, inches, character.weight]).colorize(:green)
  		print_line ("You are level %d and have %d experience points." %
  		[character.level, character.xp]).colorize(:green)
  		print_line ("============================================================").colorize(:green)
  		print_line ("Hitpoints:   %6d / %d" % [character.hp, character.max_hp]).colorize(:green)
  		print_line ("Armour:      %6d" % character.armour).colorize(:green)
  		print_line ("============================================================").colorize(:green)
  		print_line ("Strength:    %6d                     Charisma:    %6d" % [character.strength, character.charisma]).colorize(:green)
  		print_line ("Constitution:%6d                     Wisdom:      %6d" % [character.constitution, character.wisdom]).colorize(:green)
  		print_line ("Dexterity:   %6d                     Intelligence:%6d" % [character.dexterity, character.intelligence]).colorize(:green)
		print_line
	end

	# quit! maybe save something sometime in the future?
	def quit(character, input)
  		unless input =~ /quit/i
    			print_line "You must type the entire word 'quit' to quit."
  		else
			if prompt_user("Are you sure you want to exit?") =~ /\Ay/i
    				print_line "Until next time...\n".colorize(:green)
    				$win.close
				exit
			end
  		end
	end
	COMMANDS = {	north: Commands.method(:move_character),
        		east: Commands.method(:move_character),
              		south: Commands.method(:move_character),
              		west: Commands.method(:move_character),
              		up: Commands.method(:move_character),
              		down: Commands.method(:move_character),

              		commands: self.method(:list_commands),
			exits:	self.method(:list_exits),
              		look: self.method(:look),
              		stats: self.method(:stats),
              		quit: self.method(:quit)
	}
end
