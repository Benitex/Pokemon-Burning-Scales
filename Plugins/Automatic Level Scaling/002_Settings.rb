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
  #   "fixed_increase" is a pre defined value that is always added to the level avarage
  #   "random_increase" is a randomly selected value between 0 and the value provided
  # Each difficulty has an index in the Hash, which represents the difficulty
  # You can change the active difficulty by updating TRAINER_VARIABLE or WILD_VARIABLE according to these indexes
  DIFFICULTIES = {
    1 => Difficulty.new(random_increase: -3),                     # Easy
    2 => Difficulty.new(fixed_increase: -1, random_increase: 3),  # Medium
    3 => Difficulty.new(random_increase: 2),                      # Hard
  }

  # Scales levels but takes original level differences between members of the trainer party into consideration
  PROPORTIONAL_SCALING = false

  # Trainer parties will keep the same pokemon and levels of the first battle
  SAVE_TRAINER_PARTIES = true

  # Defines a "Map Level" in which all wild pokemon in the map will be, based on the the party when the player first enters the map
  USE_MAP_LEVEL_FOR_WILD_POKEMON = false

  # You can use the following to disable level scaling in any condition other then the selected below
  ONLY_SCALE_IF_HIGHER = false   # The script will only scale levels if the player is overleveled
  ONLY_SCALE_IF_LOWER = false    # The script will only scale levels if the player is underleveled

  AUTOMATIC_EVOLUTIONS = true     # Updates the evolution stage of the pokemon
  INCLUDE_PREVIOUS_STAGES = true  # Reverts pokemon to previous evolution stages if they did not reach the evolution level
  INCLUDE_NEXT_STAGES = true      # If false, stops evolution at the species used in the function call (or defined in the PBS)

  INCLUDE_NON_NATURAL_EVOLUTIONS = true # Evolve all pokemon, even if it only evolves by a non natural method
  # If INCLUDE_NON_NATURAL_EVOLUTIONS is false, the script will only consider evolutions that use the methods in the NATURAL_EVOLUTION_METHODS array
  # (All conditions other than level for these evolutions are ignored)
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
