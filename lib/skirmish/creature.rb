class Creature
	attr_accessor :hp
	attr_reader :xp
	def initialize(stats=Hash.new {|hash, key| hash[key] = rand(3..18).ceil})

		# Making sure the following keys are in the hash, and thus defined in some way
		%i(strength intelligence constitution dexterity charisma).each { |stat| stats[stat] }
	
		stats.fetch(:max_hp) {stats[:max_hp] = stats[:constitution] * rand(10).ceil until stats[:max_hp] > 5}		
		@hp = stats[:max_hp]
		@xp = stats.values.reduce(:+)
		@stats = stats 
		@stats.each_key do |stat|
			define_singleton_method(stat) {@stats[stat]}
		end
		
  	end
	
	def regenerate
		@hp = max_hp
	end

	def [](stat)
		@stats.fetch(stat)
	end 

	# Character's attack each time is calculated based on a roll of 1d10 * level
  	def melee_power
    		rand(strength).ceil
  	end

	def alive?
		hp > 0
	end
	def dead?
		hp <= 0
	end

        def magic_power
		rand(intelligence).ceil
        end
	def power
		(intelligence >= strength) ? magic_power : melee_power
	end
	def attack(other)
		attack_power = power
		other.hp -= attack_power
		attack_power
	end
	def power_type
		(intelligence >= strength) ? :magic : :melee
  	end
	def heal # TODO make less overpowered for characters with high constitution
    		@hp += constitution
    		@hp = max_hp if @hp > max_hp
 	end 	
                        
end