module FollowingPkmn
  #-----------------------------------------------------------------------------
  @@can_refresh = false
  #-----------------------------------------------------------------------------
  # Checks if the Following Pokemon is active and following the player
  #-----------------------------------------------------------------------------
  def self.active?
    return @@can_refresh
  end
  #-----------------------------------------------------------------------------
  # Forcefully refresh Following Pokemon sprite with animation (if specified)
  #-----------------------------------------------------------------------------
  def self.refresh(anim = false)
    return if !FollowingPkmn.can_check?
    $PokemonTemp.dependentEvents.remove_sprite
    first_pkmn = $Trainer.first_able_pokemon
    return if !first_pkmn
    FollowingPkmn.refresh_internal
    ret = FollowingPkmn.active?
    if anim
      $PokemonGlobal.dependentEvents.each_with_index do |event,i|
        next if !event[8][/FollowerPkmn/]
        anim_name = ret ? :ANIMATION_COME_OUT : :ANIMATION_COME_IN
        anim_id   = nil
        anim_id   = FollowingPkmn.const_get(anim_name) if FollowingPkmn.const_defined?(anim_name)
        $scene.spriteset.addUserAnimation(anim_id, $PokemonTemp.dependentEvents.realEvents[i].x,
                                          $PokemonTemp.dependentEvents.realEvents[i].y, false, 1) if anim_id
      end
      pbMoveRoute($game_player,[PBMoveRoute::Wait,2])
      pbWait(8)
    end
    shiny = first_pkmn.shiny?
    shiny = first_pkmn.superVariant if (first_pkmn.respond_to?(:superVariant) && !first_pkmn.superVariant.nil? && first_pkmn.superShiny?)
    $PokemonTemp.dependentEvents.change_sprite([
      first_pkmn.species, first_pkmn.form, first_pkmn.gender, shiny, first_pkmn.shadowPokemon?
    ]) if ret
    FollowingPkmn.move_route([(ret ? PBMoveRoute::StepAnimeOn : PBMoveRoute::StepAnimeOff)]) if FollowingPkmn::ALWAYS_ANIMATE
    return ret
  end
  #-----------------------------------------------------------------------------
  # Script Command for Following Pokémon finding an item in the field
  #-----------------------------------------------------------------------------
  def self.item(item, quantity = 1, message = nil)
    return false if !FollowingPkmn.can_check?
    return false if !$PokemonGlobal.follower_hold_item
    pokename = $Trainer.first_able_pokemon.name
    message = _INTL("{1} seems to be holding something...") if nil_or_empty?(message)
    pbMessage(_INTL(message, pokename))
    item = GameData::Item.get(item)
    return false if !item || quantity < 1
    itemname = (quantity > 1) ? item.name_plural : item.name
    pocket = item.pocket
    move   = item.move
    if $PokemonBag.pbStoreItem(item, quantity)   # If item can be picked up
      meName = (item.is_key_item?) ? "Key item get" : "Item get"
      if item == :LEFTOVERS
        pbMessage(_INTL("\\me[{1}]{3} found some \\c[1]{2}\\c[0]!\\wtnp[30]", meName, itemname, pokename))
      elsif item.is_machine?   # TM or HM
        pbMessage(_INTL("\\me[{1}]{4} found \\c[1]{2} {3}\\c[0]!\\wtnp[30]", meName, itemname, GameData::Move.get(move).name, pokename))
      elsif quantity>1
        pbMessage(_INTL("\\me[{1}]{4} found {2} \\c[1]{3}\\c[0]!\\wtnp[30]", meName, quantity, itemname, pokename))
      elsif itemname.starts_with_vowel?
        pbMessage(_INTL("\\me[{1}]{3} found an \\c[1]{2}\\c[0]!\\wtnp[30]", meName, itemname, pokename))
      else
        pbMessage(_INTL("\\me[{1}]{3} found a \\c[1]{2}\\c[0]!\\wtnp[30]", meName, itemname, pokename))
      end
      pbMessage(_INTL("You put the {1} away\\nin the <icon=bagPocket{2}>\\c[1]{3} Pocket\\c[0].",
         itemname, pocket, PokemonBag.pocketNames[pocket]))
      $PokemonGlobal.follower_hold_item = false
      $PokemonGlobal.time_taken         = 0
      return true
    end
    # Can't add the item
    if item == :LEFTOVERS
      pbMessage(_INTL("{1} found some \\c[1]{2}\\c[0]!\\wtnp[30]", pokename, itemname))
    elsif item.is_machine?   # TM or HM
      pbMessage(_INTL("{1} found \\c[1]{2} {3}\\c[0]!\\wtnp[30]", pokename, itemname, GameData::Move.get(move).name))
    elsif quantity>1
      pbMessage(_INTL("{1} found {2} \\c[1]{3}\\c[0]!\\wtnp[30]", pokename, quantity, itemname))
    elsif itemname.starts_with_vowel?
      pbMessage(_INTL("{1} found an \\c[1]{2}\\c[0]!\\wtnp[30]", pokename, itemname))
    else
      pbMessage(_INTL("{1} found a \\c[1]{2}\\c[0]!\\wtnp[30]", pokename, itemname))
    end
    pbMessage(_INTL("But your Bag is full..."))
    return false
  end
  #-----------------------------------------------------------------------------
  # Refresh Following Pokemon's visibility when Following the player
  #-----------------------------------------------------------------------------
  def self.refresh_internal
    if !FollowingPkmn.can_check? || !FollowingPkmn.get || !$PokemonGlobal.follower_toggled
      @@can_refresh = false
      return
    end
    refresh = false
    first_pkmn = $Trainer.first_able_pokemon
    if first_pkmn
      refresh = Events.FollowerRefresh.trigger(first_pkmn)
      refresh = true if refresh == -1
    end
    @@can_refresh = refresh
  end
  #-----------------------------------------------------------------------------
  # Script Command for getting the Following Pokemon Dependent event
  #-----------------------------------------------------------------------------
  def self.get
    return if !FollowingPkmn.can_check?
    $PokemonGlobal.dependentEvents.each_with_index do |event, i|
      next if !event[8][/FollowerPkmn/]
      return $PokemonTemp.dependentEvents.realEvents[i]
    end
    return nil
  end
  #-----------------------------------------------------------------------------
  # Raises The Current Following Pokemon's Happiness by 3-5 and
  # checks for hold item
  #-----------------------------------------------------------------------------
  def self.increase_time
    return if !FollowingPkmn.can_check?
    $PokemonGlobal.time_taken += 1
    friendship_time = FollowingPkmn::FRIENDSHIP_TIME_TAKEN * Graphics.frame_rate
    item_time = FollowingPkmn::ITEM_TIME_TAKEN * Graphics.frame_rate
    $Trainer.first_able_pokemon.changeHappiness("levelup") if ($PokemonGlobal.time_taken % friendship_time) == 0
    $PokemonGlobal.follower_hold_item = true if ($PokemonGlobal.time_taken > item_time)
  end
  #-----------------------------------------------------------------------------
  # Checks whether Following Pokemon data should be accessed or no
  #-----------------------------------------------------------------------------
  def self.can_check?
    return false if !$PokemonTemp || !$PokemonGlobal || !$Trainer ||
              !$PokemonTemp.respond_to?(:dependentEvents) || !$PokemonTemp.dependentEvents ||
              !$PokemonGlobal.respond_to?(:dependentEvents) || !$PokemonGlobal.dependentEvents ||
              !$Trainer.respond_to?(:party) || !$Trainer.party
    return true
  end
  #-----------------------------------------------------------------------------
end
