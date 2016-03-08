#!/usr/bin/env ruby

require 'colorize'
require_relative 'world'
require_relative 'commands'

# List of commands that can be used in the game. Command methods must be defined
# in 'commands.rb' in order to be usable - a
$commands = { "north" => method(:cmd_move_character),
              "east" => method(:cmd_move_character),
              "south" => method(:cmd_move_character),
              "west" => method(:cmd_move_character),
              "up" => method(:cmd_move_character),
              "down" => method(:cmd_move_character),

              "look" => method(:cmd_look),
              "quit" => method(:cmd_quit)
}

class Character
  attr_accessor :name, :hp, :xp, :attack, :defence, :level, :state, :location

  # Create the character, which by default begins at level one
  def initialize(name, initial_level=1)
    @name = name
    @hp = rand(80..100) + rand(10..20) * initial_level
    @xp = 0
    @attack = rand(80..100) + rand(10..20) * initial_level
    @defence = rand(80..100) + rand(10..20) * initial_level
    @level = initial_level
    @location = 3001
  end

  # Add experience. If we've gained 400xp since our last level, level up!
  def add_xp(gain)
    @xp += gain

    while @xp >= 400   # level up!
      puts "Congratulations, you have gained a level! You are now level #{@level}"
      @xp =- 400
      @attack += rand(10..20)
      @defence += rand(10..20)
      @hp = @defence
      @level += 1
    end
  end

  def get_stats
    puts "\nName:%12s" % name
    puts "Level:     %6d" % level
    puts "Experience:%6d" % xp
    puts "Hitpoints: %6d" % hp
    puts "Attack:    %6d" % attack
    puts "Defence:   %6d\n" % defence
  end

end

def get_player_choice
  case prompt_user "(A)ttack, (D)efend, or (F)lee?"
    when /\Aa/i then :attack
    when /\Ad/i then :defend
    when /\Af/i then :flee
  else
    puts "I'm sorry, that's not an option.\n"
    get_player_choice
  end
end

def get_enemy_choice(defence, attack)
  (rand(defense + attack) < defence) ? :defend : :attack
end

def fill_name_array(names)
  f = File.open("names") or die "Unable to open 'names' file."
  f.each_line {|name|names.push name}
  f.close
end

def player_action(protagonist, antagonist, choice)
  case choice
  	when :attack
    		damage = protagonist.attack * rand(1..3) / 10
    		antagonist.hp -= damage
    		"Your attack did #{damage} damage to #{antagonist.name}!".colorize :red
  	when :defend
    		restore = protagonist.defence * rand(1..2) / 15
    		protagonist.hp = [protagonist.defence, protagonist.hp + restore].min
    		"You restored #{restore} hitpoints!".colorize :red
  	when :flee
    		puts "#{antagonist.name} laughs as you run away like a coward.".colorize :red
    		exit
  end
end

def enemy_action(protagonist, antagonist, choice)
  case choice
  when :attack
    damage = protagonist.attack * rand(1..3) / 10
    antagonist.hp -= damage
    "#{protagonist.name}'s attack did #{damage} damage!"
  when :defend
    restore = protagonist.defence * rand(1..2) / 15
    protagonist.hp = [protagonist.defence, protagonist.hp + restore].min
    "#{protagonist.name} restored #{restore} hitpoints!"
  end
end

def handle_input
  input = prompt_user

  matches = $commands.select { |c| c =~ /\A#{Regexp.escape(input)}/i }
  command = matches.first

  unless command.nil?
    command[1].call($player, input)
  else
    puts "\"#{input}\" is not a valid command."
  end
end

def prompt_user(prompt="") # custom prompt
	print prompt.colorize :light_green
	print "\n> ".colorize :light_green
	input = STDIN.gets.chomp
	puts
	input
end

if __FILE__ == $0
  fill_name_array %w(Mike Joe Alice Susan)

  $world = World.new "30.wld"

  $player = Character.new prompt_user("Welcome! What is your name?")
  cmd_look($player, nil)

  loop do # starts an infinite loop
    if handle_input == "quit"
      break
    end
  end
end
