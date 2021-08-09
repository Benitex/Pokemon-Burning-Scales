#===============================================================================
#  Used for the Illusion ability
#===============================================================================
# Different methods used to obtain pokemon data from battlers
# Added for Illusion ability compatibility
def getBattlerPokemon(battler)
  battler.displayPokemon
end
#===============================================================================
#  additional functions for quick access to proper objects
#===============================================================================
def getBattlerAltitude(battler)
  dat = GameData::Species.get(battler.displaySpecies)
  ret = (dat.front_sprite_altitude rescue 0)
  ret = 0 if ret.nil?
  ret = EliteBattle.get_data(battler.displaySpecies, :Species, :ALTITUDE, (battler.displayForm rescue 0))
  return ret
end
#-------------------------------------------------------------------------------
def playBattlerCry(battler)
  pokemon = battler.displayPokemon
  pokemon = :BIDOOF if GameData::Species.exists?(:BIDOOF) && defined?(firstApr?) && firstApr?
  cry = GameData::Species.cry_filename_from_pokemon(pokemon)
  pbSEPlay(cry)
end
#-------------------------------------------------------------------------------
def shinyBattler?(battler)
  return battler.shiny? || battler.superShiny?
end
#-------------------------------------------------------------------------------
def playerBattler?(battler)
  return battler.index%2 == 0
end
#===============================================================================
#  Class override for Illusion ability as well as text overrides
#===============================================================================
class PokeBattle_Battler
  attr_accessor :thisMoveHits
  #-----------------------------------------------------------------------------
  #  battler name
  #-----------------------------------------------------------------------------
  alias name_ebdx name unless self.method_defined?(:name_ebdx)
  def name
    # sauce
    return _INTL("Bidoof") if GameData::Species.exists?(:BIDOOF) && defined?(firstApr?) && firstApr?
    return self.name_ebdx
  end
  #-----------------------------------------------------------------------------
  #  check if super shiny
  #-----------------------------------------------------------------------------
  def superShiny?
    return @effects[PBEffects::Illusion].superShiny? if @effects[PBEffects::Illusion]
    return @pokemon && @pokemon.superShiny?
  end
  #-----------------------------------------------------------------------------
  #  check if HP is below defined threshold
  #-----------------------------------------------------------------------------
  def lowHP?
    return (self.hp <= self.totalhp*0.25 && self.hp > 0)
  end
  #-----------------------------------------------------------------------------
  #  compatibility for multihit moves
  #-----------------------------------------------------------------------------
  alias pbProcessMoveHit_ebdx pbProcessMoveHit unless self.method_defined?(:pbProcessMoveHit_ebdx)
  def pbProcessMoveHit(*args)
    @thisMoveHits = args[0].respond_to?(:ebNumHits) ? args[0].ebNumHits : args[0].pbNumHits(args[1], args[2])
    ret = pbProcessMoveHit_ebdx(*args)
    @thisMoveHits = nil
    # return final output
    return ret
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  Compatibility for generic multihit moves
#===============================================================================
class PokeBattle_Move_0C0
  # alias original class
  alias pbNumHits_ebdx pbNumHits unless self.method_defined?(:pbNumHits_ebdx)
  def pbNumHits(*args)
    @ebNumHits = pbNumHits_ebdx(*args)
    return @ebNumHits
  end
  # EBDX override
  def ebNumHits; return @ebNumHits; end
  #-----------------------------------------------------------------------------
end
