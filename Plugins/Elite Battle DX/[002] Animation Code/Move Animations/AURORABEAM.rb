#-------------------------------------------------------------------------------
#  Aurora Beam
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:AURORABEAM) do
  # inital configuration
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  # set up animation
  fp = {}; rndx = []; rndy = []
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width, @viewport.height)
  fp["bg"].bitmap.fill_rect(0, 0, fp["bg"].bitmap.width, fp["bg"].bitmap.height, Color.black)
  fp["bg"].opacity = 0
  for i in 0...36
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb246")
    fp["#{i}"].src_rect.set(44*rand(4),0,44,44)
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/8
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = (@targetIsPlayer ? 29 : 19)
    rndx.push(rand(8))
    rndy.push(rand(8))
  end
  # start animation
  pbSEPlay("Anim/Psych Up")
  @sprites["battlebg"].defocus
  for i in 0...128
    pbSEPlay("Anim/Ice1", 75) if i%8==0
    cx, cy = @targetSprite.getCenter(true)
    ax, ay = @userSprite.getAnchor
    for j in 0...36
      if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
        fp["#{j}"].zoom_x = @userSprite.zoom_x
        fp["#{j}"].zoom_y = @userSprite.zoom_y
        fp["#{j}"].x = ax
        fp["#{j}"].y = ay
      end
      next if j>(i/2)
      x2 = cx - 4*@targetSprite.zoom_x + rndx[j]*@targetSprite.zoom_x
      y2 = cy - 4*@targetSprite.zoom_y + rndy[j]*@targetSprite.zoom_y
      x0 = fp["#{j}"].x
      y0 = fp["#{j}"].y
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].zoom_x -= (fp["#{j}"].zoom_x - @targetSprite.zoom_x)*0.1
      fp["#{j}"].zoom_y -= (fp["#{j}"].zoom_y - @targetSprite.zoom_y)*0.1
      fp["#{j}"].angle += 2
      if (x2 - x0)*0.1 < 1 && (y2 - y0)*0.1 < 1
        fp["#{j}"].opacity -= 8
        fp["#{j}"].tone.gray += 8
        fp["#{j}"].angle += 2
      else
        fp["#{j}"].opacity += 12
      end
    end
    if i >= 96
      fp["bg"].opacity -= 10
    else
      fp["bg"].opacity += 5 if fp["bg"].opacity < 255*0.7
    end
    if i >= 72
      if i >= 96
        @targetSprite.tone.red -= 4.8/2
        @targetSprite.tone.green -= 4.8/2
        @targetSprite.tone.blue -= 4.8/2
      else
        @targetSprite.tone.red += 4.8 if @targetSprite.tone.red < 96
        @targetSprite.tone.green += 4.8 if @targetSprite.tone.green < 96
        @targetSprite.tone.blue += 4.8 if @targetSprite.tone.blue < 96
      end
      @targetSprite.still
    end
    @vector.set(vector) if i == 24
    @vector.inc = 0.1 if i == 24
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @targetSprite.tone = Tone.new(0,0,0,0)
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
