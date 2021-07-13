#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
module SpriteRenamer
  module_function
  #-----------------------------------------------------------------------------
  # Convert Pokemon overworld sprites to new format
  #-----------------------------------------------------------------------------
  def convert_pokemon_ows(src_dir, dest_dir)
    return if !FileTest.directory?(src_dir)
    Dir.mkdir(dest_dir) if !FileTest.directory?(dest_dir)
    for ext in ["Followers/", "Followers shiny/"]
      Dir.mkdir(dest_dir + ext) if !FileTest.directory?(dest_dir + ext)
    end
    # generates a list of all graphic files
    files = readDirectoryFiles(src_dir, ["*.png"])
    # starts automatic renaming
    files.each_with_index do |file, i|
      Graphics.update if i % 100 == 0
      pbSetWindowText(_INTL("Converting Pokémon overworlds {1}/{2}...", i, files.length)) if i % 50 == 0
      next if !file[/^\d{3}[^\.]*\.[^\.]*$/]
      if file[/s/] && !file[/shadow/]
        prefix = "Followers shiny/"
      else
        prefix = "Followers/"
      end
      new_filename = convert_pokemon_filename(file,prefix)
      # moves the files into their appropriate folders
      File.move(src_dir + file, dest_dir + new_filename)
    end
  end
  #-----------------------------------------------------------------------------
  # Add new overworld method to regular sprite converter as well
  #-----------------------------------------------------------------------------
  if defined?(convert_files)
    class << self
      alias follower_convert_files convert_files
    end

    def convert_files
      follower_convert_files
      convert_pokemon_ows("Graphics/Characters/","Graphics/Characters/")
      pbSetWindowText(nil)
    end
  end
end

#-------------------------------------------------------------------------------
# New sendout animation for Followers to slide in when sent out for
# the first time in battle
#-------------------------------------------------------------------------------
class PokeballPlayerSendOutAnimation < PokeBattle_Animation
  def initialize(sprites,viewport,idxTrainer,battler,startBattle,idxOrder=0)
    @idxTrainer     = idxTrainer
    @battler        = battler
    @showingTrainer = startBattle
    @idxOrder       = idxOrder
    @trainer        = @battler.battle.pbGetOwnerFromBattlerIndex(@battler.index)
    @shadowVisible  = sprites["shadow_#{battler.index}"].visible
    @sprites        = sprites
    @viewport       = viewport
    @pictureEx      = []   # For all the PictureEx
    @pictureSprites = []   # For all the sprites
    @tempSprites    = []   # For sprites that exist only for this animation
    @animDone       = false
    if $PokemonTemp.dependentEvents.can_refresh? && battler.index == 0 && startBattle
      createFollowerProcesses
    else
      createProcesses
    end
  end

  def createFollowerProcesses
    delay = 0
    delay = 5 if @showingTrainer
    batSprite = @sprites["pokemon_#{@battler.index}"]
    shaSprite = @sprites["shadow_#{@battler.index}"]
    battlerY = batSprite.y
    battler = addSprite(batSprite,PictureOrigin::Bottom)
    battler.setVisible(delay,true)
    battler.setZoomXY(delay,100,100)
    battler.setColor(delay,Color.new(0,0,0,0))
    battler.setDelta(0,-240,0)
    battler.moveDelta(delay,12,240,0)
    battler.setCallback(delay + 12,[batSprite,:pbPlayIntroAnimation])
    if @shadowVisible
      shadow = addSprite(shaSprite,PictureOrigin::Center)
      shadow.setVisible(delay,@shadowVisible)
      shadow.setDelta(0,-Graphics.width/2,0)
      shadow.setDelta(delay,12,Graphics.width/2,0)
    end
  end
end

#-------------------------------------------------------------------------------
# Registering a fake bridge terrain tag to account for weirdness in the
# base essentials tileset
#-------------------------------------------------------------------------------
GameData::TerrainTag.register({
  :id                     => :FakeBridge,
  :id_number              => 42
})

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
class Game_Map
  #-----------------------------------------------------------------------------
  # Add a check for dependent events in the passablity method to prevent any
  # events from passing through them.
  #-----------------------------------------------------------------------------
  alias follow_passable? passable?
  def passable?(x, y, d, self_event=nil)
    ret = follow_passable?(x,y,d,self_event)
    if !$game_temp.player_transferring && pbGetFollowerDependentEvent && self_event != $game_player
      dependent = pbGetFollowerDependentEvent
      return false if self_event != dependent && dependent.x == x && dependent.y == y
    end
    return ret
  end
  #-----------------------------------------------------------------------------
  # Method which edits the passablity of Following Pokemon
  #-----------------------------------------------------------------------------
  def passableStrict?(x, y, d, self_event = nil)
    return false if !valid?(x, y)
    for event in events.values
      next if event == self_event || event.tile_id < 0 || event.through
      next if !event.at_coordinate?(x, y)
      return true if GameData::TerrainTag.try_get(@terrain_tags[event.tile_id]).ignore_passability
      if self_event != $game_player
        return true if GameData::TerrainTag.try_get(@terrain_tags[event.tile_id]).ice
        return true if GameData::TerrainTag.try_get(@terrain_tags[event.tile_id]).ledge
        return true if GameData::TerrainTag.try_get(@terrain_tags[event.tile_id]).can_surf
        return true if GameData::TerrainTag.try_get(@terrain_tags[event.tile_id]).bridge
        return true if GameData::TerrainTag.try_get(@terrain_tags[event.tile_id]).id_number == 42
      end
      return false if @passages[event.tile_id] & 0x0f != 0
      return true if @priorities[event.tile_id] == 0
    end
    for i in [2, 1, 0]
      tile_id = data[x, y, i]
      return true if GameData::TerrainTag.try_get(@terrain_tags[tile_id]).ignore_passability
      if self_event != $game_player
        return true if GameData::TerrainTag.try_get(@terrain_tags[tile_id]).ice
        return true if GameData::TerrainTag.try_get(@terrain_tags[tile_id]).ledge
        return true if GameData::TerrainTag.try_get(@terrain_tags[tile_id]).can_surf
        return true if GameData::TerrainTag.try_get(@terrain_tags[tile_id]).bridge
        return true if GameData::TerrainTag.try_get(@terrain_tags[tile_id]).id_number == 42
      end
      return false if @passages[tile_id] & 0x0f != 0
      return true if @priorities[tile_id] == 0
    end
    return true
  end
end

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
class SpriteAnimation
  #-----------------------------------------------------------------------------
  # Tiny fix for emote Animations not playing in v19 since people are unable
  # to read instructions and can't close RMXP before adding the Following
  # Pokemo EX animations
  #-----------------------------------------------------------------------------
  def effect?
    return @_animation_duration > 0 if @_animation_duration
  end
end

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
class PokemonMapFactory
  #-----------------------------------------------------------------------------
  # Fix for followers having animations (grass, etc) when toggled off
  # Treats followers as if they are under a bridge when toggled
  #-----------------------------------------------------------------------------
  alias follow_getTerrainTag getTerrainTag
  def getTerrainTag(mapid,x,y,countBridge = false)
    ret = follow_getTerrainTag(mapid,x,y,countBridge)
    return ret if $PokemonTemp.dependentEvents.can_refresh?
    for devent in $PokemonGlobal.dependentEvents
      if devent && devent[8][/FollowerPkmn/] && devent[3] == x && devent[4] == y && ret.shows_grass_rustle
        ret = GameData::TerrainTag.try_get(:Bridge)
        ret = GameData::TerrainTag.get(:None) if !ret
        break
      end
    end
    return ret
  end
end

#-------------------------------------------------------------------------------
# Make sure that when starting over, the dependent event method is not removed
#-------------------------------------------------------------------------------
def pbStartOver(gameover=false)
  if pbInBugContest?
    pbBugContestStartOver
    return
  end
  $Trainer.heal_party
  if $PokemonGlobal.pokecenterMapId && $PokemonGlobal.pokecenterMapId >= 0
    if gameover
      pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]After the unfortunate defeat, you scurry back to a Pokémon Center."))
    else
      pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]You scurry back to a Pokémon Center, protecting your exhausted Pokémon from any further harm..."))
    end
    pbCancelVehicles
    pbRemoveDependenciesExceptFollower
    $game_switches[Settings::STARTING_OVER_SWITCH] = true
    $game_temp.player_new_map_id    = $PokemonGlobal.pokecenterMapId
    $game_temp.player_new_x         = $PokemonGlobal.pokecenterX
    $game_temp.player_new_y         = $PokemonGlobal.pokecenterY
    $game_temp.player_new_direction = $PokemonGlobal.pokecenterDirection
    $scene.transfer_player if $scene.is_a?(Scene_Map)
    $game_map.refresh
  else
    homedata = GameData::Metadata.get.home
    if homedata && !pbRgssExists?(sprintf("Data/Map%03d.rxdata",homedata[0]))
      if $DEBUG
        pbMessage(_ISPRINTF("Can't find the map 'Map{1:03d}' in the Data folder. The game will resume at the player's position.",homedata[0]))
      end
      $Trainer.heal_party
      return
    end
    if gameover
      pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]After the unfortunate defeat, you scurry back home."))
    else
      pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]You scurry back home, protecting your exhausted Pokémon from any further harm..."))
    end
    if homedata
      pbCancelVehicles
      pbRemoveDependenciesExceptFollower
      $game_switches[Settings::STARTING_OVER_SWITCH] = true
      $game_temp.player_new_map_id    = homedata[0]
      $game_temp.player_new_x         = homedata[1]
      $game_temp.player_new_y         = homedata[2]
      $game_temp.player_new_direction = homedata[3]
      $scene.transfer_player if $scene.is_a?(Scene_Map)
      $game_map.refresh
    else
      $Trainer.heal_party
    end
  end
  pbEraseEscapePoint
end

#-----------------------------------------------------------------------------
#
#-----------------------------------------------------------------------------
class Game_Player < Game_Character
  #-----------------------------------------------------------------------------
  # Edit the dependent event check to account for followers
  #-----------------------------------------------------------------------------
  def pbHasDependentEvents?
    return false if pbGetFollowerDependentEvent && $PokemonGlobal.dependentEvents.length == 1
    return $PokemonGlobal.dependentEvents.length>0
  end
end

#-------------------------------------------------------------------------------
# Remove v19.0 and Gen 8 Project v1.0.4 or below compatibility
#-------------------------------------------------------------------------------
module Compiler
  if defined?(convert_files)
    PluginManager.error("Following Pokemon EX is not compatible with Essentials v19. It's only compatible with v19.1")
  end
end

class PokemonEntryScene2
  if !defined?(MODE4)
    PluginManager.error("Plugin Following Pokemon EX requires plugin Generation 8 Project for Essentials v19.1, if installed, to be version v1.1.0 or higher.")
  end
end

if defined?(Essentials::GEN_8_VERSION) && PluginManager.compare_versions(Essentials::GEN_8_VERSION, "1.1.0") < 0
  PluginManager.error("Plugin Following Pokemon EX requires plugin Generation 8 Project for Essentials v19.1, if installed, to be version v1.1.0 or higher.")
end
