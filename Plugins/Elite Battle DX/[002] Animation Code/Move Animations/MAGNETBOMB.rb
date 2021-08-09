#-------------------------------------------------------------------------------
#  Magnet Bomb
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:MAGNETBOMB) do
  factor = @targetSprite.zoom_x
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @scene.wait(16,true)
  factor = @targetSprite.zoom_x
  # set up animation
  fp = {}
  dx = []
  dy = []
  cx, cy = @targetSprite.getCenter(true)
  for j in 0..16
    fp["i#{j}"] = Sprite.new(@viewport)
    fp["i#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb523")
    fp["i#{j}"].ox = fp["i#{j}"].bitmap.width/2
    fp["i#{j}"].oy = fp["i#{j}"].bitmap.height/2
    r = 72*factor
    fp["i#{j}"].x = cx - r + rand(r*2)
    fp["i#{j}"].y = cy - r*1.5 + rand(r*2)
    fp["i#{j}"].z = @targetSprite.z + (rand(2)==0 ? 1 : -1)
    fp["i#{j}"].zoom_x = factor
    fp["i#{j}"].zoom_y = factor
    fp["i#{j}"].opacity = 0
    dx.push(rand(2)==0 ? 1 : -1)
    dy.push(rand(2)==0 ? 1 : -1)
  end
  for m in 0...12
    fp["d#{m}"] = Sprite.new(@viewport)
    fp["d#{m}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb523_2")
    fp["d#{m}"].src_rect.set(0,0,80,78)
    fp["d#{m}"].ox = fp["d#{m}"].src_rect.width/2
    fp["d#{m}"].oy = fp["d#{m}"].src_rect.height/2
    r = 32*factor
    fp["d#{m}"].x = cx - r + rand(r*2)
    fp["d#{m}"].y = cy - r + rand(r*2)
    fp["d#{m}"].z = @targetSprite.z + 1
    fp["d#{m}"].opacity = 0
    fp["d#{m}"].angle = rand(360)
  end
  for m in 0...12
    fp["s#{m}"] = Sprite.new(@viewport)
    fp["s#{m}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb523_2")
    fp["s#{m}"].src_rect.set(80,0,80,78)
    fp["s#{m}"].ox = fp["s#{m}"].src_rect.width/2
    fp["s#{m}"].oy = fp["s#{m}"].src_rect.height/2
    r = 32*factor
    fp["s#{m}"].x = fp["d#{m}"].x
    fp["s#{m}"].y = fp["d#{m}"].y
    fp["s#{m}"].z = @targetSprite.z + 1
    fp["s#{m}"].opacity = 0
    fp["s#{m}"].angle = fp["d#{m}"].angle
  end
  pbSEPlay("EBDX/Anim/iron4",100)
  for i in 0...48
    k = (i-16)/4
    pbSEPlay("EBDX/Anim/psychic4",80-20*k) if i >= 16 && i%4==0 && i < 28
    for j in 0...16
      next if j>(i/2)
      t = fp["i#{j}"].tone.red
      t += 32 if i%4==0
      t = 0 if t > 96
      fp["i#{j}"].tone = Tone.new(t,t,t)
      fp["i#{j}"].opacity += 16
      fp["i#{j}"].angle += dx[j]
    end
    @scene.wait
  end
  for i in 0...64
    pbSEPlay("EBDX/Anim/normal1",80) if i >= 2 && i%4==0 && i < 26
    for j in 0...16
      next if j>(i)
      fp["i#{j}"].x += (cx - fp["i#{j}"].x)*0.5
      fp["i#{j}"].y += (cy - fp["i#{j}"].y)*0.5
      fp["i#{j}"].angle += dx[j]
      fp["i#{j}"].visible = (cx - fp["i#{j}"].x)*0.5 >= 1
    end
    for m in 0...12
      next if i < 6
      next if m>(i-6)/2
      fp["d#{m}"].opacity += 32*(fp["d#{m}"].zoom_x < 1.5 ? 1 : -1)
      fp["d#{m}"].zoom_x += 0.05
      fp["d#{m}"].zoom_y += 0.05
      fp["d#{m}"].angle += 4
      fp["s#{m}"].opacity += 32*(fp["s#{m}"].zoom_x < 1.5 ? 1 : -1)
      fp["s#{m}"].zoom_x += 0.05
      fp["s#{m}"].zoom_y += 0.05
      fp["s#{m}"].angle += 4
    end
    @targetSprite.still
    @scene.wait
  end
  pbDisposeSpriteHash(fp)
  @vector.reset if !@multiHit
end
