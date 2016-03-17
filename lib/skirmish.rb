require 'curses'
require_relative 'skirmish/world'
require_relative 'skirmish/utilities'
require_relative 'skirmish/commands'
require_relative 'skirmish/character'

class Skirmish

  def self.play

    $world = World.new "lib/world/30.wld"

    setup_screen

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

  if __FILE__ == $0
    play
  end
end
