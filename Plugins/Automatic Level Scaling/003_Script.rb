#===============================================================================
# Automatic Level Scaling
# By Benitex
#===============================================================================

class AutomaticLevelScaling
  @@selected_difficulty = Difficulty.new
  @@settings = {
    temporary: false,
    automatic_evolutions: LevelScalingSettings::AUTOMATIC_EVOLUTIONS,
    include_non_natural_evolutions: LevelScalingSettings::INCLUDE_NON_NATURAL_EVOLUTIONS,
    include_previous_stages: LevelScalingSettings::INCLUDE_PREVIOUS_STAGES,
    include_next_stages: LevelScalingSettings::INCLUDE_NEXT_STAGES,
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

  # Constants to make the get_evolutions method array more readable
  # [Species, Method, Parameter]
  SPECIES = 0
  METHOD = 1
  PARAMETER = 2

  def self.difficulty=(id)
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
    AutomaticLevelScaling.setNewStage(pokemon) if @@settings[:automatic_evolutions]
    pokemon.calc_stats
    pokemon.reset_moves if @@settings[:update_moves]
  end

  def self.setNewStage(pokemon)
    original_species = pokemon.species
    original_form = pokemon.form   # regional form
    evolution_stage = 0

    if @@settings[:include_previous_stages]
      pokemon.species = GameData::Species.get_species_form(pokemon.species, pokemon.form).get_baby_species # Reverts to the first evolution stage
    else
      # Checks if the pokemon has evolved
      if pokemon.species != GameData::Species.get_species_form(pokemon.species, pokemon.form).get_baby_species
        evolution_stage = 1
      end
    end

    (2 - evolution_stage).times do |_|
      possible_evolutions = AutomaticLevelScaling.getPossibleEvolutions(pokemon)
      return if possible_evolutions.length == 0 || !@@settings[:include_next_stages] && pokemon.species == original_species

      evolution_level = AutomaticLevelScaling.getEvolutionLevel(pokemon, possible_evolutions, evolution_stage)

      # Evolution
      if pokemon.level >= evolution_level
        if possible_evolutions.length == 1
          pokemon.species = possible_evolutions[0][SPECIES]

        elsif possible_evolutions.length > 1
          pokemon.species = possible_evolutions.sample[SPECIES]

          # If the original species is a specific evolution, uses it instead of the random one
          for evolution in possible_evolutions do
            if evolution[SPECIES] == original_species
              pokemon.species = evolution[SPECIES]
            end
          end
        end
      end

      pokemon.setForm(original_form)
      evolution_stage += 1
    end
  end

  def self.getPossibleEvolutions(pokemon)
    possible_evolutions = GameData::Species.get_species_form(pokemon.species, pokemon.form).get_evolutions

    possible_evolutions = possible_evolutions.delete_if { |evolution|
      # Regional evolutions of pokemon not in their regional forms
      evolution[METHOD] == :None ||
      # Remove non natural evolutions evolutions if include_non_natural_evolutions is false
      !@@settings[:include_non_natural_evolutions] && !LevelScalingSettings::NATURAL_EVOLUTION_METHODS.include?(evolution[METHOD])
    }

    return possible_evolutions
  end

  def self.getEvolutionLevel(pokemon, possible_evolutions, evolution_stage)
    # Default evolution levels according to the pokemon evolution stage
    evolution_level = @@settings[evolution_stage == 0 ? :first_evolution_level : :second_evolution_level]

    if possible_evolutions.length == 1
      # Updates the evolution level if the evolution is by a natural method
      if possible_evolutions[0][PARAMETER].is_a?(Integer) && LevelScalingSettings::NATURAL_EVOLUTION_METHODS.include?(possible_evolutions[0][METHOD])
        evolution_level = possible_evolutions[0][PARAMETER]
      end

    elsif possible_evolutions.length > 1
      # Updates the evolution level if one of the evolutions is a natural evolution method. If there's more than one, uses the lowest one
      level = GameData::GrowthRate.max_level + 1
      for evolution in possible_evolutions do
        if evolution[PARAMETER].is_a?(Integer) && LevelScalingSettings::NATURAL_EVOLUTION_METHODS.include?(evolution[METHOD])
          level = evolution[PARAMETER] if evolution[PARAMETER] < level
        end
      end
      evolution_level = level if level < GameData::GrowthRate.max_level + 1
    end

    return evolution_level
  end

  def self.setTemporarySetting(setting, value)
    # Parameters validation
    case setting
    when "firstEvolutionLevel", "secondEvolutionLevel"
      if !value.is_a?(Integer)
        raise _INTL("\"{1}\" requires an integer value, but {2} was provided.", setting, value)
      end
    when "updateMoves", "automaticEvolutions", "includeNonNaturalEvolutions", "includePreviousStages", "includeNextStages", "proportionalScaling", "onlyScaleIfHigher", "onlyScaleIfLower"
      if !(value.is_a?(FalseClass) || value.is_a?(TrueClass))
        raise _INTL("\"{1}\" requires a boolean value, but {2} was provided.", setting, value)
      end
    else
      if setting.include?("_")
        raise _INTL("\"{1}\" is not a defined setting name. Try using camelCase instead of underscore_case.", setting)
      else
        raise _INTL("\"{1}\" is not a defined setting name.", setting)
      end
    end

    @@settings[:temporary] = true
    case setting
    when "updateMoves"
      @@settings[:update_moves] = value
    when "automaticEvolutions"
      @@settings[:automatic_evolutions] = value
    when "includeNonNaturalEvolutions"
      @@settings[:include_non_natural_evolutions] = value
    when "includePreviousStages"
      @@settings[:include_previous_stages] = value
    when "includeNextStages"
      @@settings[:include_next_stages] = value
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
    include_non_natural_evolutions: LevelScalingSettings::INCLUDE_NON_NATURAL_EVOLUTIONS,
    include_previous_stages: LevelScalingSettings::INCLUDE_PREVIOUS_STAGES,
    include_next_stages: LevelScalingSettings::INCLUDE_NEXT_STAGES,
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
    @@settings[:include_non_natural_evolutions] = include_non_natural_evolutions,
    @@settings[:include_previous_stages] = include_previous_stages
    @@settings[:include_next_stages] = include_next_stages
    @@settings[:only_scale_if_higher] = only_scale_if_higher
    @@settings[:only_scale_if_lower] = only_scale_if_lower
  end
end
