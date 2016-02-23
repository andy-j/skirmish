#!/usr/bin/env ruby

require 'colorize'
require_relative 'world'

class Character
  attr_accessor :name, :hp, :xp, :attack, :defence, :level, :state, :location

  # Create the chatacter
  def initialize(name, initial_level)
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

    if @xp >= 400   # level up!
      puts "Congratulations, you have gained a level!"
      @xp = @xp - 400
      @attack += rand(10..20)
      @defence += rand(10..20)
      @hp = @defence
      @level += 1
    end
  end

  def get_stats
    puts
    puts "Name:%12s" % name
    puts "Level:     %6d" % level
    puts "Experience:%6d" % xp
    puts "Hitpoints: %6d" % hp
    puts "Attack:    %6d" % attack
    puts "Defence:   %6d" % defence
    puts
  end

end

def get_player_choice
  print "(A)ttack, (D)efend, or (F)lee? "
  input = gets.chomp

  case input.upcase
  when "A" then return "attack"
  when "D" then return "defend"
  when "F" then return "flee"
  else puts "I'm sorry, that's not an option."
    return get_player_choice
  end
end

def get_enemy_choice(defence, attack)
  roll = rand(defence + attack)
  if roll < defence
    return "defend"
  else
    return "attack"
  end
end

def fill_name_array(names)
  f = File.open("names") or die "Unable to open names file."
  f.each_line {|name|
    names.push name
  }
end

def player_action(protagonist, antagonist, choice)
  case choice
  when "attack"
    damage = protagonist.attack * rand(1..3) / 10
    antagonist.hp -= damage
    return "Your attack did #{damage} damage to #{antagonist.name}!"
  when "defend"
    restore = protagonist.defence * rand(1..2) / 15
    protagonist.hp = [protagonist.defence, protagonist.hp + restore].min
    return "You restored #{restore} hitpoints!"
  when "flee"
    puts "#{antagonist.name} laughs as you run away, like a coward."
    exit
  end
end

def enemy_action(protagonist, antagonist, choice)
  case choice
  when "attack"
    damage = protagonist.attack * rand(1..3) / 10
    antagonist.hp -= damage
    return "#{protagonist.name}'s attack did #{damage} damage!"
  when "defend"
    restore = protagonist.defence * rand(1..2) / 15
    protagonist.hp = [protagonist.defence, protagonist.hp + restore].min
    return "#{protagonist.name} restored #{restore} hitpoints!"
  end
end

def handle_input(input)
  case input.downcase
  when "n"
    new_location = $world.get_destination($player.location, 0)
  when "e"
    new_location = $world.get_destination($player.location, 1)
  when "s"
    new_location = $world.get_destination($player.location, 2)
  when "w"
    new_location = $world.get_destination($player.location, 3)
  when "u"
    new_location = $world.get_destination($player.location, 4)
  when "d"
    new_location = $world.get_destination($player.location, 5)
  end

  if new_location != nil
    puts
    $player.location = new_location
  else
    puts
    puts "You can't go that way!".colorize(:green)
  end
end

if __FILE__ == $0
  names = ["Mike", "Joe", "Alice", "Susan"]
  fill_name_array(names)

  $world = World.new("30.wld")

  print "Welcome! What is your name? ".colorize(:green)

  $player = Character.new(gets.chomp, 1) # player starts at level 1
  puts

  while true
    puts $world.get_room_name($player.location).colorize(:light_blue)
    puts $world.get_room_description($player.location).colorize(:green)
    puts
    print ">".colorize(:green)
    handle_input(gets.chomp)
  end
end
