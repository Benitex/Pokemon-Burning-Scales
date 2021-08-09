#-------------------------------------------------------------------------------
#  Thunderbolt
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:THUNDERBOLT) do | args |
  strike = *args; strike = false if strike.nil?
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  q = 0
  # set up animation
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.black)
  fp["bg"].opacity = 0
  @userSprite.color = Color.new(217,189,52,0) if strike
  for i in 0...8
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb069_2")
    fp["#{i}"].src_rect.set(0,0,98,430)
    fp["#{i}"].ox = fp["#{i}"].src_rect.width/2
    fp["#{i}"].oy = fp["#{i}"].src_rect.height
    fp["#{i}"].zoom_x = 0.5
    fp["#{i}"].z = 50
  end
  for i in 0...16
    fp["s#{i}"] = Sprite.new(@viewport)
    fp["s#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb069_3")
    fp["s#{i}"].ox = fp["s#{i}"].bitmap.width/2
    fp["s#{i}"].oy = fp["s#{i}"].bitmap.height/2
    fp["s#{i}"].opacity = 0
    fp["s#{i}"].z = 51
  end
  fp["circle"] = Sprite.new(@viewport)
  fp["circle"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb069")
  fp["circle"].ox = fp["circle"].bitmap.width/2 + 4
  fp["circle"].oy = fp["circle"].bitmap.height/2 + 4
  fp["circle"].opacity = 0
  fp["circle"].z = 50
  fp["circle"].zoom_x = 1
  fp["circle"].zoom_y = 1
  # start animation
  @sprites["battlebg"].defocus
  @vector.set(vector)
  16.times do
    fp["bg"].opacity += 12
    @scene.wait(1,true)
  end
  cx, cy = @targetSprite.getCenter(true)
  fp["circle"].x = cx
  fp["circle"].y = cy
  for i in 0...96
    for j in 0...8
      next if j>(i/4)
      if fp["#{j}"].y <= 0 && i < 32
        pbSEPlay("Anim/Thunder3",80) if i%8==0
        fp["#{j}"].x = cx - 32*@targetSprite.zoom_x + rand(64)*@targetSprite.zoom_x
        fp["#{j}"].src_rect.x = 98*rand(3)
        t = rand(5)*48
        fp["#{j}"].opacity = 255
        fp["#{j}"].tone = Tone.new(t,t,t)
        fp["#{j}"].mirror = (rand(2)==0 ? true : false)
      end
      fp["#{j}"].src_rect.x += 98
      fp["#{j}"].src_rect.x = 0 if fp["#{j}"].src_rect.x >= 294
      fp["#{j}"].y += (@targetIsPlayer ? @vector.y : @vector.y2)/8.0 if fp["#{j}"].y < (@targetIsPlayer ? @vector.y : @vector.y2) + 32
      fp["#{j}"].opacity -= 32 if fp["#{j}"].y >= (@targetIsPlayer ? @vector.y : @vector.y2) + 32
      fp["#{j}"].y = 0 if fp["#{j}"].opacity <= 0
    end
    for n in 0...16
      next if i < 48
      next if n>(i-48)/4
      if fp["s#{n}"].opacity == 0 && fp["s#{n}"].tone.gray == 0
        pbSEPlay("EBDX/Anim/electric1",60) if i%8==0
        r2 = rand(4)
        fp["s#{n}"].zoom_x = [1,0.8,0.5,0.75][r2]
        fp["s#{n}"].zoom_y = [1,0.8,0.5,0.75][r2]
        fp["s#{n}"].tone = rand(2)==0 ? Tone.new(196,196,196) : Tone.new(0,0,0)
        x, y = randCircleCord(48)
        fp["s#{n}"].x = cx - 48*@targetSprite.zoom_x + x*@targetSprite.zoom_x
        fp["s#{n}"].y = cy - 48*@targetSprite.zoom_y + y*@targetSprite.zoom_y
        fp["s#{n}"].angle = -Math.atan(1.0*(fp["s#{n}"].y-cy)/(fp["s#{n}"].x-cx))*(180.0/Math::PI) + rand(2)*180 + rand(90)
      end
      fp["s#{n}"].opacity += 128 if fp["s#{n}"].tone.gray == 0
      fp["s#{n}"].angle += 180 if (i-16)%2==0
      fp["s#{n}"].tone.gray = 1 if fp["s#{n}"].opacity >= 255
      q += 1 if fp["s#{n}"].opacity >= 255
      fp["s#{n}"].opacity -= 51 if fp["s#{n}"].tone.gray > 0 && q > 96
    end
    fp["circle"].opacity += (i < 48 ? 32 : - 64)
    fp["circle"].angle += 64
    fp["bg"].opacity -= 32 if i >= 90
    @targetSprite.still if i >= 32
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
