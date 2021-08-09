#-------------------------------------------------------------------------------
#  Struggle Bug
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:STRUGGLEBUG) do
  # configure animation
  @vector.set(@scene.getRealVector(@userIndex, @userIsPlayer))
  @scene.wait(16,true)
  factor = @userSprite.zoom_x
  cx, cy = @userSprite.getCenter(true)
  dx = []
  dy = []
  fp = {}
  for j in 0...24
    fp["#{j}"] = Sprite.new(@viewport)
    fp["#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb010")
    fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
    fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
    r = 64*factor
    x, y = randCircleCord(r)
    x = cx - r + x
    y = cy - r + y
    fp["#{j}"].x = cx
    fp["#{j}"].y = cx
    fp["#{j}"].z = @userSprite.z
    fp["#{j}"].visible = false
    fp["#{j}"].angle = rand(360)
    z = [0.5,1,0.75][rand(3)]
    fp["#{j}"].zoom_x = z
    fp["#{j}"].zoom_y = z
    dx.push(x)
    dy.push(y)
  end
  # start animation
  pbSEPlay("EBDX/Anim/ground1",80)
  for i in 0...48
    for j in 0...24
      next if j>(i*2)
      fp["#{j}"].visible = true
      if ((fp["#{j}"].x - dx[j])*0.1).abs < 1
        fp["#{j}"].opacity -= 32
      else
        fp["#{j}"].x -= (fp["#{j}"].x - dx[j])*0.1
        fp["#{j}"].y -= (fp["#{j}"].y - dy[j])*0.1
      end
    end
    @scene.wait
  end
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @scene.wait(16,true)
  factor = @targetSprite.zoom_x
  cx, cy = @targetSprite.getCenter(true)
  for j in 0...12
    fp["s#{j}"] = Sprite.new(@viewport)
    fp["s#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb244_2")
    fp["s#{j}"].ox = fp["s#{j}"].bitmap.width/2
    fp["s#{j}"].oy = fp["s#{j}"].bitmap.height/2
    r = 32*factor
    fp["s#{j}"].x = cx - r + rand(r*2)
    fp["s#{j}"].y = cy - r + rand(r*2)
    fp["s#{j}"].z = @targetSprite.z + 1
    fp["s#{j}"].visible = false
    fp["s#{j}"].tone = Tone.new(255,255,255)
    fp["s#{j}"].angle = rand(360)
  end
  # anim2
  for i in 0...32
    for j in 0...12
      next if j>(i*2)
      fp["s#{j}"].visible = true
      fp["s#{j}"].opacity -= 32
      fp["s#{j}"].zoom_x += 0.02
      fp["s#{j}"].zoom_y += 0.02
      fp["s#{j}"].angle += 8
      fp["s#{j}"].tone.red -= 32
      fp["s#{j}"].tone.green -= 32
      fp["s#{j}"].tone.blue -= 32
    end
    @targetSprite.still
    pbSEPlay("EBDX/Anim/normal2",80) if i%4==0 && i < 16
    @scene.wait
  end
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
