#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
class DependentEvents
  attr_accessor :realEvents
  #-----------------------------------------------------------------------------
  # Checks if the follower needs to refresh its sprite
  #-----------------------------------------------------------------------------
  def can_refresh?
    return false if !pbGetFollowerDependentEvent
    return false if !$PokemonGlobal.follower_toggled
    first_pkmn = $Trainer.first_able_pokemon
    return false if !first_pkmn
    refresh = Events.FollowerRefresh.trigger(first_pkmn)
    refresh = true if refresh == -1
    return refresh
  end
  #-----------------------------------------------------------------------------
  # Change the sprite to the correct species based on parameters
  #-----------------------------------------------------------------------------
  def change_sprite(params)
    $PokemonGlobal.dependentEvents.each_with_index do |event,i|
      next if !event[8][/FollowerPkmn/]
      fname = GameData::Species.ow_sprite_filename(params[0], params[1],
                                                   params[2], params[3],
                                                   params[4])
      fname.gsub!("Graphics/Characters/","")
      event[6] = fname
      @realEvents[i].character_name = fname
    end
  end
  #-----------------------------------------------------------------------------
  # Adds step animation for followers
  #-----------------------------------------------------------------------------
  def start_stepping
    follower_move_route([PBMoveRoute::StepAnimeOn])
  end
  #-----------------------------------------------------------------------------
  # Removes step animation from followers
  #-----------------------------------------------------------------------------
  def stop_stepping
    follower_move_route([PBMoveRoute::StepAnimeOff])
  end
  #-----------------------------------------------------------------------------
  # Removes the sprite of the follower but doesn't remove the dependent event
  #-----------------------------------------------------------------------------
  def remove_sprite
    events = $PokemonGlobal.dependentEvents
    $PokemonGlobal.dependentEvents.each_with_index do |event,i|
      next if !event[8][/FollowerPkmn/]
      event[6] = ""
      @realEvents[i].character_name = ""
      $PokemonGlobal.time_taken = 0
    end
  end
  #-----------------------------------------------------------------------------
  # Refresh follower sprite. Change it if nescessary. Apply animation based on
  # parameter
  #-----------------------------------------------------------------------------
  def refresh_sprite(anim = false)
    first_pkmn = $Trainer.first_able_pokemon
    return if !first_pkmn
    remove_sprite
    ret = can_refresh?
    if anim
      events = $PokemonGlobal.dependentEvents
      $PokemonGlobal.dependentEvents.each_with_index do |event,i|
        next if !event[8][/FollowerPkmn/]
        animName = (ret == true)? :Animation_Come_Out : :Animation_Come_In
        anim     = getConst(FollowerSettings, animName)
        $scene.spriteset.addUserAnimation(anim, @realEvents[i].x,
                                          @realEvents[i].y, true ,1)
      end
      pbMoveRoute($game_player,[PBMoveRoute::Wait,2])
      pbWait(8)
    end
    change_sprite([first_pkmn.species, first_pkmn.form,
          first_pkmn.gender, first_pkmn.shiny?,
          first_pkmn.shadowPokemon?]) if ret
    if ret
      $PokemonTemp.dependentEvents.start_stepping
    else
      $PokemonTemp.dependentEvents.stop_stepping
    end
    return ret
  end
end

#-------------------------------------------------------------------------------
# New method for easily get the appropriate Follower Graphic
#-------------------------------------------------------------------------------
module GameData
  class Species
    def self.ow_sprite_filename(species, form = 0, gender = 0, shiny = false, shadow = false)
      ret = self.check_graphic_file("Graphics/Characters/", species, form,
                                    gender, shiny, shadow, "Followers")
      ret = "Graphics/Characters/Followers/000" if nil_or_empty?(ret)
	    return ret
    end
  end
end

#-------------------------------------------------------------------------------
# Refresh a Following Pokemon after taking a step, when a refresh is queued
#-------------------------------------------------------------------------------
Events.onStepTaken += proc { |_sender,_e|
  if $PokemonGlobal.call_refresh[0]
    $PokemonTemp.dependentEvents.refresh_sprite($PokemonGlobal.call_refresh[1])
    $PokemonGlobal.call_refresh = [false,false]
  end
}

#-------------------------------------------------------------------------------
# Update follower when mounting Bike
#-------------------------------------------------------------------------------
alias follow_pbDismountBike pbDismountBike
def pbDismountBike
  return if !$PokemonGlobal.bicycle
  ret = follow_pbDismountBike
  $PokemonTemp.dependentEvents.refresh_sprite(true)
  return ret
end

#-------------------------------------------------------------------------------
# Update follower when dismounting Bike
#-------------------------------------------------------------------------------
alias follow_pbMountBike pbMountBike
def pbMountBike
  ret = follow_pbMountBike
  map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
  bike_anim = !(map_metadata && map_metadata.always_bicycle)
  $PokemonTemp.dependentEvents.refresh_sprite(bike_anim)
  return ret
end

#-------------------------------------------------------------------------------
# Update follower when any vehicle like Surf, Lava Surf etc are done
#-------------------------------------------------------------------------------
alias follow_pbCancelVehicles pbCancelVehicles
def pbCancelVehicles(destination = nil)
  $PokemonTemp.dependentEvents.refresh_sprite(false) if destination.nil?
  return follow_pbCancelVehicles(destination)
end

#-------------------------------------------------------------------------------
# Update follower after accessing the PC
#-------------------------------------------------------------------------------
alias follow_pbTrainerPC pbTrainerPC
def pbTrainerPC
  follow_pbTrainerPC
  $PokemonTemp.dependentEvents.refresh_sprite(false)
end

#-------------------------------------------------------------------------------
# Update follower after accessing Poke Centre PC
#-------------------------------------------------------------------------------
alias follow_pbPokeCenterPC pbPokeCenterPC
def pbPokeCenterPC
  follow_pbPokeCenterPC
  $PokemonTemp.dependentEvents.refresh_sprite(false)
end

#-------------------------------------------------------------------------------
# Update follower after accessing Party Screen
#-------------------------------------------------------------------------------
class PokemonParty_Scene
  alias follow_pbEndScene pbEndScene
  def pbEndScene
    follow_pbEndScene
    $PokemonTemp.dependentEvents.refresh_sprite(false)
  end
end

#-------------------------------------------------------------------------------
# Update follower after any kind of Evolution
#-------------------------------------------------------------------------------
class PokemonEvolutionScene
  alias follow_pbEndScreen pbEndScreen
  def pbEndScreen
    follow_pbEndScreen
    $PokemonTemp.dependentEvents.refresh_sprite(false)
  end
end

#-------------------------------------------------------------------------------
# Update follower after any kind of Trade is made
#-------------------------------------------------------------------------------
class PokemonTrade_Scene
  alias follow_pbEndScreen pbEndScreen
  def pbEndScreen
    follow_pbEndScreen
    $PokemonTemp.dependentEvents.refresh_sprite(false)
  end
end

#-------------------------------------------------------------------------------
# Update follower after usage of Bag. For form changes and stuff
#-------------------------------------------------------------------------------
class PokemonBagScreen
  alias follow_bagScene pbStartScreen
  def pbStartScreen
    ret = follow_bagScene
    $PokemonTemp.dependentEvents.refresh_sprite(false)
    return ret
  end
end

#-------------------------------------------------------------------------------
# Refresh follower upon loading up the game
#-------------------------------------------------------------------------------
module Game
  class << self
    alias follower_load_map load_map
  end

  module_function

  def load_map
    follower_load_map
    $PokemonTemp.dependentEvents.refresh_sprite(false)
  end
end

#-------------------------------------------------------------------------------
# Queue a Follower refresh after the end of a battle
#-------------------------------------------------------------------------------
class PokeBattle_Scene
  alias follow_pbEndBattle pbEndBattle
  def pbEndBattle(result)
    follow_pbEndBattle(result)
    $PokemonGlobal.call_refresh = [true,false]
  end
end

class Game_Player < Game_Character
  #-----------------------------------------------------------------------------
  # Update follower's time_taken. Used to track the happiness increase and
  # and hold item
  #-----------------------------------------------------------------------------
  alias follow_update update
  def update
    follow_update
    return if !$PokemonTemp.dependentEvents.can_refresh?
    $PokemonTemp.dependentEvents.add_following_time
  end
  #-----------------------------------------------------------------------------
  # Always update follower's position if the player is moving
  #-----------------------------------------------------------------------------
  alias follow_moveto moveto
  def moveto(x,y)
    ret = follow_moveto(x,y)
    events = $PokemonGlobal.dependentEvents
    leader = $game_player
    $PokemonGlobal.dependentEvents.each_with_index do |_,i|
      event = $PokemonTemp.dependentEvents.realEvents[i]
      $PokemonTemp.dependentEvents.pbFollowEventAcrossMaps(leader, event,
                                                           true, i==0)
    end
    return ret
  end
end

class Scene_Map
  #-----------------------------------------------------------------------------
  # Check for Toggle input and update the stepping animation
  #-----------------------------------------------------------------------------
  alias follow_update update
  def update
    follow_update
    if FollowerSettings::TOGGLE_FOLLOWER_KEY &&
       Input.trigger?(getConst(Input, FollowerSettings::TOGGLE_FOLLOWER_KEY))
      pbToggleFollowingPokemon
      return
    end
    if FollowerSettings::CYCLE_PARTY_KEY &&
       Input.trigger?(getConst(Input, FollowerSettings::CYCLE_PARTY_KEY))
      return if !$PokemonTemp.dependentEvents.can_refresh?
      pbToggleFollowingPokemon(false)
      loop do
        pkmn = $Trainer.party.shift
 			  $Trainer.party.push(pkmn)
        $PokemonGlobal.follower_toggled = true
        if $PokemonTemp.dependentEvents.can_refresh?
          $PokemonGlobal.follower_toggled = false
          break
        end
        $PokemonGlobal.follower_toggled = false
      end
      pbToggleFollowingPokemon(true)
      return
    end
    # Stop stepping animation if on Ice
    if $game_player.pbTerrainTag.ice
      $PokemonTemp.dependentEvents.stop_stepping
    else
      $PokemonTemp.dependentEvents.start_stepping
    end
  end
  #-----------------------------------------------------------------------------
  # Update all Followers when the player transfers to a new area
  #-----------------------------------------------------------------------------
  alias follow_transfer transfer_player
  def transfer_player(cancelVehicles = true)
    follow_transfer(cancelVehicles)
    events = $PokemonGlobal.dependentEvents
    $PokemonTemp.dependentEvents.updateDependentEvents
    leader = $game_player
    $PokemonGlobal.dependentEvents.each_with_index do |_,i|
      event = $PokemonTemp.dependentEvents.realEvents[i]
      $PokemonTemp.dependentEvents.refresh_sprite(false)
      $PokemonTemp.dependentEvents.pbFollowEventAcrossMaps(leader, event,
                                                           false, i == 0)
      pbTurnTowardEvent(event,leader)
    end
  end
end

#-------------------------------------------------------------------------------
# Various updates to DependentEventSprites Sprites to incorporate Reflection and Shadow stuff
#-------------------------------------------------------------------------------
class DependentEventSprites
  attr_accessor :sprites
  #-----------------------------------------------------------------------------
  # Adding DayNight and Status condition tones to dependent event sprite
  #-----------------------------------------------------------------------------
  alias follower_update update
  def update
    follower_update
    @sprites.each_with_index do |_,i|
      next if !FollowerSettings::APPLY_STATUS_TONES
      next if !$PokemonGlobal.dependentEvents[i] ||
              !$PokemonGlobal.dependentEvents[i][8][/FollowerPkmn/]
      first_pkmn = $Trainer.first_able_pokemon
      next if !first_pkmn
      if first_pkmn.status == :NONE
        @sprites[i].color.set(0,0,0,0)
        $PokemonTemp.status_pulse = [50.0,50.0,150.0,(100/(Graphics.frame_rate * 2.0))]
        next
      end
      status_tone = getConst(FollowerSettings,"TONE_#{first_pkmn.status}")
      next if !status_tone.all? {|s| s > 0}
      $PokemonTemp.status_pulse[0] += $PokemonTemp.status_pulse[3]
      $PokemonTemp.status_pulse[3] *= -1 if $PokemonTemp.status_pulse[0] < $PokemonTemp.status_pulse[1] ||
                                            $PokemonTemp.status_pulse[0] > $PokemonTemp.status_pulse[2]
      @sprites[i].color.set(status_tone[0], status_tone[1], status_tone[2], $PokemonTemp.status_pulse[0])
    end
  end
end

#-------------------------------------------------------------------------------
# Functions for handling the work that the variables did earlier
# Also track new data like the current surfing and diving follower
#-------------------------------------------------------------------------------
class PokemonGlobalMetadata
  attr_accessor :follower_toggled
  attr_accessor :call_refresh
  attr_accessor :time_taken
  attr_accessor :follower_hold_item
  attr_accessor :current_surfing
  attr_accessor :current_diving
  attr_writer   :dependentEvents

  def call_refresh
    @call_refresh = [false,false] if !@call_refresh
    return @call_refresh
  end

  def call_refresh=(value)
    ret = value
    ret = [value,false] if !value.is_a?(Array)
    @call_refresh = value
  end

  def time_taken
    @time_taken = 0 if !@time_taken
    return @time_taken
  end
end

#-------------------------------------------------------------------------------
# Variable for handling status pulsing
#-------------------------------------------------------------------------------
class PokemonTemp
  attr_accessor :status_pulse

  def status_pulse
    @status_pulse = [50.0,50.0,150.0,(100/(Graphics.frame_rate * 2.0))] if !@status_pulse
    return @status_pulse
  end
end
