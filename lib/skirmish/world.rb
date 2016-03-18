# skirmish is a single-player game in the style of CircleMUD.
# This file holds the World class, as well as structures to hold room and
# description data.
#
# Author::    Andy Mikula  (mailto:andy@andymikula.ca)
# Copyright:: Copyright (c) 2016 Andy Mikula
# License::   MIT

class World

  # Create the world, using the specified file to load rooms.
  # TODO: Load multiple room files from a folder
  # TODO: Write world files in json or something similar
  def initialize(world_file)
    # Set up collections for rooms, characters, and potential mobile names
    # TODO: Move @names to mobile class for use during creation
    @rooms = Hash.new
    @characters = Array.new
    #@names = Array.new

    # Not used currently
    #f = File.open("lib/mobiles/names") or die "Unable to open 'names' file."
    #f.each_line {|name| @names.push name}
    #f.close

    # Parse the CircleMUD .wld file. This is ugly, and I do not recommend
    # touching it. Each room is given a name, description, and exits, and is
    # added to the rooms list
    # TODO: Get extra description data (signs, etc.)
    file = File.read(world_file).split(/^\#/).drop(1).each do |chunk|
      room = chunk.split(/\r?\n|\r/)
      new_room = Room.new

      room_number = room.shift.to_i
      new_room.name = room.shift[0..-2]

      new_room.description = room.shift
      line = room.shift
      until line == "~"
        new_room.description.concat "\n"
        new_room.description.concat line
        line = room.shift
      end

      2.times {line = room.shift}

      until line == "S"
        if line[0] == "D"
          direction = line[1]
          dest = room.shift
          dest = room.shift until dest == "~"
          room.shift
          dest = room.shift.split[-1]
          new_room.direction_data.store(direction.to_i, dest.to_i)
          line = room.shift
        else
          line = room.shift until line == "~"
          line = room.shift
        end
      end
      @rooms[room_number] = new_room
    end
  end

  # If we know about the room in question, return its name
  def get_room_name(room_number)
    @rooms.key?(room_number) ? @rooms[room_number].name : nil
  end

  # If we know about the room in question, return its description
  def get_room_description(room_number)
    @rooms.key?(room_number) ? @rooms[room_number].description : nil
  end

  # If we know about the room in question, and have data for the room in the
  # specified direction, return the number of the destination room. This is
  # likely a bit of an abuse of the ternary operator
  def get_destination(room_number, direction)
    @rooms.key?(room_number) && @rooms.key?(@rooms[room_number].direction_data[direction]) ? @rooms[room_number].direction_data[direction] : nil
  end

  # Return the list of characters who are currently in the specified room
  def get_room_characters(room_number)
    return @rooms[room_number].characters
  end

  # Move a character from original_location to new_location - each room's
  # 'characters' list should contain each character who is currently there
  def move_character(character, original_location, new_location)
    if @rooms.key?(original_location)
      @rooms[original_location].characters.delete(character)
    end
    @rooms[new_location].characters.push character
  end

  # Return an array of characters signifying the possible exits from the
  # specified room
  def get_exits(room_number)
    directions = ["n", "e", "s", "w", "u", "d"]
    exits = Array.new

    6.times do |i|
      if @rooms.key?(@rooms[room_number].direction_data[i])
        exits.push(directions[i])
      end
    end
    return exits
  end
end

# This does not need to be a whole class by itself, and is not currently used
# TODO: Make Room.extra_descriptions a hash, so we can store
# keyword => description pairs
class DescriptionData
  @keyword
  @description
end

# A class to represent a room. A room is uniquely identified by its number,
# knows which characters and objects are in it, and knows which rooms are
# connected to it and in which direction
class Room
  attr_accessor :number, :name, :description, :direction_data, :characters

  def initialize
    @direction_data = Hash.new
    @characters = Array.new
  end
end
