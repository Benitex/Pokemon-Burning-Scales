#-------------------------------------------------------------------------------
#  Psychic
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:PSYCHIC) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  factor = @targetIsPlayer ? 2 : 1.5
  # set up animation
  fp = {}
  fp["bg"] = ScrollingSprite.new(@viewport)
  fp["bg"].speed = 6
  fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/eb452",true)
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  fp["bg"].oy = fp["bg"].src_rect.height/2
  fp["bg"].y = @viewport.height/2
  shake = 8
  zoom = -1
  # start animation
  @vector.set(vector)
  @sprites["battlebg"].defocus
  for i in 0...72
    pbSEPlay("EBDX/Anim/psychic1",80) if i == 40
    pbSEPlay("EBDX/Anim/psychic2",80) if i == 62
    if i < 10
      fp["bg"].opacity += 25.5
    elsif i < 20
      fp["bg"].color.alpha -= 25.5
    elsif i >= 62
      fp["bg"].color.alpha += 25.5
      @targetSprite.tone.red += 18
      @targetSprite.tone.green += 18
      @targetSprite.tone.blue += 18
      @targetSprite.zoom_x += 0.04*factor
      @targetSprite.zoom_y += 0.04*factor
    elsif i >= 40
      @targetSprite.ox += shake
      shake = -8 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 4
      shake = 8 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 4
      @targetSprite.still
    end
    zoom *= -1 if i%2 == 0
    fp["bg"].update
    fp["bg"].zoom_y += 0.04*zoom
    @scene.wait(1,(i<62))
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  10.times do
    @targetSprite.tone.red -= 18
    @targetSprite.tone.green -= 18
    @targetSprite.tone.blue -= 18
    @targetSprite.zoom_x -= 0.04*factor
    @targetSprite.zoom_y -= 0.04*factor
    @targetSprite.still
    @scene.wait
  end
  @scene.wait(8)
  @vector.reset if !@multiHit
  10.times do
    fp["bg"].opacity -= 25.5
    @targetSprite.still
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  pbDisposeSpriteHash(fp)
end
