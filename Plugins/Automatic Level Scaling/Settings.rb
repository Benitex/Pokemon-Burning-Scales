#===============================================================================
# Automatic Level Scaling Settings
# By Benitex
#===============================================================================

module LevelScalingSettings
  # These two above are the variable that controls battle's difficulty
  # (You can set both of them to be the same)
  TRAINER_VARIABLE = 99
  WILD_VARIABLE = 100

  AUTOMATIC_EVOLUTIONS = true
  UPDATE_MOVES = true
  # Scales levels but takes original level differences into consideration
  # Don't forget to set random_increase values to 0 when using this setting
  PROPORTIONAL_SCALING = false

  # If evolution levels are not defined when creating a difficulty, these are the default values used
  DEFAULT_FIRST_EVOLUTION_LEVEL = 20
  DEFAULT_SECOND_EVOLUTION_LEVEL = 40

  # You can add your own difficulties here, using the function "Difficulty.new(id, random_increase, fixed_increase, (optional) first_evolution_level, (optional) second_evolution_level)"
  #   "id" is the value stored in TRAINER_VARIABLE or WILD_VARIABLE, defines the active difficulty
  #   "random_increase" is a random value that increases the level
  #   "fixed_increase" is a pre defined value that increases the level
  #   "first_evolution_level" is the level required for pokemon that don't evolve by level to get to the mid form
  #   "second_evolution_level" is the level required for pokemon that don't evolve by level to get to the final form
  # Note that these variables can also store negative values
  DIFICULTIES = [
    Difficulty.new(1, 2, -2),         # Easy
    Difficulty.new(2, 2, 0),          # Medium
    Difficulty.new(3, 3, 3, 15, 30),  # Hard
    Difficulty.new(4, 0, 0)           # Avarage
  ]

end
