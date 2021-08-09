#===============================================================================
# setup EBDX rules
#===============================================================================
EliteBattle.configProcess(:RULES) do
  # configure metrics data
  next if !File.safeData?("Data/rules.ebdx")
  echoln "  -> configuring battle rules..."
  metrics = load_data("Data/rules.ebdx")
  # iterate through all the sections
  for section in metrics.keys
    if section.upcase == "BOSSBATTLES"
      options = []
      for set in ["Immunities"]
        if metrics[section]["__pk__"] && metrics[section]["__pk__"][set]
          for immunity in metrics[section]["__pk__"][set]
            options.push(immunity.to_sym)
          end
          EliteBattle.add_data(:BOSSBATTLES, set.upcase.to_sym, options)
        end
      end
    # randomizer ruleset
    elsif section.upcase == "RANDOMIZER"
      options = []
      sets = { "ItemExclusions" => :EXCLUSIONS_ITEMS, "TrainerExclusions" => :EXCLUSIONS_TRAINERS, "SpeciesExclusions" => :EXCLUSIONS_SPECIES }
      for set in sets.keys
        if metrics[section]["__pk__"] && metrics[section]["__pk__"][set]
          for immunity in metrics[section]["__pk__"][set]
            options.push(immunity.to_sym)
          end
          EliteBattle.add_data(:RANDOMIZER, sets[set], options)
        end
      end
    end
  end
end
