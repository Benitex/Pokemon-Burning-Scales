#-------------------------------------------------------------------------------
#  Fly
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:FLY) do
  if @hitNum == 1
    EliteBattle.playMoveAnimation(:FLY_UP, @scene, @userIndex, @targetIndex)
  elsif @hitNum == 0
    EliteBattle.playMoveAnimation(:FLY_DOWN, @scene, @userIndex, @targetIndex)
  end
end

EliteBattle.defineMoveAnimation(:FLY_UP) do
  factor = @targetIsPlayer ? 2 : 1.5
  vector = @scene.getRealVector(@userIndex, @userIsPlayer)
  # set up animation
  fp = {}
  fp["fly"] = Sprite.new(@viewport)
  fp["fly"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb156")
  fp["fly"].ox = fp["fly"].bitmap.width/2
  fp["fly"].oy = fp["fly"].bitmap.height/2
  fp["fly"].z = 50
  fp["fly"].x, fp["fly"].y = @userSprite.getCenter
  fp["fly"].opacity = 0
  fp["fly"].zoom_x = factor*1.4
  fp["fly"].zoom_y = factor*1.4
  fp["dnt"] = Sprite.new(@viewport)
  fp["dnt"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb156_2")
  fp["dnt"].ox = fp["dnt"].bitmap.width/2
  fp["dnt"].oy = fp["dnt"].bitmap.height/2
  fp["dnt"].z = 50
  fp["dnt"].opacity = 0
  # start animation
  @vector.set(vector)
  @scene.wait(20,true)
  pbSEPlay("Anim/Refresh")
  for i in 0...20
    cx, cy = @userSprite.getCenter
    fp["fly"].x = cx
    fp["fly"].y = cy
    fp["fly"].zoom_x -= factor*0.4/10
    fp["fly"].zoom_y -= factor*0.4/10
    fp["fly"].opacity += 51
    fp["dnt"].x = cx
    fp["dnt"].y = cy
    fp["dnt"].zoom_x = fp["fly"].zoom_x
    fp["dnt"].zoom_y = fp["fly"].zoom_y
    fp["dnt"].opacity += 25.5
    fp["dnt"].angle -= 16
    @userSprite.visible = false if i == 6
    @userSprite.hidden = true if i == 6
    @scene.wait(1,true)
  end
  10.times do
    fp["fly"].zoom_x += factor*0.4/10
    fp["fly"].zoom_y += factor*0.4/10
    fp["dnt"].zoom_x = fp["fly"].zoom_x
    fp["dnt"].zoom_y = fp["fly"].zoom_y
    fp["dnt"].opacity -= 25.5
    fp["dnt"].angle -= 16
    @scene.wait(1,true)
  end
  @vector.set(vector[0],vector[1]+128,vector[2],vector[3],vector[4],vector[5])
  for i in 0...20
    @scene.wait(1,true)
    cx, cy = @userSprite.getCenter
    if i < 10
      fp["fly"].zoom_y -= factor*0.02
    elsif
      fp["fly"].zoom_x -= factor*0.02
      fp["fly"].zoom_y += factor*0.04
    end
    fp["fly"].x = cx
    fp["fly"].y = cy
    fp["fly"].y -= 32*(i-10) if i >= 10
    pbSEPlay("EBDX/Anim/flying2") if i == 10
  end
  for i in 0...20
    fp["fly"].y -= 32
    fp["fly"].opacity -= 25.5 if i >= 10
    @scene.wait(1,true)
  end
  pbDisposeSpriteHash(fp)
  @vector.reset
  @scene.wait(20,true)
end

EliteBattle.defineMoveAnimation(:FLY_DOWN) do
  defaultvector = EliteBattle.get_vector(:MAIN, @battle)
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  # set up animation
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.black)
  fp["bg"].opacity = 0
  fp["drop"] = Sprite.new(@viewport)
  fp["drop"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb156_3")
  fp["drop"].ox = fp["drop"].bitmap.width/2
  fp["drop"].oy = fp["drop"].bitmap.height/2
  fp["drop"].y = 0
  fp["drop"].z = 50
  fp["drop"].visible = false
  # start animation
  @vector.set(defaultvector[0], defaultvector[1]+128, defaultvector[2], defaultvector[3], defaultvector[4], defaultvector[5])
  @sprites["battlebg"].defocus
  32.times do
    fp["bg"].opacity += 2
    @scene.wait(1,true)
  end
  @vector.set(vector)
  maxy = ((@targetIsPlayer ? @vector.y : @vector.y2)*0.1).ceil*10 - 80
  fp["drop"].y = -((maxy-(@targetIsPlayer ? @vector.y-80 : @vector.y2-80))*0.1).ceil*10
  fp["drop"].x = @targetSprite.x
  pbSEPlay("Anim/Wind1")
  for i in 0...20
    @scene.wait(1,true)
    if i >= 10
      fp["drop"].visible = true
      fp["drop"].x = @targetSprite.x
      fp["drop"].y += maxy/10
      fp["drop"].zoom_x = @targetSprite.zoom_x
      fp["drop"].zoom_y = @targetSprite.zoom_y*1.4
    end
    fp["bg"].opacity -= 51 if i >= 15
  end
  @sprites["battlebg"].focus
  @userSprite.hidden = false
  @userSprite.visible = true
  pbDisposeSpriteHash(fp)
  EliteBattle.playMoveAnimation(:TACKLE, @scene, @userIndex, @targetIndex, 0, false, nil, false, true)
end
