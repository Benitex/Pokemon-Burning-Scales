#-------------------------------------------------------------------------------
# Defining a new class for Following Pokemon event which will have constant
# rate of move animation, will update maps without glitching and will
# have proper juming
#-------------------------------------------------------------------------------
class Game_FollowerEvent < Game_Event
  #-----------------------------------------------------------------------------
  attr_writer :map
  #-----------------------------------------------------------------------------
  # Update pattern at a constant rate independent of move speed
  #-----------------------------------------------------------------------------
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
  #-----------------------------------------------------------------------------
  # Update event map for smooth movement across map connections
  #-----------------------------------------------------------------------------
  def moveto_new_map(new_map)
    vector = $MapFactory.getRelativePos(new_map, 0, 0, self.map.map_id, @x, @y)
    @map = $MapFactory.getMap(new_map)
    # NOTE: Can't use moveto because vector is outside the boundaries of the
    #       map, and moveto doesn't allow setting invalid coordinates.
    @x = vector[0]
    @y = vector[1]
    @real_x = @x * Game_Map::REAL_RES_X
    @real_y = @y * Game_Map::REAL_RES_Y
  end
  #-----------------------------------------------------------------------------
  # Add Dust animation when the event is done jumping
  #-----------------------------------------------------------------------------
  def update_move
    was_jumping = jumping? && !@move_route_forcing
    super
    return unless was_jumping && !jumping?
    $scene.spriteset.addUserAnimation(Settings::DUST_ANIMATION_ID, self.x, self.y, true, 1)
  end
  #-----------------------------------------------------------------------------
end



class DependentEvents
  #-----------------------------------------------------------------------------
  # Define the Follower Dependent events as a different class from Game_Event
  # This class has consistent frame animation inspite of speed of event
  #-----------------------------------------------------------------------------
  def createEvent(eventData)
    rpgEvent = RPG::Event.new(eventData[3], eventData[4])
    rpgEvent.id = eventData[1]
    if eventData[9]
      # Must setup common event list here and now
      commonEvent = Game_CommonEvent.new(eventData[9])
      rpgEvent.pages[0].list = commonEvent.list
    end
    if eventData[8][/FollowerPkmn/]
      newEvent = Game_FollowerEvent.new(eventData[0], rpgEvent, $MapFactory.getMap(eventData[2]))
    else
      newEvent = Game_Event.new(eventData[0], rpgEvent, $MapFactory.getMap(eventData[2]))
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
  #-----------------------------------------------------------------------------
  # Dependent Event method to remove all events except following pokemon
  #-----------------------------------------------------------------------------
  def remove_except_follower
    events = $PokemonGlobal.dependentEvents
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
end
