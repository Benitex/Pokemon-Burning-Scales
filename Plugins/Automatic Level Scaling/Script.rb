#===============================================================================
# Automatic Level Scaling
# By Benitex
#===============================================================================

Events.onWildPokemonCreate += proc { |_sender, e|
  pokemon = e[0]
  difficulty = $game_variables[LevelScalingSettings::WILD_VARIABLE] 

  # Make all wild Pokémon shiny while a certain Switch is ON (see Pokemon Essentials Settings script).
  if $game_switches[Settings::SHINY_WILD_POKEMON_SWITCH]
    pokemon.shiny = true
  end

  if difficulty > 0
    setNewLevel(pokemon, difficulty)
  end
}

Events.onTrainerPartyLoad += proc { |_sender, trainer|
  if trainer   # An NPCTrainer object containing party/items/lose text, etc.
    difficulty = $game_variables[LevelScalingSettings::TRAINER_VARIABLE]
    if difficulty > 0
      for pokemon in trainer[0].party
        setNewLevel(pokemon, difficulty)
      end
    end
  end
}

def setNewLevel(pokemon, selectedDifficulty)
  new_level = pbBalancedLevel($Trainer.party) - 2 # pbBalancedLevel increses level by 2 to challenge the player

  # Difficulty modifiers
  for difficulty in LevelScalingSettings::DIFICULTIES do
    if difficulty.id == selectedDifficulty
      new_level += rand(difficulty.random_increase) + difficulty.fixed_increase
    end
  end

  new_level = new_level.clamp(1, GameData::GrowthRate.max_level)
  pokemon.level = new_level

  if LevelScalingSettings::AUTOMATIC_EVOLUTIONS
    setNewStage(pokemon, selectedDifficulty)  # Evolution part
  end
  pokemon.calc_stats
  if LevelScalingSettings::UPDATE_MOVES
    pokemon.reset_moves    
  end
end

def setNewStage(pokemon, selectedDifficulty)
  evolvedTimes = 0
  pokemon.species = GameData::Species.get(pokemon.species).get_baby_species # revert to the first stage

  while evolvedTimes < 2
    evolutions = GameData::Species.get(pokemon.species).get_evolutions(false)

    # Checks if the species only evolve by level up
    other_evolving_method = false
    i = 0
    while i < evolutions.length
      if evolutions[i][1] != :Level
        other_evolving_method = true
      end
      i += 1
    end

    # Species that evolve by level up
    if !other_evolving_method
      if pokemon.check_evolution_on_level_up != nil
        pokemon.species = pokemon.check_evolution_on_level_up
      end

    # For species with other evolving methods
    else
      # Checks if the pokemon is in it's midform and defines the level to evolve
      if evolvedTimes == 0
        for difficulty in LevelScalingSettings::DIFICULTIES do
          if difficulty.id == selectedDifficulty
            level = difficulty.first_evolution_level
          end
        end
      else
        for difficulty in LevelScalingSettings::DIFICULTIES do
          if difficulty.id == selectedDifficulty
            level = difficulty.secund_evolution_level
          end
        end
      end

      # Species with only one possible evolution
      if evolutions.length == 1 && pokemon.level >= level
        pokemon.species = evolutions[0][0]
      # Species with only multiple possible evolutions (the evolution is defined randomly)
      elsif evolutions.length > 1 && pokemon.level >= level
        pokemon.species = evolutions[rand(0, evolutions.length - 1)][0]
      end
    end

    evolvedTimes += 1
  end
end

class Difficulty
  attr_accessor :id
  attr_accessor :random_increase
  attr_accessor :fixed_increase
  attr_accessor :first_evolution_level
  attr_accessor :secund_evolution_level

  def initialize(id, random_increase, fixed_increase, first_evolution_level = LevelScalingSettings::DEFAULT_FIRST_EVOLUTION_LEVEL, secund_evolution_level = LevelScalingSettings::DEFAULT_SECOND_EVOLUTION_LEVEL)
    @id = id
    @random_increase = random_increase
    @fixed_increase = fixed_increase
    @first_evolution_level = first_evolution_level
    @secund_evolution_level = secund_evolution_level
  end
end
