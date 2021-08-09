#-------------------------------------------------------------------------------
#  Ice Punch
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:ICEPUNCH) do
  # set up animation
  fp = {}
  rndx = []
  rndy = []
  angl = []
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(100,128,142))
  fp["bg"].opacity = 0
  for i in 0...12
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb248")
    fp["#{i}"].src_rect.set(rand(2)*26,0,26,42)
    fp["#{i}"].ox = 13
    fp["#{i}"].oy = 21
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = (@targetIsPlayer ? 29 : 19)
    r = rand(101)
    fp["#{i}"].zoom_x = (@targetSprite.zoom_x - r*0.0075*@targetSprite.zoom_x)
    fp["#{i}"].zoom_y = (@targetSprite.zoom_y - r*0.0075*@targetSprite.zoom_y)
    rndx.push(rand(196))
    rndy.push(rand(196))
    angl.push((1+rand(3))*4*(rand(2)==0 ? 1 : -1))
  end
  fp["punch"] = Sprite.new(@viewport)
  fp["punch"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb108")
  fp["punch"].ox = fp["punch"].bitmap.width/2
  fp["punch"].oy = fp["punch"].bitmap.height/2
  fp["punch"].opacity = 0
  fp["punch"].z = 40
  fp["punch"].angle = 180
  fp["punch"].zoom_x = @targetIsPlayer ? 6 : 4
  fp["punch"].zoom_y = @targetIsPlayer ? 6 : 4
  fp["punch"].tone = Tone.new(6,16,48)
  shake = 4
  # start animation
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @sprites["battlebg"].defocus
  pbSEPlay("Anim/fog2",75)
  for i in 0...72
    cx, cy = @targetSprite.getCenter(true)
    fp["punch"].x = cx
    fp["punch"].y = cy
    fp["punch"].angle -= 45 if i < 40
    fp["punch"].zoom_x -= @targetIsPlayer ? 0.2 : 0.15 if i < 40
    fp["punch"].zoom_y -= @targetIsPlayer ? 0.2 : 0.15 if i < 40
    fp["punch"].opacity += 8 if i < 40
    if i >= 40
      fp["punch"].tone = Tone.new(255,255,255) if i == 40
      fp["punch"].tone.all -= 25.5
      fp["punch"].opacity -= 25.5
    end
    pbSEPlay("Anim/Ice2") if i==40
    pbSEPlay("EBDX/Anim/ice1",75) if i==40
    for j in 0...12
      next if i < 40
      if fp["#{j}"].opacity == 0
        fp["#{j}"].x = cx
        fp["#{j}"].y = cy
      end
      x2 = cx - 98*@targetSprite.zoom_x + rndx[j]*@targetSprite.zoom_x
      y2 = cy - 98*@targetSprite.zoom_y + rndy[j]*@targetSprite.zoom_y
      x0 = fp["#{j}"].x
      y0 = fp["#{j}"].y
      fp["#{j}"].x += (x2 - x0)*0.2
      fp["#{j}"].y += (y2 - y0)*0.2
      fp["#{j}"].angle += angl[j]
      fp["#{j}"].opacity += 32
    end
    fp["bg"].opacity += 4 if  i < 40
    if i >= 40
      if i >= 56 && i < 72
        @targetSprite.tone.red -= 8
        @targetSprite.tone.green -= 8
        @targetSprite.tone.blue -= 8
        fp["bg"].opacity -= 10
      elsif i < 56
        @targetSprite.tone.red += 8
        @targetSprite.tone.green += 8
        @targetSprite.tone.blue += 8
      end
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @vector.reset if !@multiHit
  @sprites["battlebg"].focus
  20.times do
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...12
      fp["#{j}"].x = cx - 98*@targetSprite.zoom_x + rndx[j]*@targetSprite.zoom_x
      fp["#{j}"].y = cy - 98*@targetSprite.zoom_y + rndy[j]*@targetSprite.zoom_y
      fp["#{j}"].angle += angl[j]
      fp["#{j}"].opacity -= 13
    end
    @scene.wait(1,true)
  end
  pbDisposeSpriteHash(fp)
end
