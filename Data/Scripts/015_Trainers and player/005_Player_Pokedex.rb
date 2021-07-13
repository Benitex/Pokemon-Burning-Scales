class Player < Trainer
  # Represents the player's Pokédex.
  class Pokedex
    # @return [Array<Integer>] an array of accessible Dexes
    # @see #refresh_accessible_dexes
    attr_reader :accessible_dexes

    def inspect
      str = super.chop
      str << format(' seen: %d, owned: %d>', self.seen_count, self.owned_count)
      return str
    end

    # Creates an empty Pokédex.
    def initialize
      @unlocked_dexes = []
      0.upto(pbLoadRegionalDexes.length) do |i|
        @unlocked_dexes[i] = (i == 0)
      end
      self.clear
    end

    # Clears the Pokédex.
    def clear
      @seen            = {}
      @owned           = {}
      @seen_forms      = {}
      @last_seen_forms = {}
      @owned_shadow    = {}
      @number_battled  = {}
      self.refresh_accessible_dexes
    end

    #===========================================================================

    # Sets the given species as seen in the Pokédex.
    # @param species [Symbol, GameData::Species] species to set as seen
    # @param should_refresh_dexes [Boolean] whether Dex accessibility should be recalculated
    def set_seen(species, should_refresh_dexes = true)
      species_id = GameData::Species.try_get(species)&.species
      return if species_id.nil?
      @seen[species_id] = true
      self.refresh_accessible_dexes if should_refresh_dexes
    end

    # @param species [Symbol, GameData::Species] species to check
    # @return [Boolean] whether the species is seen
    def seen?(species)
      species_id = GameData::Species.try_get(species)&.species
      return false if species_id.nil?
      return @seen[species_id] == true
    end

    # @param species [Symbol, GameData::Species] species to check
    # @param gender [Integer] gender to check
    # @param form [Integer] form to check
    # @return [Boolean] whether the species of the given gender and form is seen
    def seen_form?(species, gender, form)
      species_id = GameData::Species.try_get(species)&.species
      return false if species_id.nil?
      @seen_forms[species_id] ||= [[], []]
      return @seen_forms[species_id][gender][form] == true
    end

    # Returns the amount of seen Pokémon.
    # If a region ID is given, returns the amount of seen Pokémon
    # in that region.
    # @param dex [Integer] region ID
    def seen_count(dex = -1)
      validate dex => Integer
      return self.count_species(@seen, dex)
    end

    # Returns whether there are any seen Pokémon.
    # If a region is given, returns whether there are seen Pokémon
    # in that region.
    # @param region [Integer] region ID
    # @return [Boolean] whether there are any seen Pokémon
    def seen_any?(dex = -1)
      validate dex => Integer
      if dex == -1
        GameData::Species.each { |s| return true if s.form == 0 && @seen[s.species] }
      else
        pbAllRegionalSpecies(dex).each { |s| return true if s && @seen[s] }
      end
      return false
    end

    # Returns the amount of seen forms for the given species.
    # @param species [Symbol, GameData::Species] Pokémon species
    # @return [Integer] amount of seen forms
    def seen_forms_count(species)
      species_id = GameData::Species.try_get(species)&.species
      return 0 if species_id.nil?
      ret = 0
      @seen_forms[species_id] ||= [[], []]
      array = @seen_forms[species_id]
      for i in 0...[array[0].length, array[1].length].max
        ret += 1 if array[0][i] || array[1][i]
      end
      return ret
    end

    # @param species [Symbol, GameData::Species] Pokémon species
    def last_form_seen(species)
      @last_seen_forms[species] ||= []
      return @last_seen_forms[species][0] || 0, @last_seen_forms[species][1] || 0
    end

    # @param species [Symbol, GameData::Species] Pokémon species
    # @param gender [Integer] gender (0=male, 1=female, 2=genderless)
    # @param form [Integer] form number
    def set_last_form_seen(species, gender = 0, form = 0)
      @last_seen_forms[species] = [gender, form]
    end

    #===========================================================================

    # Sets the given species as owned in the Pokédex.
    # @param species [Symbol, GameData::Species] species to set as owned
    # @param should_refresh_dexes [Boolean] whether Dex accessibility should be recalculated
    def set_owned(species, should_refresh_dexes = true)
      species_id = GameData::Species.try_get(species)&.species
      return if species_id.nil?
      @owned[species_id] = true
      self.refresh_accessible_dexes if should_refresh_dexes
    end

    # Sets the given species as owned in the Pokédex.
    # @param species [Symbol, GameData::Species] species to set as owned
    def set_shadow_pokemon_owned(species)
      species_id = GameData::Species.try_get(species)&.species
      return if species_id.nil?
      @owned_shadow[species_id] = true
      self.refresh_accessible_dexes
    end

    # @param species [Symbol, GameData::Species] species to check
    # @return [Boolean] whether the species is owned
    def owned?(species)
      species_id = GameData::Species.try_get(species)&.species
      return false if species_id.nil?
      return @owned[species_id] == true
    end

    # @param species [Symbol, GameData::Species] species to check
    # @return [Boolean] whether a Shadow Pokémon of the species is owned
    def owned_shadow_pokemon?(species)
      species_id = GameData::Species.try_get(species)&.species
      return false if species_id.nil?
      return @owned_shadow[species_id] == true
    end

    # Returns the amount of owned Pokémon.
    # If a region ID is given, returns the amount of owned Pokémon
    # in that region.
    # @param region [Integer] region ID
    def owned_count(dex = -1)
      validate dex => Integer
      return self.count_species(@owned, dex)
    end

    #===========================================================================

    # @param pkmn [Pokemon, Symbol, GameData::Species] Pokemon to register as seen
    # @param gender [Integer] gender to register (0=male, 1=female, 2=genderless)
    # @param form [Integer] form to register
    def register(species, gender = 0, form = 0, should_refresh_dexes = true)
      if species.is_a?(Pokemon)
        species_data = species.species_data
        gender = species.gender
      else
        species_data = GameData::Species.get_species_form(species, form)
      end
      species = species_data.species
      gender = 0 if gender >= 2
      form = species_data.form
      if form != species_data.pokedex_form
        species_data = GameData::Species.get_species_form(species, species_data.pokedex_form)
        form = species_data.form
      end
      form = 0 if species_data.form_name.nil? || species_data.form_name.empty?
      # Register as seen
      @seen[species] = true
      @seen_forms[species] ||= [[], []]
      @seen_forms[species][gender][form] = true
      @last_seen_forms[species] ||= []
      @last_seen_forms[species] = [gender, form] if @last_seen_forms[species] == []
      self.refresh_accessible_dexes if should_refresh_dexes
    end

    # @param pkmn [Pokemon] Pokemon to register as most recently seen
    def register_last_seen(pkmn)
      validate pkmn => Pokemon
      species_data = pkmn.species_data
      form = species_data.pokedex_form
      form = 0 if species_data.form_name.nil? || species_data.form_name.empty?
      @last_seen_forms[pkmn.species] = [pkmn.gender, form]
    end

    #===========================================================================

    # Unlocks the given Dex, -1 being the National Dex.
    # @param dex [Integer] Dex ID (-1 is the National Dex)
    def unlock(dex)
      validate dex => Integer
      dex = @unlocked_dexes.length - 1 if dex < 0 || dex > @unlocked_dexes.length - 1
      @unlocked_dexes[dex] = true
      self.refresh_accessible_dexes
    end

    # Locks the given Dex, -1 being the National Dex.
    # @param dex [Integer] Dex ID (-1 is the National Dex)
    def lock(dex)
      validate dex => Integer
      dex = @unlocked_dexes.length - 1 if dex < 0 || dex > @unlocked_dexes.length - 1
      @unlocked_dexes[dex] = false
      self.refresh_accessible_dexes
    end

    # @param dex [Integer] Dex ID (-1 is the National Dex)
    # @return [Boolean] whether the given Dex is unlocked
    def unlocked?(dex)
      validate dex => Integer
      dex = @unlocked_dexes.length - 1 if dex == -1
      return @unlocked_dexes[dex] == true
    end

    # @return [Integer] the number of defined Dexes (including the National Dex)
    def dexes_count
      return @unlocked_dexes.length
    end

    # Decides which Dex lists are able to be viewed (i.e. they are unlocked and
    # have at least 1 seen species in them), and saves all accessible Dex region
    # numbers into {#accessible_dexes}. National Dex comes after all regional
    # Dexes.
    # If the Dex list shown depends on the player's location, this just decides
    # if a species in the current region has been seen - doesn't look at other
    # regions.
    def refresh_accessible_dexes
      @accessible_dexes = []
      if Settings::USE_CURRENT_REGION_DEX
        region = pbGetCurrentRegion
        region = -1 if region >= dexes_count - 1
        @accessible_dexes[0] = region if self.seen_any?(region)
        return
      end
      if dexes_count == 1   # Only National Dex is defined
        if self.unlocked?(0) && self.seen_any?
          @accessible_dexes.push(-1)
        end
      else   # Regional Dexes + National Dex
        for i in 0...dexes_count
          dex_list_to_check = (i == dexes_count - 1) ? -1 : i
          if self.unlocked?(i) && self.seen_any?(dex_list_to_check)
            @accessible_dexes.push(dex_list_to_check)
          end
        end
      end
    end

    #===========================================================================

    # Return the Number of Pokemon of this species that the player has
    # caught or defeated
    # @param species [Symbol, GameData::Species] species to check
    # @return [Integer] amount of pokemon of the species battled
    def number_battled(species)
      species_id = GameData::Species.try_get(species)&.species
      return false if species_id.nil?
      @number_battled[species_id] = 0 if !@number_battled[species_id]
      return @number_battled[species_id]
    end

    # Increase the Number of Pokemon of this species that the player has
    # caught or defeated
    # @param species [Symbol, GameData::Species] species to increase
    def register_battled(species)
      species_id = GameData::Species.try_get(species)&.species
      return if species_id.nil?
      @number_battled[species_id] = 0 if !@number_battled[species_id]
      @number_battled[species_id] += 1
    end

    # Return the array of tries and chance of boosted shiny odds from the
    # number of Pokemon of this species that the player has caught or defeated
    # @param species [Symbol, GameData::Species] species to increase
    # @return [Array]
    def number_battled_shiny_tier(species)
      number = number_battled(species)
      if number >= 500
        return [5,30]
      elsif number >= 300
        return [4,30]
      elsif number >= 200
        return [3,25]
      elsif number >= 100
        return [2,20]
      elsif number >= 50
        return [1,15]
      else
        return [0,0]
      end
    end

    # Return the boosted odds for encountering Brilliant Pokemon from
    # the number of Pokemon of this species that the player has caught
    # or defeated
    # @return [Float]
    def number_battled_brilliant_tier(species)
      number = number_battled(species)
      if number >= 200
        return 2.0
      elsif number >= 50
        return 1.6
      elsif number >= 20
        return 1.3
      else
        return 1.0
      end
    end

    # Return the boosted odds for encountering shiny Brilliant Pokemon from
    # the number of Pokemon of this species that the player has caught
    # or defeated
    # @return [Integer]
    def number_battled_brilliant_shiny(species)
      number = number_battled(species)
      if number >= 100
        ret = 2 + (number/100)
        ret.clamp(0,6)
        return ret
      elsif number >= 50
        return 2
      else
        return 1
      end
    end

    #===========================================================================

    private

    # @param hash [Hash]
    # @param region [Integer]
    # @return [Integer]
    def count_species(hash, region = -1)
      ret = 0
      if region == -1
        GameData::Species.each { |s| ret += 1 if s.form == 0 && hash[s.species] }
      else
        pbAllRegionalSpecies(region).each { |s| ret += 1 if s && hash[s] }
      end
      return ret
    end
  end
end
