#-------------------------------------------------------------------------------
#  Ice Fang
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:ICEFANG) do
  # set up animation
  fp = {}
  rndx = []
  rndy = []
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(100,128,142))
  fp["bg"].opacity = 0
  for i in 0...12
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb248")
    fp["#{i}"].src_rect.set(0,0,26,42)
    fp["#{i}"].ox = 13
    fp["#{i}"].oy = 21
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = (@targetIsPlayer ? 29 : 19)
    fp["#{i}"].zoom_x = (@targetSprite.zoom_x)
    fp["#{i}"].zoom_y = (@targetSprite.zoom_y)
    rndx.push(rand(128))
    rndy.push(rand(128))
  end
  fp["fang1"] = Sprite.new(@viewport)
  fp["fang1"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb028")
  fp["fang1"].ox = fp["fang1"].bitmap.width/2
  fp["fang1"].oy = fp["fang1"].bitmap.height - 20
  fp["fang1"].opacity = 0
  fp["fang1"].z = 41
  fp["fang1"].tone = Tone.new(6,16,48)
  fp["fang2"] = Sprite.new(@viewport)
  fp["fang2"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb028")
  fp["fang2"].ox = fp["fang1"].bitmap.width/2
  fp["fang2"].oy = fp["fang1"].bitmap.height - 20
  fp["fang2"].opacity = 0
  fp["fang2"].z = 40
  fp["fang2"].angle = 180
  fp["fang2"].tone = Tone.new(6,16,48)
  shake = 4
  # start animation
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @sprites["battlebg"].defocus
  for i in 0...92
    cx, cy = @targetSprite.getCenter(true)
    fp["fang1"].x = cx; fp["fang1"].y = cy
    fp["fang1"].zoom_x = @targetSprite.zoom_x; fp["fang1"].zoom_y = @targetSprite.zoom_y
    fp["fang2"].x = cx; fp["fang2"].y = cy
    fp["fang2"].zoom_x = @targetSprite.zoom_x; fp["fang2"].zoom_y = @targetSprite.zoom_y
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
      pbSEPlay("EBDX/Anim/ice1",75)
    end
    for j in 0...12
      next if i < 40
      if fp["#{j}"].opacity == 0 && fp["#{j}"].src_rect.x == 0
        fp["#{j}"].x = cx - 64*@targetSprite.zoom_x + rndx[j]*@targetSprite.zoom_x
        fp["#{j}"].y = cy - 64*@targetSprite.zoom_y + rndy[j]*@targetSprite.zoom_y
      end
      fp["#{j}"].src_rect.x += 26 if i%4==0 && fp["#{j}"].opacity >= 255
      fp["#{j}"].src_rect.x = 78 if fp["#{j}"].src_rect.x > 78
      if fp["#{j}"].src_rect.x==78
        fp["#{j}"].opacity -= 24
        fp["#{j}"].zoom_x += 0.02
        fp["#{j}"].zoom_y += 0.02
      elsif fp["#{j}"].opacity >= 255
        fp["#{j}"].opacity -= 24
      else
        fp["#{j}"].opacity += 45 if (i-40)/2 > j
      end
    end
    fp["bg"].opacity += 4 if  i < 40
    if i >= 40
      if i >= 56 && i < 72
        @targetSprite.tone.red -= 8
        @targetSprite.tone.green -= 8
        @targetSprite.tone.blue -= 8
        fp["bg"].opacity -= 10
      elsif i < 65
        @targetSprite.tone.red += 8
        @targetSprite.tone.green += 8
        @targetSprite.tone.blue += 8
      end
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    if i == 72
      @targetSprite.ox = @targetSprite.bitmap.width/2
      @vector.reset if !@multiHit
    end
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  pbDisposeSpriteHash(fp)
end
