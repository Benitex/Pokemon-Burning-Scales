#-------------------------------------------------------------------------------
# These are used to define whether the follower should appear or disappear when
# refreshing it. "next true" will let it stay and "next false" will make it
# disappear
#-------------------------------------------------------------------------------
Events.FollowerRefresh += proc { |_pkmn|
  # The Pokemon disappears if the player is cycling
  next false if $PokemonGlobal.bicycle
  # Pokeride Compatibility
  next false if defined?($PokemonGlobal.mount) && $PokemonGlobal.mount
}

Events.FollowerRefresh += proc { |_pkmn|
  # The Pokemon disappears if the name of the map is Cedolan Gym
  next false if $game_map.name.include?("Cedolan Gym")
}

Events.FollowerRefresh += proc { |pkmn|
  if $PokemonGlobal.surfing
    next false if pkmn == $PokemonGlobal.current_surfing
    next true if pkmn.hasType?(:WATER)
    next false if FollowingPkmn::SURFING_FOLLOWERS_EXCEPTIONS.any? do |s|
                    s == pkmn.species || s.to_s == "#{pkmn.species}_#{pkmn.form}"
                  end
    next true if pkmn.hasType?(:FLYING)
    next true if pkmn.hasAbility?(:LEVITATE)
    next true if FollowingPkmn::SURFING_FOLLOWERS.any? do |s|
                   s == pkmn.species || s.to_s == "#{pkmn.species}_#{pkmn.form}"
                 end
    next false
  end
}

Events.FollowerRefresh += proc { |pkmn|
  if $PokemonGlobal.diving
    next false if pkmn == $PokemonGlobal.current_diving
    next true if pkmn.hasType?(:WATER)
    next false
  end
}

Events.FollowerRefresh += proc { |pkmn|
  metadata = GameData::MapMetadata.try_get($game_map.map_id)
  if metadata && metadata.outdoor_map != true
    # The Pokemon disappears if it's height is greater than 3 meters and there are no encounters ie a building or something
    height =  GameData::Species.get_species_form(pkmn.species, pkmn.form).height
    next false if (height / 10.0) > 3 && !$PokemonEncounters.encounter_possible_here?
  end
}
