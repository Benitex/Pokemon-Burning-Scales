#===============================================================================
# Automatic Level Scaling Event Handlers
# By Benitex
#===============================================================================

# Activates script when a wild pokemon is created
Events.onWildPokemonCreate += proc { |_sender, e|
  pokemon = e[0]
  id = pbGet(LevelScalingSettings::WILD_VARIABLE)
  next if id == 0
  AutomaticLevelScaling.difficulty = id

  case pbGet(LevelScalingSettings::TRAINER_VARIABLE)
  when 1
    AutomaticLevelScaling.setTemporarySetting("automaticEvolutions", false)
    $game_switches[33] = true
  else
    $game_switches[33] = false
  end

  AutomaticLevelScaling.setNewLevel(pokemon)
}

# Activates script when a trainer pokemon is created
Events.onTrainerPartyLoad += proc { |_sender, trainer|
  id = pbGet(LevelScalingSettings::TRAINER_VARIABLE)
  next if !trainer || id == 0
  AutomaticLevelScaling.difficulty = id

  case id
  when 1
    $game_switches[33] = true
  when 2
    $game_switches[33] = false
  when 3
    $game_switches[33] = false
    setBattleRule("setStyle")
  end

  avarage_level = 0
  trainer[0].party.each { |pokemon| avarage_level += pokemon.level }
  avarage_level /= trainer[0].party.length

  for pokemon in trainer[0].party
    AutomaticLevelScaling.setNewLevel(pokemon, pokemon.level - avarage_level)
  end
}

# Updates partner's pokemon levels after battle
Events.onEndBattle += proc { |_sender, e|
  id = pbGet(LevelScalingSettings::TRAINER_VARIABLE)
  next if !$PokemonGlobal.partner || id == 0

  avarage_level = 0
  $PokemonGlobal.partner[3].each { |pokemon| avarage_level += pokemon.level }
  avarage_level /= $PokemonGlobal.partner[3].length

  for pokemon in $PokemonGlobal.partner[3] do
    AutomaticLevelScaling.setNewLevel(pokemon, pokemon.level - avarage_level)
  end
}

# Resets settings after battle if they are temporaray
Events.onEndBattle += proc { |_sender, e|
  if AutomaticLevelScaling.settings[:temporary]
    AutomaticLevelScaling.setSettings
  end
}
