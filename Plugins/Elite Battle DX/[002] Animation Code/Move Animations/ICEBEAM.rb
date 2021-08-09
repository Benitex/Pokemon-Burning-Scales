#-------------------------------------------------------------------------------
#  Ice Beam
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:ICEBEAM) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  factor = @targetIsPlayer ? 2 : 1
  @viewport.color = Color.new(255,255,255,155)
  # set up animation
  fp = {}; rndx = []; rndy = []; crndx = []; crndy = []; dx = []; dy = []
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(100,128,142))
  fp["bg"].opacity = 0
  for i in 0...16
    fp["c#{i}"] = Sprite.new(@viewport)
    fp["c#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb250")
    fp["c#{i}"].ox = fp["c#{i}"].bitmap.width/2
    fp["c#{i}"].oy = fp["c#{i}"].bitmap.height/2
    fp["c#{i}"].opacity = 0
    fp["c#{i}"].z = 19
    crndx.push(rand(64))
    crndy.push(rand(64))
  end
  for i in 0...72
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb243")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 19
    rndx.push(rand(16))
    rndy.push(rand(16))
    dx.push(0)
    dy.push(0)
  end
  @sprites["battlebg"].defocus
  # start animation
  for i in 0...96
    pbSEPlay("Anim/Ice8") if i == 12
    ax, ay = @userSprite.getAnchor
    cx, cy = @targetSprite.getCenter(true)
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
      fp["#{j}"].zoom_x = @targetIsPlayer ? @userSprite.zoom_x : @targetSprite.zoom_x
      fp["#{j}"].zoom_y = @targetIsPlayer ? @userSprite.zoom_y : @targetSprite.zoom_y
      fp["#{j}"].opacity += 32
      fp["#{j}"].angle = -Math.atan(1.0*(y2-y0)/(x2-x0))*180/Math::PI + (rand(4)==0 ? 180 : 0)
      nextx = fp["#{j}"].x + (x2 - x0)*0.05
      nexty = fp["#{j}"].y + (y2 - y0)*0.05
      if !@targetIsPlayer
        fp["#{j}"].z = @targetSprite.z - 1 if nextx > cx && nexty < cy
        fp["#{j}"].visible = false if nextx > cx && nexty < cy
      else
        fp["#{j}"].visible = false if nextx < cx && nexty > cy
      end
    end
    pbSEPlay("Anim/Ice1") if i>32 && (i-32)%4==0
    for j in 0...16
      if fp["c#{j}"].opacity == 0 && fp["c#{j}"].tone.gray == 0
        fp["c#{j}"].zoom_x = factor*@targetSprite.zoom_x
        fp["c#{j}"].zoom_y = factor*@targetSprite.zoom_x
        fp["c#{j}"].x = cx
        fp["c#{j}"].y = cy
      end
      next if j>((i-12)/4)
      next if i<12
      x2 = cx - 32*@targetSprite.zoom_x + crndx[j]*@targetSprite.zoom_x
      y2 = cy - 32*@targetSprite.zoom_y + crndy[j]*@targetSprite.zoom_y
      x0 = fp["c#{j}"].x
      y0 = fp["c#{j}"].y
      fp["c#{j}"].x += (x2 - x0)*0.2
      fp["c#{j}"].y += (y2 - y0)*0.2
      fp["c#{j}"].angle += 2
      if (x2 - x0)*0.2 < 1 && (y2 - y0)*0.2 < 1
        fp["c#{j}"].opacity -= 24
        fp["c#{j}"].tone.gray += 8
        fp["c#{j}"].angle += 2
      else
        fp["c#{j}"].opacity += 35
      end
    end
    fp["bg"].opacity += 5 if fp["bg"].opacity < 255*0.5
    if i >= 32
      @targetSprite.tone.red += 5.4 if @targetSprite.tone.red < 108
      @targetSprite.tone.green += 6.4 if @targetSprite.tone.green < 128
      @targetSprite.tone.blue += 8 if @targetSprite.tone.blue < 160
      @targetSprite.still
    end
    @vector.set(vector) if i == 24
    @vector.inc = 0.1 if i == 24
    @viewport.color.alpha -= 5 if @viewport.color.alpha > 0
    @scene.wait(1,true)
  end
  20.times do
    @targetSprite.tone.red -= 5.4
    @targetSprite.tone.green -= 6.4
    @targetSprite.tone.blue -= 8
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
