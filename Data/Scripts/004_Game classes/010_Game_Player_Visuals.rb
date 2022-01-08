class Game_Player < Game_Character
  @@bobFrameSpeed = 1.0/15

  def fullPattern
    case self.direction
    when 2 then return self.pattern
    when 4 then return self.pattern + 4
    when 6 then return self.pattern + 8
    when 8 then return self.pattern + 12
    end
    return 0
  end

  def setDefaultCharName(chname, pattern, lockpattern = false)
    return if !(0...16).include?(pattern)
    @character_name = chname
    @direction = [2,4,6,8][pattern/4]
    @pattern = pattern%4
    @lock_pattern = lockpattern
    refresh_charset if @character_name.nil?
  end

  def pbCanRun?
    return false if $game_temp.in_menu || $game_temp.in_battle ||
                    @move_route_forcing || $game_temp.message_window_showing ||
                    pbMapInterpreterRunning?
    return false if !$Trainer.has_running_shoes && !$PokemonGlobal.diving &&
                    !$PokemonGlobal.surfing && !$PokemonGlobal.bicycle
    return false if jumping?
    return false if pbTerrainTag.must_walk
    run_key = Input::ACTION
    return ($PokemonSystem.runstyle == 1) ^ Input.press?(run_key)
  end

  def pbIsRunning?
    return moving? && !@move_route_forcing && pbCanRun?
  end

  def set_movement_type(type)
    return if @move_route_forcing
    meta = GameData::Metadata.get_player($Trainer&.character_ID || 0)
    new_charset = nil
    case type
    when :fishing
      new_charset = pbGetPlayerCharset(meta, 6)
    when :surf_fishing
      new_charset = pbGetPlayerCharset(meta, 7)
    when :diving, :diving_fast, :diving_jumping, :diving_stopped
      self.move_speed = 3
      new_charset = pbGetPlayerCharset(meta, 5)
    when :surfing, :surfing_fast, :surfing_jumping, :surfing_stopped
      self.move_speed = (type == :surfing_jumping) ? 3 : 4
      new_charset = pbGetPlayerCharset(meta, 3)
    when :cycling, :cycling_fast, :cycling_jumping, :cycling_stopped
      self.move_speed = (type == :cycling_jumping) ? 3 : 5
      new_charset = pbGetPlayerCharset(meta, 2)
    when :running
      self.move_speed = 4
      new_charset = pbGetPlayerCharset(meta, 4)
    when :ice_sliding
      self.move_speed = 4
      new_charset = pbGetPlayerCharset(meta, 1)
    else   # :walking, :jumping, :walking_stopped
      self.move_speed = 3
      new_charset = pbGetPlayerCharset(meta, 1)
    end
    @character_name = new_charset if new_charset
  end

  # Called when the player's character or outfit changes. Assumes the player
  # isn't moving.
  def refresh_charset
    meta = GameData::Metadata.get_player($Trainer&.character_ID || 0)
    new_charset = nil
    if $PokemonGlobal&.diving
      new_charset = pbGetPlayerCharset(meta, 5)
    elsif $PokemonGlobal&.surfing
      new_charset = pbGetPlayerCharset(meta, 3)
    elsif $PokemonGlobal&.bicycle
      new_charset = pbGetPlayerCharset(meta, 2)
    else
      new_charset = pbGetPlayerCharset(meta, 1)
    end
    @character_name = new_charset if new_charset
  end

  def update_move
    if !@moved_last_frame || @stopped_last_frame   # Started a new step
      if pbTerrainTag.ice
        set_movement_type(:ice_sliding)
      elsif !@move_route_forcing
        faster = pbCanRun?
        if $PokemonGlobal&.diving
          set_movement_type((faster) ? :diving_fast : :diving)
        elsif $PokemonGlobal&.surfing
          set_movement_type((faster) ? :surfing_fast : :surfing)
        elsif $PokemonGlobal&.bicycle
          set_movement_type((faster) ? :cycling_fast : :cycling)
        else
          set_movement_type((faster) ? :running : :walking)
        end
      end
      if jumping?
        if $PokemonGlobal&.diving
          set_movement_type(:diving_jumping)
        elsif $PokemonGlobal&.surfing
          set_movement_type(:surfing_jumping)
        elsif $PokemonGlobal&.bicycle
          set_movement_type(:cycling_jumping)
        else
          set_movement_type(:jumping)   # Walking speed/charset while jumping
        end
      end
    end
    super
  end

  def update_command
    return super
  end

  def update_stop
    if @stopped_last_frame
      if $PokemonGlobal&.diving
        set_movement_type(:diving_stopped)
      elsif $PokemonGlobal&.surfing
        set_movement_type(:surfing_stopped)
      elsif $PokemonGlobal&.bicycle
        set_movement_type(:cycling_stopped)
      else
        set_movement_type(:walking_stopped)
      end
    end
    super
  end

  def update_pattern
    if $PokemonGlobal&.surfing || $PokemonGlobal&.diving
      p = ((Graphics.frame_count % 60) * @@bobFrameSpeed).floor
      @pattern = p if !@lock_pattern
      @pattern_surf = p
      @bob_height = (p >= 2) ? 2 : 0
    else
      @bob_height = 0
      super
    end
  end
end
