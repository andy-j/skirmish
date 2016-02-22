#!/usr/bin/env ruby

class Character
  attr_accessor :name
  attr_accessor :hp
  attr_accessor :xp
  attr_accessor :attack
  attr_accessor :defence
  attr_accessor :level

  # Create the chatacter
  def initialize(name, initial_level)
    @name = name
    @hp = rand(80..100) + rand(10..20) * initial_level
    @xp = 0
    @attack = rand(80..100) + rand(10..20) * initial_level
    @defence = rand(80..100) + rand(10..20) * initial_level
    @level = initial_level
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
    puts "ENEMY RESTORE: #{restore}"
    protagonist.hp = [protagonist.defence, protagonist.hp + restore].min
    return "#{protagonist.name} restored #{restore} hitpoints!"
  end
end

if __FILE__ == $0
  names = ["Mike", "Joe", "Alice", "Susan"]
  fill_name_array(names)

  print "Welcome to the dungeon. What is your name? "

  player = Character.new(gets.chomp, 1) # player starts at level 1
  enemy = Character.new(names.sample.chomp.capitalize, 1) # start with a level 1 enemy

  puts
  puts "A terrifying monster that goes by the name of #{enemy.name} stands before you!"

  while player.hp > 0
    puts
    puts "#{player.name} HP: #{player.hp} | #{enemy.name} HP: #{enemy.hp}"

    puts player_action(player, enemy, get_player_choice)
    sleep 1.5

    if enemy.hp <= 0
      puts "You have defeated #{enemy.name}! Good riddance!"
      player.add_xp(rand(100..200))
      enemy = Character.new(names.sample.chomp.capitalize, player.level)
      puts
      puts "You take a moment to gather your breath."
      sleep 1.5
      puts "A terrifying monster that goes by the name of #{enemy.name} stands before you!"
    else
      choice = get_enemy_choice(enemy.defence, enemy.attack)
      puts enemy_action(enemy, player, choice)
      sleep 1.5
    end
  end

  puts
  puts "You have died. #{enemy.name} laughs."
  puts "Level reached: #{player.level}"

end
