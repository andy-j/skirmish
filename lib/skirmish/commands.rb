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
    $world.move_character character, character.location, new_location
    character.location = new_location
    if character.is_a?(Player)
      cmd_look character, ""
    end
  else
    if character.is_a?(Player)
      print_line "You can't go that way!\n"
    end
  end
end

# list the available exits from the room the player is currently in
def cmd_list_exits(player, input)
  exits = $world.get_exits player.location

  exits_list = "[ Exits: "
  until exits.empty? do
    exits_list << "#{exits.shift} "
  end
  exits_list << "]\n"

  print_line exits_list, :cyan
end

# list the commands available to the player
def cmd_list_commands(player, input)
  commands = $commands.keys

  print_line commands.join(" ")
  print_line
end

# display room name and description to the player
def cmd_look(player, input)

    look_at = input.split[1..-1]

  unless look_at.nil? || look_at.first.nil?
    matches = $world.get_room_characters(player.location)
              .select { |c| c.keywords =~ /\A#{Regexp.escape(look_at.first)}/i }
    unless matches.first.nil?
      print_line matches.first.description + "\n"
    else
      print_line "There is nothing to look at with that name.\n"
    end
  else
    print_line $world.get_room_name(player.location), :cyan
    print_line $world.get_room_description(player.location)
    $world.get_room_characters(player.location).each do | char |
      unless char.name == player.name
        print_line char.name + " is standing here.", :white
      end
    end
    cmd_list_exits player, nil
  end
end

# show player's statistics
def cmd_stats(player, input)

  feet = player.height / 12
  inches = player.height % 12

  print_line("Your name is %s. You are %d'%d\" tall and you weigh %d lbs." %
  [player.name, feet, inches, player.weight])
  print_line("You are level %d and have %d experience points." %
  [player.level, player.xp])
  print_line("============================================================")
  print_line("Hitpoints:   %6d / %d" % [player.hp, player.maxhp])
  print_line("Attack:      %6d - %2d" % [player.level, player.level * 10])
  print_line("Armour:           %6d" % player.armour)
  print_line("============================================================")
  print_line("Strength:    %6d                     Charisma:    %6d" % [player.str, player.cha])
  print_line("Constitution:%6d                     Wisdom:      %6d" % [player.con, player.wis])
  print_line("Dexterity:   %6d                     Intelligence:%6d" % [player.dex, player.int])
  print_line
end

# quit! maybe save something sometime in the future?
def cmd_quit(player, input)
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
