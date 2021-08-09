#===============================================================================
#  Common Animation: FROZEN
#===============================================================================
EliteBattle.defineCommonAnimation(:FROZEN) do
  #-----------------------------------------------------------------------------
  #  configure variables
  @scene.wait(16, true) if @scene.afterAnim
  fp = {}; rndx = []; rndy = []; k = -1
  factor = @targetSprite.zoom_x
  #-----------------------------------------------------------------------------
  #  set up sprites
  for i in 0...12
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb248")
    fp["#{i}"].src_rect.set(rand(2)*26, 0, 26, 42)
    fp["#{i}"].ox = 13
    fp["#{i}"].oy = 21
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = (@targetIsPlayer ? 29 : 19)
    r = rand(101)
    fp["#{i}"].zoom_x = (factor - r*0.0075*factor)
    fp["#{i}"].zoom_y = (factor - r*0.0075*factor)
    rndx.push(rand(96))
    rndy.push(rand(96))
  end
  #-----------------------------------------------------------------------------
  #  play animation
  pbSEPlay("EBDX/Anim/ice1")
  for i in 0...32
    k *= -1 if i%8 == 0
    for j in 0...12
      next if j>(i/2)
      if fp["#{j}"].opacity == 0
        cx, cy = @targetSprite.getCenter(true)
        fp["#{j}"].x = cx - 48*factor + rndx[j]*factor
        fp["#{j}"].y = cy - 48*factor + rndy[j]*factor
      end
      fp["#{j}"].src_rect.x += 26 if i%4 == 0 && fp["#{j}"].opacity >= 255
      fp["#{j}"].src_rect.x = 78 if fp["#{j}"].src_rect.x > 78
      if fp["#{j}"].src_rect.x == 78
        fp["#{j}"].opacity -= 24
        fp["#{j}"].zoom_x += 0.02
        fp["#{j}"].zoom_y += 0.02
      elsif fp["#{j}"].opacity >= 255
        fp["#{j}"].opacity -= 24
      else
        fp["#{j}"].opacity += 45 if (i)/2 > k
      end
    end
    @targetSprite.tone.red += 3.2*k; @targetSprite.tone.green += 3.2*k; @targetSprite.tone.blue += 3.2*k
    @targetSprite.still
    @scene.wait(1, true)
  end
  #-----------------------------------------------------------------------------
  #  dispose sprites
  pbDisposeSpriteHash(fp)
  #-----------------------------------------------------------------------------
end
