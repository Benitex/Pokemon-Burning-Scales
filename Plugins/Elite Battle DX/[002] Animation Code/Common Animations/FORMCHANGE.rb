#===============================================================================
#  Common Animation: FORMCHANGE
#===============================================================================
EliteBattle.defineCommonAnimation(:FORMCHANGE) do | pokemon |
  #-----------------------------------------------------------------------------
  #  transition sprite
  10.times do
    @targetSprite.tone.all += 51 if @targetSprite.tone.all < 255
    @scene.wait(1)
  end
  #-----------------------------------------------------------------------------
  #  apply new Pokemon bitmap
  @targetSprite.setPokemonBitmap(pokemon[0], @targetIsPlayer)
  @targetDatabox.refresh
  @scene.wait
  #-----------------------------------------------------------------------------
  #  transition sprite
  10.times do
    @targetSprite.tone.all -= 51 if @targetSprite.tone.all > 0
    @scene.wait(1)
  end
  #-----------------------------------------------------------------------------
end
