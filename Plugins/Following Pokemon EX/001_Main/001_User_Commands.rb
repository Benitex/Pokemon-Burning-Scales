#-------------------------------------------------------------------------------
# Control the following Pokemon
# Example:
#     follower_move_route([
#         PBMoveRoute::TurnRight,
#         PBMoveRoute::Wait,4,
#         PBMoveRoute::Jump,0,0
#     ])
# The Pokemon turns Right, waits 4 frames, and then jumps
#-------------------------------------------------------------------------------
def follower_move_route(commands,waitComplete=false)
  return if !$Trainer.first_able_pokemon || !$PokemonGlobal.follower_toggled
  $PokemonTemp.dependentEvents.set_move_route(commands,waitComplete)
end

alias followingMoveRoute follower_move_route

#-------------------------------------------------------------------------------
# Script Command to toggle Following Pokemon
#-------------------------------------------------------------------------------
def pbToggleFollowingPokemon(forced = nil,anim = nil)
  return if !pbGetFollowerDependentEvent
  return if !$Trainer.first_able_pokemon
  anim_1 = $PokemonTemp.dependentEvents.can_refresh?
  if forced.is_a?(String)
    if forced[/on/i]
      $PokemonGlobal.follower_toggled = true
      echoln("The next update of Following Pokemon EX will remove support for \"on\" in pbToggleFollowingPokemon. Use true instead.")
    elsif forced[/off/i]
      $PokemonGlobal.follower_toggled = false
      echoln("The next update of Following Pokemon EX will remove support for \"off\" in pbToggleFollowingPokemon. Use false instead.")
    end
  elsif !forced.nil?
    # This may seem redundant but it keeps follower_toggled a boolean always
    $PokemonGlobal.follower_toggled = !(!forced)
  else
    $PokemonGlobal.follower_toggled = !($PokemonGlobal.follower_toggled)
  end
  anim_2 = $PokemonTemp.dependentEvents.can_refresh?
  anim = anim_1 != anim_2 if anim.nil?
  $PokemonTemp.dependentEvents.refresh_sprite(anim)
end

#-------------------------------------------------------------------------------
# Script Command to start Pokemon Following. x is the Event ID that will be the follower
#-------------------------------------------------------------------------------
def pbPokemonFollow(x)
  return false if !$Trainer.first_able_pokemon
  $PokemonTemp.dependentEvents.removeEventByName("FollowerPkmn") if pbGetFollowerDependentEvent
  pbAddDependency2(x,"FollowerPkmn",FollowerSettings::FOLLOWER_COMMON_EVENT)
  $PokemonGlobal.follower_toggled = true
  event = pbGetFollowerDependentEvent
  $PokemonTemp.dependentEvents.pbFollowEventAcrossMaps($game_player,event,true,false)
  $PokemonTemp.dependentEvents.refresh_sprite(true)
end

#-------------------------------------------------------------------------------
# Script Command for Talking to Following Pokemon
#-------------------------------------------------------------------------------
def pbTalkToFollower
  if !$PokemonTemp.dependentEvents.can_refresh?
    if !($PokemonGlobal.surfing ||
         (GameData::MapMetadata.exists?($game_map.map_id) &&
         GameData::MapMetadata.get($game_map.map_id).always_bicycle) ||
         !$game_player.pbFacingTerrainTag.can_surf_freely ||
         !$game_map.passable?($game_player.x,$game_player.y,$game_player.direction,$game_player))
      pbSurf
    end
    return false
  end
  first_pkmn = $Trainer.first_able_pokemon
  GameData::Species.play_cry(first_pkmn)
  event = pbGetFollowerDependentEvent
  random_val = rand(6)
  Events.OnTalkToFollower.trigger(first_pkmn,event.x,event.y,random_val)
  pbTurnTowardEvent(event,$game_player)
end

#-------------------------------------------------------------------------------
# Script Command for getting the Following Pokemon Dependency
#-------------------------------------------------------------------------------
def pbGetFollowerDependentEvent
  return $PokemonTemp.dependentEvents.follower_dependent_event
end

#-------------------------------------------------------------------------------
# Script Command for removing every dependent event except Following Pokemon
#-------------------------------------------------------------------------------
def pbRemoveDependenciesExceptFollower
  $PokemonTemp.dependentEvents.remove_except_follower
end

#-------------------------------------------------------------------------------
# Script Command for  Pokémon finding an item in the field
#-------------------------------------------------------------------------------
def pbPokemonFound(item,quantity = 1,message = "")
  return false if !$PokemonGlobal.follower_hold_item
  pokename = $Trainer.first_able_pokemon.name
  message = "{1} seems to be holding something..." if nil_or_empty?(message)
  pbMessage(_INTL(message,pokename))
  item = GameData::Item.get(item)
  return false if !item || quantity < 1
  itemname = (quantity > 1) ? item.name_plural : item.name
  pocket = item.pocket
  move   = item.move
  if $PokemonBag.pbStoreItem(item,quantity)   # If item can be picked up
    meName = (item.is_key_item?) ? "Key item get" : "Item get"
    if item == :LEFTOVERS
      pbMessage(_INTL("\\me[{1}]#{pokename} found some \\c[1]{2}\\c[0]!\\wtnp[30]",meName,itemname))
    elsif item.is_machine?   # TM or HM
      pbMessage(_INTL("\\me[{1}]#{pokename} found \\c[1]{2} {3}\\c[0]!\\wtnp[30]",meName,itemname,GameData::Move.get(move).name))
    elsif quantity>1
      pbMessage(_INTL("\\me[{1}]#{pokename} found {2} \\c[1]{3}\\c[0]!\\wtnp[30]",meName,quantity,itemname))
    elsif itemname.starts_with_vowel?
      pbMessage(_INTL("\\me[{1}]#{pokename} found an \\c[1]{2}\\c[0]!\\wtnp[30]",meName,itemname))
    else
      pbMessage(_INTL("\\me[{1}]#{pokename} found a \\c[1]{2}\\c[0]!\\wtnp[30]",meName,itemname))
    end
    pbMessage(_INTL("#{pokename} put the {1} away\\nin the <icon=bagPocket{2}>\\c[1]{3} Pocket\\c[0].",
       itemname,pocket,PokemonBag.pocketNames()[pocket]))
    $PokemonGlobal.follower_hold_item = false
    $PokemonGlobal.time_taken         = 0
    return true
  end
  # Can't add the item
  if item == :LEFTOVERS
    pbMessage(_INTL("#{pokename} found some \\c[1]{1}\\c[0]!\\wtnp[30]",itemname))
  elsif item.is_machine?   # TM or HM
    pbMessage(_INTL("#{pokename} found \\c[1]{1} {2}\\c[0]!\\wtnp[30]",itemname,GameData::Move.get(move).name))
  elsif quantity>1
    pbMessage(_INTL("#{pokename} found {1} \\c[1]{2}\\c[0]!\\wtnp[30]",quantity,itemname))
  elsif itemname.starts_with_vowel?
    pbMessage(_INTL("#{pokename} found an \\c[1]{1}\\c[0]!\\wtnp[30]",itemname))
  else
    pbMessage(_INTL("#{pokename} found a \\c[1]{1}\\c[0]!\\wtnp[30]",itemname))
  end
  pbMessage(_INTL("But your Bag is full..."))
  return false
end
