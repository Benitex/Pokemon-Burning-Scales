#-------------------------------------------------------------------------------
#  Earth Power
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:EARTHPOWER) do
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.black)
  fp["bg"].opacity = 0
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @sprites["battlebg"].defocus
  16.times do
    fp["bg"].opacity += 8
    @scene.wait(1,true)
  end
  # set up animation
  factor = @targetSprite.zoom_x
  cx, cy = @targetSprite.getCenter(true)
  y0 = @targetSprite.y
  x = [cx - 64*factor, cx + 64*factor, cx]
  y = [y0, y0, y0 + 24*factor]
  dx = []
  for k in 0...3
    fp["f#{k}"] = Sprite.new(@viewport)
    fp["f#{k}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb224")
    fp["f#{k}"].ox = fp["f#{k}"].bitmap.width/2
    fp["f#{k}"].oy = fp["f#{k}"].bitmap.height
    fp["f#{k}"].zoom_x = factor + 0.25
    fp["f#{k}"].zoom_y = 0
    fp["f#{k}"].x = x[k]
    fp["f#{k}"].y = y[k]
    fp["f#{k}"].z = @targetSprite.z
    for m in 0...16
      fp["p#{k}#{m}"] = Sprite.new(@viewport)
      fp["p#{k}#{m}"].bitmap = Bitmap.new(8,8)
      fp["p#{k}#{m}"].ox = 4
      fp["p#{k}#{m}"].oy = 4
      c = [Color.new(139,7,7),Color.new(239,90,1)][rand(2)]
      fp["p#{k}#{m}"].bitmap.bmp_circle(c)
      fp["p#{k}#{m}"].visible = false
      z = [1,0.5,0.75,0.25][rand(4)]
      fp["p#{k}#{m}"].zoom_x = z
      fp["p#{k}#{m}"].zoom_y = z
      fp["p#{k}#{m}"].x = x[k] - 16 + rand(32)
      fp["p#{k}#{m}"].y = y[k] - rand(32)
      fp["p#{k}#{m}"].z = @targetSprite.z + 1
      dx.push((rand(2)==0 ? 1 : -1)*2)
    end
  end
  # start animation
  for k in 0...3
    @scene.wait(8,true)
    j = -1
    l = 6
    pbSEPlay("EBDX/Anim/rock1",80)
    pbSEPlay("Anim/Earth4",50,50)
    for i in 0...24
      j *= -1 if i%4==0
      l -= 2 if i%8==0
      fp["f#{k}"].zoom_x -= 0.1 if fp["f#{k}"].zoom_x > 0
      fp["f#{k}"].zoom_y += 0.3
      fp["f#{k}"].opacity -= 24
      @scene.moveEntireScene(0, j*l, true, true) if i < 16
      for m in 0...16
        next if m>(i*2)
        fp["p#{k}#{m}"].visible = true
        fp["p#{k}#{m}"].y -= 16
        fp["p#{k}#{m}"].x += dx[m]
        fp["p#{k}#{m}"].opacity -= 16
      end
      @scene.wait
    end
  end
  16.times do
    fp["bg"].opacity -= 8
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  pbDisposeSpriteHash(fp)
  @vector.reset if !@multiHit
end
