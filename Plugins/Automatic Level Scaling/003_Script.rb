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
    save_trainer_parties: LevelScalingSettings::SAVE_TRAINER_PARTIES,
    use_map_level_for_wild_pokemon: LevelScalingSettings::USE_MAP_LEVEL_FOR_WILD_POKEMON,
    update_moves: true
  }

  def self.difficulty=(id)
    if LevelScalingSettings::DIFFICULTIES[id] == nil
      raise _INTL("No difficulty with id \"{1}\" was provided in the DIFFICULTIES Hash of Settings.", id)
    else
      @@selected_difficulty = LevelScalingSettings::DIFFICULTIES[id]
    end
  end

  def self.settings
    return @@settings
  end

  def self.getScaledLevel
    level = pbBalancedLevel($Trainer.party) - 2 # pbBalancedLevel increses level by 2 to challenge the player

    # Difficulty modifiers
    level += @@selected_difficulty.fixed_increase

    unless @@settings[:proportional_scaling] || @@settings[:use_map_level_for_wild_pokemon]
      if @@selected_difficulty.random_increase < 0
        level += rand(@@selected_difficulty.random_increase..0)
      elsif @@selected_difficulty.random_increase > 0
        level += rand(@@selected_difficulty.random_increase)
      end
    end

    level = level.clamp(1, GameData::GrowthRate.max_level)

    return level
  end

  def self.getMapLevel(map_id)
    if !$PokemonGlobal.map_levels.has_key?(map_id)
      $PokemonGlobal.map_levels[map_id] = AutomaticLevelScaling.getScaledLevel
    end

    level = $PokemonGlobal.map_levels[map_id]

    # Adding randomness from the selected difficulty
    if @@selected_difficulty.random_increase < 0
      level += rand(@@selected_difficulty.random_increase..0)
    elsif @@selected_difficulty.random_increase > 0
      level += rand(@@selected_difficulty.random_increase)
    end

    return level
  end

  def self.shouldScaleLevel?(previous_level, new_level)
    # Checks for only_scale_if_higher and only_scale_if_lower
    return false if @@settings[:only_scale_if_higher] && previous_level > new_level
    return false if @@settings[:only_scale_if_lower] && previous_level < new_level
    return true
  end

  def self.battledTrainer?(trainer_id)
    return $PokemonGlobal.previous_trainer_parties.has_key?(trainer_id)
  end

  def self.scaleToPreviousTrainerParty(trainer)
    trainer.party = $PokemonGlobal.previous_trainer_parties[trainer.key]
  end

  def self.savePreviousTrainerParty(trainer_key, party)
    $PokemonGlobal.previous_trainer_parties[trainer_key] = party
  end

  def self.setTemporarySetting(setting, value)
    # Parameters validation
    case setting
    when "firstEvolutionLevel", "secondEvolutionLevel"
      if !value.is_a?(Integer)
        raise _INTL("\"{1}\" requires an integer value, but {2} was provided.", setting, value)
      end
    when "updateMoves", "automaticEvolutions", "includeNonNaturalEvolutions", "includePreviousStages", "includeNextStages",
        "proportionalScaling", "onlyScaleIfHigher", "onlyScaleIfLower", "saveTrainerParties", "useMapLevelForWildPokemon"
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
    when "saveTrainerParties"
      @@settings[:save_trainer_parties] = value
    when "useMapLevelForWildPokemon"
      @@settings[:use_map_level_for_wild_pokemon] = value
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
    only_scale_if_lower: LevelScalingSettings::ONLY_SCALE_IF_LOWER,
    save_trainer_parties: LevelScalingSettings::SAVE_TRAINER_PARTIES,
    use_map_level_for_wild_pokemon: LevelScalingSettings::USE_MAP_LEVEL_FOR_WILD_POKEMON
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
    @@settings[:save_trainer_parties] = save_trainer_parties
    @@settings[:use_map_level_for_wild_pokemon] = use_map_level_for_wild_pokemon
  end

  def self.setNewLevel(pokemon, difference_from_average = 0)
    new_level = AutomaticLevelScaling.getScaledLevel

    # Proportional scaling
    if @@settings[:proportional_scaling]
      new_level += difference_from_average
      new_level = new_level.clamp(1, GameData::GrowthRate.max_level)
    end

    pokemon.scale(new_level)
  end

  def self.setNewStage(pokemon)
    pokemon.scaleEvolutionStage
  end

  def self.getPossibleEvolutions(pokemon)
    return pokemon.getPossibleEvolutions
  end

  def self.getEvolutionLevel(pokemon, possible_evolutions, evolution_stage)
    return pokemon.getEvolutionLevel(evolution_stage == 0)
  end
end
