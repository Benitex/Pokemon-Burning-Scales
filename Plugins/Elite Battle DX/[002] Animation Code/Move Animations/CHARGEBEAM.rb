#-------------------------------------------------------------------------------
#  Charge Beam
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:CHARGEBEAM) do
  # Charging animation
  EliteBattle.playMoveAnimation(:CHARGE, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, true)
  @viewport.color = Color.new(255,255,255,255)
  # set up animation
  fp = {}
  rndx = []
  rndy = []
  dx = []
  dy = []
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.black)
  fp["bg"].opacity = 255*0.75
  for i in 0...72
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb078")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 19
    rndx.push(rand(16))
    rndy.push(rand(16))
    dx.push(0)
    dy.push(0)
  end
  shake = 4
  # start animation
  pbSEPlay("Anim/Flash")
  pbSEPlay("Anim/Pollen")
  for i in 0...96
    pbSEPlay("Anim/Paralyze1") if i%8==0
    cx, cy = @targetSprite.getCenter(true)
    ax, ay = @userSprite.getAnchor
    for j in 0...72
      if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
        dx[j] = ax - 8*@userSprite.zoom_x*0.5 + rndx[j]*@userSprite.zoom_x*0.5
        dy[j] = ay - 8*@userSprite.zoom_y*0.5 + rndy[j]*@userSprite.zoom_y*0.5
        fp["#{j}"].x = dx[j]
        fp["#{j}"].y = dy[j]
      end
      next if j>(i)
      x2 = cx - 8*@targetSprite.zoom_x*0.5 + rndx[j]*@targetSprite.zoom_x*0.5
      y2 = cy - 8*@targetSprite.zoom_y*0.5 + rndy[j]*@targetSprite.zoom_y*0.5
      x0 = dx[j]
      y0 = dy[j]
      fp["#{j}"].x += (x2 - x0)*0.05
      fp["#{j}"].y += (y2 - y0)*0.05
      fp["#{j}"].opacity += 32
      fp["#{j}"].angle = -Math.atan(1.0*(y2-y0)/(x2-x0))*180/Math::PI + (rand(4)==0 ? 180 : 0)
      nextx = fp["#{j}"].x + (x2 - x0)*0.05
      nexty = fp["#{j}"].y + (y2 - y0)*0.05
      if !@targetIsPlayer
        fp["#{j}"].visible = false if nextx > cx && nexty < cy
      else
        fp["#{j}"].visible = false if nextx < cx && nexty > cy
      end
    end
    if i >= 32
      cx, cy = @targetSprite.getCenter(true)
      @targetSprite.tone.red += 8 if @targetSprite.tone.red < 160
      @targetSprite.tone.green += 6.4 if @targetSprite.tone.green < 128
      @targetSprite.tone.blue += 6.4 if @targetSprite.tone.blue < 128
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer)) if i == 24
    @vector.inc = 0.1 if i == 24
    @viewport.color.alpha -= 5 if @viewport.color.alpha > 0
    @scene.wait(1,true)
  end
  20.times do
    cx, cy = @targetSprite.getCenter(true)
    @targetSprite.tone.red -= 8
    @targetSprite.tone.green -= 6.4
    @targetSprite.tone.blue -= 6.4
    @targetSprite.ox += shake
    shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
    shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
    @targetSprite.still
    fp["bg"].opacity -= 15
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @targetSprite.tone = Tone.new(0,0,0)
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
