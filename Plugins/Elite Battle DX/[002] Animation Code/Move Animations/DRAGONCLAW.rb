#-------------------------------------------------------------------------------
#  Dragon Claw
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:DRAGONCLAW) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  # set up animation
  fp = {}
  speed = []
  for j in 0...32
    fp["#{j}"] = Sprite.new(@viewport)
    fp["#{j}"].z = @userIsPlayer ? 29 : 19
    fp["#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb057")
    fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
    fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
    fp["#{j}"].color = Color.new(255,255,255,255)
    z = [0.5,1.5,1,0.75,1.25][rand(5)]
    fp["#{j}"].zoom_x = z
    fp["#{j}"].zoom_y = z
    fp["#{j}"].opacity = 0
    speed.push((rand(8)+1)*4)
  end
  for j in 0...8
    fp["s#{j}"] = Sprite.new(@viewport)
    fp["s#{j}"].z = @userIsPlayer ? 29 : 19
    fp["s#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb057_2")
    fp["s#{j}"].ox = fp["s#{j}"].bitmap.width/2
    fp["s#{j}"].oy = fp["s#{j}"].bitmap.height
    #z = [0.5,1.5,1,0.75,1.25][rand(5)]
    fp["s#{j}"].color = Color.new(255,255,255,255)
    #fp["s#{j}"].zoom_y = z
    fp["s#{j}"].opacity = 0
  end
  @userSprite.color = Color.new(255,0,0,0)
  # start animation
  @vector.set(vector2)
  @vector.inc = 0.1
  oy = @userSprite.oy
  k = -1
  for i in 0...64
    k *= -1 if i%4==0
    pbSEPlay("EBDX/Anim/dragon2") if i == 12
    cx, cy = @userSprite.getCenter(true)
    for j in 0...32
      next if i < 8
      next if j>(i-8)
      if fp["#{j}"].opacity == 0 && fp["#{j}"].color.alpha == 255
        fp["#{j}"].y = @userSprite.y + 8*@userSprite.zoom_y - rand(24)*@userSprite.zoom_y
        fp["#{j}"].x = cx - 64*@userSprite.zoom_x + rand(128)*@userSprite.zoom_x
      end
      if fp["#{j}"].color.alpha <= 96
        fp["#{j}"].opacity -= 32
      else
        fp["#{j}"].opacity += 32
      end
      fp["#{j}"].color.alpha -= 16
      fp["#{j}"].y -= speed[j]
    end
    for j in 0...8
      next if i < 12
      next if j>(i-12)/2
      if fp["s#{j}"].opacity == 0 && fp["s#{j}"].color.alpha == 255
        fp["s#{j}"].y = @userSprite.y + 48*@userSprite.zoom_y - rand(16)*@userSprite.zoom_y
        fp["s#{j}"].x = cx - 64*@userSprite.zoom_x + rand(128)*@userSprite.zoom_x
      end
      if fp["s#{j}"].color.alpha <= 96
        fp["s#{j}"].opacity -= 32
      else
        fp["s#{j}"].opacity += 32
      end
      fp["s#{j}"].color.alpha -= 16
      fp["s#{j}"].zoom_y += speed[j]*0.25*0.01
      fp["s#{j}"].y -= speed[j]
    end
    if i < 48
      @userSprite.color.alpha += 4
    else
      @userSprite.color.alpha -= 16
    end
    @userSprite.oy -= 2*k if i%2==0
    @userSprite.still
    @userSprite.anim = true
    @scene.wait(1,true)
  end
  @userSprite.oy = oy
  @vector.set(vector)
  @vector.inc = 0.2
  @scene.wait(16,true)
  cx, cy = @targetSprite.getCenter(true)
  fp["claw1"] = Sprite.new(@viewport)
  fp["claw1"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb057_3")
  fp["claw1"].src_rect.set(-82,0,82,174)
  fp["claw1"].ox = fp["claw1"].src_rect.width
  fp["claw1"].oy = fp["claw1"].src_rect.height/2
  fp["claw1"].x = cx - 32*@targetSprite.zoom_x
  fp["claw1"].y = cy
  fp["claw1"].z = @targetIsPlayer ? 29 : 19
  fp["claw2"] = Sprite.new(@viewport)
  fp["claw2"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb057_3")
  fp["claw2"].src_rect.set(-82,0,82,174)
  fp["claw2"].ox = 0
  fp["claw2"].oy = fp["claw2"].src_rect.height/2
  fp["claw2"].x = cx + 32*@targetSprite.zoom_x
  fp["claw2"].y = cy
  fp["claw2"].z = @targetIsPlayer ? 29 : 19
  fp["claw2"].mirror = true
  shake = 4
  for i in 0...32
    @targetSprite.still
    pbSEPlay("Anim/Slash10") if i == 4 || i == 16
    for j in 1..2
      next if (j-1)>(i/12)
      fp["claw#{j}"].src_rect.x += 82 if fp["claw#{j}"].src_rect.x < 82*3 && i%2==0
    end
    fp["claw1"].visible = false if i == 16
    fp["claw2"].visible = false if i == 32
    if i.between?(4,12) || i.between?(20,28)
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
    end
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
