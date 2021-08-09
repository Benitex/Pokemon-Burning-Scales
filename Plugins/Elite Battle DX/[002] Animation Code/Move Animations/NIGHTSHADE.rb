#-------------------------------------------------------------------------------
#  Night Shade
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:NIGHTSHADE) do
  # set up animation
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.black)
  fp["bg"].opacity = 0
  factor = @userSprite.zoom_x
  shake = 2
  # play animation
  pbSEPlay("Anim/fog2", 80)
  @sprites["battlebg"].defocus
  16.times do
    fp["bg"].opacity += 8
    @userSprite.still
    @scene.wait(1,true)
  end
  for i in 0...24
    if i < 16
      @userSprite.zoom_x += 0.2*factor/8.0 if @userSprite.zoom_x < 1.2*factor
      @userSprite.zoom_y += 0.2*factor/8.0 if @userSprite.zoom_y < 1.2*factor
      @userSprite.tone.red += 8
      @userSprite.tone.green += 8
      @userSprite.tone.blue += 8
    end
    @userSprite.still
    @scene.wait
  end
  for i in 0...24
    if i < 24
      @targetSprite.ox += shake
      shake = -2 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 2 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    @targetSprite.tone.red -= 16 if i < 16
    @targetSprite.tone.green -= 16 if i < 16
    @targetSprite.tone.blue -= 16 if i < 16
    @targetSprite.still if i >= 12
    @userSprite.still
    @scene.wait
  end
  8.times do
    @userSprite.zoom_x -= 0.2*factor/8.0
    @userSprite.zoom_y -= 0.2*factor/8.0
    @userSprite.tone.red -= 16
    @userSprite.tone.green -= 16
    @userSprite.tone.blue -= 16
    @userSprite.still
    @targetSprite.still
    @scene.wait
  end
  16.times do
    @targetSprite.tone.red += 16
    @targetSprite.tone.green += 16
    @targetSprite.tone.blue += 16
    fp["bg"].opacity -= 8
    @userSprite.still
    @scene.wait
  end
  @sprites["battlebg"].focus
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
