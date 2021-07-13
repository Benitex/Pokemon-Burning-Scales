#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
class DependentEvents
  attr_accessor :realEvents
  #-----------------------------------------------------------------------------
  # Raises The Current Pokemon's Happiness by 3-5 and Pokemon finds item
  #-----------------------------------------------------------------------------
  def add_following_time
    $PokemonGlobal.time_taken += 1
    friendship_time = FollowerSettings::FRIENDSHIP_TIME_TAKEN * Graphics.frame_rate
    item_time = FollowerSettings::ITEM_TIME_TAKEN * Graphics.frame_rate
    $Trainer.first_able_pokemon.changeHappiness("levelup") if ($PokemonGlobal.time_taken % friendship_time) == 0
    $PokemonGlobal.follower_hold_item = true if ($PokemonGlobal.time_taken > item_time)
  end
  #-----------------------------------------------------------------------------
  # Dependent Event method to remove all events except following pokemon
  #-----------------------------------------------------------------------------
  def remove_except_follower
    events=$PokemonGlobal.dependentEvents
    $PokemonGlobal.dependentEvents.each_with_index do |event,i|
      next if event[8][/FollowerPkmn/]
      events[i]      = nil
      @realEvents[i] = nil
      @lastUpdate    += 1
    end
    events.compact!
    @realEvents.compact!
  end
  #-----------------------------------------------------------------------------
  # Dependent Event method to look for Following Pokemon Event
  #-----------------------------------------------------------------------------
  def follower_dependent_event
    $PokemonGlobal.dependentEvents.each_with_index do |event,i|
      next if !event[8][/FollowerPkmn/]
      return @realEvents[i]
    end
    return nil
  end
  #-----------------------------------------------------------------------------
  # Overriden method to prevent follower from changing it's direction with
  # the player
  #-----------------------------------------------------------------------------
  def pbTurnDependentEvents
    updateDependentEvents
    leader = $game_player
    $PokemonGlobal.dependentEvents.each_with_index do |evArr,i|
      event = @realEvents[i]
      # Update direction for this event of it's not a Following Pokemon
      if evArr[8][/FollowerPkmn/] && FollowerSettings::ALWAYS_FACE_PLAYER
        pbTurnTowardEvent(event,leader)
        evArr[5] = event.direction
      end
      # Set leader to this event
      leader = event
    end
  end
  #-----------------------------------------------------------------------------
  # Add a Move Route to a Following Pokemon event
  #-----------------------------------------------------------------------------
  def set_move_route(commands,waitComplete=true)
    $PokemonGlobal.dependentEvents.each_with_index do |event,i|
      next if !event[8][/FollowerPkmn/]
      pbMoveRoute(@realEvents[i],commands,waitComplete)
    end
  end
  #-----------------------------------------------------------------------------
  # Define the Follower Dependent events as a different class from Game_Event
  # This class has consistent frame animation inspite of speed of event
  #-----------------------------------------------------------------------------
  def createEvent(eventData)
    rpgEvent = RPG::Event.new(eventData[3],eventData[4])
    rpgEvent.id = eventData[1]
    if eventData[9]
      # Must setup common event list here and now
      commonEvent = Game_CommonEvent.new(eventData[9])
      rpgEvent.pages[0].list = commonEvent.list
    end
    if eventData[8][/FollowerPkmn/]
      newEvent = Game_FollowerEvent.new(eventData[0],rpgEvent,$MapFactory.getMap(eventData[2]))
    else
      newEvent = Game_Event.new(eventData[0],rpgEvent,$MapFactory.getMap(eventData[2]))
    end
    newEvent.character_name = eventData[6]
    newEvent.character_hue  = eventData[7]
    case eventData[5]   # direction
    when 2 then newEvent.turn_down
    when 4 then newEvent.turn_left
    when 6 then newEvent.turn_right
    when 8 then newEvent.turn_up
    end
    return newEvent
  end
end

#-------------------------------------------------------------------------------
# Defining a new class for Following Pokemon event which will have constant
# rate of move animation
#-------------------------------------------------------------------------------
class Game_FollowerEvent < Game_Event
  def update_pattern
    return if @lock_pattern
    if @moved_last_frame && !@moved_this_frame && !@step_anime
      @pattern = @original_pattern
      @anime_count = 0
      return
    end
    if !@moved_last_frame && @moved_this_frame && !@step_anime
      @pattern = (@pattern + 1) % 4 if @walk_anime
      @anime_count = 0
      return
    end
    frames_per_pattern = Game_Map::REAL_RES_X / (512.0 / Graphics.frame_rate * 1.5)
    frames_per_pattern *= 2 if move_speed > 5
    return if @anime_count < frames_per_pattern
    @pattern = (@pattern + 1) % 4
    @anime_count -= frames_per_pattern
  end
end

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
class DependentEventSprites
  attr_accessor :sprites
  #-------------------------------------------------------------------------------
  # Updating the refresh method to incorporate Marins Footprints
  #-------------------------------------------------------------------------------
  def refresh
    for sprite in @sprites
      sprite.dispose
    end
    @sprites.clear
    $PokemonTemp.dependentEvents.eachEvent { |event,data|
      if data[0]==@map.map_id # Check original map
        @map.events[data[1]].erase if @map.events[data[1]]
      end
      if data[2]==@map.map_id # Check current map
        spr = Sprite_Character.new(@viewport,event)
        spr.setReflection(event, @viewport)
        if defined?(EVENTNAME_MAY_NOT_INCLUDE) && spr.follower &&
           $PokemonTemp.dependentEvents.can_refresh?
          spr.steps = $FollowerSteps
          $FollowerSteps = nil
        end
        @sprites.push(spr)
      end
    }
  end
end

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
class DependentEvents
  #-------------------------------------------------------------------------------
  # Updating the method which controls dependent event positions
  # Includes changes to work with Marin and Boonzeets side stairs and also
  # adds fix for weird dependent event map connection "jump" bug
  #-------------------------------------------------------------------------------
  def pbFollowEventAcrossMaps(leader,follower,instant = false,leaderIsTrueLeader = true)
    d = leader.direction
    areConnected = $MapFactory.areConnected?(leader.map.map_id,follower.map.map_id)
    # Get the rear facing tile of leader
    facingDirection = 10 - d
    if !leaderIsTrueLeader && areConnected
      relativePos = $MapFactory.getThisAndOtherEventRelativePos(leader,follower)
      # Assumes leader and follower are both 1x1 tile in size
      if (relativePos[1] == 0 && relativePos[0] == 2)   # 2 spaces to the right of leader
        facingDirection = 6
      elsif (relativePos[1] == 0 && relativePos[0] == -2)   # 2 spaces to the left of leader
        facingDirection = 4
      elsif relativePos[1] == -2 && relativePos[0] == 0   # 2 spaces above leader
        facingDirection = 8
      elsif relativePos[1] == 2 && relativePos[0] == 0   # 2 spaces below leader
        facingDirection = 2
      end
    end
    facings = [facingDirection] # Get facing from behind
    facings.push([0,0,4,0,8,0,2,0,6][d])   # Get right facing
    facings.push([0,0,6,0,2,0,8,0,4][d])   # Get left facing
    facings.push(d) if !leaderIsTrueLeader # Get forward facing
    mapTile = nil
    boon_stair = 0
    if areConnected
      bestRelativePos = -1
      oldthrough = follower.through
      follower.through = false
      for i in 0...facings.length
        facing = facings[i]
        tile = $MapFactory.getFacingTile(facing,leader)
        if GameData::TerrainTag.exists?(:StairLeft)
          currentTag = $game_player.pbTerrainTag
          if tile[1] > $game_player.x
            tile[2] -= 1 if currentTag == :StairLeft
            boon_stair = -1
          elsif tile[1] < $game_player.x
            tile[2] += 1 if currentTag == :StairLeft
            boon_stair = 1
          end
          if tile[1] > $game_player.x
            tile[2] += 1 if currentTag == :StairRight
            boon_stair = 1
          elsif tile[1] < $game_player.x
            tile[2] -= 1 if currentTag == :StairRight
            boon_stair = -1
          end
        end
        # Assumes leader is 1x1 tile in size
        passable = tile && $MapFactory.isPassableStrict?(tile[0],tile[1],tile[2],follower)
        if i == 0 && !passable && tile &&
           $MapFactory.getTerrainTag(tile[0],tile[1],tile[2]).ledge
          # If the tile isn't passable and the tile is a ledge,
          # get tile from further behind
          tile = $MapFactory.getFacingTileFromPos(tile[0],tile[1],tile[2],facing)
          passable = tile && $MapFactory.isPassableStrict?(tile[0],tile[1],tile[2],follower)
        end
        if passable
          relativePos = $MapFactory.getThisAndOtherPosRelativePos(
             follower,tile[0],tile[1],tile[2])
          # Assumes follower is 1x1 tile in size
          distance = Math.sqrt(relativePos[0] * relativePos[0] + relativePos[1] * relativePos[1])
          if bestRelativePos == -1 || bestRelativePos > distance
            bestRelativePos = distance
            mapTile = tile
          end
          break if i == 0 && distance <= 1 # Prefer behind if tile can move up to 1 space
        end
      end
      follower.through = oldthrough
    else
      tile = $MapFactory.getFacingTile(facings[0],leader)
      # Assumes leader is 1x1 tile in size
      passable = tile && $MapFactory.isPassableStrict?(tile[0],tile[1],tile[2],follower)
      mapTile = passable ? mapTile : nil
    end
    if mapTile && follower.map.map_id == mapTile[0]
      # Follower is on same map
      newX = mapTile[1]
      newY = mapTile[2]
      if defined?(leader.on_stair?) && leader.on_stair?
        newX = leader.x + (leader.direction == 4 ? 1 : leader.direction == 6 ? -1 : 0)
        if leader.on_middle_of_stair?
          newY = leader.y + (leader.direction == 8 ? 1 : leader.direction == 2 ? -1 : 0)
        else
          if follower.on_middle_of_stair?
            newY = follower.stair_start_y - follower.stair_y_position
          else
            newY = leader.y + (leader.direction == 8 ? 1 : leader.direction == 2 ? -1 : 0)
          end
        end
      end
      deltaX = (d == 6 ? -1 : d == 4 ? 1 : 0)
      deltaY = (d == 2 ? -1 : d == 8 ? 1 : 0)
      posX = newX + deltaX
      posY = newY + deltaY
      follower.move_speed = leader.move_speed # sync movespeed
      if (follower.x - newX == -1 && follower.y == newY) ||
         (follower.x - newX == 1  && follower.y == newY) ||
         (follower.y - newY == -1 && follower.x == newX) ||
         (follower.y - newY == 1  && follower.x == newX)
        if instant
          follower.moveto(newX,newY)
        else
          pbFancyMoveTo(follower,newX,newY,leader)
        end
      elsif (follower.x - newX == -2 && follower.y == newY) ||
            (follower.x - newX == 2  && follower.y == newY) ||
            (follower.y - newY == -2 && follower.x == newX) ||
            (follower.y - newY == 2  && follower.x == newX)
        if instant
          follower.moveto(newX,newY)
        else
          pbFancyMoveTo(follower,newX,newY,leader)
        end
      elsif follower.x != posX || follower.y != posY
        if instant
          follower.moveto(newX,newY)
        else
          pbFancyMoveTo(follower,posX,posY,leader)
          pbFancyMoveTo(follower,newX,newY,leader)
        end
      end
    else
      if !mapTile
        # Make current position into leader's position
        mapTile = [leader.map.map_id,leader.x,leader.y]
      end
      if follower.map.map_id == mapTile[0]
        # Follower is on same map as leader
        follower.moveto(leader.x,leader.y)
      else
        # Follower will move to different map
        events = $PokemonGlobal.dependentEvents
        eventIndex = pbEnsureEvent(follower,mapTile[0])
        if eventIndex >= 0
          newFollower = @realEvents[eventIndex]
          newEventData = events[eventIndex]
          offset = [[0,-1],[1,0],[-1,0],[0,1]][leader.direction/2 - 1]
          if eventIndex >= 1 && !$dependent_connection_bug
            echoln "The janky movement you see near map connection\nfrom the 2nd Dependent event onwards is not\ncaused by Following Pokemon EX.\n"
            $dependent_connection_bug = true
          end
          if eventIndex == 0
            mapTile[1] = leader.x + offset[0]
            mapTile[2] = leader.y + offset[1] + boon_stair
          end
          newFollower.moveto(mapTile[1],mapTile[2])
          newEventData[3] = mapTile[1]
          newEventData[4] = mapTile[2]
        end
      end
    end
  end
  #-----------------------------------------------------------------------------
  # Fix follower not being in the same spot upon save
  #-----------------------------------------------------------------------------
  def pbMapChangeMoveDependentEvents
    return
  end
end

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
class Sprite_Character
  attr_accessor :steps
  #-------------------------------------------------------------------------------
  # Add Marin's feet to Following Pokemon when it starts working
  #-------------------------------------------------------------------------------
  def setReflection(event, viewport)
    @reflection = Sprite_Reflection.new(self,event,viewport) if !@reflection
  end
  #-------------------------------------------------------------------------------
  # Add Marin's feet to Following Pokemon when it starts working
  #-------------------------------------------------------------------------------
  if defined?(EVENTNAME_MAY_NOT_INCLUDE)
    alias follow_init footsteps_initialize

    def initialize(viewport, character = nil, is_follower = false)
      @viewport = viewport
      @is_follower = is_follower
      follow_init(@viewport, character)
      @steps = []
    end

    def update
      follow_update
      @old_x ||= @character.x
      @old_y ||= @character.y
      if (@character.x != @old_x || @character.y != @old_y) && !["", "nil"].include?(@character.character_name)
        if @character == $game_player && $PokemonTemp.dependentEvents &&
           $PokemonTemp.dependentEvents.respond_to?(:realEvents) &&
           $PokemonTemp.dependentEvents.realEvents.select { |e| !["", "nil"].include?(e.character_name) }.size > 0 &&
           !DUPLICATE_FOOTSTEPS_WITH_FOLLOWER
          if !EVENTNAME_MAY_NOT_INCLUDE.include?($PokemonTemp.dependentEvents.realEvents[0].name) &&
             !FILENAME_MAY_NOT_INCLUDE.include?($PokemonTemp.dependentEvents.realEvents[0].character_name)
            make_steps = false
          else
            make_steps = true
          end
        elsif @character.respond_to?(:name) && !(EVENTNAME_MAY_NOT_INCLUDE.include?(@character.name) &&
               FILENAME_MAY_NOT_INCLUDE.include?(@character.character_name))
          tilesetid = @character.map.instance_eval { @map.tileset_id }
          make_steps = [2,1,0].any? do |e|
            tile_id = @character.map.data[@old_x, @old_y, e]
            next false if tile_id.nil?
            next $data_tilesets[tilesetid].terrain_tags[tile_id] == PBTerrain::Sand
          end
        end
        if make_steps
          fstep = Sprite.new(self.viewport)
          fstep.z = 0
          dirs = [nil,"DownLeft","Down","DownRight","Left","Still","Right","UpLeft",
              "Up", "UpRight"]
          if @character == $game_player && $PokemonGlobal.bicycle
            fstep.bmp("Graphics/Characters/Footprints/steps#{dirs[@character.direction]}Bike")
          else
            fstep.bmp("Graphics/Characters/Footprints/steps#{dirs[@character.direction]}")
          end
          @steps ||= []
          if @character == $game_player && $PokemonGlobal.bicycle
            x = BIKE_X_OFFSET
            y = BIKE_Y_OFFSET
          else
            x = WALK_X_OFFSET
            y = WALK_Y_OFFSET
          end
          @steps << [fstep, @character.map, @old_x + x / Game_Map::TILE_WIDTH.to_f, @old_y + y / Game_Map::TILE_HEIGHT.to_f]
        end
      end
      @old_x = @character.x
      @old_y = @character.y
      update_footsteps
    end
  end
end
