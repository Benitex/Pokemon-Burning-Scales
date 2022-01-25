#-----------------------------------------------------------------------------
# Update method which checks Dependent Event passabilities to account for
# Following Pokemon
#-----------------------------------------------------------------------------
class Game_Map
  def passableStrict?(x, y, d, self_event = nil)
    return false if !valid?(x, y)
    bit = (1 << (d / 2 - 1)) & 0x0f
    for event in events.values
      next if event == self_event || event.tile_id < 0 || event.through
      next if !event.at_coordinate?(x, y)
      return true if GameData::TerrainTag.try_get(@terrain_tags[event.tile_id]).ignore_passability
      return false if GameData::TerrainTag.try_get(@terrain_tags[event.tile_id]).ledge
      if self_event != $game_player
        return true if GameData::TerrainTag.try_get(@terrain_tags[event.tile_id]).bridge
        return true if GameData::TerrainTag.try_get(@terrain_tags[event.tile_id]).ice
        return true if GameData::TerrainTag.try_get(@terrain_tags[event.tile_id]).can_surf
        return true if GameData::TerrainTag.try_get(@terrain_tags[event.tile_id]).waterfall
      end
      passage = @passages[event.tile_id] || 0
      return false if passage & bit != 0 || passage & 0x0f == 0x0f
      return true if @priorities[event.tile_id] == 0
    end
    for i in [2, 1, 0]
      tile_id = data[x, y, i]
      return true if GameData::TerrainTag.try_get(@terrain_tags[tile_id]).ignore_passability
      return false if GameData::TerrainTag.try_get(@terrain_tags[tile_id]).ledge
      if self_event != $game_player
        return true if GameData::TerrainTag.try_get(@terrain_tags[tile_id]).bridge
        return true if GameData::TerrainTag.try_get(@terrain_tags[tile_id]).ice
        return true if GameData::TerrainTag.try_get(@terrain_tags[tile_id]).can_surf
        return true if GameData::TerrainTag.try_get(@terrain_tags[tile_id]).waterfall
      end
      passage = @passages[tile_id] || 0
      return false if passage & bit != 0 || passage & 0x0f == 0x0f
      return true if @priorities[tile_id] == 0
    end
    return true
  end
end

#-------------------------------------------------------------------------------
# Prevent other events from passing through Following Pokemon. Toggleable
#-------------------------------------------------------------------------------
class Game_Character
  alias __followingpkmn__passable? passable? unless method_defined?(:__followingpkmn__passable?)
  def passable?(x, y, d, strict = false)
    ret = __followingpkmn__passable?(x, y, d, strict)
    if ret && FollowingPkmn::IMPASSABLE_FOLLOWER && self != $game_player && !self.is_a?(Game_FollowerEvent)
      new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
      new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
      $PokemonTemp.dependentEvents.realEvents.each do |e|
        return false if e.at_coordinate?(new_x, new_y) && !e.through && e.is_a?(Game_FollowerEvent) && FollowingPkmn.active?
      end
    end
    return ret
  end
end


class PokemonMapFactory
  #-----------------------------------------------------------------------------
  # Fix for followers having animations (grass, etc) when toggled off
  # Treats followers as if they are under a bridge when toggled
  #-----------------------------------------------------------------------------
  alias __followingpkmn__getTerrainTag getTerrainTag unless method_defined?(:__followingpkmn__getTerrainTag)
  def getTerrainTag(*args)
    ret = __followingpkmn__getTerrainTag(*args)
    return ret if FollowingPkmn.active?
    x = args[1]
    y = args[2]
    for devent in $PokemonGlobal.dependentEvents
      if devent && devent[8][/FollowerPkmn/] && devent[3] == x &&
         devent[4] == y && ret.shows_grass_rustle
        ret = GameData::TerrainTag.get(:None)
        break
      end
    end
    return ret
  end
  #-----------------------------------------------------------------------------
  # Fixed Relative Postions being incorrectly calculated
  #-----------------------------------------------------------------------------
  def getRelativePos(thisMapID, thisX, thisY, otherMapID, otherX, otherY)
    if thisMapID == otherMapID   # Both events share the same map
      return [otherX - thisX, otherY - thisY]
    end
    conns = MapFactoryHelper.getMapConnections
    if conns[thisMapID]
      for conn in conns[thisMapID]
        if conn[0] == otherMapID
          posX = conn[4] - conn[1] + otherX - thisX
          posY = conn[5] - conn[2] + otherY - thisY
          return [posX, posY]
        elsif conn[3] == otherMapID
          posX =  conn[1] - conn[4] + otherX - thisX
          posY =  conn[2] - conn[5] + otherY - thisY
          return [posX, posY]
        end
      end
    end
    return [0, 0]
  end
end
