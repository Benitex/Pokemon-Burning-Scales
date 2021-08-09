#-------------------------------------------------------------------------------
#  Flash Cannon
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:FLASHCANNON) do
  @vector.set(@scene.getRealVector(@userIndex, @userIsPlayer))
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].create_rect(@viewport.width,@viewport.height,Color.black)
  fp["bg"].opacity = 0
  @sprites["battlebg"].defocus
  16.times do
    fp["bg"].opacity += 12
    @scene.wait(1,true)
  end
  cx, cy = @userSprite.getCenter(true)
  # charging animation
  for j in 0...8
    fp["s#{j}"] = Sprite.new(@viewport)
    fp["s#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb519_2")
    fp["s#{j}"].center!
    r = 64*@userSprite.zoom_x
    x1, y1 = randCircleCord(r)
    fp["s#{j}"].x = cx - r + x1
    fp["s#{j}"].y = cy - r + y1
    fp["s#{j}"].opacity = 0
    z = [1.1,1,0.9,1.2,0.8][rand(5)]
    fp["s#{j}"].zoom_x = z
    fp["s#{j}"].zoom_y = z
    fp["s#{j}"].z = @userSprite.z + 1
  end
  fp["glow"] = Sprite.new(@viewport)
  fp["glow"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb519_3")
  fp["glow"].center!
  fp["glow"].x = cx
  fp["glow"].y = cy
  fp["glow"].opacity = 0
  fp["glow"].toggle = 1
  for j in 0...2
    fp["c#{j}"] = Sprite.new(@viewport)
    fp["c#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb519_#{5+j}")
    fp["c#{j}"].center!
    fp["c#{j}"].toggle = 1
    fp["c#{j}"].x = cx
    fp["c#{j}"].y = cy
    fp["c#{j}"].opacity = 0
    fp["c#{j}"].param = 1
    fp["c#{j}"].zoom_x = @userSprite.zoom_x
    fp["c#{j}"].zoom_y = @userSprite.zoom_y
    fp["c#{j}"].z = @userSprite.z + 1
  end
  for j in 0...8
    fp["t#{j}"] = TrailingSprite.new(@viewport,pbBitmap("Graphics/EBDX/Animations/Moves/eb519"))
    fp["t#{j}"].z = @userSprite.z + 1
    r = @viewport.width
    x1, y1 = randCircleCord(r)
    fp["t#{j}"].x = cx - r + x1
    fp["t#{j}"].y = cy - r + y1
    fp["t#{j}"].color = Color.white
  end
  fp["circle"] = Sprite.new(@viewport)
  fp["circle"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb519_4")
  fp["circle"].center!
  fp["circle"].x = cx
  fp["circle"].y = cy
  fp["circle"].zoom_x = 0
  fp["circle"].zoom_y = 0
  fp["circle"].color = Color.new(192,56,121,0)
  fp["circle"].param = 0
  fp["circle"].z = @userSprite.z + 2
  fp["circle"].opacity = 0
  fp["ripples"] = Sprite.new(@viewport)
  fp["ripples"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb519_7")
  fp["ripples"].center!
  fp["ripples"].x = cx
  fp["ripples"].y = cy
  fp["ripples"].opacity = 0
  fp["ripples"].zoom_x = @userSprite.zoom_x
  fp["ripples"].zoom_y = @userSprite.zoom_y
  fp["ripples"].color = Color.new(255,255,255,0)
  fp["ripples"].z = @userSprite.z + 2
  pbSEPlay("Anim/Harden")
  for i in 0...148
    pbSEPlay("Anim/Refresh") if i == 16
    pbSEPlay("Anim/Saint8") if i == 68
    for j in 0...8
      next if j > i/4
      fp["s#{j}"].opacity += 48
      fp["s#{j}"].zoom_x -= 0.0625 if i > 4 + j*4 && fp["s#{j}"].zoom_x > 0
      fp["s#{j}"].zoom_y -= 0.0625 if i > 4 + j*4 && fp["s#{j}"].zoom_y > 0
      fp["s#{j}"].x -= (cx - fp["s#{j}"].x)*0.01
      fp["s#{j}"].y -= (cy - fp["s#{j}"].y)*0.01
    end
    for j in 0...8
      next if i < 16
      next if j > (i-16)/8
      fp["t#{j}"].x -= (fp["t#{j}"].x - cx)*0.1
      fp["t#{j}"].y -= (fp["t#{j}"].y - cy)*0.1
      fp["t#{j}"].color.alpha -= 8
      fp["t#{j}"].update if i < 128
      fp["t#{j}"].visible = false if i == 128
    end
    for j in 0...2
      next if i < 32
      fp["c#{j}"].param -= fp["c#{j}"].toggle*0.0625*(j+1)
      if j == 0
        fp["c#{j}"].zoom_x = fp["c#{j}"].param*@userSprite.zoom_x
      else
        fp["c#{j}"].zoom_y = fp["c#{j}"].param*@userSprite.zoom_y
      end
      fp["c#{j}"].opacity += i < 132 ? 8 : -32
      fp["c#{j}"].toggle *= -1 if fp["c#{j}"].param <= 0 || fp["c#{j}"].param >= 1
      fp["c#{j}"].x = cx
      fp["c#{j}"].y = cy
    end
    if i >= 32
      fp["circle"].zoom_x += 0.03125 if fp["circle"].zoom_x < 1
      fp["circle"].zoom_y += 0.03125 if fp["circle"].zoom_y < 1
      fp["circle"].param = (fp["circle"].param == 0 ? 255 : 0) if i%12 == 0 || i%12 == 4
      fp["circle"].color.alpha = fp["circle"].param if i < 132
      fp["circle"].opacity += 8
      fp["glow"].opacity += i < 132 ? 4 : -32
      fp["glow"].zoom_x -= 0.02*fp["glow"].toggle
      fp["glow"].zoom_y -= 0.02*fp["glow"].toggle
      fp["glow"].toggle *= -1 if i%4 == 0
    end
    pbSEPlay("EBDX/Anim/move2") if i == 132
    pbSEPlay("EBDX/Anim/normal5",80) if i == 132
    # shooting at the target
    @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer)) if i == 132
    fp["circle"].z = @targetSprite.z + 1 if i == 132
    if i >= 132
      cx, cy = @userSprite.getCenter(true)
      x1, y1 = @targetSprite.getCenter(true)
      fp["ripples"].opacity += i < 140 ? 32 : - 32
      fp["ripples"].zoom_x += 0.1*@userSprite.zoom_x
      fp["ripples"].zoom_y += 0.1*@userSprite.zoom_y
      fp["ripples"].color.alpha += 16
      fp["ripples"].x = cx
      fp["ripples"].y = cy
      fp["circle"].color.alpha = 0
      fp["circle"].zoom_x = @vector.zoom1
      fp["circle"].zoom_y = @vector.zoom1
      fp["circle"].x += (x1 - fp["circle"].x)*0.1
      fp["circle"].y -= (fp["circle"].y - y1)*0.1
      fp["circle"].opacity -= 64 if i >= 144
    end
    @scene.wait(1,true)
  end
  pbSEPlay("EBDX/Anim/iron4")
  pbSEPlay("EBDX/Anim/iron1")
  # hitting the target
  for j in 0...24
    fp["r2#{j}"] = Sprite.new(@viewport)
    fp["r2#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb519_10")
    fp["r2#{j}"].center!
    fp["r2#{j}"].x = @targetSprite.x - @targetSprite.ox + rand(@targetSprite.bitmap.width)
    fp["r2#{j}"].y = @targetSprite.y - @targetSprite.oy + rand(@targetSprite.bitmap.height)
    fp["r2#{j}"].z = @targetSprite.z + 1 + rand(2)
    fp["r2#{j}"].visible = false
  end
  for j in 0...32
    fp["r#{j}"] = Sprite.new(@viewport)
    b = rand(2)
    fp["r#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb519_#{8+b}")
    fp["r#{j}"].center!
    fp["r#{j}"].ox /= 2 if b == 0
    fp["r#{j}"].src_rect.set(rand(2)*fp["r#{j}"].bitmap.width/2,0,fp["r#{j}"].bitmap.width/2,fp["r#{j}"].bitmap.height) if b == 0
    fp["r#{j}"].x = x1
    fp["r#{j}"].y = y1
    r = (48 + rand(49))*@targetSprite.zoom_x
    rx, ry = randCircleCord(r)
    fp["r#{j}"].end_x = x1 - r + rx
    fp["r#{j}"].end_y = y1 - r + ry
    fp["r#{j}"].opacity = 0
    fp["r#{j}"].toggle = 2
    fp["r#{j}"].z = @targetSprite.z + 1
    fp["r#{j}"].zoom_x = @targetSprite.zoom_x
    fp["r#{j}"].zoom_y = @targetSprite.zoom_y
    fp["r#{j}"].param = 0
    fp["r#{j}"].speed = rand(15)
  end
  k = 1
  for i in 0...64
    for j in 0...32
      #next if j > i
      fp["r#{j}"].opacity += 16*fp["r#{j}"].toggle
      fp["r#{j}"].toggle = -4 if fp["r#{j}"].param >= 24+fp["r#{j}"].speed
      fp["r#{j}"].x += (fp["r#{j}"].end_x - fp["r#{j}"].x)*0.05
      fp["r#{j}"].y += (fp["r#{j}"].end_y - fp["r#{j}"].y)*0.05
      fp["r#{j}"].zoom_x -= fp["r#{j}"].zoom_x*0.02
      fp["r#{j}"].zoom_y -= fp["r#{j}"].zoom_y*0.02
      fp["r#{j}"].param += 1
    end
    for j in 0...24
      next if i < 8
      next if j > (i-8)/2
      fp["r2#{j}"].visible = true
      fp["r2#{j}"].opacity -= 24
      fp["r2#{j}"].zoom_x -= 0.02
      fp["r2#{j}"].zoom_y -= 0.02
    end
    if i >= 24
      @targetSprite.ox += k*2
      k *= -1 if i%2 == 0
      pbSEPlay("EBDX/Anim/normal2",50) if i%4 == 0
    end
    @targetSprite.still
    @scene.wait
  end
  @vector.reset
  for key in fp.keys
    next if key == "bg"
    fp[key].dispose
  end
  16.times do
    fp["bg"].opacity -= 16
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  fp["bg"].dispose
  fp.clear
end
