#===============================================================================
# Automatic Level Scaling
# By Benitex
#===============================================================================

Events.onWildPokemonCreate += proc { |_sender, e|
  pokemon = e[0]
  selectedDifficultyID = $game_variables[LevelScalingSettings::WILD_VARIABLE]
  if selectedDifficultyID != 0
    AutomaticLevelScaling.setDifficulty(selectedDifficultyID)
    AutomaticLevelScaling.setNewLevel(pokemon)
  end
}

Events.onTrainerPartyLoad += proc { |_sender, trainer|
  if trainer   # An NPCTrainer object containing party/items/lose text, etc.
    selectedDifficultyID = $game_variables[LevelScalingSettings::TRAINER_VARIABLE]
    if selectedDifficultyID != 0
      AutomaticLevelScaling.setDifficulty(selectedDifficultyID)
      avarage_level = 0
      trainer[0].party.each { |pokemon| avarage_level += pokemon.level }
      avarage_level /= trainer[0].party.length

      for pokemon in trainer[0].party
        AutomaticLevelScaling.setNewLevel(pokemon, pokemon.level - avarage_level)
      end
    end
  end
}

class AutomaticLevelScaling
  @@selectedDifficulty
  @@settings = {
    automatic_evolutions: true,
    first_evolution_level: 20,
    second_evolution_level: 40,
    update_moves: true,
    proportional_scaling: false
  }

  def self.setDifficulty(selectedDifficultyID)
    for difficulty in LevelScalingSettings::DIFICULTIES do
      @@selectedDifficulty = difficulty if difficulty.id == selectedDifficultyID
    end
  end

  def self.setNewLevel(pokemon, difference_from_average = 0)
    new_level = pbBalancedLevel($Trainer.party) - 2 # pbBalancedLevel increses level by 2 to challenge the player

    # Difficulty modifiers
    new_level += @@selectedDifficulty.fixed_increase
    if @@selectedDifficulty.random_increase < 0
      new_level += rand(@@selectedDifficulty.random_increase..0)
    elsif @@selectedDifficulty.random_increase > 0
      new_level += rand(@@selectedDifficulty.random_increase)
    end
    # Proportional scaling
    new_level += difference_from_average if LevelScalingSettings::PROPORTIONAL_SCALING || @@settings[:proportional_scaling]

    new_level = new_level.clamp(1, GameData::GrowthRate.max_level)
    pokemon.level = new_level

    # Evolution part
    AutomaticLevelScaling.setNewStage(pokemon) if LevelScalingSettings::AUTOMATIC_EVOLUTIONS || @@settings[:automatic_evolutions]

    pokemon.calc_stats
    pokemon.reset_moves if @@settings[:update_moves]
  end

  def self.setNewStage(pokemon)
    pokemon.species = GameData::Species.get(pokemon.species).get_baby_species # revert to the first stage

    2.times do |evolvedTimes|
      evolutions = GameData::Species.get(pokemon.species).get_evolutions(false)

      # Checks if the species only evolve by level up
      other_evolving_method = false
      evolutions.length.times { |i|
        if evolutions[i][1] != :Level
          other_evolving_method = true
        end
      }

      if !other_evolving_method   # Species that evolve by level up
        if pokemon.check_evolution_on_level_up != nil
          pokemon.species = pokemon.check_evolution_on_level_up
        end

      else  # For species with other evolving methods
        # Checks if the pokemon is in it's midform and defines the level to evolve
        level = evolvedTimes == 0 ? @@settings[:second_evolution_level] : @@settings[:second_evolution_level]

        if pokemon.level >= level
          if evolutions.length == 1     # Species with only one possible evolution
            pokemon.species = evolutions[0][0]
          elsif evolutions.length > 1   # Species with multiple possible evolutions (the evolution is randomly defined)
            pokemon.species = evolutions[rand(0, evolutions.length - 1)][0]
          end
        end
      end
    end
  end

  def self.setSettings(update_moves: true, automatic_evolutions: LevelScalingSettings::AUTOMATIC_EVOLUTIONS, proportional_scaling: LevelScalingSettings::PROPORTIONAL_SCALING, first_evolution_level: LevelScalingSettings::DEFAULT_FIRST_EVOLUTION_LEVEL, second_evolution_level: LevelScalingSettings::DEFAULT_SECOND_EVOLUTION_LEVEL)
    @@settings[:update_moves] = update_moves
    @@settings[:first_evolution_level] = first_evolution_level
    @@settings[:second_evolution_level] = second_evolution_level
    @@settings[:proportional_scaling] = proportional_scaling
    @@settings[:automatic_evolutions] = automatic_evolutions
  end
end

class Difficulty
  attr_accessor :id
  attr_accessor :fixed_increase
  attr_accessor :random_increase

  def initialize(id:, fixed_increase: 0, random_increase: 0)
    @id = id
    @random_increase = random_increase
    @fixed_increase = fixed_increase
  end
end
