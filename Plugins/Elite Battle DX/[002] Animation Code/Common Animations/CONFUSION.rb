#===============================================================================
#  Common Animation: CONFUSION
#===============================================================================
EliteBattle.defineCommonAnimation(:CONFUSION) do
  #-----------------------------------------------------------------------------
  #  configure variables
  @scene.wait(16, true) if @scene.afterAnim
  fp = {}; k = -1
  factor = @targetSprite.zoom_x
  reversed = []; cx, cy = @targetSprite.getCenter(true)
  #-----------------------------------------------------------------------------
  #  set up sprites
  for j in 0...8
    fp["#{j}"] = Sprite.new(@viewport)
    fp["#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebConfused")
    fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
    fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
    fp["#{j}"].zoom_x = factor
    fp["#{j}"].zoom_y = factor
    fp["#{j}"].opacity
    fp["#{j}"].y = cy - 32*factor
    fp["#{j}"].x = cx + 64*factor - (j%4)*32*factor
    reversed.push([false,true][j/4])
  end
  #-----------------------------------------------------------------------------
  #  play animation
  vol = 80
  for i in 0...64
    k = i if i < 16
    pbSEPlay("EBDX/Anim/confusion1",vol) if i%8 == 0
    vol -= 5 if i%8 == 0
    for j in 0...8
      reversed[j] = true if fp["#{j}"].x <= cx - 64*factor
      reversed[j] = false if fp["#{j}"].x >= cx + 64*factor
      fp["#{j}"].z = reversed[j] ? @targetSprite.z - 1 : @targetSprite.z + 1
      fp["#{j}"].y = cy - 48*factor - k*2*factor - (reversed[j] ? 4*factor : 0)
      fp["#{j}"].x -= reversed[j] ? -4*factor : 4*factor
      fp["#{j}"].opacity += 16 if i < 16
      fp["#{j}"].opacity -= 16 if i >= 48
    end
    @scene.wait(1,true)
  end
  #-----------------------------------------------------------------------------
  #  dispose sprites
  pbDisposeSpriteHash(fp)
  #-----------------------------------------------------------------------------
end
