require_relative "utilities"
require_relative "creature"
require_relative "character"
$player ||= Character.new(nil) # Making sure $player is defined
module Battle
	class << self
	def enemy_turn(opponent=@opponent)
		damage = opponent.attack $player
		damage -= 1 while $player.hp < 0
		if damage.zero?
			puts "The opponent missed!"
		else
			puts "The opponent attacked you for #{damage} hitpoints!"
			puts "You now have #{$player.dead? ? 0 : $player.hp} hitpoints!"
		end
	end
		
	def start(opponent = Creature.new) # Sets up the battle
		raise "A battle is already in progress" unless @opponent.nil? 
		@opponent = opponent
	end
	def end_battle
		@opponent = nil
	end
	def user_decision
		# Otherwise next part will be skipped...
		case Utilities::prompt_user("\nChoose one: Attack Heal Compare")
			when /\Aa/i then :attack
			when /\Ah/i
				$player.heal
				puts "You healed #{ $player[:constitution] } hitpoints!\nYou now have #{$player.hp} hitpoints!"
			when /\Ac/i
				compare
				puts()
				user_decision 
				
		end 
	end
	def compare
		puts "Health:\t\t#{$player.hp}/#{$player.max_hp}\tvs\t#{@opponent.hp}/#{@opponent.max_hp}"
		puts "Strength:\t#{$player.strength}\tvs\t#{@opponent.strength}"
		puts "Intelligence:\t#{$player.intelligence}\tvs\t#{@opponent.intelligence}"
		puts "Attack Type:\t#{$player.power_type}\tvs\t#{@opponent.power_type}"
		puts "Constitution:\t#{$player.constitution}\tvs\t#{@opponent.constitution}"
		puts "Dexterity:\t#{$player[:dexterity]}\tvs\t#{@opponent[:dexterity]}"
	end
	def duel
		start if @opponent.nil?
		compare
		enemy_turn if @opponent.dexterity > $player.dexterity
		turn = :user
		while $player.alive? && @opponent.alive?
			if turn == :user
				if user_decision == :attack
					puts "You attacked!"
					attack_power = $player.attack @opponent
					if attack_power.zero?
						puts "You missed!"
					else
						puts "The opponent lost #{$player.attack @opponent} hitpoints!"
						puts "The opponent now has #{@opponent.hp} hitpoints!"
					end
				end
				turn = :foe
			else
				enemy_turn
				turn = :user
			end
		end
		if @opponent.dead?
			puts "You win!"
			puts "You gained #{@opponent.xp} xp!"
			$player.gain_xp @opponent.xp
		else
			puts "You died....\n"
			$player.regenerate
		end
		end_battle
	end
end; end		
				
				
