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
    cmd_look character, nil
  else
    print_line "You can't go that way!\n"
  end
end

# list the available exits from the room the player is currently in
def cmd_list_exits(character, input)
  exits = $world.get_exits character.location

  exits_list = "[ Exits: "
  until exits.empty? do
    exits_list << "#{exits.shift} "
  end
  exits_list << "]\n"

  print_line exits_list, :cyan
end

# list the commands available to the player
def cmd_list_commands(character, input)
  commands = $commands.keys

  print_line commands.join(" ")
  print_line
end

# display room name and description to character
def cmd_look(character, keyword)
  print_line $world.get_room_name(character.location), :cyan
  print_line $world.get_room_description(character.location)
  cmd_list_exits character, nil
end

# show player's statistics
def cmd_stats(character, input)

  feet = character.height / 12
  inches = character.height % 12

  print_line("Your name is %s. You are %d'%d\" tall and you weigh %d lbs." %
  [character.name, feet, inches, character.weight])
  print_line("You are level %d and have %d experience points." %
  [character.level, character.xp])
  print_line("============================================================")
  print_line("Hitpoints:   %6d / %d" % [character.hp, character.maxhp])
  print_line("Attack:      %6d - %2d" % [character.level, character.level * 10])
  print_line("Armour:           %6d" % character.armour)
  print_line("============================================================")
  print_line("Strength:    %6d                     Charisma:    %6d" % [character.str, character.cha])
  print_line("Constitution:%6d                     Wisdom:      %6d" % [character.con, character.wis])
  print_line("Dexterity:   %6d                     Intelligence:%6d" % [character.dex, character.int])
  print_line
end

# quit! maybe save something sometime in the future?
def cmd_quit(character, input)
  unless input =~ /quit/i
    print_line "You must type the entire word 'quit' to quit.\n"
  else
    print_line "Until next time..."
    $win.refresh
    sleep 3
    $win.close
    exit
  end
end

$commands = { "north" => method(:cmd_move_character),
              "east" => method(:cmd_move_character),
              "south" => method(:cmd_move_character),
              "west" => method(:cmd_move_character),
              "up" => method(:cmd_move_character),
              "down" => method(:cmd_move_character),

              "commands" => method(:cmd_list_commands),
              "exits" => method(:cmd_list_exits),
              "look" => method(:cmd_look),
              "stats" => method(:cmd_stats),
              "quit" => method(:cmd_quit)
}
