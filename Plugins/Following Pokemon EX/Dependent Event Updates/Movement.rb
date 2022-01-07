class DependentEvents
  #-----------------------------------------------------------------------------
  # Updating the dependent event movement method to not update events every
  # frame and also update Following Pokemon Map
  #-----------------------------------------------------------------------------
  def pbMoveDependentEvents
    return false if !$game_temp.move_followers
    events = $PokemonGlobal.dependentEvents
    leader = $game_player
    for i in 0...events.length
      event = @realEvents[i]
      pbFollowEventAcrossMaps(leader, event, false, i == 0)
      # Update X and Y for this event
      events[i][2] = event.map.map_id
      events[i][3] = event.x
      events[i][4] = event.y
      events[i][5] = event.direction
      # Set leader to this event
      leader = event
    end
    $game_temp.move_followers = false
  end
  #-----------------------------------------------------------------------------
  # Updating the dependent event turning method to prevent follower from
  # changing it's direction with the player
  #-----------------------------------------------------------------------------
  def pbTurnDependentEvents
    leader = $game_player
    $PokemonGlobal.dependentEvents.each_with_index do |evArr,i|
      event = @realEvents[i]
      # Update direction for this event if it's not a Following Pokemon
      if !evArr[8][/FollowerPkmn/] || FollowingPkmn::ALWAYS_FACE_PLAYER
        pbTurnTowardEvent(event, leader)
        evArr[5] = event.direction
      end
      # Set leader to this event
      leader = event
    end
  end
  #-----------------------------------------------------------------------------
  # Updating the dependent event update method to fix ice sliding and make
  # Following Pokemon independent of Common Events
  #-----------------------------------------------------------------------------
  def updateDependentEvents
    return false if $game_temp.disallow_follower_update
    events = $PokemonGlobal.dependentEvents
    return if events.length == 0
    for i in 0...events.length
      event = @realEvents[i]
      next if !@realEvents[i]
      event.transparent = $game_player.transparent
      if event.jumping? || event.moving? ||
         !($game_player.jumping? || $game_player.moving?)
        event.update
      elsif !event.starting
        event.set_starting
        event.update
        event.clear_starting
      end
      if !event.is_a?(Game_FollowerEvent)
        events[i][3] = event.x
        events[i][4] = event.y
      else
        if $PokemonGlobal.sliding || $game_player.pbTerrainTag.ice
          event.straighten
          event.walk_anime = false
        else
          event.walk_anime = true
        end
      end
      events[i][5] = event.direction
    end
    # Check event triggers
    if Input.trigger?(Input::USE) && !($game_temp.in_menu ||
      $game_temp.in_battle || $game_player.move_route_forcing ||
      $game_temp.message_window_showing || pbMapInterpreterRunning? ||
      $game_player.moving?)
      # Get position of tile facing the player
      facingTile = $MapFactory.getFacingTile
      # Assumes player is 1x1 tile in size
      self.eachEvent { |e, d|
        next if (!d[9] && !e.is_a?(Game_FollowerEvent)) || e.jumping?
        if e.at_coordinate?($game_player.x, $game_player.y) && !e.is_a?(Game_FollowerEvent)
          # On same position
          if (!e.respond_to?("over_trigger") || e.over_trigger?) && e.list.size > 1
            # Start event
            $game_map.refresh if $game_map.need_refresh
            e.lock
            pbMapInterpreter.setup(e.list,e.id,e.map.map_id)
          end
        elsif facingTile && e.map.map_id == facingTile[0] && e.at_coordinate?(facingTile[1], facingTile[2])
          # On facing tile
          if e.is_a?(Game_FollowerEvent) && !d[9]
            $game_map.refresh if $game_map.need_refresh
            e.lock
            FollowingPkmn.talk
            e.unlock
          elsif (!e.respond_to?("over_trigger") || !e.over_trigger?) && e.list.size > 1
            # Start event
            $game_map.refresh if $game_map.need_refresh
            e.lock
            pbMapInterpreter.setup(e.list,e.id,e.map.map_id)
          end
        end
      }
    end
  end
  #-----------------------------------------------------------------------------
  # Updating the method which controls dependent event positions
  # Includes changes to work with Marin and Boonzeets side stairs and also
  # adds fix ledges and map connections
  #-----------------------------------------------------------------------------
  def pbFollowEventAcrossMaps(leader, follower, instant = false, leaderIsTrueLeader = true)
    d = leader.direction
    areConnected = $MapFactory.areConnected?(leader.map.map_id, follower.map.map_id)
    # Get the rear facing tile of leader
    facingDirection = 10 - d
    if !leaderIsTrueLeader && areConnected
      relativePos = $MapFactory.getThisAndOtherEventRelativePos(leader, follower)
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
    facings.push([0, 0, 4, 0, 8, 0, 2, 0, 6][d])   # Get right facing
    facings.push([0, 0, 6, 0, 2, 0, 8, 0, 4][d])   # Get left facing
    facings.push(d) if !leaderIsTrueLeader # Get forward facing
    mapTile = nil
    if areConnected
      bestRelativePos = -1
      oldthrough = follower.through
      follower.through = false
      facings.each_with_index do |facing, i|
        facing = facings[i]
        tile = $MapFactory.getFacingTile(facing, leader)
        if GameData::TerrainTag.exists?(:StairLeft)
          currentTag = $game_player.pbTerrainTag
          if currentTag == :StairLeft
            tile[2] += (tile[1] > $game_player.x ? -1 : 1)
          elsif currentTag == :StairRight
            tile[2] += (tile[1] < $game_player.x ? -1 : 1)
          end
        end
        # Assumes leader is 1x1 tile in size
        passable = tile && $MapFactory.isPassableStrict?(tile[0], tile[1], tile[2], follower)
        if i == 0 && !passable && tile &&
           $MapFactory.getTerrainTag(tile[0], tile[1], tile[2]).ledge
          # If the tile isn't passable and the tile is a ledge,
          # get tile from further behind
          tile = $MapFactory.getFacingTileFromPos(tile[0], tile[1], tile[2], facing)
          passable = tile && $MapFactory.isPassableStrict?(tile[0], tile[1], tile[2], follower)
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
      tile = $MapFactory.getFacingTile(facings[0], leader)
      # Assumes leader is 1x1 tile in size
      passable = tile && $MapFactory.isPassableStrict?(tile[0], tile[1], tile[2], follower)
      mapTile = passable ? mapTile : nil
    end
    # Make current position into leader's position
    mapTile = [leader.map.map_id, leader.x, leader.y] if !mapTile
    if follower.map.map_id == mapTile[0]
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
          follower.moveto(newX, newY)
        else
          pbFancyMoveTo(follower, newX, newY, leader)
        end
      elsif (follower.x - newX == -2 && follower.y == newY) ||
            (follower.x - newX == 2  && follower.y == newY) ||
            (follower.y - newY == -2 && follower.x == newX) ||
            (follower.y - newY == 2  && follower.x == newX)
        if instant
          follower.moveto(newX, newY)
        else
          pbFancyMoveTo(follower,newX,newY,leader)
        end
      elsif follower.x != posX || follower.y != posY
        if instant
          follower.moveto(newX, newY)
        else
          pbFancyMoveTo(follower, posX, posY, leader)
          pbFancyMoveTo(follower, newX, newY, leader)
        end
      end
    else
      if follower.is_a?(Game_FollowerEvent)
        follower.moveto_new_map(mapTile[0])
        pbFancyMoveTo(follower, mapTile[1], mapTile[2], leader)
      else
        # Follower will move to different map
        events = $PokemonGlobal.dependentEvents
        eventIndex = pbEnsureEvent(follower, mapTile[0])
        if eventIndex >= 0
          newFollower = @realEvents[eventIndex]
          newEventData = events[eventIndex]
          newFollower.moveto(mapTile[1], mapTile[2])
          newEventData[3] = mapTile[1]
          newEventData[4] = mapTile[2]
        end
      end
    end
  end
  #-----------------------------------------------------------------------------
end


#-------------------------------------------------------------------------------
# Always update follower's position if the player is moving
#-------------------------------------------------------------------------------
class Game_Player
  alias __followingpkmn__update update unless method_defined?(:__followingpkmn__update)
  def update(*args)
    $game_temp.disallow_follower_update = true
    __followingpkmn__update(*args)
    $game_temp.disallow_follower_update = false
    # Update dependent events
    if (!@moved_last_frame || @stopped_last_frame ||
       (@stopped_this_frame && $PokemonGlobal.sliding)) && (moving? || jumping?)
      $game_temp.move_followers = true
      $PokemonTemp.dependentEvents.pbMoveDependentEvents
    end
    $PokemonTemp.dependentEvents.updateDependentEvents
  end
end
