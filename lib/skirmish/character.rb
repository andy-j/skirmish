# skirmish is a single-player game in the style of CircleMUD.
# This file holds the Character class, as well as the Player and Mobile
# subclasses.
#
# Author::    Andy Mikula  (mailto:andy@andymikula.ca)
# Coauthor::  Zachary Perlmutter  (mailto:zrp200@gmail.com)
# Copyright:: Copyright (c) 2016 Andy Mikula
# License::   MIT
require "colorize"
require_relative "utilities"
require_relative "creature"
class Character < Creature
  	attr_reader :height, :weight, :level
	attr_writer :xp
  	attr_accessor :armour, :state, :location, :name
  	# Create the character, which by default begins at level one
 	def initialize(name="", initial_level=1, inital_location=3001) # Create the player, which by default begins at level one
    		@name     = name
		@state    = :CREATING
		@level    = initial_level
		@location = initial_location
		$world.move_character self, 0, @location

		stats = Hash.new {|hash, key| hash[key] = Utilities.roll_dice(3, 6)}
		%i(strength constitution charisma wisdom intelligence).each { |stat| stats[stat] }
    		size_roll = Utilities::roll_dice 2, 10
    		stats[:height] = 54 + size_roll                        # inches
    		stats[:weight] = 110 + rand(8).ceil * size_roll     # pounds
		stats[:armour] = stat[:dexterity] + 10 # Not implemented yet

		max_hp_modifier = 0 # Make sure following line runs at least once
                max_hp_modifier = rand(10) until max_hp_modifier > 1 
		max_hp = proc { (stats[:constitution] * max_hp_modifier).ceil }
		stats[:max_hp] = max_hp.call
		
		super stats

		@base_stats = @stats.dup.freeze
                @stat_modifiers = Hash.new do |hash, key|
			hash[key] = rand(@base_stats.fetch key)
			hash[key] = rand(@base_stats.fetch key) until hash[key] > 0
		end
    		
		@xp = 0
    		@location = 3001
	end
	def xp
		@xp = 0 if @xp < 0
		@xp
	end
	def regenerate
		super
		@xp -= 50
		@xp = 0 if xp < 1
	end
	def gain_xp(amount)
		raise TypeError unless amount.is_a? Integer
                @xp += amount
		while @xp >= 400 # Level up while possible.
			old_stats = @stats.dup.freeze
                        level_up
	  		puts "You leveled up! You are now level #{@level}!".colorize(:green)
			@stats.each_key { |key| puts "#{old_stats.fetch key} -> #{@stats.fetch key}".colorize(:green) }
       		end
  	end
	private
     	def level_up
           	raise "Expected xp to be at least 400. Got #{xp}." unless xp >= 400
		regenerate # takes away 50 xp automatically
                @xp -= 350 
		@level += 1
                @stats.each_key {|key| @stats[key] = (@base_stats.fetch(key) * level / @stat_modifiers[key]).ceil}
        end 	
                        
end
class Player < Character
	def initialize(name="", initial_level=1)
		@quest = nil
		@created_time = Time.now.freeze
		super
	end
	def time_since_creation
		Time.now - @created_time
	end
end
# A 'Mobile' is any non-player character in the game
# TODO: Write 'act' method for Mobile to be called on game ticks (or some
# multiple thereof)
class Mobile < Character
  attr_reader :description, :keywords

  def initialize(name="", initial_level=1, initial_location=3001, description="", keywords=Array.new)
    	@description = description
	@keywords = keywords
	super(name, initial_level, initial_location)
  end
end
