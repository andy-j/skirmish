require 'curses'
require_relative 'skirmish/world'
require_relative 'skirmish/utilities'
require_relative 'skirmish/commands'
require_relative 'skirmish/player'
require_relative 'skirmish/creature'
#require_relative 'skirmish/battle'

class Skirmish
  include Curses, Utilities
  def self.play
    $world = World.new "lib/world/30.wld"
    $player = Player.new
    $input_buffer = Array.new
    $command_history = Command_History.new

    @mobile = Mobile.new("Bob", 1, 3014, "Bob is a character, just like you!", "bob")

    setup_screen
    time = 0
    stats_displayed = false

    # main game loop. loops until player inputs the 'quit' command
    loop do
      time += 1

      case $player.state
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

        when :ROLLING
          show_prompt("Is this acceptable (y/n)?")
          choice = get_input
          unless choice.nil?
            $win.addstr("\n\n")
            if choice =~ /\An\Z/i
              $player.roll_stats
              Commands::stats $player
            elsif choice =~ /\Ay\Z/i
              Commands::look $player, ""

              $win.timeout = 100
              $player.state = :PLAYING
            else
              Commands::stats $player
            end
          end
        when :PLAYING
          if time % 20 == 0
            time = 0
            # do world stuff
          end
          show_prompt ?>
          handle_input get_input
          # do world stuff

        when :FIGHTING
          # fighting!
      end
    end
  end

  if __FILE__ == $0
    play
  end
end
