#-------------------------------------------------------------------------------
# Add Reflections to Following Pokemon sprite
#-------------------------------------------------------------------------------
class Sprite_Character
  def setReflection(event, viewport)
    @reflection = Sprite_Reflection.new(self,event,viewport) if !@reflection
  end
end



class DependentEvents
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
      @realEvents[i].character_hue = 0
      $game_temp.super_shiny_hue = false
    end
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
end



class DependentEventSprites
  attr_accessor :sprites
  #-----------------------------------------------------------------------------
  # Updating the refresh method to allow clearing of base event in all maps,
  # add reflections and prevent crash when base map/event is deleted
  #-----------------------------------------------------------------------------
  def refresh
    @sprites.each { |sprite| sprite.dispose }
    @sprites.clear
    $PokemonTemp.dependentEvents.eachEvent { |event, data|
      $MapFactory.maps.each { |map| map.events[data[1]].erase if map.events[data[1]] && data[0] == map.map_id }
      spr = Sprite_Character.new(@viewport, event)
      spr.setReflection(event, @viewport)
      @sprites.push(spr)
    }
    FollowingPkmn.refresh(false)
  end
  #-----------------------------------------------------------------------------
  # Add emote animation to Following Pokemon
  #-----------------------------------------------------------------------------
  def setAnimation(anim_id)
    @sprites.each do |spr|
      next if spr.character != FollowingPkmn.get
      spr.character.animation_id = anim_id
    end
  end
  #-----------------------------------------------------------------------------
end

#-------------------------------------------------------------------------------
# Adding DayNight and Status condition pulsing effect to Following Pokemon sprite
#-------------------------------------------------------------------------------
class DependentEventSprites
  alias __followingpkmn__update update unless method_defined?(:__followingpkmn__update)
  def update(*args)
    __followingpkmn__update(*args)
    return if !FollowingPkmn.active?
    @sprites.each_with_index do |_, i|
      next if !$PokemonGlobal.dependentEvents[i] ||
              !$PokemonGlobal.dependentEvents[i][8][/FollowerPkmn/]
      first_pkmn = $Trainer.first_able_pokemon
      next if !first_pkmn
      if first_pkmn.respond_to?(:superShiny?) && first_pkmn.superShiny? &&
         !$game_temp.super_shiny_hue && !$PokemonTemp.dependentEvents.realEvents[i].move_route_forcing
        $PokemonTemp.dependentEvents.realEvents[i].character_hue = first_pkmn.superHue
        $game_temp.super_shiny_hue = true
      end
      if first_pkmn.status == :NONE || !FollowingPkmn::APPLY_STATUS_TONES
        @sprites[i].color.set(0, 0, 0, 0)
        $game_temp.status_pulse = [50.0, 50.0, 150.0, (100/(Graphics.frame_rate * 2.0))]
        next
      end
      status_tone = nil
      status_tone = FollowingPkmn.const_get("TONE_#{first_pkmn.status}") if FollowingPkmn.const_defined?("TONE_#{first_pkmn.status}")
      next if !status_tone || !status_tone.all? {|s| s > 0}
      $game_temp.status_pulse[0] += $game_temp.status_pulse[3]
      $game_temp.status_pulse[3] *= -1 if $game_temp.status_pulse[0] < $game_temp.status_pulse[1] ||
                                            $game_temp.status_pulse[0] > $game_temp.status_pulse[2]
      @sprites[i].color.set(status_tone[0], status_tone[1], status_tone[2], $game_temp.status_pulse[0])
    end
  end
end

#-------------------------------------------------------------------------------
# Variable for handling status pulsing
#-------------------------------------------------------------------------------
class Game_Temp
  attr_accessor :status_pulse
  attr_accessor :super_shiny_hue

  def status_pulse
    @status_pulse = [50.0, 50.0, 150.0, (100/(Graphics.frame_rate * 2.0))] if !@status_pulse
    return @status_pulse
  end
end
