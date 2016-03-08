#!/usr/bin/env ruby

require 'colorize'
require_relative 'world'
require_relative 'utilities'
require_relative 'commands'
include Commands
class Character
  attr_accessor :name, :height, :weight, :str, :dex, :con, :int, :wis, :cha,
    :maxhp, :hp, :xp, :armour, :level, :state, :location

  # Create the character, which by default begins at level one
  def initialize(name, initial_level=1)
    @name = name

    size_roll = roll_dice 2, 10
    @height = 54 + size_roll                        # inches
    @weight = 110 + roll_dice(2, 4) * size_roll     # pounds

    # roll 3d6 for attributes
    rolls = Array.new
    6.times {rolls.push roll_dice(3,6)}
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
    roll_dice(1, 10) * @level
  end
end

def fill_name_array(names)
  f = File.open("names") or die "Unable to open 'names' file.".colorize(:red)
  f.each_line {|name| names.push name}
  f.close
end

def handle_input
  input = prompt_user.to_s

  matches = COMMANDS.select { |c| c =~ /\A#{Regexp.escape(input.split.first)}/i }
  command = matches.first

  unless command.nil?
    command[1].call $player, input
  else
    puts "'#{input}' is not a valid command.".colorize(:red)
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

if __FILE__ == $0
  fill_name_array %w(Mike Joe Alice Susan)

  $world = World.new "30.wld"

  name = prompt_user "Welcome! What is your name?".colorize(:light_green)
  $player = Character.new(name)

  begin
    stats $player
    puts
    input = prompt_user "Is this acceptable (y/n)?"
    $player = Character.new(name) if (input =~ /n/i)
  end until input =~ /y/i

  puts
  look $player, nil

  # loop until player inputs the 'quit' command
  loop {break if handle_input == :quit}
end
