#-------------------------------------------------------------------------------
#  Hyper Beam
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:HYPERBEAM) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  factor = @userIsPlayer ? 2 : 1
  # set up animation
  fp = {}; rndx = []; rndy = []; dx = []; dy = []
  fp["bg"] = ScrollingSprite.new(@viewport)
  fp["bg"].speed = 64
  fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/eb263_bg")
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  for i in 0...72
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb263_4")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 19
    rndx.push(rand(16))
    rndy.push(rand(16))
    dx.push(0)
    dy.push(0)
  end
  for i in 0...72
    fp["#{i}2"] = Sprite.new(@viewport)
    fp["#{i}2"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb263_3")
    fp["#{i}2"].ox = fp["#{i}2"].bitmap.width/2
    fp["#{i}2"].oy = fp["#{i}2"].bitmap.height/2
    fp["#{i}2"].opacity = 0
    fp["#{i}2"].z = 19
  end
  fp["cir"] = Sprite.new(@viewport)
  fp["cir"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb263")
  fp["cir"].ox = fp["cir"].bitmap.width/2
  fp["cir"].oy = fp["cir"].bitmap.height/2
  fp["cir"].z = 50
  fp["cir"].zoom_x = @targetIsPlayer ? 0.5 : 1
  fp["cir"].zoom_y = @targetIsPlayer ? 0.5 : 1
  fp["cir"].opacity = 0
  for i in 0...8
    fp["#{i}s"] = Sprite.new(@viewport)
    fp["#{i}s"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb263_2")
    fp["#{i}s"].ox = -32 - rand(64)
    fp["#{i}s"].oy = fp["#{i}s"].bitmap.height/2
    fp["#{i}s"].angle = rand(270)
    r = rand(2)
    fp["#{i}s"].zoom_x = (r==0 ? 0.1 : 0.2)*factor
    fp["#{i}s"].zoom_y = (r==0 ? 0.1 : 0.2)*factor
    fp["#{i}s"].visible = false
    fp["#{i}s"].opacity = 255 - rand(101)
    fp["#{i}s"].z = 50
  end
  shake = 4
  # start animation
  @sprites["battlebg"].defocus
  @vector.set(vector2)
  for i in 0...20
    if i < 10
      fp["bg"].opacity += 25.5
    else
      fp["bg"].color.alpha -= 25.5
    end
    pbSEPlay("Anim/Harden") if i == 4
    fp["bg"].update
    @scene.wait(1,true)
  end
  @scene.wait(4,true)
  pbSEPlay("Anim/Psych Up")
  for i in 0...96
    ax, ay = @userSprite.getAnchor
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...72
      if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
        dx[j] = ax - 8*@userSprite.zoom_x*0.5 + rndx[j]*@userSprite.zoom_x*0.5
        dy[j] = ay - 8*@userSprite.zoom_y*0.5 + rndy[j]*@userSprite.zoom_y*0.5
        fp["#{j}"].x = dx[j]
        fp["#{j}"].y = dy[j]
      end
      @scene.applySpriteProperties(fp["#{j}"],fp["#{j}2"])
      next if j>(i)
      x0 = dx[j]
      y0 = dy[j]
      x2 = cx - 8*@targetSprite.zoom_x*0.5 + rndx[j]*@targetSprite.zoom_x*0.5
      y2 = cy - 8*@targetSprite.zoom_y*0.5 + rndy[j]*@targetSprite.zoom_y*0.5
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].opacity += 51
      fp["#{j}"].angle = -Math.atan(1.0*(y2-y0)/(x2-x0))*180/Math::PI + (rand(4)==0 ? 180 : 0)
      nextx = fp["#{j}"].x# + (x2 - x0)*0.1
      nexty = fp["#{j}"].y# + (y2 - y0)*0.1
      if !@targetIsPlayer
        fp["#{j}"].z = @targetSprite.z - 1 if nextx > cx && nexty < cy
      else
        fp["#{j}"].z = @targetSprite.z + 1 if nextx < cx && nexty > cy
      end
      @scene.applySpriteProperties(fp["#{j}"],fp["#{j}2"])
    end
    if i >= 64
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    pbSEPlay("Anim/Comet Punch") if i == 64
    fp["cir"].x, fp["cir"].y = ax, ay
    fp["cir"].angle += 32
    fp["cir"].opacity += (i>72) ? -51 : 255
    fp["bg"].update
    for m in 0...8
      fp["#{m}s"].visible = true
      fp["#{m}s"].opacity -= 12
      fp["#{m}s"].zoom_x += 0.04*factor if fp["#{m}s"].opacity > 0
      fp["#{m}s"].zoom_y += 0.04*factor if fp["#{m}s"].opacity > 0
      fp["#{m}s"].x, fp["#{m}s"].y = ax, ay
    end
    @vector.set(vector) if i == 32
    @vector.inc = 0.1 if i == 32
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  fp["cir"].opacity = 0
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
