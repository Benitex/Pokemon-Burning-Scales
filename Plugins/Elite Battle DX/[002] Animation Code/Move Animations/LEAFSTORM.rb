#-------------------------------------------------------------------------------
#  Leaf Storm
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:LEAFSTORM) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  factor = @userIsPlayer ? 2 : 1
  # set up animation
  fp = {}
  rndx = []; prndx = []
  rndy = []; prndy = []
  rangl = []
  dx = []
  dy = []
  fp["bg"] = ScrollingSprite.new(@viewport)
  fp["bg"].speed = 64
  fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/eb191_bg")
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  for i in 0...128
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb191_2")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].visible = false
    fp["#{i}"].z = 50
    rndx.push(rand(256)); prndx.push(rand(72))
    rndy.push(rand(256)); prndy.push(rand(72))
    rangl.push(rand(9))
    dx.push(0)
    dy.push(0)
  end
  fp["cir"] = Sprite.new(@viewport)
  fp["cir"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb191")
  fp["cir"].ox = fp["cir"].bitmap.width/2
  fp["cir"].oy = fp["cir"].bitmap.height/2
  fp["cir"].z = 50
  fp["cir"].mirror = @userIsPlayer
  fp["cir"].zoom_x = (@targetIsPlayer ? 1 : 1.5)*0.5
  fp["cir"].zoom_y = (@targetIsPlayer ? 1 : 1.5)*0.5
  fp["cir"].opacity = 0
  for i in 0...8
    fp["#{i}s"] = Sprite.new(@viewport)
    fp["#{i}s"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb191_3")
    fp["#{i}s"].ox = fp["#{i}s"].bitmap.width/2
    fp["#{i}s"].oy = fp["#{i}s"].bitmap.height + 8*factor
    fp["#{i}s"].angle = rand(360)
    r = rand(2)
    fp["#{i}s"].zoom_x = (r==0 ? 0.5 : 1)*factor
    fp["#{i}s"].zoom_y = (r==0 ? 0.5 : 1)*factor
    fp["#{i}s"].visible = false
    fp["#{i}s"].opacity = 255 - rand(101)
    fp["#{i}s"].z = 50
  end
  shake = 4
  k = 0
  # start animation
  @vector.set(vector2)
  @sprites["battlebg"].defocus
  for i in 0...30
    if i < 10
      fp["bg"].opacity += 25.5
    elsif i < 20
      fp["bg"].color.alpha -= 25.5
    else
      fp["cir"].x, fp["cir"].y = @userSprite.getCenter
      fp["cir"].angle += 16*(@userIsPlayer ? -1 : 1)
      fp["cir"].opacity += 25.5
      fp["cir"].zoom_x += (@targetIsPlayer ? 1 : 1.5)*0.05
      fp["cir"].zoom_y += (@targetIsPlayer ? 1 : 1.5)*0.05
      k += 1 if i%4==0; k = 0 if k > 1
      fp["cir"].tone = [Tone.new(0,0,0),Tone.new(155,155,155)][k]
    end
    pbSEPlay("EBDX/Anim/grass2") if i == 20
    fp["bg"].update
    @scene.wait(1,true)
  end
  pbSEPlay("EBDX/Anim/wind1",90)
  for i in 0...96
    pbSEPlay("EBDX/Anim/grass1",60) if i%3==0 && i < 64
    ax, ay = @userSprite.getCenter
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...128
      next if j>(i*2)
      if !fp["#{j}"].visible
        dx[j] = ax - 46*@userSprite.zoom_x*0.5 + prndx[j]*@userSprite.zoom_x*0.5
        dy[j] = ay - 46*@userSprite.zoom_y*0.5 + prndy[j]*@userSprite.zoom_y*0.5
        fp["#{j}"].x = dx[j]
        fp["#{j}"].y = dy[j]
        fp["#{j}"].visible = true
      end
      x0 = ax - 46*@userSprite.zoom_x*0.5 + prndx[j]*@userSprite.zoom_x*0.5
      y0 = ay - 46*@userSprite.zoom_y*0.5 + prndy[j]*@userSprite.zoom_y*0.5
      x2 = cx - 128*@targetSprite.zoom_x*0.5 + rndx[j]*@targetSprite.zoom_x*0.5
      y2 = cy - 128*@targetSprite.zoom_y*0.5 + rndy[j]*@targetSprite.zoom_y*0.5
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].angle += rangl[j]*2
      nextx = fp["#{j}"].x# + (x2 - x0)*0.1
      nexty = fp["#{j}"].y# + (y2 - y0)*0.1
      if !@targetIsPlayer
        fp["#{j}"].opacity -= 51 if nextx > cx && nexty < cy
      else
        fp["#{j}"].opacity -= 51 if nextx < cx && nexty > cy
      end
    end
    fp["cir"].x, fp["cir"].y = ax, ay
    fp["cir"].angle += 16*(@userIsPlayer ? -1 : 1)
    fp["cir"].opacity -= (i>=72) ? 51 : 2
    k += 1 if i%4==0; k = 0 if k > 1
    fp["cir"].tone = [Tone.new(0,0,0),Tone.new(155,155,155)][k]
    if i >= 64
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    for m in 0...8
      fp["#{m}s"].visible = true
      fp["#{m}s"].opacity -= 12
      fp["#{m}s"].oy +=6*factor if fp["#{m}s"].opacity > 0
      fp["#{m}s"].x, fp["#{m}s"].y = @userSprite.getCenter
    end
    #pbSEPlay("Anim/Comet Punch") if i == 64
    fp["bg"].update
    @vector.set(vector) if i == 32
    @vector.inc = 0.1 if i == 32
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  for i in 0...20
    @targetSprite.still
    if i < 10
      fp["bg"].color.alpha += 25.5
    else
      fp["bg"].opacity -= 25.5
    end
    fp["bg"].update
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
