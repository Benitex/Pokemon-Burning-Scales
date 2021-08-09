#-------------------------------------------------------------------------------
#  Shadow Claw
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:SHADOWCLAW) do
  factor = @targetSprite.zoom_x
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @scene.wait(16,true)
  factor = @targetSprite.zoom_x
  cx, cy = @targetSprite.getCenter(true)
  # set up animation
  fp = {}
  fp["claw"] = Sprite.new(@viewport)
  fp["claw"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb176")
  fp["claw"].ox = fp["claw"].bitmap.width/2
  fp["claw"].oy = fp["claw"].bitmap.height/2
  fp["claw"].x = cx
  fp["claw"].y = cy
  fp["claw"].zoom_x = factor
  fp["claw"].zoom_y = factor
  fp["claw"].src_rect.height = 0
  fp["claw"].z = @targetSprite.z + 1
  for j in 0...12
    fp["s#{j}"] = Sprite.new(@viewport)
    fp["s#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb176_3")
    fp["s#{j}"].ox = fp["s#{j}"].bitmap.width/2
    fp["s#{j}"].oy = fp["s#{j}"].bitmap.height/2
    r = 32*factor
    fp["s#{j}"].x = cx - r + rand(r*2)
    fp["s#{j}"].y = cy - r + rand(r*2)
    fp["s#{j}"].opacity = 0
    fp["s#{j}"].z = @targetSprite.z
    fp["s#{j}"].angle = rand(360)
  end
  for j in 0...12
    fp["p#{j}"] = Sprite.new(@viewport)
    fp["p#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb176_2")
    fp["p#{j}"].ox = fp["p#{j}"].bitmap.width/2
    fp["p#{j}"].oy = fp["p#{j}"].bitmap.height/2
    r = 48*factor
    fp["p#{j}"].x = cx - r + rand(r*2)
    fp["p#{j}"].y = cy - r + rand(r)
    fp["p#{j}"].opacity = 0
    fp["p#{j}"].z = @targetSprite.z + 1
    fp["p#{j}"].color = Color.new(0,0,0,0)
  end
  pbSEPlay("EBDX/Anim/ground1",75)
  for i in 0...64
    pbSEPlay("EBDX/Anim/normal3",85) if i == 4
    fp["claw"].src_rect.height += 16
    for j in 0...12
      next if i < 8
      fp["s#{j}"].opacity += 16*((i-8) < 24 ? 1 : -2)
      fp["s#{j}"].angle += 2
      fp["s#{j}"].zoom_x -= 0.01 if i >= 12 if fp["s#{j}"].zoom_x > 0
      fp["s#{j}"].zoom_y -= 0.01 if i >= 12 if fp["s#{j}"].zoom_y > 0
    end
    for j in 0...12
      next if i < 8
      next if j>(i-8)
      fp["p#{j}"].opacity += 32*((i-8) < 24 ? 1 : -1)
      fp["p#{j}"].color.alpha += 8
      fp["p#{j}"].zoom_x -= 0.05 if i >= 24 if fp["p#{j}"].zoom_x > 0
      fp["p#{j}"].zoom_y -= 0.05 if i >= 24 if fp["p#{j}"].zoom_y > 0
    end
    fp["claw"].opacity -= 32 if i >= 16
    @scene.wait(1,true)
  end
  pbDisposeSpriteHash(fp)
  @vector.reset if !@multiHit
end
#-------------------------------------------------------------------------------
