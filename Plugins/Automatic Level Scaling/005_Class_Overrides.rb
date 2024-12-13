#===============================================================================
# Automatic Level Scaling Class Overrides
# By Benitex
#===============================================================================

class Trainer
  def key
    return [@trainer_type, self.name, @version]
  end
end

class Pokemon
  # Constants to make the get_evolutions method array more readable
  # [Species, Method, Parameter]
  EVOLUTION_SPECIES = 0
  EVOLUTION_METHOD = 1
  EVOLUTION_PARAMETER = 2

  def scale(new_level = nil)
    new_level = AutomaticLevelScaling.getScaledLevel if new_level.nil?
    new_level = new_level.clamp(1, GameData::GrowthRate.max_level)
    return if !AutomaticLevelScaling.shouldScaleLevel?(self.level, new_level)

    self.level = new_level
    self.scaleEvolutionStage if AutomaticLevelScaling.settings[:automatic_evolutions]
    self.calc_stats
    self.reset_moves if AutomaticLevelScaling.settings[:update_moves]
  end

  def scaleEvolutionStage
    original_species = self.species
    original_form = self.form   # regional form
    evolution_stage = 0

    if AutomaticLevelScaling.settings[:include_previous_stages]
      self.species = GameData::Species.get_species_form(self.species, self.form).get_baby_species # Reverts to the first evolution stage
    else
      # Checks if the pokemon has evolved
      if self.species != GameData::Species.get_species_form(self.species, self.form).get_baby_species
        evolution_stage = 1
      end
    end

    (2 - evolution_stage).times do |_|
      possible_evolutions = self.getPossibleEvolutions
      return if possible_evolutions.length == 0 || (!AutomaticLevelScaling.settings[:include_next_stages] && self.species == original_species)

      evolution_level = getEvolutionLevel(evolution_stage == 0)

      # Evolution
      if self.level >= evolution_level
        if possible_evolutions.length == 1
          self.species = possible_evolutions[0][EVOLUTION_SPECIES]

        elsif possible_evolutions.length > 1
          self.species = possible_evolutions.sample[EVOLUTION_SPECIES]

          # If the original species is a specific evolution, uses it instead of the random one
          for evolution in possible_evolutions do
            if evolution[EVOLUTION_SPECIES] == original_species
              self.species = evolution[EVOLUTION_SPECIES]
            end
          end
        end
      end

      setForm(original_form)
      evolution_stage += 1
    end
  end

  # @param has_evolved [Boolean] is necessary to determine the default evolution level for pokemon with non natural evolution methods
  def getEvolutionLevel(has_evolved)
    # Default evolution levels according to the pokemon evolution stage
    evolution_level = AutomaticLevelScaling.settings[!has_evolved ? :first_evolution_level : :second_evolution_level]
    possible_evolutions = self.getPossibleEvolutions

    if possible_evolutions.length == 1
      # Updates the evolution level if the evolution is by a natural method
      if possible_evolutions[0][EVOLUTION_PARAMETER].is_a?(Integer) && LevelScalingSettings::NATURAL_EVOLUTION_METHODS.include?(possible_evolutions[0][EVOLUTION_METHOD])
        evolution_level = possible_evolutions[0][EVOLUTION_PARAMETER]
      end

    elsif possible_evolutions.length > 1
      # Updates the evolution level if one of the evolutions is a natural evolution method. If there's more than one, uses the lowest one
      level = GameData::GrowthRate.max_level + 1
      for evolution in possible_evolutions do
        if evolution[EVOLUTION_PARAMETER].is_a?(Integer) && LevelScalingSettings::NATURAL_EVOLUTION_METHODS.include?(evolution[EVOLUTION_METHOD])
          level = evolution[EVOLUTION_PARAMETER] if evolution[EVOLUTION_PARAMETER] < level
        end
      end
      evolution_level = level if level < GameData::GrowthRate.max_level + 1
    end

    return evolution_level
  end

  def getPossibleEvolutions
    possible_evolutions = GameData::Species.get_species_form(self.species, self.form).get_evolutions

    possible_evolutions = possible_evolutions.delete_if { |evolution|
      # Regional evolutions of pokemon not in their regional forms
      evolution[EVOLUTION_METHOD] == :None ||
      # Remove non natural evolutions evolutions if include_non_natural_evolutions is false
      !AutomaticLevelScaling.settings[:include_non_natural_evolutions] && !LevelScalingSettings::NATURAL_EVOLUTION_METHODS.include?(evolution[EVOLUTION_METHOD])
    }

    return possible_evolutions
  end
end

class PokemonGlobalMetadata
  def previous_trainer_parties
    @previous_trainer_parties = {} if !@previous_trainer_parties
    return @previous_trainer_parties
  end

  def map_levels
    @map_levels = {} if !@map_levels
    return @map_levels
  end
end
