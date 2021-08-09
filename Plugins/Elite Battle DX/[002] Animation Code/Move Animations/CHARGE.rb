#-------------------------------------------------------------------------------
#  Charge
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:CHARGE) do | args |
  beam, strike = *args; beam = false if beam.nil?; strike = false if strike.nil?
  factor = 2
  # set up animation
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].create_rect(@viewport.width,@viewport.height,Color.black)
  fp["bg"].opacity = 0
  @userSprite.color = Color.new(217,189,52,0) if strike
  rndx = []
  rndy = []
  for i in 0...8
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb081_2")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 50
  end
  for i in 0...16
    fp["c#{i}"] = Sprite.new(@viewport)
    fp["c#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb081")
    fp["c#{i}"].ox = fp["c#{i}"].bitmap.width/2
    fp["c#{i}"].oy = fp["c#{i}"].bitmap.height/2
    fp["c#{i}"].opacity = 0
    fp["c#{i}"].z = 51
    rndx.push(0)
    rndy.push(0)
  end
  m = 0
  fp["circle"] = Sprite.new(@viewport)
  fp["circle"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb081_3")
  fp["circle"].ox = fp["circle"].bitmap.width/4
  fp["circle"].oy = fp["circle"].bitmap.height/2
  fp["circle"].opacity = 0
  fp["circle"].src_rect.set(0,0,484,488)
  fp["circle"].z = 50
  fp["circle"].zoom_x = 0.5
  fp["circle"].zoom_y = 0.5
  # start animation
  @vector.set(@scene.getRealVector(@userIndex, !@targetIsPlayer))
  @sprites["battlebg"].defocus
  for i in 0...112
    pbSEPlay("Anim/Flash3",90) if i == 32
    pbSEPlay("Anim/Saint8") if i == 64
    cx, cy = @userSprite.getCenter
    for j in 0...8
      if fp["#{j}"].opacity == 0
        r = rand(2)
        fp["#{j}"].zoom_x = factor*(r==0 ? 1 : 0.5)
        fp["#{j}"].zoom_y = factor*(r==0 ? 1 : 0.5)
        fp["#{j}"].tone = rand(2)==0 ? Tone.new(196,196,196) : Tone.new(0,0,0)
        x, y = randCircleCord(96*factor)
        fp["#{j}"].x = cx - 96*factor*@userSprite.zoom_x + x*@userSprite.zoom_x
        fp["#{j}"].y = cy - 96*factor*@userSprite.zoom_y + y*@userSprite.zoom_y
      end
      next if j>(i/8)
      x2 = cx
      y2 = cy
      x0 = fp["#{j}"].x
      y0 = fp["#{j}"].y
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].zoom_x -= fp["#{j}"].zoom_x*0.1
      fp["#{j}"].zoom_y -= fp["#{j}"].zoom_y*0.1
      fp["#{j}"].angle = -Math.atan(1.0*(y2-y0)/(x2-x0))*(180.0/Math::PI)# + (rand{4}==0 ? 180 : 0)
      fp["#{j}"].mirror = !fp["#{j}"].mirror if i%2==0
      if i >= 96
        fp["#{j}"].opacity -= 35
      elsif (x2 - x0)*0.1 < 1 && (y2 - y0)*0.1 < 1
        fp["#{j}"].opacity = 0
      else
        fp["#{j}"].opacity += 35
      end
    end
    for k in 0...16
      if fp["c#{k}"].opacity == 0
        r = rand(2)
        fp["c#{k}"].zoom_x = (r==0 ? 1 : 0.5)
        fp["c#{k}"].zoom_y = (r==0 ? 1 : 0.5)
        fp["c#{k}"].tone = rand(2)==0 ? Tone.new(196,196,196) : Tone.new(0,0,0)
        x, y = randCircleCord(48*factor)
        rndx[k] = cx - 48*factor*@userSprite.zoom_x + x*@userSprite.zoom_x
        rndy[k] = cy - 48*factor*@userSprite.zoom_y + y*@userSprite.zoom_y
        fp["c#{k}"].x = cx
        fp["c#{k}"].y = cy
      end
      next if k>(i/4)
      x2 = rndx[k]
      y2 = rndy[k]
      x0 = fp["c#{k}"].x
      y0 = fp["c#{k}"].y
      fp["c#{k}"].x += (x2 - x0)*0.05
      fp["c#{k}"].y += (y2 - y0)*0.05
      fp["c#{k}"].opacity += 5
    end
    fp["circle"].x = cx
    fp["circle"].y = cy
    fp["circle"].opacity += 25.5
    if i < 124
      fp["circle"].zoom_x += 0.01
      fp["circle"].zoom_y += 0.01
    else
      fp["circle"].zoom_x += 0.05
      fp["circle"].zoom_y += 0.05
    end
    m = 1 if i%4==0
    fp["circle"].src_rect.x = 484*m
    m = 0 if i%2==0
    if i < 96
      if strike
        fp["bg"].opacity += 10 if fp["bg"].opacity < 255
      else
        fp["bg"].opacity += 5 if fp["bg"].opacity < 255*0.75
      end
    else
      fp["bg"].opacity -= 10 if !beam && !strike
    end
    if strike && i > 16
      @userSprite.color.alpha += 10 if @userSprite.color.alpha < 200
      fp["circle"].opacity -= 76.5 if i > 106
      for k in 0...16
        next if i < 96
        fp["c#{k}"].opacity -= 30.5
      end
      for j in 0...8
        next if i < 96
        fp["#{j}"].opacity -= 30.5
      end
    end
    @userSprite.still if !strike
    @userSprite.anim = true if strike
    @scene.wait(1,true)
  end
  if strike
    for i in 0...2
      8.times do
        @userSprite.x -= (@targetIsPlayer ? 12 : -6)*(i==0 ? 1 : -1)
        @userSprite.y += (@targetIsPlayer ? 4 : -2)*(i==0 ? 1 : -1)
        @userSprite.zoom_y -= (factor*0.04)*(i==0 ? 1 : -1)
        @userSprite.still
        @scene.wait
      end
    end
  end
  pbDisposeSpriteHash(fp)
  if !beam && !strike
    @sprites["battlebg"].focus
    @vector.reset if !@multiHit
    @viewport.color = Color.new(255,255,255,255)
    10.times do
      @viewport.color.alpha -= 25.5
      @scene.wait(1,true)
    end
  end
end
