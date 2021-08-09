#===============================================================================
#  Common Animation: BURN
#===============================================================================
EliteBattle.defineCommonAnimation(:BURN) do
  #-----------------------------------------------------------------------------
  #  configure variables
  @scene.wait(16, true) if @scene.afterAnim
  fp = {}; rndx = []; rndy = []; shake = 2; k = -1
  factor = @targetIsPlayer ? 1 : 0.5
  cx, cy = @targetSprite.getCenter(true)
  #-----------------------------------------------------------------------------
  #  set up sprites
  for i in 0...3
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb136")
    fp["#{i}"].src_rect.set(0, 101*rand(3), 53, 101)
    fp["#{i}"].ox = 26
    fp["#{i}"].oy = 101
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = (@targetIsPlayer ? 29 : 19)
    rndx.push(rand(64))
    rndy.push(rand(64))
    fp["#{i}"].x = cx - 32*factor + rndx[i]*factor
    fp["#{i}"].y = cy - 32*factor + rndy[i]*factor + 50*factor
  end
  #-----------------------------------------------------------------------------
  #  begin animation
  pbSEPlay("EBDX/Anim/fire1", 80)
  for i in 0...32
    k *= -1 if i%16 == 0
    for j in 0...3
      if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
        fp["#{j}"].zoom_x = factor; fp["#{j}"].zoom_y = factor
        fp["#{j}"].y -= 2*factor
      end
      next if j > (i/4)
      fp["#{j}"].src_rect.x += 53 if i%4 == 0
      fp["#{j}"].src_rect.x = 0 if fp["#{j}"].src_rect.x >= fp["#{j}"].bitmap.width
      if fp["#{j}"].opacity == 255 || fp["#{j}"].tone.gray > 0
        fp["#{j}"].opacity -= 16
        fp["#{j}"].tone.gray += 8
        fp["#{j}"].tone.red -= 2; fp["#{j}"].tone.green -= 2; fp["#{j}"].tone.blue -= 2
        fp["#{j}"].zoom_x -= 0.01; fp["#{j}"].zoom_y += 0.02
      else
        fp["#{j}"].opacity += 51
      end
    end
    @targetSprite.tone.red += 2.4*k
    @targetSprite.tone.green -= 1.2*k
    @targetSprite.tone.blue -= 2.4*k
    @targetSprite.ox += shake
    shake = -2 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
    shake = 2 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
    @targetSprite.still
    @scene.wait(1, true)
  end
  #-----------------------------------------------------------------------------
  #  restore parameters
  @targetSprite.ox = @targetSprite.bitmap.width/2
  pbDisposeSpriteHash(fp)
  #-----------------------------------------------------------------------------
end
