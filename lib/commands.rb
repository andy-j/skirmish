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
    			puts "You can't go that way!".colorize(:green)
  		end
	end
# list the available exits from the room the player is currently in
def list_exits(character, input=nil)
  exits = $world.get_exits(character.location)

  print ("[ Exits: ").colorize(:light_blue)
  print ("#{exits.shift} ").colorize(:light_blue) until exits.empty?
  print ("]\n").colorize(:light_blue)
end

# list the commands available to the player
def list_commands(character, input)
  commands = COMMANDS.keys
  columns = 5
  width = 75

  # assume 75-character window
  until commands.empty? do
    columns.times {print ("%#{width/columns}s" % commands.pop).colorize(:light_blue)}
    puts()
  end
end

# display room name and description to character
def look(character, keyword=nil)
  puts $world.get_room_name(character.location).colorize(:light_blue)
  puts $world.get_room_description(character.location).colorize(:green)
end
	# show player's statistics
	def stats(character, input=nil)

 		feet = character.height / 12
  		inches = character.height % 12
		puts ("Your name is %s. You are %d'%d\" tall and you weigh %d lbs." %
  		[character.name, feet, inches, character.weight]).colorize(:green)
  		puts ("You are level %d and have %d experience points." %
  		[character.level, character.xp]).colorize(:green)
  		puts ("============================================================").colorize(:green)
  		puts ("Hitpoints:   %6d / %d" % [character.hp, character.maxhp]).colorize(:green)
  		puts ("Attack:      %6d - %2d" % [character.level, character.level * 10]).colorize(:green)
  		puts ("Armour:           %6d" % character.armour).colorize(:green)
  		puts ("============================================================").colorize(:green)
  		puts ("Strength:    %6d                     Charisma:    %6d" % [character.str, character.cha]).colorize(:green)
  		puts ("Constitution:%6d                     Wisdom:      %6d" % [character.con, character.wis]).colorize(:green)
  		puts ("Dexterity:   %6d                     Intelligence:%6d" % [character.dex, character.int]).colorize(:green)
	end

	# quit! maybe save something sometime in the future?
	def quit(character, input)
  		unless input =~ /quit/i
    			puts "You must type the entire word 'quit' to quit."
  		else
			if prompt_user("Are you sure you want to exit?") =~ /\Ay/i
    				puts "Until next time...\n".colorize(:green)
    				:quit
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