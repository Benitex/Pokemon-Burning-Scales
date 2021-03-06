#===============================================================================
# Automatic Level Scaling Settings
# By Benitex
#===============================================================================

module LevelScalingSettings
  # These two above are the variable that controls battle's difficulty
  # (You can set both of them to be the same)
  TRAINER_VARIABLE = 99
  WILD_VARIABLE = 100

  # If evolution levels are not defined when creating a difficulty, these are the default values used
  AUTOMATIC_EVOLUTIONS = true
  DEFAULT_FIRST_EVOLUTION_LEVEL = 20
  DEFAULT_SECOND_EVOLUTION_LEVEL = 40

  # Scales levels but takes original level differences into consideration
  # Don't forget to set random_increase values to 0 when using this setting
  PROPORTIONAL_SCALING = false

  # You can add your own difficulties here, using the function "Difficulty.new(id, fixed_increase, random_increase, first_evolution_level, second_evolution_level)"
  #   "id" is the value stored in TRAINER_VARIABLE or WILD_VARIABLE, defines the active difficulty
  #   "fixed_increase" is a pre defined value that increases the level (optional)
  #   "random_increase" is a random value that increases the level (optional)
  # Note that these variables can also store negative values
  DIFICULTIES = [
    Difficulty.new(id: 1, fixed_increase: -2, random_increase: 2),  # Easy
    Difficulty.new(id: 2, random_increase: 2),                      # Medium
    Difficulty.new(id: 3, fixed_increase: 3, random_increase: 3),   # Hard
  ]

end
