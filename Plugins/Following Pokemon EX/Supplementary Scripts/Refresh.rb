#-------------------------------------------------------------------------------
# Refresh follower when mounting Bike
#-------------------------------------------------------------------------------
alias __followingpkmn__pbDismountBike pbDismountBike unless defined?(__followingpkmn__pbDismountBike)
def pbDismountBike(*args)
  return if !$PokemonGlobal.bicycle
  ret = __followingpkmn__pbDismountBike(*args)
  FollowingPkmn.refresh_internal
  FollowingPkmn.refresh(FollowingPkmn.active?)
  return ret
end

#-------------------------------------------------------------------------------
# Refresh follower when dismounting Bike
#-------------------------------------------------------------------------------
alias __followingpkmn__pbMountBike pbMountBike unless defined?(__followingpkmn__pbMountBike)
def pbMountBike(*args)
  ret = __followingpkmn__pbMountBike(*args)
  map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
  bike_anim = map_metadata && !map_metadata.always_bicycle
  FollowingPkmn.refresh(bike_anim)
  return ret
end

#-------------------------------------------------------------------------------
# Refresh follower when any vehicle like Surf, Lava Surf etc are done
#-------------------------------------------------------------------------------
alias __followingpkmn__pbCancelVehicles pbCancelVehicles unless defined?(__followingpkmn__pbCancelVehicles)
def pbCancelVehicles(*args)
  FollowingPkmn.refresh(false) if args[0].nil?
  return __followingpkmn__pbCancelVehicles(*args)
end

#-------------------------------------------------------------------------------
# Refresh follower after accessing the PC
#-------------------------------------------------------------------------------
alias __followingpkmn__pbTrainerPC pbTrainerPC unless defined?(__followingpkmn__pbTrainerPC)
def pbTrainerPC(*args)
  ret = __followingpkmn__pbTrainerPC(*args)
  FollowingPkmn.refresh(false)
  return ret
end

#-------------------------------------------------------------------------------
# Refresh follower after accessing Poke Centre PC
#-------------------------------------------------------------------------------
alias __followingpkmn__pbPokeCenterPC pbPokeCenterPC unless defined?(__followingpkmn__pbPokeCenterPC)
def pbPokeCenterPC(*args)
  ret = __followingpkmn__pbPokeCenterPC(*args)
  FollowingPkmn.refresh(false)
  return ret
end

#-------------------------------------------------------------------------------
# Refresh follower after accessing Party Screen
#-------------------------------------------------------------------------------
class PokemonParty_Scene
  alias __followingpkmn__pbEndScene pbEndScene unless method_defined?(:__followingpkmn__pbEndScene)
  def pbEndScene(*args)
    ret = __followingpkmn__pbEndScene(*args)
    FollowingPkmn.refresh(false)
    return ret
  end
end

#-------------------------------------------------------------------------------
# Refresh follower after any kind of Evolution
#-------------------------------------------------------------------------------
class PokemonEvolutionScene
  alias __followingpkmn__pbEndScreen pbEndScreen unless method_defined?(:__followingpkmn__pbEndScreen)
  def pbEndScreen(*args)
    ret = __followingpkmn__pbEndScreen(*args)
    FollowingPkmn.refresh(false)
    return ret
  end
end

#-------------------------------------------------------------------------------
# Refresh follower after any kind of Trade is made
#-------------------------------------------------------------------------------
class PokemonTrade_Scene
  alias __followingpkmn__pbEndScreen pbEndScreen unless method_defined?(:__followingpkmn__pbEndScreen)
  def pbEndScreen(*args)
    ret = __followingpkmn__pbEndScreen(*args)
    FollowingPkmn.refresh(false)
    return ret
  end
end

#-------------------------------------------------------------------------------
# Refresh follower after any Egg is hatched
#-------------------------------------------------------------------------------
alias __followingpkmn__pbHatch pbHatch unless defined?(__followingpkmn__pbHatch)
def pbHatch(*args)
  ret = __followingpkmn__pbHatch(*args)
  FollowingPkmn.refresh(false)
  return ret
end

#-------------------------------------------------------------------------------
# Refresh follower after usage of Bag. For form changes and stuff
#-------------------------------------------------------------------------------
class PokemonBagScreen
  alias __followingpkmn__pbStartScreen pbStartScreen unless method_defined?(:__followingpkmn__pbStartScreen)
  def pbStartScreen(*args)
    ret = __followingpkmn__pbStartScreen(*args)
    FollowingPkmn.refresh(false)
    return ret
  end
end

#-------------------------------------------------------------------------------
# Refresh follower upon loading the Debug menu
#-------------------------------------------------------------------------------
alias __followingpkmn__pbDebugMenu pbDebugMenu unless defined?(__followingpkmn__pbDebugMenu)
def pbDebugMenu(*args)
  ret = __followingpkmn__pbDebugMenu(*args)
  FollowingPkmn.refresh(false)
  return ret
end

#-------------------------------------------------------------------------------
# Refresh follower upon closing the pause menu
#-------------------------------------------------------------------------------
class Scene_Map
  alias __followingpkmn__call_menu call_menu unless method_defined?(:__followingpkmn__call_menu)
  def call_menu(*args)
    __followingpkmn__call_menu(*args)
    FollowingPkmn.refresh(false)
  end
end

#-------------------------------------------------------------------------------
# Refresh follower upon loading up the game
#-------------------------------------------------------------------------------
module Game
  class << self
    alias __followingpkmn__load_map load_map unless method_defined?(:__followingpkmn__load_map)
    alias __followingpkmn__load load unless method_defined?(:__followingpkmn__load)
  end

  def self.load_map(*args)
    __followingpkmn__load_map(*args)
    FollowingPkmn.refresh(false)
  end
end

#-------------------------------------------------------------------------------
# Queue a Follower refresh after the end of a battle
#-------------------------------------------------------------------------------
alias __followingpkmn__pbAfterBattle pbAfterBattle unless defined?(__followingpkmn__pbAfterBattle)
def pbAfterBattle(*args)
  __followingpkmn__pbAfterBattle(*args)
  $PokemonGlobal.call_refresh = true
end

class Scene_Map
  #-----------------------------------------------------------------------------
  # Check for Toggle input and update follower's time_taken for to tracking
  # the happiness increase and hold item
  #-----------------------------------------------------------------------------
  alias __followingpkmn__update update unless method_defined?(:__followingpkmn__update)
  def update(*args)
    __followingpkmn__update(*args)
    if defined?(FollowingPkmn::TOGGLE_FOLLOWER_KEY) && FollowingPkmn::TOGGLE_FOLLOWER_KEY &&
       ((Input.const_defined?(FollowingPkmn::TOGGLE_FOLLOWER_KEY) &&
        Input.trigger?(Input.const_get(FollowingPkmn::TOGGLE_FOLLOWER_KEY))) ||
        Input.triggerex?(FollowingPkmn::TOGGLE_FOLLOWER_KEY))
      FollowingPkmn.toggle
      return
    end
    return if !FollowingPkmn.active?
    FollowingPkmn.increase_time
    if defined?(FollowingPkmn::CYCLE_PARTY_KEY) && FollowingPkmn::CYCLE_PARTY_KEY &&
       ((Input.const_defined?(FollowingPkmn::CYCLE_PARTY_KEY) &&
        Input.trigger?(Input.const_get(FollowingPkmn::CYCLE_PARTY_KEY))) ||
        Input.triggerex?(FollowingPkmn::CYCLE_PARTY_KEY))
      FollowingPkmn.toggle_off
      loop do
        pkmn = $Trainer.party.shift
        $Trainer.party.push(pkmn)
        $PokemonGlobal.follower_toggled = true
        if FollowingPkmn.active?
          $PokemonGlobal.follower_toggled = false
          break
        end
        $PokemonGlobal.follower_toggled = false
      end
      FollowingPkmn.toggle_on
      return
    end
  end
  #-----------------------------------------------------------------------------
  # Update all Followers when the player transfers to a new area
  #-----------------------------------------------------------------------------
  alias __followingpkmn__transfer_player transfer_player unless method_defined?(:__followingpkmn__transfer_player)
  def transfer_player(*args)
    __followingpkmn__transfer_player(*args)
    events = $PokemonGlobal.dependentEvents
    $PokemonTemp.dependentEvents.updateDependentEvents
    leader = $game_player
    $PokemonGlobal.dependentEvents.each_with_index do |_,i|
      event = $PokemonTemp.dependentEvents.realEvents[i]
      FollowingPkmn.refresh(false)
      if event.is_a?(Game_FollowerEvent)
        event.map = $game_map
        event.moveto($game_player.x, $game_player.y)
        event.direction = $game_player.direction
      end
      $PokemonTemp.dependentEvents.pbFollowEventAcrossMaps(leader, event,
                                                           false, i == 0)
      pbTurnTowardEvent(event,leader)
    end
  end
  #-----------------------------------------------------------------------------
  # Update follower's time_taken for to tracking the happiness increase
  # and hold item
  #-----------------------------------------------------------------------------
  alias __followingpkmn__miniupdate miniupdate unless method_defined?(:__followingpkmn__miniupdate)
  def miniupdate(*args)
    __followingpkmn__miniupdate(*args)
    return if !FollowingPkmn.active?
    FollowingPkmn.increase_time
  end
  #-----------------------------------------------------------------------------
end

#-------------------------------------------------------------------------------
# Refresh Following Pokemon after using the Pokecenter
#-------------------------------------------------------------------------------
alias __followingpkmn__pbSetPokemonCenter pbSetPokemonCenter unless defined?(__followingpkmn__pbSetPokemonCenter)
def pbSetPokemonCenter(*args)
  ret = __followingpkmn__pbSetPokemonCenter(*args)
  $game_temp.pokecenter_following_pkmn = 1  if FollowingPkmn::SHOW_POKECENTER_ANIMATION && FollowingPkmn.active?
  return ret
end

class Interpreter
  alias __followingpkmn__command_314 command_314 unless method_defined?(:__followingpkmn__command_314)
  def command_314(*args)
    ret = __followingpkmn__command_314(*args)
    if FollowingPkmn::SHOW_POKECENTER_ANIMATION && $game_temp.pokecenter_following_pkmn > 0 &&
      FollowingPkmn.active?
      FollowingPkmn.toggle_off
      $game_temp.pokecenter_following_pkmn = 2
    end
    return ret
  end

  alias __followingpkmn__update update unless method_defined?(:__followingpkmn__update)
  def update(*args)
    __followingpkmn__update(*args)
    if FollowingPkmn::SHOW_POKECENTER_ANIMATION && $game_temp.pokecenter_following_pkmn > 0 && !running?
      FollowingPkmn.toggle_on
      $game_temp.pokecenter_following_pkmn = 0
    end
  end
end

Events.onMapChange += proc { |_sender,e|
  $game_temp.pokecenter_following_pkmn = 0
}


#-------------------------------------------------------------------------------
# Refresh Following Pokemon after taking a step, when a refresh is queued
#-------------------------------------------------------------------------------
Events.onStepTaken += proc { |_sender, _e|
  if $PokemonGlobal.call_refresh[0]
    FollowingPkmn.refresh($PokemonGlobal.call_refresh[1])
    $PokemonGlobal.call_refresh = false
  end
}

class Game_Temp
  attr_writer :pokecenter_following_pkmn

  def pokecenter_following_pkmn
    @pokecenter_following_pkmn = 0 if !@pokecenter_following_pkmn
    return @pokecenter_following_pkmn
  end
end
