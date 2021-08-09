#-------------------------------------------------------------------------------
#  Poison Jab
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:POISONJAB) do
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @scene.wait(16,true)
  # set up animation
  factor = @targetSprite.zoom_x
  cx, cy = @targetSprite.getCenter(true)
  fp = {}
  for j in 0...32
    fp["s#{j}"] = Sprite.new(@viewport)
    fp["s#{j}"].bitmap = Bitmap.new(8,8)
    fp["s#{j}"].bitmap.bmp_circle(Color.new(25,75,183))
    fp["s#{j}"].ox = fp["s#{j}"].bitmap.width/2
    fp["s#{j}"].oy = fp["s#{j}"].bitmap.height
    fp["s#{j}"].x = cx
    fp["s#{j}"].y = cy
    fp["s#{j}"].z = @targetSprite.z
    fp["s#{j}"].angle = rand(360)
    fp["s#{j}"].visible = false
  end
  for j in 0...16
    fp["#{j}"] = Sprite.new(@viewport)
    fp["#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb430")
    fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
    fp["#{j}"].angle = rand(360)
    fp["#{j}"].ox = - 80*factor
    fp["#{j}"].x = cx
    fp["#{j}"].y = cy
    fp["#{j}"].z = @targetSprite.z + 1
    fp["#{j}"].opacity = 0
  end
  # play animation
  for i in 0...48
    for j in 0...16
      next if j>i
      fp["#{j}"].opacity += 32
      fp["#{j}"].ox += (80*factor/8).ceil
      fp["#{j}"].visible = false if fp["#{j}"].ox >= 0
    end
    for j in 0...32
      next if j>i*2
      fp["s#{j}"].visible = true
      fp["s#{j}"].opacity -= 32
      fp["s#{j}"].oy += 16
    end
    @targetSprite.zoom_y = factor + 0.32 if i%6 == 0 && i < 32
    @targetSprite.zoom_y -= 0.08 if @targetSprite.zoom_y > factor
    pbSEPlay("Anim/hit",80) if i%6==0 && i < 32
    pbSEPlay("EBDX/Anim/poison1",60) if i%4==0 && i < 32
    @scene.wait
  end
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
