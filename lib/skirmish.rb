require 'curses'
require_relative 'skirmish/world'
require_relative 'skirmish/utilities'
require_relative 'skirmish/commands'
require_relative 'skirmish/character'
#require_relative 'skirmish/creature'
#require_relative 'skirmish/battle'

class Skirmish
  include Curses
  def self.play

    $world = World.new "lib/world/30.wld"

    setup_screen

    $player = Character.new
    $input_buffer = Array.new

    # main game loop. loops until player inputs the 'quit' command
    loop do
      case $player.state
        when :CREATING

          show_prompt "Welcome! What is your name? "
          name = get_input

          unless name.nil?
            print_line
            $player.name = name
            $player.state = :ROLLING
          end

        when :ROLLING
          # turning on echo and blocking is kinda ugly, but we haven't started yet,
          # so maybe it's not that bad...
          echo

          begin
            print_line
            Commands::stats $player
            input = prompt_user "Is this acceptable (y/n)?"
            $player = Character.new(name) if (input =~ /n/i)
          end until input =~ /y/i

          print_line
          Commands::look $player

          noecho
          $win.timeout = 100
          $player.state = :PLAYING

        when :PLAYING

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
