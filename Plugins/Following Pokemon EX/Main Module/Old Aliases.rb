def follower_move_route(commands, waitComplete = false)
  echoln "'follower_move_route' will be removed in later versions of Following Pokemon EX. Use 'FollowingPkmn.move_route' instead."
  return FollowingPkmn.move_route(commands, waitComplete)
end


def pbToggleFollowingPokemon(forced = nil, anim = nil)
  echoln "'pbToggleFollowingPokemon' will be removed in later versions of Following Pokemon EX. Use 'FollowingPkmn.toggle' instead."
  return FollowingPkmn.toggle(forced, anim)
end


def pbPokemonFollow(x)
  echoln "'pbPokemonFollow' will be removed in later versions of Following Pokemon EX. Use 'FollowingPkmn.start_following' instead."
  return FollowingPkmn.start_following(x)
end


def pbTalkToFollower
  echoln "'pbTalkToFollower' will be removed in later versions of Following Pokemon EX. Use 'FollowingPkmn.talk' instead."
  return FollowingPkmn.talk
end


def pbGetFollowerDependentEvent
  echoln "'pbGetFollowerDependentEvent' will be removed in later versions of Following Pokemon EX. Use 'FollowingPkmn.get' instead."
  return FollowingPkmn.get
end



def pbPokemonFound(item, quantity = 1, message = "")
  echoln "'pbPokemonFound' will be removed in later versions of Following Pokemon EX. Use 'FollowingPkmn.item' instead."
  return FollowingPkmn.item(item, quantity, message)
end


class DependentEvents
  def can_refresh?
    echoln "'$PokemonTemp.dependentEvents.can_refresh?' will be removed in later versions of Following Pokemon EX. Use 'FollowingPkmn.active?' instead."
    return FollowingPkmn.active?
  end

  def add_following_time
    echoln "'$PokemonTemp.dependentEvents.add_following_time' will be removed in later versions of Following Pokemon EX. Use 'FollowingPkmn.increase_time' instead."
    FollowingPkmn.increase_time
  end

  def refresh_sprite(anim = false)
    echoln "'$PokemonTemp.dependentEvents.refresh_sprite' will be removed in later versions of Following Pokemon EX. Use 'FollowingPkmn.refresh' instead."
    return FollowingPkmn.refresh(anim)
  end
end
