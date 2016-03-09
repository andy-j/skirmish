require "colorize"
class Character
  attr_accessor :name, :height, :weight, :strength, :dexterity, :constitution, :intelligence, :wisdom, :charisma,
    :max_hp, :hp, :xp, :armour, :level, :state, :location
  # Create the character, which by default begins at level one
  def initialize(name, initial_level=1)
    @name = name

    size_roll = roll_dice 2, 10
    @height = 54 + size_roll                        # inches
    @weight = 110 + roll_dice(2, 4) * size_roll     # pounds

    # roll 3d6 for attributes
    rolls = Array.new
    6.times {rolls.push roll_dice(3,6)}
    rolls.sort! { |a, b| a <=> b }

    @strength = rolls.pop()
    @constitution = rolls.pop()
    @dexterity = rolls.pop()
    @charisma = rolls.pop()
    @wisdom = rolls.pop()
    @intelligence = rolls.pop()
    @max_hp = @constitution + 10
    @hp = @max_hp
    @xp = 0
    @armour = @dexterity + 10
    @level = initial_level
    @location = 3001
  end

  # Character's attack each time is calculated based on a roll of 1d10 * level
  def attack
    roll_dice(1, 10) * @level
  end
  def heal
    @hp += rand(@constitution).round
    @hp = max_hp if @hp > @max_hp
  end
  def level_up
	while @xp >= 400
	  puts "You leveled up! You are now level #{@level += 1}!".colorize(:green)
	  @xp -= 400
       end
  end
end