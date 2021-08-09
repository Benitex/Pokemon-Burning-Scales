#-------------------------------------------------------------------------------
#  Icicle Crash
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:ICICLECRASH) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  # set up animation
  @vector.set(vector)
  @scene.wait(16,true)
  fp = {}
  for j in 0...16
    fp["i#{j}"] = Sprite.new(@viewport)
    fp["i#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb250")
    fp["i#{j}"].ox = fp["i#{j}"].bitmap.width/2
    fp["i#{j}"].oy = fp["i#{j}"].bitmap.height/2
    fp["i#{j}"].opacity = 0
    fp["i#{j}"].zoom_x = @targetSprite.zoom_x
    fp["i#{j}"].zoom_y = @targetSprite.zoom_y
    fp["i#{j}"].z = @targetIsPlayer ? 29 : 19
    fp["i#{j}"].x = @targetSprite.x + rand(32)*@targetSprite.zoom_x*(rand(2)==0 ? 1 : -1)
    fp["i#{j}"].y = @targetSprite.y - 8*@targetSprite.zoom_y + rand(16)*@targetSprite.zoom_y
  end
  for j in 0...5
    fp["s#{j}"] = Sprite.new(@viewport)
    fp["s#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb244")
    fp["s#{j}"].ox = fp["s#{j}"].bitmap.width/2
    fp["s#{j}"].oy = fp["s#{j}"].bitmap.height
    fp["s#{j}"].opacity = 0
    fp["s#{j}"].zoom_x = @targetSprite.zoom_x
    fp["s#{j}"].zoom_y = @targetSprite.zoom_y
    fp["s#{j}"].z = @targetIsPlayer ? 29 : 19
    fp["s#{j}"].x = @targetSprite.x - 48*@targetSprite.zoom_x + rand(96)*@targetSprite.zoom_x
    fp["s#{j}"].y = @targetSprite.y - 192*@targetSprite.zoom_y
    fp["p#{j}"] = Sprite.new(@viewport)
    fp["p#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb244_2")
    fp["p#{j}"].ox = fp["p#{j}"].bitmap.width/2
    fp["p#{j}"].oy = fp["p#{j}"].bitmap.height/2
    fp["p#{j}"].visible = false
    fp["p#{j}"].zoom_x = 2
    fp["p#{j}"].zoom_y = 2
    fp["p#{j}"].z = @targetIsPlayer ? 29 : 19
    fp["p#{j}"].x = fp["s#{j}"].x
    fp["p#{j}"].y = fp["s#{j}"].y + 192*@targetSprite.zoom_y
  end
  k = -2
  for i in 0...64
    k *= -1 if i%4==0 && i >= 8
    pbSEPlay("EBDX/Anim/rock1",70) if i%8==0 && i >0 && i < 48
    for j in 0...5
      next if j>(i/6)
      fp["s#{j}"].opacity += 64
      fp["s#{j}"].y += 24*@targetSprite.zoom_y if fp["s#{j}"].y < @targetSprite.y
      fp["s#{j}"].zoom_y -= 0.2*@targetSprite.zoom_y if fp["s#{j}"].y >= @targetSprite.y
      fp["s#{j}"].visible = false if fp["s#{j}"].zoom_y <= 0.4*@targetSprite.zoom_y
    end
    for j in 0...5
      next if i < 8
      next if j>(i-8)/8
      fp["p#{j}"].visible = true
      fp["p#{j}"].opacity -= 32
      fp["p#{j}"].zoom_x += 0.02
      fp["p#{j}"].zoom_y += 0.02
      fp["p#{j}"].angle += 8
    end
    for j in 0...16
      next if i < 8
      next if j>(i-8)/2
      fp["i#{j}"].opacity += 32*(fp["i#{j}"].zoom_x <= 0.5*@targetSprite.zoom_x ? -1 : 1)
      fp["i#{j}"].zoom_x -= 0.02*@targetSprite.zoom_x
      fp["i#{j}"].zoom_y -= 0.02*@targetSprite.zoom_y
      fp["i#{j}"].x += 2*@targetSprite.zoom_x*(fp["i#{j}"].x >= @targetSprite.x ? 1 : -1)
      fp["i#{j}"].angle += 4*(fp["i#{j}"].x >= @targetSprite.x ? 1 : -1)
    end
    @scene.moveEntireScene(0, k, true, true) if i >= 8 && i < 48
    @scene.wait
  end
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
