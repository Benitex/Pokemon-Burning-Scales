module FollowingPkmn
  #-----------------------------------------------------------------------------
  # Script Command to have an event follow the player as a Following Pokemon
  #-----------------------------------------------------------------------------
  def self.start_following(event_id = nil, anim = true)
    return if !FollowingPkmn.can_check?
    event_id = pbMapInterpreter.get_character(0).id if event_id.nil? && pbMapInterpreter
    return false if !$Trainer.first_able_pokemon || !$game_map.events[event_id]
    $PokemonTemp.dependentEvents.removeEventByName("FollowerPkmn") if FollowingPkmn.get
    pbAddDependency2(event_id, "FollowerPkmn", FollowingPkmn::FOLLOWER_COMMON_EVENT)
    $PokemonGlobal.follower_toggled = true
    event = FollowingPkmn.get
    $PokemonTemp.dependentEvents.pbFollowEventAcrossMaps($game_player, event, true, false)
    FollowingPkmn.refresh(anim)
  end
  #-----------------------------------------------------------------------------
  # Script Command to remove the event following the player as a Following
  # Pokemon
  #-----------------------------------------------------------------------------
  def self.stop_following
    return if !FollowingPkmn.can_check?
    pbRemoveDependency2("FollowerPkmn")
  end
  #-----------------------------------------------------------------------------
  # Script Command to toggle Following Pokemon
  #-----------------------------------------------------------------------------
  def self.toggle(forced = nil, anim = nil)
    return if !FollowingPkmn.can_check? || !FollowingPkmn.get
    return if !$Trainer.first_able_pokemon
    anim_1 = FollowingPkmn.active?
    if !forced.nil?
      # This may seem redundant but it keeps follower_toggled a boolean always
      $PokemonGlobal.follower_toggled = !(!forced)
    else
      $PokemonGlobal.follower_toggled = !($PokemonGlobal.follower_toggled)
    end
    anim_2 = FollowingPkmn.active?
    anim = anim_1 != anim_2 if anim.nil?
    FollowingPkmn.refresh(anim)
  end
  #-----------------------------------------------------------------------------
  # Script Command to toggle Following Pokemon off
  #-----------------------------------------------------------------------------
  def self.toggle_off(anim = nil)
    FollowingPkmn.toggle(false, anim)
  end
  #-----------------------------------------------------------------------------
  # Script Command to toggle Following Pokemon on
  #-----------------------------------------------------------------------------
  def self.toggle_on(anim = nil)
    FollowingPkmn.toggle(true, anim)
  end
  #-----------------------------------------------------------------------------
  # Script Command for talking to Following Pokemon
  #-----------------------------------------------------------------------------
  def self.talk
    return if !FollowingPkmn.can_check?
    return if !$game_temp || $game_temp.in_battle || $game_temp.in_menu
    facing = pbFacingTile
    if !FollowingPkmn.active? || !$game_map.passable?(facing[1], facing[2], $game_player.direction, $game_player)
      $game_player.straighten
      Events.onAction.trigger(nil)
      return false
    end
    event = FollowingPkmn.get
    pbTurnTowardEvent(event, $game_player)
    first_pkmn = $Trainer.first_able_pokemon
    GameData::Species.play_cry(first_pkmn)
    random_val = rand(6)
    Events.OnTalkToFollower.trigger(first_pkmn, random_val)
    pbTurnTowardEvent(event, $game_player)
    return true
  end
  #-----------------------------------------------------------------------------
  # Control the following Pokemon using move routes
  #-----------------------------------------------------------------------------
  def self.move_route(commands, wait_complete = false)
    return if !FollowingPkmn.can_check?
    $PokemonGlobal.dependentEvents.each_with_index do |event,i|
      next if !event[8][/FollowerPkmn/]
      pbMoveRoute($PokemonTemp.dependentEvents.realEvents[i], commands, false)
    end
    pbMapInterpreter&.command_210 if wait_complete
  end
  #-----------------------------------------------------------------------------
  # Script Command for adding an animation to the Following Pokemon event
  #-----------------------------------------------------------------------------
  def self.animation(id)
    return if !FollowingPkmn.can_check? || !FollowingPkmn.active?
    sprites = $scene.spritesetGlobal.followingpkmn_sprites
    return if !sprites
    sprites.setAnimation(id)
  end
  #-----------------------------------------------------------------------------
end
