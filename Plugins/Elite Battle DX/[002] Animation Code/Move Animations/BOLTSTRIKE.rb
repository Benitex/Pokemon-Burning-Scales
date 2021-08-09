#-------------------------------------------------------------------------------
#  Bolt Strike
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:BOLTSTRIKE) do
  # Charging animation
  EliteBattle.playMoveAnimation(:CHARGE, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, false, true)
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  factor = @targetIsPlayer ? 2 : 1.5
  # set up animation
  fp = {}
  rndx = []
  rndy = []
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].create_rect(@viewport.width,@viewport.height,Color.black)
  fp["bg2"] = Sprite.new(@viewport)
  fp["bg2"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg2"].bitmap.stretch_blt(Rect.new(0,0,fp["bg2"].bitmap.width,fp["bg2"].bitmap.height),pbBitmap("Graphics/EBDX/Animations/Moves/eb064_bg"),Rect.new(0,0,512,384))
  fp["bg2"].opacity = 0
  l = 0
  m = 0
  q = 0
  for i in 0...24
    fp["c#{i}"] = Sprite.new(@viewport)
    fp["c#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb081")
    fp["c#{i}"].ox = fp["c#{i}"].bitmap.width/2
    fp["c#{i}"].oy = fp["c#{i}"].bitmap.height/2
    fp["c#{i}"].opacity = 0
    fp["c#{i}"].z = 51
    rndx.push(rand(256))
    rndy.push(rand(256))
  end
  for i in 0...12
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb064_2")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 51
  end
  fp["circle"] = Sprite.new(@viewport)
  fp["circle"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb081_3")
  fp["circle"].src_rect.set(0,0,fp["circle"].bitmap.width/2,fp["circle"].bitmap.height)
  fp["circle"].ox = fp["circle"].src_rect.width/2
  fp["circle"].oy = fp["circle"].src_rect.height/2
  fp["circle"].opacity = 0
  fp["circle"].z = @targetSprite.z + 1
  fp["half"] = Sprite.new(@viewport)
  fp["half"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb064")
  fp["half"].ox = fp["half"].src_rect.width/2
  fp["half"].oy = fp["half"].src_rect.height/2
  fp["half"].opacity = 0
  fp["half"].zoom_x = 0.5
  fp["half"].zoom_y = 0.5
  fp["half"].color = Color.new(255,255,255,255)
  fp["half"].z = @targetSprite.z + 2
  # start animation
  @vector.set(vector)
  for i in 0...72
    cx, cy = @targetSprite.getCenter(true)
    fp["circle"].x = cx; fp["circle"].y = cy
    fp["half"].x = cx; fp["half"].y = cy
    pbSEPlay("Anim/Paralyze1") if i >= 16 && (i-16)%8==0
    if i == 16
      pbSEPlay("Anim/slam")
      pbSEPlay("Anim/Thunder3")
    end
    for k in 0...24
      next if i < 16
      if fp["c#{k}"].opacity == 0 && fp["c#{k}"].tone.gray == 0
        r = rand(2)
        fp["c#{k}"].zoom_x = (r==0 ? 1 : 0.5)
        fp["c#{k}"].zoom_y = (r==0 ? 1 : 0.5)
        fp["c#{k}"].tone = rand(2)==0 ? Tone.new(196,196,196) : Tone.new(0,0,0)
        x, y = randCircleCord(128*factor)
        rndx[k] = cx - 128*factor*@targetSprite.zoom_x + x*@targetSprite.zoom_x
        rndy[k] = cy - 128*factor*@targetSprite.zoom_y + y*@targetSprite.zoom_y
        fp["c#{k}"].x = @targetSprite.x
        fp["c#{k}"].y = @targetSprite.y
      end
      x2 = rndx[k]
      y2 = rndy[k]
      x0 = fp["c#{k}"].x
      y0 = fp["c#{k}"].y
      fp["c#{k}"].x += (x2 - x0)*0.1
      fp["c#{k}"].y += (y2 - y0)*0.1
      if (x2 - x0)*0.1 < 1 && (y2 - y0)*0.1 < 1
        fp["c#{k}"].tone.gray = 1
        fp["c#{k}"].opacity -= 51
      else
        fp["c#{k}"].opacity += 51
      end
    end
    for n in 0...12
      next if i < 16
      if fp["#{n}"].opacity == 0 && fp["#{n}"].tone.gray == 0
        r = rand(2); r2 = rand(4)
        fp["#{n}"].zoom_x = [0.2,0.25,0.5,0.75][r2]
        fp["#{n}"].zoom_y = [0.2,0.25,0.5,0.75][r2]
        fp["#{n}"].tone = rand(2)==0 ? Tone.new(196,196,196) : Tone.new(0,0,0)
        x, y = randCircleCord(64*factor)
        fp["#{n}"].x = cx - 64*factor*@targetSprite.zoom_x + x*@targetSprite.zoom_x
        fp["#{n}"].y = cy - 64*factor*@targetSprite.zoom_y + y*@targetSprite.zoom_y
        fp["#{n}"].angle = -Math.atan(1.0*(fp["#{n}"].y-cy)/(fp["#{n}"].x-cx))*(180.0/Math::PI) + rand(2)*180 + rand(90)
      end
      next if m>(i-16)/4
      fp["#{n}"].opacity += 51 if fp["#{n}"].tone.gray == 0
      fp["#{n}"].angle += 180 if (i-16)%3==0
      fp["#{n}"].tone.gray = 1 if fp["#{n}"].opacity >= 255
      q += 1 if fp["#{n}"].opacity >= 255
      fp["#{n}"].opacity -= 10 if fp["#{n}"].tone.gray > 0 && q > 96
    end
    if i < 64
      fp["bg2"].opacity += 15
    else
      fp["bg2"].opacity -= 32
    end
    if i.between?(16,24)
      @targetSprite.x += (@targetIsPlayer ? -8 : 4)*((i-16)/4>0 ? -1 : 1)
      @targetSprite.y -= (@targetIsPlayer ? -4 : 2)*((i-16)/4>0 ? -1 : 1)
    end
    @targetSprite.tone = Tone.new(250,250,250) if i == 16
    if i >= 16
      if (i-16)/3 > l
        m += 1
        m = 0 if m > 1
        l = (i-16)/3
      end
      @targetSprite.zoom_y -= 0.16*(m==0 ? 1 : -1)
      @targetSprite.zoom_x += 0.08*(m==0 ? 1 : -1)
      @targetSprite.tone.red -= 15 if @targetSprite.tone.red > 100
      @targetSprite.tone.green -= 17 if @targetSprite.tone.green > 80
      @targetSprite.tone.blue -= 19 if @targetSprite.tone.blue > 60
      fp["circle"].zoom_x += 0.2
      fp["circle"].zoom_y += 0.2
      fp["circle"].opacity += (i>=20 ? -24 : 48)
      fp["half"].zoom_x += 0.1
      fp["half"].zoom_y += 0.06
      fp["half"].opacity += (i>=24 ? -40 : 40)
    end
    @userSprite.color.alpha -= 20 if @userSprite.color.alpha > 0
    @userSprite.anim = true
    @scene.wait(1,(i < 16))
  end
  @vector.reset if !@multiHit
  20.times do
    fp["bg"].opacity -= 15
    @targetSprite.tone.red -= 5
    @targetSprite.tone.green -= 4
    @targetSprite.tone.blue -= 3
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  pbDisposeSpriteHash(fp)
end
