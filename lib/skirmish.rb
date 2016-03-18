# skirmish is a single-player game in the style of CircleMUD.
# This file holds the main class and game loop.
#
# Author::    Andy Mikula  (mailto:andy@andymikula.ca)
# Copyright:: Copyright (c) 2016 Andy Mikula
# License::   MIT

require 'curses'
require_relative 'skirmish/world'
require_relative 'skirmish/utilities'
require_relative 'skirmish/commands'
require_relative 'skirmish/player'
require_relative 'skirmish/creature'
#require_relative 'skirmish/battle'

class Skirmish
  include Curses, Utilities
  # Set up the world and run the game loop
  # TODO: Load the player / world state from a save file
  def self.play
    $world = World.new "lib/world/30.wld"
    $player = Player.new
    $input_buffer = Array.new
    $command_history = Command_History.new

    # TODO: Generate a number of mobiles that may or may not be a part of the
    # player's quest. This shouldn't happen explicitly in the play method, but
    # it does serve to demonstrate the functionality of the 'look' command
    @mobile = Mobile.new("Bob", 1, 3014, "Bob is a character, just like you!", "bob")

    # Set up the screen for curses and begin time
    setup_screen
    time = 0

    # Main game loop
    loop do
      time += 1

      case $player.state
        # Player is entering their name
        # TODO: Ask for confirmation on the name before continuing on.
        when :CREATING
          show_prompt "Welcome! What is your name? "
          name = get_input

          # TODO: Adding two newlines here is ugly.
          unless name.nil?
            $win.addstr("\n\n")
            $player.name = name
            Commands::stats $player
            $player.state = :ROLLING
          end

        # Player is rolling stats
        when :ROLLING
          show_prompt("Is this acceptable (y/n)?")
          choice = get_input
          unless choice.nil?
            $win.addstr("\n\n")
            if choice =~ /\An\Z/i
              $player.roll_stats
              Commands::stats $player
            elsif choice =~ /\Ay\Z/i
              # Stats OK - set timeout for getch and show the player where
              # they are in the world
              $win.timeout = 100
              $player.state = :PLAYING
              Commands::look $player, ""
            else
              Commands::stats $player
            end
          end
        # Player is in the game, walking around
        when :PLAYING
          # TODO: Pick a reasonable length of time for a 'tick'
          if time % 20 == 0
            time = 0
            # Tick! Do world stuff
          end
          show_prompt ?>
          handle_input get_input
          # do world stuff

        # Player is engaged in a fight
        when :FIGHTING
=begin
        	Battle.start(opponent)
		Battle.duel
=end
      end
    end
  end

  if __FILE__ == $0
    play
  end
end
