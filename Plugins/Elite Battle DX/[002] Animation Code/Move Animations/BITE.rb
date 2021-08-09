#-------------------------------------------------------------------------------
#  Bite
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:BITE) do
  # set up animation
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(66,60,81))
  fp["bg"].opacity = 0
  fp["fang1"] = Sprite.new(@viewport)
  fp["fang1"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb028")
  fp["fang1"].ox = fp["fang1"].bitmap.width/2
  fp["fang1"].oy = fp["fang1"].bitmap.height - 20
  fp["fang1"].opacity = 0
  fp["fang1"].z = 41
  fp["fang2"] = Sprite.new(@viewport)
  fp["fang2"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb028")
  fp["fang2"].ox = fp["fang1"].bitmap.width/2
  fp["fang2"].oy = fp["fang1"].bitmap.height - 20
  fp["fang2"].opacity = 0
  fp["fang2"].z = 40
  fp["fang2"].angle = 180
  shake = 4
  # start animation
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @sprites["battlebg"].defocus
  for i in 0...72
    cx, cy = @targetSprite.getCenter(true)
    fp["fang1"].x = cx; fp["fang1"].y = cy
    fp["fang1"].zoom_x = @targetSprite.zoom_x; fp["fang1"].zoom_y = @targetSprite.zoom_y
    fp["fang2"].x = cx; fp["fang2"].y = cy
    fp["fang2"].zoom_x = @targetSprite.zoom_x; fp["fang2"].zoom_y = @targetSprite.zoom_y
    if i.between?(20,29)
      fp["fang1"].opacity += 5
      fp["fang1"].oy += 2
      fp["fang2"].opacity += 5
      fp["fang2"].oy += 2
    elsif i.between?(30,40)
      fp["fang1"].opacity += 25.5
      fp["fang1"].oy -= 4
      fp["fang2"].opacity += 25.5
      fp["fang2"].oy -= 4
    else
      fp["fang1"].opacity -= 26
      fp["fang1"].oy += 2
      fp["fang2"].opacity -= 26
      fp["fang2"].oy += 2
    end
    if i==32
      pbSEPlay("Anim/Super Fang")
    end
    fp["bg"].opacity += 4 if  i < 40
    if i >= 40
      fp["bg"].opacity -= 10 if i >= 56
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
