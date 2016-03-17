require 'curses'
require_relative 'skirmish/world'
require_relative 'skirmish/utilities'
require_relative 'skirmish/commands'
require_relative 'skirmish/character'

class Skirmish

  def self.play
    $world = World.new "lib/world/30.wld"
    $player = Character.new
    $input_buffer = Array.new
    $command_history = Command_History.new
    setup_screen
    time = 0

    # main game loop. loops until player inputs the 'quit' command
    loop do
      time += 1

      case $player.state
        when :CREATING
          show_prompt("Welcome! What is your name?")
          name = get_input

          # TODO: Adding two newlines here is ugly.
          unless name.nil?
            $win.addstr("\n\n")
            $player.name = name
            $player.state = :ROLLING
          end

        when :ROLLING
          # TODO: if the player begins typing and backspaces to the beginning of
          # the line, this will re-print the stats readout - not ideal.
          if $input_buffer.empty?
            cmd_stats($player, nil)
          end

          show_prompt("Is this acceptable (yes/no)?")
          choice = get_input
          unless choice.nil?
            $win.addstr("\n\n")
            if choice =~ /n/i
              $player.roll_stats
            elsif choice =~ /y/i
              cmd_look($player, nil)

              $win.timeout = 100
              $player.state = :PLAYING
            end
          end

        when :PLAYING
          if time % 20 == 0
            # do world stuff
          end

          show_prompt(">")
          handle_input(get_input)

        when :FIGHTING
          # fighting!
      end
    end
  end

  if __FILE__ == $0
    play
  end
end
