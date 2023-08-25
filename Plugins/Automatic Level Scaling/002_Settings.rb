#===============================================================================
# Automatic Level Scaling Settings
# By Benitex
#===============================================================================

module LevelScalingSettings
  # These two below are the variables that control difficulty
  # (You can set both of them to be the same)
  TRAINER_VARIABLE = 99
  WILD_VARIABLE = 100

  AUTOMATIC_EVOLUTIONS = true
  INCLUDE_PREVIOUS_STAGES = true # Reverts pokemon to previous evolution stages if they did not reach the evolution level

  # Trainer and wild pokemon that do not evolve by level automatically evolve in these levels instead
  DEFAULT_FIRST_EVOLUTION_LEVEL = 20
  DEFAULT_SECOND_EVOLUTION_LEVEL = 40

  # Scales levels but takes original level differences into consideration
  # Don't forget to set random_increase values to 0 when using this setting
  PROPORTIONAL_SCALING = false

  # You can use the following to disable level scaling in any condition other then the selected below
  ONLY_SCALE_IF_HIGHER = false   # The script will only scale levels if the player is overleveled
  ONLY_SCALE_IF_LOWER = false    # The script will only scale levels if the player is underleveled

  # You can add your own difficulties in the following Hash, using the function "Difficulty.new(fixed_increase, random_increase)"
  #   "fixed_increase" is a pre defined value that increases the level
  #   "random_increase" is a randomly selected value between 0 and the value provided
  # Each difficulty has an index in the Hash, which represents the difficulty
  # You can change the active difficulty by updating TRAINER_VARIABLE or WILD_VARIABLE according to these indexes
  DIFFICULTIES = {
    1 => Difficulty.new(random_increase: -3),                     # Easy
    2 => Difficulty.new(fixed_increase: -1, random_increase: 3),  # Medium
    3 => Difficulty.new(fixed_increase: 1, random_increase: 2),   # Hard
  }

  # You can insert the first stage of a custom regional form here
  # Pokemon not included in this array will have their evolution selected randomly among all their possible forms
  POKEMON_WITH_REGIONAL_FORMS = [
    :RATTATA, :SANDSHREW, :VULPIX, :DIGLETT, :MEOWTH, :GEODUDE,
    :GRIMER, :PONYTA, :FARFETCHD, :CORSOLA, :ZIGZAGOON,
    :DARUMAKA, :YAMASK, :STUNFISK, :SLOWPOKE, :ARTICUNO, :ZAPDOS,
    :MOLTRES, :PIKACHU, :EXEGGCUTE, :CUBONE, :KOFFING, :MIMEJR,
    :BURMY, :DEERLING, :ROCKRUFF, :MINIOR, :PUMPKABOO
  ]
end
