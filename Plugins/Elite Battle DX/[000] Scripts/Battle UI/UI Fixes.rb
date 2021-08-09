#===============================================================================
#  addition for PokemonSprite class to add bitmap constraints
#===============================================================================
class PokemonSprite < SpriteWrapper
  #-----------------------------------------------------------------------------
  #  boxes in the bitmap
  #-----------------------------------------------------------------------------
  def constrict(amt, deanimate = true)
    @_iconbitmap.constrict = amt if @_iconbitmap.respond_to?(:constrict)
    @_iconbitmap.setSpeed(0) if @_iconbitmap.respond_to?(:setSpeed) && deanimate
    @_iconbitmap.deanimate if @_iconbitmap.respond_to?(:deanimate) && deanimate
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  Fix for form page misalignment
#===============================================================================
class PokemonPokedexInfo_Scene
  #-----------------------------------------------------------------------------
  #  updates y positioning
  #-----------------------------------------------------------------------------
  alias pbUpdateDummyPokemon_ebdx pbUpdateDummyPokemon unless self.method_defined?(:pbUpdateDummyPokemon_ebdx)
  def pbUpdateDummyPokemon
    pbUpdateDummyPokemon_ebdx
    @sprites["infosprite"].constrict(208)
    @sprites["formfront"].constrict(200) if @sprites["formfront"]
    if @sprites["formback"]
      @sprites["formback"].constrict(200)
      @sprites["formback"].setOffset(PictureOrigin::Center)
      @sprites["formback"].y = @sprites["formfront"].y if @sprites["formfront"]
    end
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
class PokemonPokedex_Scene
  #-----------------------------------------------------------------------------
  #  restrains the sprite from overflowing out of the sprite area
  #-----------------------------------------------------------------------------
  alias setIconBitmap_ebdx setIconBitmap unless self.method_defined?(:setIconBitmap_ebdx)
  def setIconBitmap(*args)
    setIconBitmap_ebdx(*args)
    @sprites["icon"].constrict(224)
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  Fix for box storage sprite overflow
#===============================================================================
class PokemonStorageScene
  #-----------------------------------------------------------------------------
  #  restrains the sprite from overflowing out of the sprite area
  #-----------------------------------------------------------------------------
  alias pbUpdateOverlay_ebdx pbUpdateOverlay unless self.method_defined?(:pbUpdateOverlay_ebdx)
  def pbUpdateOverlay(*args)
    pbUpdateOverlay_ebdx(*args)
    @sprites["pokemon"].constrict(168)
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  Fix for summary screen sprite overflow
#===============================================================================
class PokemonSummary_Scene
  #-----------------------------------------------------------------------------
  #  restrains the sprite from overflowing out of the sprite area
  #-----------------------------------------------------------------------------
  alias pbStartScene_ebdx pbStartScene unless self.method_defined?(:pbStartScene_ebdx)
  def pbStartScene(*args)
    ret = pbStartScene_ebdx(*args)
    #@sprites["pokemon"].constrict(164, false)
  end
  alias pbChangePokemon_ebdx pbChangePokemon unless self.method_defined?(:pbChangePokemon_ebdx)
  def pbChangePokemon
    pbChangePokemon_ebdx
    #@sprites["pokemon"].constrict(164, false)
  end
end
