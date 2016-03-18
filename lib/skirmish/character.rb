class Character
  attr_accessor :name, :height, :weight, :str, :dex, :con, :int, :wis, :cha,
    :maxhp, :hp, :xp, :armour, :level, :state, :location, :description, :keywords

  # Create the character, which by default begins at level one
  def initialize(name="", initial_level=1, initial_location=3001, description="", keywords=Array.new)
    @state = :CREATING
    @name = name
    @description = description
    @keywords = keywords

    roll_stats initial_level
    @location = initial_location
    $world.move_character(self, 0, initial_location)
  end

  def roll_stats(initial_level = 1)
    size_roll = roll_dice(2, 10)
    @height = 60 + size_roll                        #inches
    @weight = 110 + roll_dice(2, 3) * size_roll     #pounds

    # roll 3d6 for attributes
    rolls = Array.new
    6.times do
      rolls.push roll_dice(3,6)
    end
    rolls.sort! { |a, b| a <=> b }

    @str = rolls.pop()
    @con = rolls.pop()
    @dex = rolls.pop()
    @cha = rolls.pop()
    @wis = rolls.pop()
    @int = rolls.pop()
    @maxhp = @con + 10
    @hp = @maxhp
    @xp = 0
    @armour = @dex + 10
    @level = initial_level
  end

  # Character's attack each time is calculated based on a roll of 1d10 * level,
  # or as otherwise specified
  def attack(num=1, size=10)
    return roll_dice(num, size) * @level
  end
end

class Player < Character
  def initialize(name="", initial_level=1, initial_location=3001, description="You're...you!", keywords="self")
    super(name, initial_level, initial_location, description, keywords)
    @quest = nil
  end
end

class Mobile < Character
  attr_reader :description, :keywords

  def initialize(name="", initial_level=1, initial_location=3001, description="", keywords=Array.new)
    super(name, initial_level, initial_location, description, keywords)
  end
end
