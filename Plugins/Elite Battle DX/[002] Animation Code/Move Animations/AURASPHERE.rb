#-------------------------------------------------------------------------------
#  Aura Sphere
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:AURASPHERE) do
  # inital configuration
  defaultvector = EliteBattle.get_vector(:MAIN, @battle)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  # set up animation
  fp = {}; dx = []; dy = []
  fp["bg"] = ScrollingSprite.new(@viewport)
  fp["bg"].speed = 64
  fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/eb093_bg")
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  fp["cir"] = Sprite.new(@viewport)
  fp["cir"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb093")
  fp["cir"].ox = fp["cir"].bitmap.width/2
  fp["cir"].oy = fp["cir"].bitmap.height/2
  fp["cir"].z = @userSprite.z + 1
  fp["cir"].mirror = @userIsPlayer
  fp["cir"].zoom_x = (@targetIsPlayer ? 0.75 : 1)
  fp["cir"].zoom_y = (@targetIsPlayer ? 0.75 : 1)
  fp["cir"].opacity = 0
  shake = 4; k = 0
  # start animation
  @sprites["battlebg"].defocus
  for i in 0...40
    if i < 8
      fp["bg"].opacity += 32
    else
      fp["bg"].color.alpha -= 32
      fp["cir"].x, fp["cir"].y = @userSprite.getCenter
      fp["cir"].angle += 24*(@userIsPlayer ? -1 : 1)
      fp["cir"].opacity += 24
    end
    if i == 8
      @vector.set(vector2)
      pbSEPlay("Anim/eb_grass2",80)
    end
    fp["bg"].update
    @scene.wait(1,true)
  end
  cx, cy = @userSprite.getCenter(true)
  dx = []
  dy = []
  for i in 0...8
    fp["#{i}s"] = Sprite.new(@viewport)
    fp["#{i}s"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb093_2")
    fp["#{i}s"].src_rect.set(rand(3)*36,0,36,36)
    fp["#{i}s"].ox = fp["#{i}s"].src_rect.width/2
    fp["#{i}s"].oy = fp["#{i}s"].src_rect.height/2
    r = 128*@userSprite.zoom_x
    z = [0.5,0.25,1,0.75][rand(4)]
    x, y = randCircleCord(r)
    x = cx - r + x
    y = cy - r + y
    fp["#{i}s"].x = cx
    fp["#{i}s"].y = cy
    fp["#{i}s"].zoom_x = z*@userSprite.zoom_x
    fp["#{i}s"].zoom_y = z*@userSprite.zoom_x
    fp["#{i}s"].visible = false
    fp["#{i}s"].z = @userSprite.z + 1
    dx.push(x); dy.push(y)
  end
  fp["shot"] = Sprite.new(@viewport)
  fp["shot"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb093_3")
  fp["shot"].ox = fp["shot"].bitmap.width/2
  fp["shot"].oy = fp["shot"].bitmap.height/2
  fp["shot"].z = @userSprite.z + 1
  fp["shot"].zoom_x = @userSprite.zoom_x
  fp["shot"].zoom_y = @userSprite.zoom_x
  fp["shot"].opacity = 0
  x = defaultvector[0]; y = defaultvector[1]
  x2, y2 = @vector.spoof(defaultvector)
  fp["shot"].x = cx
  fp["shot"].y = cy
  pbSEPlay("EBDX/Anim/normal5",80)
  k = -1
  for i in 0...20
    cx, cy = @userSprite.getCenter
    @vector.reset if i == 0
    if i > 0
      fp["shot"].angle = Math.atan(1.0*(@vector.y-@vector.y2)/(@vector.x2-@vector.x))*(180.0/Math::PI) + (@targetIsPlayer ? 180 : 0)
      fp["shot"].opacity += 32
      fp["shot"].zoom_x -= (fp["shot"].zoom_x - @targetSprite.zoom_x)*0.1
      fp["shot"].zoom_y -= (fp["shot"].zoom_y - @targetSprite.zoom_y)*0.1
      fp["shot"].x += (@targetIsPlayer ? -1 : 1)*(x2 - x)/24
      fp["shot"].y -= (@targetIsPlayer ? -1 : 1)*(y - y2)/24
      for j in 0...8
        fp["#{j}s"].visible = true
        fp["#{j}s"].opacity -= 32
        fp["#{j}s"].x -= (fp["#{j}s"].x - dx[j])*0.2
        fp["#{j}s"].y -= (fp["#{j}s"].y - dy[j])*0.2
      end
      fp["cir"].angle += 24*(@userIsPlayer ? -1 : 1)
      fp["cir"].opacity -= 16
      fp["cir"].x = cx
      fp["cir"].y = cy
    end
    fp["bg"].update
    factor = @targetSprite.zoom_x if i == 12
    if i >= 12
      k *= -1 if i%4==0
      @targetSprite.zoom_x -= factor*0.01*k
      @targetSprite.zoom_y += factor*0.04*k
      @targetSprite.still
    end
    cx, cy = @targetSprite.getCenter(true)
    if !@targetIsPlayer
      fp["shot"].z = @targetSprite.z - 1 if fp["shot"].x > cx && fp["shot"].y < cy
    else
      fp["shot"].z = @targetSprite.z + 1 if fp["shot"].x < cx && fp["shot"].y > cy
    end
    @scene.wait(1,i < 12)
  end
  shake = 2
  16.times do
    fp["shot"].angle = Math.atan(1.0*(@vector.y-@vector.y2)/(@vector.x2-@vector.x))*(180.0/Math::PI) + (@targetIsPlayer ? 180 : 0)
    fp["shot"].opacity += 32
    fp["shot"].zoom_x -= (fp["shot"].zoom_x - @targetSprite.zoom_x)*0.1
    fp["shot"].zoom_y -= (fp["shot"].zoom_y - @targetSprite.zoom_y)*0.1
    fp["shot"].x += (@targetIsPlayer ? -1 : 1)*(x2 - x)/24
    fp["shot"].y -= (@targetIsPlayer ? -1 : 1)*(y - y2)/24
    fp["bg"].color.alpha += 16
    fp["bg"].update
    @targetSprite.ox += shake
    shake = -2 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 4
    shake = 2 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 4
    @targetSprite.still
    cx, cy = @targetSprite.getCenter(true)
    if !@targetIsPlayer
      fp["shot"].z = @targetSprite.z - 1 if fp["shot"].x > cx && fp["shot"].y < cy
    else
      fp["shot"].z = @targetSprite.z + 1 if fp["shot"].x < cx && fp["shot"].y > cy
    end
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  16.times do
    fp["bg"].update
    @targetSprite.still
    @scene.wait(1,true)
  end
  16.times do
    fp["bg"].update
    fp["bg"].opacity -= 16
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  pbDisposeSpriteHash(fp)
end
