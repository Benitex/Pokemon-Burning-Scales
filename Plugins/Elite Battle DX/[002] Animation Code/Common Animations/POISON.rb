#===============================================================================
#  Common Animation: POISON
#===============================================================================
EliteBattle.defineCommonAnimation(:POISON) do
  #-----------------------------------------------------------------------------
  #  configure variables
  @scene.wait(16, true) if @scene.afterAnim
  fp = {}; shake = 1; k = -0.1; inc = 1
  factor = @targetSprite.zoom_x
  cx, cy = @targetSprite.getCenter(true)
  endy = []
  #-----------------------------------------------------------------------------
  #  set up sprites
  for j in 0...12
    fp["#{j}"] = Sprite.new(@viewport)
    fp["#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebPoison#{rand(3)+1}")
    fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
    fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
    fp["#{j}"].x = cx - 48*factor + rand(96)*factor
    fp["#{j}"].y = cy
    z = [1,0.9,0.8][rand(3)]
    fp["#{j}"].zoom_x = z*factor
    fp["#{j}"].zoom_y = z*factor
    fp["#{j}"].opacity = 0
    fp["#{j}"].z = @targetIsPlayer ? 29 : 19
    endy.push(cy - 64*factor - rand(32)*factor)
  end
  #-----------------------------------------------------------------------------
  #  play animation
  for i in 0...32
    pbSEPlay("EBDX/Anim/poison1", 80) if i%8 == 0
    @targetSprite.ox += shake
    k *= -1 if i%16 == 0
    inc += k
    for j in 0...12
      next if j>(i/2)
      fp["#{j}"].y -= (fp["#{j}"].y - endy[j])*0.06
      fp["#{j}"].opacity += 51 if i < 16
      fp["#{j}"].opacity -= 16 if i >= 16
      fp["#{j}"].x -= 1*factor*(fp["#{j}"].x < cx ? 1 : -1)
      fp["#{j}"].angle += 4*(fp["#{j}"].x < cx ? 1 : -1)
    end
    shake = -1*inc.round if @targetSprite.ox > @targetSprite.bitmap.width/2
    shake = 1*inc.round if @targetSprite.ox < @targetSprite.bitmap.width/2
    @targetSprite.still
    @targetSprite.color.alpha += k*60
    @targetSprite.anim = true
    @scene.wait(1,true)
  end
  #-----------------------------------------------------------------------------
  #  restore original
  @targetSprite.ox = @targetSprite.bitmap.width/2
  pbDisposeSpriteHash(fp)
  #-----------------------------------------------------------------------------
end
