#-------------------------------------------------------------------------------
#  Thunder Fang
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:THUNDERFANG) do
  factor = @targetIsPlayer ? 2 : 1.5
  # set up animation
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(217/6,189/6,52/6))
  fp["bg"].opacity = 0
  fp["fang1"] = Sprite.new(@viewport)
  fp["fang1"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb028")
  fp["fang1"].ox = fp["fang1"].bitmap.width/2
  fp["fang1"].oy = fp["fang1"].bitmap.height - 20
  fp["fang1"].opacity = 0
  fp["fang1"].color = Color.new(217,189,52,50)
  fp["fang1"].z = 41
  fp["fang2"] = Sprite.new(@viewport)
  fp["fang2"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb028")
  fp["fang2"].ox = fp["fang1"].bitmap.width/2
  fp["fang2"].oy = fp["fang1"].bitmap.height - 20
  fp["fang2"].opacity = 0
  fp["fang2"].color = Color.new(217,189,52,50)
  fp["fang2"].z = 40
  fp["fang2"].angle = 180
  l = 0; m = 0; q = 0
  for i in 0...12
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb064_2")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 51
  end
  # start animation
  @sprites["battlebg"].defocus
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  for i in 0...72
    cx, cy = @targetSprite.getCenter(true)
    fp["fang1"].x = cx; fp["fang1"].y = cy
    if i < 32
      fp["fang1"].zoom_x = @targetSprite.zoom_x; fp["fang1"].zoom_y = @targetSprite.zoom_y
    end
    fp["fang2"].x = cx; fp["fang2"].y = cy
    if i < 32
      fp["fang2"].zoom_x = @targetSprite.zoom_x; fp["fang2"].zoom_y = @targetSprite.zoom_y
    end
    if i.between?(20,29)
      fp["fang1"].opacity += 5
      fp["fang1"].oy += 2
      fp["fang2"].opacity += 5
      fp["fang2"].oy += 2
    elsif i.between?(30,40)
      fp["fang1"].opacity += 25.5
      fp["fang1"].oy -= 4
      fp["fang2"].opacity += 25.5
      fp["fang2"].oy -= 4
    else
      fp["fang1"].opacity -= 26
      fp["fang1"].oy += 2
      fp["fang2"].opacity -= 26
      fp["fang2"].oy += 2
    end
    if i==32
      pbSEPlay("Anim/Super Fang")
    end
    pbSEPlay("Anim/Paralyze1") if i%8==0 && i>=48
    for n in 0...12
      next if i < 32
      if fp["#{n}"].opacity == 0 && fp["#{n}"].tone.gray == 0
        r2 = rand(4)
        fp["#{n}"].zoom_x = [0.2,0.25,0.5,0.75][r2]
        fp["#{n}"].zoom_y = [0.2,0.25,0.5,0.75][r2]
        fp["#{n}"].tone = rand(2)==0 ? Tone.new(196,196,196) : Tone.new(0,0,0)
        x, y = randCircleCord(48*factor)
        fp["#{n}"].x = cx - 48*factor*@targetSprite.zoom_x + x*@targetSprite.zoom_x
        fp["#{n}"].y = cy - 48*factor*@targetSprite.zoom_y + y*@targetSprite.zoom_y
        fp["#{n}"].angle = -Math.atan(1.0*(fp["#{n}"].y-cy)/(fp["#{n}"].x-cx))*(180.0/Math::PI) + rand(2)*180 + rand(90)
      end
      next if m>(i-32)/4
      fp["#{n}"].opacity += 51 if fp["#{n}"].tone.gray == 0
      fp["#{n}"].angle += 180 if (i-16)%3==0
      fp["#{n}"].tone.gray = 1 if fp["#{n}"].opacity >= 255
      q += 1 if fp["#{n}"].opacity >= 255
      fp["#{n}"].opacity -= 10 if fp["#{n}"].tone.gray > 0 && q > 96
    end
    fp["bg"].opacity += 4 if  i < 40
    fp["bg"].opacity -= 10 if i >= 56
    @targetSprite.tone = Tone.new(100,80,60) if i == 32
    if i >= 32
      if (i-32)/3 > l
        m += 1
        m = 0 if m > 1
        l = (i-32)/3
      end
      @targetSprite.zoom_y -= 0.16*(m==0 ? 1 : -1)
      @targetSprite.zoom_x += 0.08*(m==0 ? 1 : -1)
      @targetSprite.tone.red -= 5 if @targetSprite.tone.red > 0
      @targetSprite.tone.green -= 4 if @targetSprite.tone.green > 0
      @targetSprite.tone.blue -= 3 if @targetSprite.tone.blue > 0
      @targetSprite.still
    end
    @scene.wait(1,(i < 32))
  end
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
