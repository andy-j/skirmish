#!/usr/bin/env ruby

require 'colorize'
require_relative 'world'

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
  print "(A)ttack, (D)efend, or (F)lee? "

  case prompt_user
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
    		"Your attack did #{damage} damage to #{antagonist.name}!"
  	when :defend
    		restore = protagonist.defence * rand(1..2) / 15
    		protagonist.hp = [protagonist.defence, protagonist.hp + restore].min
    		"You restored #{restore} hitpoints!"
  	when :flee
    		puts "#{antagonist.name} laughs as you run away like a coward."
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
  	new_location = $world.get_destination($player.location,
		case prompt_user
			when /\An/i then 0
			when /\Ae/i then 1
			when /\As/i then 2
			when /\Aw/i then 3
			when /\Au/i then 4
 			when /\Ad/i then 5
		else
			puts "\nYou can't go that way!".colorize(:green)
			return handle_input
		end
	)
    	$player.location = new_location
end

def prompt_user # custom prompt
	print "\n> ".colorize :green
	STDIN.gets.chomp
end

if __FILE__ == $0
  fill_name_array %w(Mike Joe Alice Susan)

  $world = World.new "30.wld"

  print "Welcome! What is your name? ".colorize(:green)

  $player = Character.new prompt_user
  puts

  loop do # starts an infinite loop
    puts $world.get_room_name($player.location).colorize(:light_blue)
    puts $world.get_room_description($player.location).colorize(:green)
    print "\nWhich way do you want to go?".colorize(:green)

    handle_input
  end
end
