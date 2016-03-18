# skirmish is a single-player game in the style of CircleMUD.
# This file holds player commands.
#
# Author::    Andy Mikula  (mailto:andy@andymikula.ca)
# Copyright:: Copyright (c) 2016 Andy Mikula
# License::   MIT

# Implementation of player commands. Each command must accept two arguments - a
# character object and the original input string.

# Move the character in the specified direction, if possible
def cmd_move_character(character, direction)
  # Ask the world if there's a room in the direction we want to move
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
  # If there's a room to go to, tell the world where the character is going, and
  # let the character track it as well. If character is a player, either display
  # their new location or a message telling them they are unable to move in that
  # direction
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

# List the available exits from the room the player is currently in
def cmd_list_exits(player, input)
  exits = $world.get_exits player.location

  exits_list = "[ Exits: "
  until exits.empty? do
    exits_list << "#{exits.shift} "
  end
  exits_list << "]\n"

  print_line exits_list, :cyan
end

# List the commands available to the player
# TODO: Pretty this output up a little bit - even columns would be nice
def cmd_list_commands(player, input)
  commands = $commands.keys

  print_line commands.join(" ")
  print_line
end

# For the Player's current location, display the room name, description, and any
# other characters who are in the room with the player
def cmd_look(player, input)

  look_at = input.split[1..-1]

  # If the player has specified a target / keyword, try to find it in the list
  # of keywords on characters in the room
  # TODO: Look at room keywords as well (i.e. 'look sign', etc.)
  unless look_at.nil? || look_at.first.nil?
    matches = $world.get_room_characters(player.location)
              .select { |c| c.keywords =~ /\A#{Regexp.escape(look_at.first)}/i }
    unless matches.first.nil?
      print_line matches.first.description + "\n"
    else
      print_line "There is nothing to look at with that name.\n"
    end
  # No target specified - just show them the room name / description, any other
  # characters who might be present, and the available exits
  # TODO: Get the '...is standing here' description from the character.
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

# Print the player's statistics to the screen
def cmd_stats(player, input)

  # Height is stored in inches, but it's nice to have something like 5'10"
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

# Quit the game. Make sure the player is sure! We don't want to quit on an
# accidental 'q', for example
# TODO: Save player / world state
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

# The possible command strings and their associated methods. To be able to use
# a new command, it must be implemented above and added here. Ruby remembers the
# order in which keys are added to a hash, which is convenient - we always match
# the first key we see. As a result, entries higher up in the list have greater
# precedence (making sure we match 'north' on 'n' instead of 'nap', for example)
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
