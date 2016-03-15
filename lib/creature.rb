class Creature
	attr_accessor :hp
	attr_reader :max_hp
	def initialize(health=rand(100).round, stats=Hash.new {|hash, key| hash[key] = rand(15).ceil})
		@max_hp = @hp = health

		stats[:xp] ||= 1

		# Making sure the following keys are in the hash, and thus defined in some way
		%i(strength intelligence constitution dexterity).each { |stat| stats[stat] }
		
		@stats = stats 
		@stats.each_key do |stat|
			define_singleton_method(stat) {@stats[stat]}
		end
  	end

	# Character's attack each time is calculated based on a roll of 1d10 * level
  	def melee_power
    		rand(strength).round * dexterity
  	end

	def alive?
		hp > 0
	end
	def dead?
		hp <= 0
	end

        def magic_power
		rand(intelligence).round * dexterity
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
	def heal
    		@hp += constitution
    		@hp = max_hp if @hp > max_hp
 	end 	
                        
end