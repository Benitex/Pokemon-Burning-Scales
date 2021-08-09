#-------------------------------------------------------------------------------
#  Metal Claw
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:METALCLAW) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  # set up animation
  fp = {}
  @userSprite.color = Color.new(255,0,0,0)
  # start animation
  @vector.set(vector2)
  @vector.inc = 0.1
  oy = @userSprite.oy
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
    pbSEPlay("EBDX/Anim/iron5") if i == 4 || i == 16
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
