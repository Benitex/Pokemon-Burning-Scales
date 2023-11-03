#===============================================================================
# Automatic Level Scaling
# By Benitex
#===============================================================================

class AutomaticLevelScaling
  @@selected_difficulty = Difficulty.new
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
  def self.settings
    return @@settings
  end

  def self.setDifficulty(id)
    if LevelScalingSettings::DIFFICULTIES[id] == nil
      raise _INTL("No difficulty with id \"{1}\" was provided in the DIFFICULTIES Hash of Settings.", id)
    else
      @@selected_difficulty = LevelScalingSettings::DIFFICULTIES[id]
    end
  end

  def self.getScaledLevel
    level = pbBalancedLevel($Trainer.party) - 2 # pbBalancedLevel increses level by 2 to challenge the player

    # Difficulty modifiers
    level += @@selected_difficulty.fixed_increase
    if @@selected_difficulty.random_increase < 0
      level += rand(@@selected_difficulty.random_increase..0)
    elsif @@selected_difficulty.random_increase > 0
      level += rand(@@selected_difficulty.random_increase)
    end

    level = level.clamp(1, GameData::GrowthRate.max_level)

    return level
  end

  def self.setNewLevel(pokemon, difference_from_average = 0)
    new_level = AutomaticLevelScaling.getScaledLevel

    # Checks for only_scale_if_higher and only_scale_if_lower
    is_blocked_by_higher_level = @@settings[:only_scale_if_higher] && pokemon.level > new_level
    is_blocked_by_lower_level = @@settings[:only_scale_if_lower] && pokemon.level < new_level
    return if is_blocked_by_higher_level || is_blocked_by_lower_level

    # Proportional scaling
    if @@settings[:proportional_scaling]
      new_level += difference_from_average
      new_level = new_level.clamp(1, GameData::GrowthRate.max_level)
    end

    pokemon.level = new_level

    # Evolution part
    AutomaticLevelScaling.setNewStage(pokemon) if @@settings[:automatic_evolutions]

    pokemon.calc_stats
    pokemon.reset_moves if @@settings[:update_moves]
  end

  def self.setNewStage(pokemon)
    original_species = pokemon.species
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

    is_regional_form = false
    for species in LevelScalingSettings::POKEMON_WITH_REGIONAL_FORMS do
      is_regional_form = true if pokemon.isSpecies?(species)
    end

    (2 - stage).times do |_|
      evolutions = GameData::Species.get(pokemon.species).get_evolutions

      # Checks if the species only evolve by level up
      has_other_evolving_method = false
      evolutions.length.times { |i|
        if evolutions[i][1] != :Level
          has_other_evolving_method = true
        end
      }

      unless has_other_evolving_method || is_regional_form  # Species that evolve by level up
        if pokemon.check_evolution_on_level_up != nil
          pokemon.species = pokemon.check_evolution_on_level_up
        end

      else  # For species with other evolving methods
        # Checks if the pokemon is in it's midform and defines the level to evolve
        level = @@settings[stage == 0 ? :first_evolution_level : :second_evolution_level]

        if pokemon.level >= level
          if evolutions.length == 1         # Species with only one possible evolution
            pokemon.species = evolutions[0][0]
            pokemon.setForm(form) if is_regional_form

          elsif evolutions.length > 1
            if is_regional_form
              if form >= evolutions.length  # regional form
                pokemon.species = evolutions[0][0]
                pokemon.setForm(form)
              else                          # regional evolution
                pokemon.species = evolutions[form][0]
              end

            else                            # Species with multiple possible evolutions
              pokemon.species = evolutions[rand(0, evolutions.length - 1)][0]
              # Checks for the evolution defined in the PBS
              for evolution in evolutions do
                if evolution[0] == original_species
                  pokemon.species = evolution[0]
                end
              end
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

  def self.setSettings(
    temporary: false,
    update_moves: true,
    automatic_evolutions: LevelScalingSettings::AUTOMATIC_EVOLUTIONS,
    include_previous_stages: LevelScalingSettings::INCLUDE_PREVIOUS_STAGES,
    proportional_scaling: LevelScalingSettings::PROPORTIONAL_SCALING,
    first_evolution_level: LevelScalingSettings::DEFAULT_FIRST_EVOLUTION_LEVEL,
    second_evolution_level: LevelScalingSettings::DEFAULT_SECOND_EVOLUTION_LEVEL,
    only_scale_if_higher: LevelScalingSettings::ONLY_SCALE_IF_HIGHER,
    only_scale_if_lower: LevelScalingSettings::ONLY_SCALE_IF_LOWER
  )
    @@settings[:temporary] = temporary
    @@settings[:update_moves] = update_moves
    @@settings[:first_evolution_level] = first_evolution_level
    @@settings[:second_evolution_level] = second_evolution_level
    @@settings[:proportional_scaling] = proportional_scaling
    @@settings[:automatic_evolutions] = automatic_evolutions
    @@settings[:include_previous_stages] = include_previous_stages
    @@settings[:only_scale_if_higher] = only_scale_if_higher
    @@settings[:only_scale_if_lower] = only_scale_if_lower
  end
end
