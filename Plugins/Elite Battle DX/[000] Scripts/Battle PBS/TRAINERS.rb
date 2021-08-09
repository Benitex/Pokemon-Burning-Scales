#===============================================================================
# setup Trainer metadata
#===============================================================================
EliteBattle.configProcess(:TRAINERS) do
  # configure metrics data
  next if !File.safeData?("Data/trainers.ebdx")
  echoln "  -> configuring trainer data..."
  metrics = load_data("Data/trainers.ebdx")
  for key in metrics.keys
    i = (key.split(",").map { |s| s.strip }).join("__i__")
    args = [i.to_sym]
    vals = {
      'TrainerPositionX' => :X,
      'TrainerPositionY' => :Y,
      'TrainerAltitude' => :ALTITUDE,
      'BattleBGM' => :BGM,
      'LowHPBGM' => :LOWHPBGM,
      'BattleVS' => :TRANSITION,
      'BattleIntro' => :TRANSITION,
      'SpriteScale' => :SCALE,
      'SpriteSpeed' => :SPRITESPEED,
      'VictoryTheme' => :VICTORYTHEME,
      'BattleScript' => :BATTLESCRIPT,
      'Ace' => :ACE
    }
    # failsafe
    next if !metrics[key]
    # iterate through registered metrics
    for v in vals.keys
      next if !metrics[key]["__pk__"] || !metrics[key]["__pk__"][v]
      next if vals[v] == :BATTLESCRIPT && metrics[key]["BATTLESCRIPT"]
      args.push(vals[v]); args.push(metrics[key]["__pk__"][v].length > 1 ? metrics[key]["__pk__"][v] : metrics[key]["__pk__"][v][0])
    end
    # set up full battle script
    if metrics[key] && metrics[key]["BATTLESCRIPT"]
      # add entire section hash as script argument
      args.push(:BATTLESCRIPT)
      options = {}
      for bkey in metrics[key]["BATTLESCRIPT"].keys
        options[bkey] = metrics[key]["BATTLESCRIPT"][bkey].join(", ")
      end
      args.push(options)
    end
    # set up battle environment
    if metrics[key]["__pk__"] && metrics[key]["__pk__"]["BattleEnv"]
      ebenv = metrics[key]["__pk__"]["BattleEnv"][0]
      if hasConst?(EnvironmentEBDX, ebenv.to_sym)
        args.push(:BACKDROP); args.push(getConst(EnvironmentEBDX, ebenv.to_sym))
      else
        EliteBattle.log.warn("Environment #{ebenv} for Trainer #{key} is not defined in the ENVIRONMENTS.rb file!")
      end
    end
    # configure common metrics
    args = EliteBattle.commonConfig(metrics, args, key)
    # push arguments
    EliteBattle.add_data(*args)
  end
end
