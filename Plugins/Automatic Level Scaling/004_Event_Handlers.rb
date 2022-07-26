#===============================================================================
# Automatic Level Scaling Event Handlers
# By Benitex
#===============================================================================

# Activates script when a wild pokemon is created
Events.onWildPokemonCreate += proc { |_sender, e|
  pokemon = e[0]
  id = $game_variables[LevelScalingSettings::WILD_VARIABLE]
  if id != 0
    AutomaticLevelScaling.setDifficulty(id)
    AutomaticLevelScaling.setNewLevel(pokemon)
  end
}

# Activates script when a trainer pokemon is created
Events.onTrainerPartyLoad += proc { |_sender, trainer|
  id = $game_variables[LevelScalingSettings::TRAINER_VARIABLE]
  if trainer && id != 0
    AutomaticLevelScaling.setDifficulty(id)
    avarage_level = 0
    trainer[0].party.each { |pokemon| avarage_level += pokemon.level }
    avarage_level /= trainer[0].party.length

    for pokemon in trainer[0].party
      AutomaticLevelScaling.setNewLevel(pokemon, pokemon.level - avarage_level)
    end
  end
}

# Updates partner's pokemon levels after battle
Events.onEndBattle += proc { |_sender,e|
  if $PokemonGlobal.partner != nil
    avarage_level = 0
    $PokemonGlobal.partner[3].each { |pokemon| avarage_level += pokemon.level }
    avarage_level /= $PokemonGlobal.partner[3].length

    for pokemon in $PokemonGlobal.partner[3] do
      AutomaticLevelScaling.setNewLevel(pokemon, pokemon.level - avarage_level)
    end
  end
}
