#===============================================================================
# Automatic Level Scaling Settings
# By Benitex
#===============================================================================

module LevelScalingSettings
  # These two below are the variables that control difficulty
  # (You can set both of them to be the same)
  TRAINER_VARIABLE = 99
  WILD_VARIABLE = 100

  # You can add your own difficulties in the following Hash, using the constructor "Difficulty.new(fixed_increase, random_increase)"
  #   "fixed_increase" is a pre defined value that increases the level
  #   "random_increase" is a randomly selected value between 0 and the value provided
  # Each difficulty has an index in the Hash, which represents the difficulty
  # You can change the active difficulty by updating TRAINER_VARIABLE or WILD_VARIABLE according to these indexes
  DIFFICULTIES = {
    1 => Difficulty.new(random_increase: -3),                     # Easy
    2 => Difficulty.new(fixed_increase: -1, random_increase: 3),  # Medium
    3 => Difficulty.new(random_increase: 2),                      # Hard
  }

  # Scales levels but takes original level differences into consideration
  # Don't forget to set random_increase values to 0 when using this setting
  PROPORTIONAL_SCALING = false

  # You can use the following to disable level scaling in any condition other then the selected below
  ONLY_SCALE_IF_HIGHER = false   # The script will only scale levels if the player is overleveled
  ONLY_SCALE_IF_LOWER = false    # The script will only scale levels if the player is underleveled

  AUTOMATIC_EVOLUTIONS = true     # Updates the evolution stage of the pokemon
  INCLUDE_PREVIOUS_STAGES = true  # Reverts pokemon to previous evolution stages if they did not reach the evolution level
  INCLUDE_NEXT_STAGES = true      # If false, stops evolution at the species used in the function call (or defined in the PBS)

  INCLUDE_NON_NATURAL_EVOLUTIONS = true # Evolve all pokemon, even if it only evolves by a non natural method
  # Evolutions that don't use the methods of this array won't be considered if INCLUDE_NON_NATURAL_EVOLUTIONS is false
  # All other conditions other than level for these evolutions are ignored
  NATURAL_EVOLUTION_METHODS = [
    :Level,
    :LevelMale, :LevelFemale,
    :LevelDay, :LevelNight, :LevelMorning, :LevelAfternoon, :LevelEvening,
    :LevelNoWeather, :LevelSun, :LevelRain, :LevelSnow, :LevelSandstorm,
    :LevelCycling, :LevelSurfing, :LevelDiving, :LevelDarkness, :LevelDarkInParty,

    # Specific pokemon
    :AttackGreater, :AtkDefEqual, :DefenseGreater,
    :Silcoon, :Cascoon, :Ninjask,
  ]

  # The default evolution levels are used for all evolution methods that are not in the NATURAL_EVOLUTION_METHODS array
  DEFAULT_FIRST_EVOLUTION_LEVEL = 20
  DEFAULT_SECOND_EVOLUTION_LEVEL = 40
end
