#===============================================================================
# Automatic Level Scaling
# By Benitex
#===============================================================================

class AutomaticLevelScaling
  @@selectedDifficulty = Difficulty.new(id: 0)
  @@settings = {
    temporary: false,
    automatic_evolutions: LevelScalingSettings::AUTOMATIC_EVOLUTIONS,
    include_previous_stages: LevelScalingSettings::INCLUDE_PREVIOUS_STAGES,
    first_evolution_level: LevelScalingSettings::DEFAULT_FIRST_EVOLUTION_LEVEL,
    second_evolution_level: LevelScalingSettings::DEFAULT_SECOND_EVOLUTION_LEVEL,
    proportional_scaling: LevelScalingSettings::PROPORTIONAL_SCALING,
    only_scale_if_higher: LevelScalingSettings::ONLY_SCALE_IF_HIGHER,
    only_scale_if_lower: LevelScalingSettings::ONLY_SCALE_IF_LOWER,
    update_moves: true
  }

  def self.setDifficulty(id)
    for difficulty in LevelScalingSettings::DIFICULTIES do
      @@selectedDifficulty = difficulty if difficulty.id == id
    end
  end

  def self.getScaledLevel
    level = pbBalancedLevel($Trainer.party) - 2 # pbBalancedLevel increses level by 2 to challenge the player

    # Difficulty modifiers
    level += @@selectedDifficulty.fixed_increase
    if @@selectedDifficulty.random_increase < 0
      level += rand(@@selectedDifficulty.random_increase..0)
    elsif @@selectedDifficulty.random_increase > 0
      level += rand(@@selectedDifficulty.random_increase)
    end

    level = level.clamp(1, GameData::GrowthRate.max_level)

    return level
  end

  def self.setNewLevel(pokemon, difference_from_average = 0)
    # Checks for only_scale_if_higher and only_scale_if_lower
    higher_level_block = @@settings[:only_scale_if_higher] && pokemon.level > new_level
    lower_level_block = @@settings[:only_scale_if_lower] && pokemon.level < new_level
    unless higher_level_block || lower_level_block
      pokemon.level = AutomaticLevelScaling.getScaledLevel

      # Proportional scaling
      if @@settings[:proportional_scaling]
        level = pokemon.level + difference_from_average
        pokemon.level = level.clamp(1, GameData::GrowthRate.max_level)
      end

      # Evolution part
      AutomaticLevelScaling.setNewStage(pokemon) if @@settings[:automatic_evolutions]

      pokemon.calc_stats
      pokemon.reset_moves if @@settings[:update_moves]
    end

    # Settings reset
    if @@settings[:temporary]
      @@settings = {
        temporary: false,
        automatic_evolutions: LevelScalingSettings::AUTOMATIC_EVOLUTIONS,
        include_previous_stages: LevelScalingSettings::INCLUDE_PREVIOUS_STAGES,
        first_evolution_level: LevelScalingSettings::DEFAULT_FIRST_EVOLUTION_LEVEL,
        second_evolution_level: LevelScalingSettings::DEFAULT_SECOND_EVOLUTION_LEVEL,
        proportional_scaling: LevelScalingSettings::PROPORTIONAL_SCALING,
        only_scale_if_higher: LevelScalingSettings::ONLY_SCALE_IF_HIGHER,
        only_scale_if_lower: LevelScalingSettings::ONLY_SCALE_IF_LOWER,
        update_moves: true
      }
    end
  end

  def self.setNewStage(pokemon)
    form = pokemon.form   # regional form
    stage = 0             # evolution stage

    if @@settings[:include_previous_stages]
      pokemon.species = GameData::Species.get(pokemon.species).get_baby_species # revert to the first stage
    else
      # Checks if the pokemon has evolved
      if pokemon.species != GameData::Species.get(pokemon.species).get_baby_species
        stage = 1
      end
    end

    regionalForm = false
    for species in LevelScalingSettings::POKEMON_WITH_REGIONAL_FORMS do
      regionalForm = true if pokemon.isSpecies?(species)
    end

    (2 - stage).times do |_|
      evolutions = GameData::Species.get(pokemon.species).get_evolutions

      # Checks if the species only evolve by level up
      other_evolving_method = false
      evolutions.length.times { |i|
        if evolutions[i][1] != :Level
          other_evolving_method = true
        end
      }

      unless other_evolving_method || regionalForm  # Species that evolve by level up
        if pokemon.check_evolution_on_level_up != nil
          pokemon.species = pokemon.check_evolution_on_level_up
        end

      else  # For species with other evolving methods
        # Checks if the pokemon is in it's midform and defines the level to evolve
        level = stage == 0 ? @@settings[:first_evolution_level] : @@settings[:second_evolution_level]

        if pokemon.level >= level
          if evolutions.length == 1         # Species with only one possible evolution
            pokemon.species = evolutions[0][0]
            pokemon.setForm(form) if regionalForm

          elsif evolutions.length > 1
            if regionalForm
              if form >= evolutions.length  # regional form
                pokemon.species = evolutions[0][0]
                pokemon.setForm(form)
              else                          # regional evolution
                pokemon.species = evolutions[form][0]
              end

            else                            # Species with multiple possible evolutions
              pokemon.species = evolutions[rand(0, evolutions.length - 1)][0]
            end
          end
        end
      end

      stage += 1
    end
  end

  def self.setTemporarySetting(setting, value)
    # Parameters validation
    case setting
    when "firstEvolutionLevel", "secondEvolutionLevel"
      if !value.is_a?(Integer)
        raise _INTL("\"{1}\" requires an integer value, but {2} was provided.",setting,value)
      end
    when "updateMoves", "automaticEvolutions", "includePreviousStages", "proportionalScaling", "onlyScaleIfHigher", "onlyScaleIfLower"
      if !(value.is_a?(FalseClass) || value.is_a?(TrueClass))
        raise _INTL("\"{1}\" requires a boolean value, but {2} was provided.",setting,value)
      end
    else
      raise _INTL("\"{1}\" is not a defined setting name.",setting)
    end

    @@settings[:temporary] = true
    case setting
    when "updateMoves"
      @@settings[:update_moves] = value
    when "automaticEvolutions"
      @@settings[:automatic_evolutions] = value
    when "includePreviousStages"
      @@settings[:include_previous_stages] = value
    when "proportionalScaling"
      @@settings[:proportional_scaling] = value
    when "firstEvolutionLevel"
      @@settings[:first_evolution_level] = value
    when "secondEvolutionLevel"
      @@settings[:second_evolution_level] = value
    when "onlyScaleIfHigher"
      @@settings[:only_scale_if_higher] = value
    when "onlyScaleIfLower"
      @@settings[:only_scale_if_lower] = value
    end
  end
end
