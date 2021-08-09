#===============================================================================
# setup Map metadata
#===============================================================================
EliteBattle.configProcess(:MAPS) do
  # configure metrics data
  next if !File.safeData?("Data/maps.ebdx")
  echoln "  -> configuring map data..."
  metrics = load_data("Data/maps.ebdx")
  for key in metrics.keys
    args = [key.to_i]
    vals = {
      'BattleBGM' => :BGM,
    }
    # failsafe
    next if !metrics[key]
    # iterate through registered metrics
    for section in metrics[key].keys
      for v in vals.keys
        next if !metrics[key][section] || !metrics[key][section][v]
        ksym = section == "__pk__" ? vals[v] : "#{section.upcase}_#{vals[v]}".to_sym
        args.push(ksym); args.push(metrics[key][section][v].length > 1 ? metrics[key][section][v] : metrics[key][section][v][0])
      end
      # set up battle environment
      if metrics[key][section] && metrics[key][section]["BattleEnv"]
        ebenv = metrics[key][section]["BattleEnv"][0]
        if hasConst?(EnvironmentEBDX, ebenv.to_sym)
          ksym = section == "__pk__" ? :BACKDROP : "#{section.upcase}_BACKDROP".to_sym
          args.push(ksym); args.push(getConst(EnvironmentEBDX, ebenv.to_sym))
        else
          EliteBattle.log.warn("Environment #{ebenv} for Map #{key} is not defined in the ENVIRONMENTS.rb file!")
        end
      end
      # configure common metrics
      args = EliteBattle.commonConfig(metrics, args, key)
      # push arguments
      EliteBattle.add_data(*args)
    end
  end
end
