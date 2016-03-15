require "colorize"
require_relative "utilities"
require_relative "creature"
class Character < Creature
  	attr_reader :name, :height, :weight, :level
  	attr_accessor :xp, :armour, :state, :location
  	# Create the character, which by default begins at level one
 	def initialize(name, initial_level=1) # Create the character, which by default begins at level one
    		@name = name
		@level = initial_level
		
		stats = Hash.new {|hash, key| hash[key] = rand(2...16).ceil}
		%i(strength constitution dexterity charisma wisdom intelligence).each { |stat| stats[stat] }
    		size_roll = rand(20).ceil
    		stats[:height] = 54 + size_roll                        # inches
    		stats[:weight] = 110 + rand(8).ceil * size_roll     # pounds
		stats[:armour] = 0

                @base_stats = stats.dup.freeze
                @stat_modifiers = Hash.new {|hash, key| hash[key] = rand(@base_stats.fetch key)}
		@stat_modifiers.freeze

		max_hp_modifier = 0 # Make sure following line runs at least once
                max_hp_modifier = rand(10) until max_hp_modifier > 1 
		max_hp = proc { (stats[:constitution] * max_hp_modifier).round }

		super(max_hp.call, stats)
                
		define_singleton_method(:max_hp, max_hp)
    		
		@xp = 0
    		@location = 3001
  end
	def gain_xp(amount)
		raise TypeError unless amount.is_a? Integer
                @xp += amount
		while @xp >= 400 # Level up while possible.
                        level_up
	  		puts "You leveled up! You are now level #{@level}!".colorize(:green)
       		end
  	end
	private
     	def level_up
           	raise "Expected xp to be at least 400. Got #{xp}." unless xp >= 400
                @xp -= 400 
		@level += 1
                @stats.each_pair {|key, value| @stats[key] = (@base_stats[key] * level * @stat_modifiers[key]).round}
        end 	
                        
end