#!/usr/bin/env ruby

require 'colorize'
require 'curses'
require_relative 'world'
require_relative 'utilities'
require_relative 'commands'

# List of commands that can be used in the game. Command methods must be defined
# in 'commands.rb' in order to be usable
$COMMANDS = { "north" => method(:cmd_move_character),
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
  def initialize(name="", initial_level=1, initial_location=3001)
    @state = :CREATING
    @name = name

    roll_stats(initial_level)
    @location = initial_location
  end

  def roll_stats(initial_level)
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

if __FILE__ == $0
  fill_name_array %w(Mike Joe Alice Susan)

  $world = World.new "30.wld"

  Curses.init_screen
  Curses.cbreak
  Curses.noecho
  Curses.nl

  $win = Curses::Window.new(Curses.lines - 5, 0, 0, 0)
  $win.scrollok true
  $win.idlok true
  $win.keypad = true

  $player = Character.new
  $input_buffer = Array.new

  # main game loop. loops until player inputs the 'quit' command
  loop do
    case $player.state
      when :CREATING

        show_prompt("Welcome! What is your name? ")
        name = get_input

        unless name.nil?
          print_line
          $player.name = name
          $player.state = :ROLLING
        end

      when :ROLLING
        # turning on echo and blocking is kinda ugly, but we haven't started yet,
        # so maybe it's not that bad...
        Curses.echo

        begin
          print_line
          cmd_stats($player, nil)
          input = prompt_user("Is this acceptable (y/n)?")
          if (input =~ /n/i)
            $player = Character.new(name)
          end
        end until input =~ /y/i

        print_line
        cmd_look($player, nil)

        Curses.noecho
        $win.timeout = 100
        $player.state = :PLAYING

      when :PLAYING

        show_prompt(">")
        handle_input(get_input)
        # do world stuff

      when :FIGHTING
        # fighting!
    end
  end
end
