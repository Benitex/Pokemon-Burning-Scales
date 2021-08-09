#===============================================================================
# setup Pokemon metadata
#===============================================================================
EliteBattle.configProcess(:POKEMON) do
  # configure metrics data
  next if !File.safeData?("Data/pokemon.ebdx")
  echoln "  -> configuring Pokemon data..."
  metrics = load_data("Data/pokemon.ebdx")
  for key in metrics.keys
    dnom = key.include?(",") ? "," : "-"
    args = [key.gsub(dnom, "_").to_sym]
    vals = {
      'BattlerEnemyX' => :EX,
      'BattlerEnemyY' => :EY,
      'BattlerPlayerX' => :PX,
      'BattlerPlayerY' => :PY,
      'BattlerAltitude' => :ALTITUDE,
      'BattleBGM' => :BGM,
      'LowHPBGM' => :LOWHPBGM,
      'BattleVS' => :TRANSITION,
      'BattleIntro' => :TRANSITION,
      'SpriteScaleEnemy' => :SCALE,
      'SpriteScalePlayer' => :BACKSCALE,
      'SpriteAnchorEnemy' => :ANCHOR,
      'SpriteAnchorPlayer' => :BACKANCHOR,
      'EvolutionBG' => :EVOBG,
      'HatchingBG' => :HATCHBG,
      'IsGrounded' => :GROUNDED,
      'HideName' => :HIDENAME,
      'SpriteSpeed' => :SPRITESPEED,
      'VictoryTheme' => :VICTORYTHEME,
      'BattleScript' => :BATTLESCRIPT,
      'CaptureME' => :CAPTUREME,
      'CaptureBGM' => :CAPTUREBGM,
      'PerfectIVs' => :PERFECT_IVS
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
        EliteBattle.log.warn("Environment #{ebenv} for Species #{key} is not defined in the ENVIRONMENTS.rb file!")
      end
    end
    # pokedex capture screen
    if metrics[key]["POKEDEXCAPTURESCREEN"]
      vals = {
        'Background' => :BACKGROUND,
        'Overlay' => :OVERLAY,
        'Highlight' => :HIGHLIGHT,
        'EndScreen' => :END_SCREEN,
        'Elements' => :ELEMENTS
      }; options = {}
      for v in vals.keys
        options[vals[v]] = metrics[key]["POKEDEXCAPTURESCREEN"][v][0]
      end
      args.push(:DEX_CAPTURE); args.push(options)
    end
    # configure common metrics
    args = EliteBattle.commonConfig(metrics, args, key)
    # push arguments
    EliteBattle.add_data(*args)
  end
end
