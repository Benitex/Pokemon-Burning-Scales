#-------------------------------------------------------------------------------
# Edited Surf call to refresh follower when the player jumps to surf
#-------------------------------------------------------------------------------
def pbSurf
  return false if $game_player.pbFacingEvent
  return false if $game_player.pbHasDependentEvents?
  move = :SURF
  movefinder = $Trainer.get_pokemon_with_move(move)
  if !defined?(Item_Surf)
    if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_SURF,false) || (!$DEBUG && !movefinder)
      return false
    end
  elsif !pbCanUseItem(Item_Surf)
    return false
  end
  if pbConfirmMessage(_INTL("The water is a deep blue...\nWould you like to surf on it?"))
    if defined?(Item_Surf) && pbCanUseItem(Item_Surf)
      speciesname = $Trainer.name
      movename    = _INTL("the {1}", GameData::Item.get(Item_Surf[:internal_name]).name)
    elsif movefinder
      speciesname = movefinder.name
      movename    = GameData::Move.get(move).name
      $PokemonGlobal.current_surfing = movefinder
    else
      speciesname = $Trainer.name
      movename    = GameData::Move.get(move).name
    end
    pbMessage(_INTL("{1} used {2}!", speciesname, movename))
    pbCancelVehicles
    pbHiddenMoveAnimation(movefinder,false)
    surfbgm = GameData::Metadata.get.surf_BGM
    pbCueBGM(surfbgm,0.5) if surfbgm
    surf_anim_1 = FollowingPkmn.active?
    $PokemonGlobal.surfing = true
    FollowingPkmn.refresh_internal
    surf_anim_2 = FollowingPkmn.active?
    $PokemonGlobal.surfing = false
    old_toggled = $PokemonGlobal.follower_toggled
    FollowingPkmn.toggle_off(true) if surf_anim_1 != surf_anim_2
    pbStartSurfing
    FollowingPkmn.toggle(old_toggled, false)
    return true
  end
  return false
end

#-------------------------------------------------------------------------------
# Edited Surf call to refresh follower when the player jumps to get off surfing
# Pokemon
#-------------------------------------------------------------------------------
alias __followingpkmn__pbEndSurf pbEndSurf unless defined?(__followingpkmn__pbEndSurf)
def pbEndSurf(*args)
  surf_anim_1 = FollowingPkmn.active?
  ret = __followingpkmn__pbEndSurf(*args)
  FollowingPkmn.refresh_internal
  surf_anim_2 = FollowingPkmn.active?
  return false if ! ret
  $PokemonGlobal.current_surfing = nil
  $PokemonGlobal.call_refresh = [true, (surf_anim_1 != surf_anim_2)]
  return true
end

#-------------------------------------------------------------------------------
# Edited Dive call to incorporate new HM Animation when diving
#-------------------------------------------------------------------------------
def pbDive
  return false if $game_player.pbFacingEvent
  map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
  return false if !map_metadata || !map_metadata.dive_map_id
  move = :DIVE
  movefinder = $Trainer.get_pokemon_with_move(move)
  if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_DIVE,false) || (!$DEBUG && !movefinder)
    pbMessage(_INTL("The sea is deep here. A Pokémon may be able to go underwater."))
    return false
  end
  if pbConfirmMessage(_INTL("The sea is deep here. Would you like to use Dive?"))
    if movefinder
      speciesname = movefinder.name
      $PokemonGlobal.diving = movefinder
    else
      speciesname = $Trainer.name
    end
    pbMessage(_INTL("{1} used {2}!",speciesname,GameData::Move.get(move).name))
    pbHiddenMoveAnimation(movefinder,false)
    pbFadeOutIn {
       $game_temp.player_new_map_id    = map_metadata.dive_map_id
       $game_temp.player_new_x         = $game_player.x
       $game_temp.player_new_y         = $game_player.y
       $game_temp.player_new_direction = $game_player.direction
       $PokemonGlobal.surfing = false
       $PokemonGlobal.diving  = true
       pbUpdateVehicle
       $scene.transfer_player(false)
       $game_map.autoplay
       $game_map.refresh
    }
    return true
  end
  return false
end

#-------------------------------------------------------------------------------
# Edited Dive call to incorporate new HM Animation when surfacing
#-------------------------------------------------------------------------------
def pbSurfacing
  return if !$PokemonGlobal.diving
  return false if $game_player.pbFacingEvent
  surface_map_id = nil
  GameData::MapMetadata.each do |map_data|
    next if !map_data.dive_map_id || map_data.dive_map_id != $game_map.map_id
    surface_map_id = map_data.id
    break
  end
  return if !surface_map_id
  move = :DIVE
  movefinder = $Trainer.get_pokemon_with_move(move)
  if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_DIVE,false) || (!$DEBUG && !movefinder)
    pbMessage(_INTL("Light is filtering down from above. A Pokémon may be able to surface here."))
    return false
  end
  if pbConfirmMessage(_INTL("Light is filtering down from above. Would you like to use Dive?"))
    speciesname = (movefinder) ? movefinder.name : $Trainer.name
    pbMessage(_INTL("{1} used {2}!",speciesname,GameData::Move.get(move).name))
    pbHiddenMoveAnimation(movefinder,false)
    $PokemonGlobal.current_diving = nil
    pbFadeOutIn {
       $game_temp.player_new_map_id    = surface_map_id
       $game_temp.player_new_x         = $game_player.x
       $game_temp.player_new_y         = $game_player.y
       $game_temp.player_new_direction = $game_player.direction
       $PokemonGlobal.surfing = true
       $PokemonGlobal.diving  = false
       pbUpdateVehicle
       $scene.transfer_player(false)
       surfbgm = GameData::Metadata.get.surf_BGM
       (surfbgm) ?  pbBGMPlay(surfbgm) : $game_map.autoplayAsCue
       $game_map.refresh
    }

    return true
  end
  return false
end

#-------------------------------------------------------------------------------
# Edited Strength call to incorporate new HM Animation when you start pushing
# boulders
#-------------------------------------------------------------------------------
HiddenMoveHandlers::UseMove.add(:STRENGTH,proc {|move,pokemon|
  if !pbHiddenMoveAnimation(pokemon,false)
    pbMessage(_INTL("{1} used {2}!\1",pokemon.name,GameData::Move.get(move).name))
  end
  pbMessage(_INTL("{1}'s Strength made it possible to move boulders around!",pokemon.name))
  $PokemonMap.strengthUsed = true
  next true
})

#-------------------------------------------------------------------------------
# Edited Headbutt call to incorporate new HM Animation when headbutting
#-------------------------------------------------------------------------------
def pbHeadbutt(event = nil)
  event = $game_player.pbFacingEvent(true)
  move = :HEADBUTT
  movefinder = $Trainer.get_pokemon_with_move(move)
  if !$DEBUG && !movefinder
    pbMessage(_INTL("A Pokémon could be in this tree. Maybe a Pokémon could shake it."))
    return false
  end
  if pbConfirmMessage(_INTL("A Pokémon could be in this tree. Would you like to use Headbutt?"))
    speciesname = (movefinder) ? movefinder.name : $Trainer.name
    pbMessage(_INTL("{1} used {2}!",speciesname,GameData::Move.get(move).name))
    pbHiddenMoveAnimation(movefinder)
    pbHeadbuttEffect(event)
    return true
  end
  return false
end
