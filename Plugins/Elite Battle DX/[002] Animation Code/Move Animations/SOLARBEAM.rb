#-------------------------------------------------------------------------------
#  Solar Beam
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:SOLARBEAM) do
  if @hitNum == 1
    EliteBattle.playMoveAnimation(:SOLARBEAM_CHARGE, @scene, @userIndex, @targetIndex)
  elsif @hitNum == 0
    EliteBattle.playMoveAnimation(:SOLARBEAM_ATK, @scene, @userIndex, @targetIndex)
  end
end

EliteBattle.defineMoveAnimation(:SOLARBEAM_CHARGE) do
  vector = @scene.getRealVector(@userIndex, @userIsPlayer)
  factor = @userIsPlayer ? 2 : 1
  # set up animation
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.black)
  fp["bg"].opacity = 0
  for i in 0...12
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb195")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 50
  end
  k = 0
  c = [Tone.new(211,186,3),Tone.new(0,0,0)]
  # start animation
  @sprites["battlebg"].defocus
  @vector.set(vector)
  for i in 0...128
    cx, cy = @userSprite.getCenter
    for j in 0...12
      if fp["#{j}"].opacity == 0
        r = rand(2)
        fp["#{j}"].zoom_x = factor*(r==0 ? 1 : 0.5)
        fp["#{j}"].zoom_y = factor*(r==0 ? 1 : 0.5)
        x, y = randCircleCord(64*factor)
        fp["#{j}"].x = cx - 64*factor*@userSprite.zoom_x + x*@userSprite.zoom_x
        fp["#{j}"].y = cy - 64*factor*@userSprite.zoom_y + y*@userSprite.zoom_y
      end
      next if j>(i/4)
      x2 = cx
      y2 = cy
      x0 = fp["#{j}"].x
      y0 = fp["#{j}"].y
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].zoom_x -= fp["#{j}"].zoom_x*0.1
      fp["#{j}"].zoom_y -= fp["#{j}"].zoom_y*0.1
      if i >= 96
        fp["#{j}"].opacity -= 35
      elsif (x2 - x0)*0.1 < 1 && (y2 - y0)*0.1 < 1
        fp["#{j}"].opacity = 0
      else
        fp["#{j}"].opacity += 35
      end
    end
    if i < 96
      fp["bg"].opacity += 5 if fp["bg"].opacity < 255*0.6
    else
      fp["bg"].opacity -= 5
    end
    if i < 112
      if i%16 == 0
        k += 1
        k = 0 if k > 1
      end
      @userSprite.tone.red += (c[k].red - @userSprite.tone.red)*0.2
      @userSprite.tone.green += (c[k].green - @userSprite.tone.green)*0.2
      @userSprite.tone.blue += (c[k].blue - @userSprite.tone.blue)*0.2
    end
    pbSEPlay("Anim/Absorb2",100) if i == 16
    pbSEPlay("Anim/Saint8",70) if i == 16
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @userSprite.tone = Tone.new(0,0,0)
  @vector.reset
  pbDisposeSpriteHash(fp)
end

EliteBattle.defineMoveAnimation(:SOLARBEAM_ATK) do
  # set up animation
  fp = {}; rndx = []; rndy = []
  dx = []; dy = []
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.black)
  fp["bg"].opacity = 0
  for i in 0...72
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb195")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 19
    rndx.push(rand(64))
    rndy.push(rand(64))
    dx.push(0)
    dy.push(0)
  end
  shake = 4
  # start animation
  pbSEPlay("Anim/Refresh",150)
  @sprites["battlebg"].defocus
  for i in 0...96
    pbSEPlay("Anim/Psych Up",80) if i == 48
    ax, ay = @userSprite.getAnchor
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...72
      if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
        dx[j] = ax - 32*@userSprite.zoom_x*0.5 + rndx[j]*@userSprite.zoom_x*0.5
        dy[j] = ay - 32*@userSprite.zoom_y*0.5 + rndy[j]*@userSprite.zoom_y*0.5
        fp["#{j}"].x = dx[j]
        fp["#{j}"].y = dy[j]
      end
      next if j>(i)
      x2 = cx - 32*@targetSprite.zoom_x + rndx[j]*@targetSprite.zoom_x
      y2 = cy - 32*@targetSprite.zoom_y + rndy[j]*@targetSprite.zoom_y
      x0 = dx[j]
      y0 = dy[j]
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].opacity += 32
      nextx = fp["#{j}"].x + (x2 - x0)*0.1
      nexty = fp["#{j}"].y + (y2 - y0)*0.1
      if !@targetIsPlayer
        fp["#{j}"].z = @targetSprite.z - 1 if nextx > cx && nexty < cy
      else
        fp["#{j}"].z = @targetSprite.z + 1 if nextx < cx && nexty > cy
      end
    end
    fp["bg"].opacity += 10 if fp["bg"].opacity < 255*0.75
    if i >= 32
      @targetSprite.tone.red += 5.4 if @targetSprite.tone.red < 194.4
      @targetSprite.tone.green += 3.4 if @targetSprite.tone.green < 122.4
      @targetSprite.tone.blue += 0.15 if @targetSprite.tone.blue < 5.4
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    @vector.set(EliteBattle.get_vector(:DUAL)) if i == 24
    @vector.inc = 0.1 if i == 24
    @scene.wait(1,true)
  end
  20.times do
    @targetSprite.tone.red -= 9.7
    @targetSprite.tone.green -= 6.1
    @targetSprite.tone.blue -= 0.27
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
  @vector.reset
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
