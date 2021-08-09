#-------------------------------------------------------------------------------
#  Shadow Ball
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:SHADOWBALL) do
  x1, y1 = @targetSprite.getCenter(true)
  x2, y2 = @userSprite.getCenter(true)
  if @targetIsPlayer
    cx = x1 + (x2 - x1)*0.65
    cy = y1 - (y1 - y2)*0.65
  else
    cx = x2 + (x1 - x2)*0.5
    cy = y2 - (y2 - y1)*0.5
  end
  fp = {}
  for j in 0...16
    fp["p#{j}"] = Sprite.new(@viewport)
    fp["p#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb175_2")
    fp["p#{j}"].oy = fp["p#{j}"].bitmap.height/2
    fp["p#{j}"].x = cx
    fp["p#{j}"].y = cy
    fp["p#{j}"].opacity = 0
    fp["p#{j}"].z = 20
  end
  for j in 0...32
    fp["c#{j}"] = Sprite.new(@viewport)
    fp["c#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb175_1")
    fp["c#{j}"].opacity = 0
    fp["c#{j}"].angle = rand(360)
    fp["c#{j}"].ox = 12
    fp["c#{j}"].oy = 18 + rand(24)
    fp["c#{j}"].x = cx
    fp["c#{j}"].y = cy
    fp["c#{j}"].z = 20
    fp["c#{j}"].color = Color.new(123,64,89,0)
    fp["c#{j}"].toggle = 1
  end
  fp["circle"] = Sprite.new(@viewport)
  fp["circle"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb175")
  fp["circle"].center!
  fp["circle"].x = cx
  fp["circle"].y = cy
  fp["circle"].zoom_x = 0
  fp["circle"].zoom_y = 0
  fp["circle"].z = 20
  pbSEPlay("Anim/Heal4")
  for i in 0...64
    fp["circle"].zoom_x += 0.125 if fp["circle"].zoom_x < 1
    fp["circle"].zoom_y += 0.125 if fp["circle"].zoom_y < 1
    fp["circle"].angle += 8
    for j in 0...16
      next if j > i/4
      if fp["p#{j}"].ox >= -16
        fp["p#{j}"].ox = -128
        fp["p#{j}"].angle = rand(360)
        fp["p#{j}"].opacity = 0
      end
      fp["p#{j}"].opacity += 32
      fp["p#{j}"].ox += 16
    end
    for j in 0...32
      fp["c#{j}"].toggle *= -1 if i%4==0
      next if j > i/2
      fp["c#{j}"].opacity += 16
      fp["c#{j}"].color.alpha = 255*fp["c#{j}"].toggle
    end
    @scene.wait
  end
  for key in fp.keys
    next if key == "circle"
    fp[key].dispose
    fp.delete(key)
  end
  fp["circle2"] = Sprite.new(@viewport)
  fp["circle2"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb175_3")
  fp["circle2"].center!
  fp["circle2"].x = cx
  fp["circle2"].y = cy
  fp["circle2"].z = fp["circle"].z - 1
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  16.times do
    fp["circle2"].zoom_x = @vector.zoom1
    fp["circle2"].zoom_y = @vector.zoom1
    fp["circle"].zoom_x = @vector.zoom1
    fp["circle"].zoom_y = @vector.zoom1
    x1, y1 = @targetSprite.getCenter(true)
    x2, y2 = @userSprite.getCenter(true)
    if @targetIsPlayer
      cx = x1 + (x2 - x1)*0.65
      cy = y1 - (y1 - y2)*0.65
    else
      cx = x2 + (x1 - x2)*0.5
      cy = y2 - (y2 - y1)*0.5
    end
    fp["circle2"].x = cx
    fp["circle2"].y = cy
    fp["circle"].x = cx
    fp["circle"].y = cy
    fp["circle"].angle += 8
    @scene.wait(1,true)
  end
  fp["circle"].visible = false
  fp["circle2"].z = @targetSprite.z + 1
  pbSEPlay("Anim/Flash")
  8.times do
    fp["circle2"].x += (x1 - fp["circle2"].x)*0.5
    fp["circle2"].y -= (fp["circle2"].y - y1)*0.5
    @scene.wait
  end
  fp["circle2"].visible = false
  @targetSprite.anim = true
  @targetSprite.color = Color.new(122,71,109)
  2.times do
    @targetSprite.anim = true
    @scene.wait
  end
  for j in 0...16
    fp["i#{j}"] = Sprite.new(@viewport)
    fp["i#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb175_4")
    fp["i#{j}"].ox = fp["i#{j}"].bitmap.width/2
    fp["i#{j}"].oy = fp["i#{j}"].bitmap.height
    fp["i#{j}"].angle = rand(360)
    fp["i#{j}"].z = @targetSprite.z + 1
    fp["i#{j}"].x = x1
    fp["i#{j}"].y = y1
  end
  for i in 0...32
    for j in 0...16
      next if j > i
      fp["i#{j}"].opacity -= 16
      fp["i#{j}"].oy += 8
    end
    @targetSprite.color.alpha -= 16
    @targetSprite.anim = true
    @scene.wait
  end
  pbDisposeSpriteHash(fp)
  @vector.reset
end
