#!/usr/bin/env ruby

require 'colorize'
require_relative 'world'
require_relative 'utilities'
require_relative 'commands'

# List of commands that can be used in the game. Command methods must be defined
# in 'commands.rb' in order to be usable
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

class Character
  attr_accessor :name, :height, :weight, :str, :dex, :con, :int, :wis, :cha,
    :maxhp, :hp, :xp, :armour, :level, :state, :location

  # Create the character, which by default begins at level one
  def initialize(name, initial_level=1)
    @name = name

    size_roll = roll_dice(2, 10)
    @height = 54 + size_roll                        #inches
    @weight = 110 + roll_dice(2, 4) * size_roll     #pounds

    # roll 3d6 for attributes
    rolls = Array.new
    6.times do
      rolls.push(roll_dice(3,6))
    end
    rolls.sort! { |a, b| a <=> b }

    @str = rolls.pop()
    @con = rolls.pop()
    @dex = rolls.pop()
    @cha = rolls.pop()
    @wis = rolls.pop()
    @int = rolls.pop()
    @maxhp = @con + 10
    @hp = @maxhp
    @xp = 0
    @armour = @dex + 10
    @level = initial_level
    @location = 3001
  end

  # Character's attack each time is calculated based on a roll of 1d10 * level
  def attack
    return roll_dice(1, 10) * @level
  end
end

def fill_name_array(names)
  f = File.open("names") or die "Unable to open 'names' file."
  f.each_line {|name| names.push name}
  f.close
end

def handle_input
  input = prompt_user

  matches = $commands.select { |c| c =~ /\A#{Regexp.escape(input.split.first)}/i }
  command = matches.first

  unless command.nil?
    return command[1].call($player, input)
  else
    puts "\"#{input}\" is not a valid command."
  end
end

# receive input from user with optional string as prompt
def prompt_user(prompt="")
	print prompt.colorize :light_green
	print "\n> ".colorize :light_green
	input = STDIN.gets.chomp
	puts
	return input
end

if __FILE__ == $0
  fill_name_array %w(Mike Joe Alice Susan)

  $world = World.new "30.wld"

  name = prompt_user("Welcome! What is your name?")
  $player = Character.new(name)

  begin
    cmd_stats($player, nil)
    puts
    input = prompt_user("Is this acceptable (y/n)?")
    if (input =~ /n/i)
      $player = Character.new(name)
    end
  end until input =~ /y/i

  puts
  cmd_look($player, nil)

  # loop until player inputs the 'quit' command
  loop do
    if handle_input == "quit"
      break
    end
  end
end
