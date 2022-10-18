class PokeBattle_Simulated_Battle
  def pbGetOwnerName(idxBattler)
    owner = pbGetOwnerFromBattlerIndex(idxBattler)
    return pbGetNameOf(owner,opposes?(idxBattler))
  end
  
  # For choosing a replacement Pokémon when prompted in the middle of other
  # things happening (U-turn, Baton Pass, in def pbSwitch).
  def pbSwitchInBetween(idxBattler,checkLaxOnly=false,canCancel=false)
    return @battleAI.pbDefaultChooseNewEnemy(idxBattler,pbParty(idxBattler))
  end
  
  def pbOwnedByPlayer?(idxBattler)
    return false if opposes?(idxBattler)
    return pbGetOwnerIndexFromBattlerIndex(idxBattler)==0 && !@controlPlayer
  end

end