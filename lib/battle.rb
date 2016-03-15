require_relative "utilities"
require_relative "creature"
require_relative "character"
$player ||= Character.new(nil) # Making sure $player is defined
def battle( opponent=Creature.new(rand(15).round) )
	if opponent.dexterity > $player.dexterity
		puts "The opponent attacked!"
		puts "You lost #{opponent.attack($player)} hitpoints"
	end
	turn = :user
	while $player.alive? && opponent.alive?
		if turn == :user
			action = case Utilities::prompt_user("Choose one:\tAttack\tHeal")
				when /\Aattack/i
					puts "You attacked!"
					puts "The opponent lost #{$player.attack(opponent)} hitpoints!"
				when /\Aheal/i then "You healed for #{$player.constitution}!"
			else puts "You skipped your turn!"
			end
			turn = :foe
		else
			puts "The opponent attacked you for #{opponent.attack($player)}"
			turn = :user
		end
	end
	if opponent.dead?
		puts "You win!"
		puts "You gained #{opponent.xp} xp!"
		$player.gain_xp(opponent.xp)
	else
		puts "You died...."
		exit
	end
end
		
				
				
