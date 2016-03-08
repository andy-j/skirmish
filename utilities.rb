# various utility functions - die rolling, etc.

def roll_dice(number_of_dice, size_of_dice)
  roll = 0
  i = 0

  until i == number_of_dice do
    roll += rand(1..size_of_dice)
    i += 1
  end

  roll
end
