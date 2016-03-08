# Implementation of player commands. Each command must accept two arguments - a
# character object and the original input string.

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

# list the commands available to the player
def cmd_list_commands(character, input)
  commands = $commands.keys

  lines = commands.length / 4
  leftover = commands.length % 4

  for i in 0...lines
    puts ("%10s    %10s    %10s    %10s" % [commands[4*i], commands[4*i+1], commands[4*i+2], commands[4*i+3]]).colorize(:light_blue)
  end

  for i in 0...leftover
    print ("%10s    " % commands[i-1]).colorize(:light_blue)
  end
  puts
end

# display room name and description to character
def cmd_look(character, keyword)
  puts $world.get_room_name(character.location).colorize(:light_blue)
  puts $world.get_room_description(character.location).colorize(:green)
end

# show player's statistics
def cmd_stats(character, input)

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
def cmd_quit(character, input)
  unless input =~ /quit/i
    puts "You must type the entire word 'quit' to quit."
  else
    puts "Until next time...".colorize(:green)
    puts
    return "quit"
  end
end
