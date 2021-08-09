#===============================================================================
#  Common Animation: ROAR
#===============================================================================
EliteBattle.defineCommonAnimation(:ROAR) do
  #-----------------------------------------------------------------------------
  fp = {}
  #-----------------------------------------------------------------------------
  #  vector config
  back = !@battle.opposes?(@targetIndex)
  @vector.set(@scene.getRealVector(@targetIndex, back))
  @scene.wait(16, true)
  factor = @targetSprite.zoom_x
  #-----------------------------------------------------------------------------
  # animate impact
  fp["impact"] = Sprite.new(@viewport)
  fp["impact"].bitmap = pbBitmap("Graphics/EBDX/Pictures/impact")
  fp["impact"].center!(true)
  fp["impact"].z = 999
  fp["impact"].opacity = 0
  playBattlerCry(@battlers[@targetIndex])
  k = -2
  for i in 0...24
    fp["impact"].opacity += 64
    fp["impact"].angle += 180 if i%4 == 0
    fp["impact"].mirror = !fp["impact"].mirror if i%4 == 2
    k *= -1 if i%4 == 0
    @viewport.color.alpha -= 16 if i > 1
    @scene.moveEntireScene(0,k,true,true)
    @scene.wait(1,false)
  end
  for i in 0...16
    fp["impact"].opacity -= 64
    fp["impact"].angle += 180 if i%4 == 0
    fp["impact"].mirror = !fp["impact"].mirror if i%4 == 2
    @scene.wait
  end
  #-----------------------------------------------------------------------------
  fp["impact"].dispose
  @vector.reset
  @scene.wait(16, true)
  #-----------------------------------------------------------------------------
end
