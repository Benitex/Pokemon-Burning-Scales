#===============================================================================
#  Class addition to play Low HP Battle BGM
#===============================================================================
class PokeBattle_Scene
  attr_accessor :custom_bgm
  #-----------------------------------------------------------------------------
  #  function used to play the Low HP Battle BGM
  #-----------------------------------------------------------------------------
  def setBGMLowHP(state)
    # exit if global setting is off
    return if !EliteBattle::USE_LOW_HP_BGM
    # check for state if already toggled
    if !@lowHPBGM && state
      # exit if battler HP is not low enough
      skip = true
      @battle.battlers.each_with_index do |b, i|
        next if !b || i%2 != 0
        skip = false if @battle.battlers[i].lowHP?
      end
      return if skip
      # change BGM
      $game_system.bgm_memorize
      pbBGMPlay("EBDX/Low HP Battle")
      @lowHPBGM = true
    elsif @lowHPBGM && !state
      # exit if one of the battlers is at low HP
      @battle.battlers.each_with_index do |b, i|
        next if !b || i%2 != 0
        return if @battle.battlers[i].lowHP?
      end
      # reset BGM state
      if self.custom_bgm.nil?
        $game_system.bgm_restore
      else
        pbBGMPlay(self.custom_bgm)
      end
      @lowHPBGM = false
    end
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  Low HP quantifier for battlers
#===============================================================================
class PokeBattle_Battler
  #-----------------------------------------------------------------------------
  #  check if HP is below defined threshold
  #-----------------------------------------------------------------------------
  def lowHP?
    return (self.hp <= self.totalhp*0.25 && self.hp > 0)
  end
  #-----------------------------------------------------------------------------
end
