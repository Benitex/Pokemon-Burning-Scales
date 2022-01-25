#-------------------------------------------------------------------------------
# Exposing realEvents attribute of DependentEvents
#-------------------------------------------------------------------------------
class DependentEvents
  attr_accessor :realEvents
end

#-------------------------------------------------------------------------------
# Adding a few variables to track temporary data
#-------------------------------------------------------------------------------
class Game_Temp
  # Jank fix prevent removal of Following Pokemon when starting over
  attr_accessor :starting_over
  # Jank Fix to prevent followers from moving when not needed
  attr_accessor :move_followers
  # Jank Fix to prevent followers from updating when not needed
  attr_accessor :disallow_follower_update
end


#-------------------------------------------------------------------------------
# Make sure that when starting over, the Following Pokemon method is not removed
#-------------------------------------------------------------------------------
alias __followingpkmn__pbStartOver pbStartOver unless defined?(__followingpkmn__pbStartOver)
def pbStartOver(*args)
  $game_temp.starting_over = true
  __followingpkmn__pbStartOver(*args)
  $game_temp.starting_over = false
end

alias __followingpkmn__pbRemoveDependencies pbRemoveDependencies unless defined?(__followingpkmn__pbRemoveDependencies)
def pbRemoveDependencies(*args)
  if $game_temp.starting_over
    $PokemonTemp.dependentEvents.remove_except_follower
  else
    __followingpkmn__pbRemoveDependencies(*args)
  end
  FollowingPkmn.refresh(false)
end

#-------------------------------------------------------------------------------
# Refresh Follower after Dependent Events are removed
#-------------------------------------------------------------------------------
alias __followingpkmn_pbRemoveDependency pbRemoveDependency unless defined?(__followingpkmn_pbRemoveDependency)
def pbRemoveDependency(*args)
  __followingpkmn_pbRemoveDependency(*args)
  FollowingPkmn.refresh(false)
end

alias __followingpkmn__pbRemoveDependency2 pbRemoveDependency2 unless defined?(__followingpkmn__pbRemoveDependency2)
def pbRemoveDependency2(*args)
  __followingpkmn__pbRemoveDependency2(*args)
  FollowingPkmn.refresh(false)
end

def pbRemoveDependenciesExceptFollower
  $PokemonTemp.dependentEvents.remove_except_follower
end


#-------------------------------------------------------------------------------
# Edit the dependent event check to account for followers
#-------------------------------------------------------------------------------
class Game_Player
  def pbHasDependentEvents?
    return false if FollowingPkmn.get && $PokemonGlobal.dependentEvents.length == 1
    return $PokemonGlobal.dependentEvents.length>0
  end
end

#-------------------------------------------------------------------------------
# Functions for handling the work that the variables did earlier
# Also track new data like the current surfing and diving follower
#-------------------------------------------------------------------------------
class PokemonGlobalMetadata
  attr_reader   :follower_toggled
  attr_accessor :call_refresh
  attr_accessor :time_taken
  attr_accessor :follower_hold_item
  attr_accessor :current_surfing
  attr_accessor :current_diving

  def follower_toggled=(value)
    @follower_toggled = value
    FollowingPkmn.refresh_internal
  end

  def call_refresh
    @call_refresh = [false, false] if !@call_refresh
    return @call_refresh
  end

  def call_refresh=(value)
    ret = value
    ret = [value, false] if !value.is_a?(Array)
    @call_refresh = ret
  end

  def time_taken
    @time_taken = 0 if !@time_taken
    return @time_taken
  end
end
