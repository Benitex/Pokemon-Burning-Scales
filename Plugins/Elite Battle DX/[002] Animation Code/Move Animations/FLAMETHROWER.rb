#-------------------------------------------------------------------------------
#  Flamethrower
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:FLAMETHROWER) do
  itself = (@userIndex==@targetIndex)
  # set up animation
  fp = {}
  rndx = []
  rndy = []
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(130,52,42))
  fp["bg"].opacity = 0
  for i in 0...16
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb136")
    fp["#{i}"].src_rect.set(0,101*rand(3),53,101)
    fp["#{i}"].ox = 26
    fp["#{i}"].oy = 101
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = (@targetIsPlayer ? 29 : 19)
    rndx.push(rand(64))
    rndy.push(rand(64))
  end
  shake = 2
  # start animation
  @sprites["battlebg"].defocus
  for i in 0...132
    ax, ay = @userSprite.getAnchor
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...16
      if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
        fp["#{j}"].zoom_x = @userSprite.zoom_x
        fp["#{j}"].zoom_y = @userSprite.zoom_y
        fp["#{j}"].x = ax
        fp["#{j}"].y = ay + 50*@userSprite.zoom_y
      end
      next if j>(i/4)
      x2 = cx - 32*@targetSprite.zoom_x + rndx[j]*@targetSprite.zoom_x
      y2 = cy - 32*@targetSprite.zoom_y + rndy[j]*@targetSprite.zoom_y + 50*@targetSprite.zoom_y
      x0 = fp["#{j}"].x
      y0 = fp["#{j}"].y
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].zoom_x -= (fp["#{j}"].zoom_x - @targetSprite.zoom_x)*0.1
      fp["#{j}"].zoom_y -= (fp["#{j}"].zoom_y - @targetSprite.zoom_y)*0.1
      fp["#{j}"].src_rect.x += 53 if i%4==0
      fp["#{j}"].src_rect.x = 0 if fp["#{j}"].src_rect.x >= fp["#{j}"].bitmap.width
      if (x2 - x0)*0.1 < 1 && (y2 - y0)*0.1 < 1
        fp["#{j}"].opacity -= 8
        fp["#{j}"].tone.gray += 8
        fp["#{j}"].tone.red -= 2; fp["#{j}"].tone.green -= 2; fp["#{j}"].tone.blue -= 2
        fp["#{j}"].zoom_x -= 0.02
        fp["#{j}"].zoom_y += 0.04
      else
        fp["#{j}"].opacity += 12
      end
    end
    fp["bg"].opacity += 5 if fp["bg"].opacity < 255*0.5
    pbSEPlay("Anim/Fire2",80) if i%12==0 && i <= 96
    pbSEPlay("Anim/Smokescreen",120) if i==84
    if i >= 96
      @targetSprite.tone.red += 2.4*2 if @targetSprite.tone.red < 48*2
      @targetSprite.tone.green -= 1.2*2 if @targetSprite.tone.green > -24*2
      @targetSprite.tone.blue -= 2.4*2 if @targetSprite.tone.blue > -48*2
      @targetSprite.ox += shake
      shake = -2 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 2 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    @vector.set(EliteBattle.get_vector(:DUAL)) if i == 24
    @vector.inc = 0.1 if i == 24
    @scene.wait(1,true)
  end
  20.times do
    @targetSprite.tone.red -= 2.4*2
    @targetSprite.tone.green += 1.2*2
    @targetSprite.tone.blue += 2.4*2
    @targetSprite.ox += shake
    shake = -2 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
    shake = 2 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
    @targetSprite.still
    fp["bg"].opacity -= 15
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
