#-------------------------------------------------------------------------------
#  Giga Drain
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:GIGADRAIN) do
  EliteBattle.playMoveAnimation(:ABSORB, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, "giga")
end
#-------------------------------------------------------------------------------
#  Mega Drain
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:MEGADRAIN) do
  EliteBattle.playMoveAnimation(:ABSORB, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, "mega")
end
#-------------------------------------------------------------------------------
#  Absorb
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:ABSORB) do | args |
  type = args[0]; type = "absorb" if type.nil?
  # set up animation
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width, @viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.black)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(100,166,94)) if type == "mega"
  fp["bg"].opacity = 0
  ext = ["eb210","eb210_2"]
  ext = ["eb210","eb207"] if type == "mega"
  ext = ["eb200"] if type == "giga"
  cxT, cyT = @targetSprite.getCenter(true)
  cxP, cyP = @userSprite.getCenter(true)
  mx = !@targetIsPlayer ? (cxT-cxP)/2 : (cxP-cxT)/2
  mx += @targetIsPlayer ? cxT : cxP
  my = !@targetIsPlayer ? (cyP-cyT)/2 : (cyT-cyP)/2
  my += @targetIsPlayer ? cyP : cyT
  curves = []
  zoom = []
  frames = ["giga","mega"].include?(type) ? 32 : 16
  factor = (type == "giga" ? 2 : 1)
  pbSEPlay("Anim/Absorb2", factor==2 ? 100 : 80)
  for j in 0...frames
    fp["#{j}"] = Sprite.new(@viewport)
    fp["#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/"+ext[rand(ext.length)])
    fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
    fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
    fp["#{j}"].x = cxT
    fp["#{j}"].y = cyT
    z = [1,0.75,0.5,0.25][rand(4)]
    fp["#{j}"].zoom_x = z*@userSprite.zoom_x
    fp["#{j}"].zoom_y = z*@userSprite.zoom_y
    v = type == "mega" ? 1 : 0
    ox = -16*factor + rand(32*factor) - 32*v + rand(64*v)
    oy = -16*factor + rand(32*factor) - 32*v + rand(64*v)
    vert = rand(96)*(rand(2)==0 ? 1 : -1)*(factor**2)
    fp["#{j}"].z = 50
    fp["#{j}"].opacity = 0
    curve = calculateCurve(cxT+ox,cyT+oy,mx,my+vert+oy,cxP+ox,cyP+oy,32)
    curves.push(curve)
    zoom.push(z)
  end
  max = type == "giga" ? 16 : 8
  for j in 0...max
    fp["s#{j}"] = Sprite.new(@viewport)
    fp["s#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebHealing")
    fp["s#{j}"].ox = fp["s#{j}"].bitmap.width/2
    fp["s#{j}"].oy = fp["s#{j}"].bitmap.height/2
    fp["s#{j}"].zoom_x = @userSprite.zoom_x
    fp["s#{j}"].zoom_y = @userSprite.zoom_x
    cx, cy = @userSprite.getCenter(true)
    fp["s#{j}"].x = cx - 48*@userSprite.zoom_x + rand(96)*@userSprite.zoom_x
    fp["s#{j}"].y = cy - 48*@userSprite.zoom_y + rand(96)*@userSprite.zoom_y
    fp["s#{j}"].visible = false
    fp["s#{j}"].z = 51
  end
  @sprites["battlebg"].defocus
  for i in 0...64
    fp["bg"].opacity += 16 if fp["bg"].opacity < 128
    for j in 0...frames
      next if j>i/(32/frames)
      k = i - j*(32/frames)
      fp["#{j}"].visible = false if k >= frames
      k = frames - 1 if k >= frames
      k = 0 if k < 0
      if type == "giga"
        fp["#{j}"].tone.red += 4
        fp["#{j}"].tone.blue += 4
        fp["#{j}"].tone.green += 4
      end
      fp["#{j}"].x = curves[j][k][0]
      fp["#{j}"].y = curves[j][k][1]
      fp["#{j}"].opacity += (k < 16) ? 64 : -16
      fp["#{j}"].zoom_x -= (fp["#{j}"].zoom_x - @targetSprite.zoom_x*zoom[j])*0.1
      fp["#{j}"].zoom_y -= (fp["#{j}"].zoom_y - @targetSprite.zoom_y*zoom[j])*0.1
    end
    for k in 0...max
      next if type == "absorb"
      next if i < frames/2
      next if k>(i-frames/2)/(16/max)
      fp["s#{k}"].visible = true
      fp["s#{k}"].opacity -= 16
      fp["s#{k}"].y -= 2
    end
    if type == "giga"
      @userSprite.tone.red += 8 if @userSprite.tone.red < 128
      @userSprite.tone.green += 8 if @userSprite.tone.green < 128
      @userSprite.tone.blue += 8 if @userSprite.tone.blue < 128
    end
    pbSEPlay("Anim/Recovery",80) if type != "absorb" && i == (frames/2)
    @scene.wait(1,true)
  end
  for i in 0...8
    fp["bg"].opacity -= 16
    if type == "giga"
      @userSprite.tone.red -= 16
      @userSprite.tone.green -= 16
      @userSprite.tone.blue -= 16
    end
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  pbDisposeSpriteHash(fp)
end
