#-------------------------------------------------------------------------------
#  Psycho Cut
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:PSYCHOCUT) do
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  # extra parameters
  xt,yt = @targetSprite.getCenter(true)
  xp,yp = @userSprite.getCenter(true)
  distance_x = xt - xp
  distance_y = yp - yt
  @vector.set(vector2)
  @scene.wait(16,true)
  # set up animation
  cx, cy = @userSprite.getCenter(true)
  factor = @userSprite.zoom_x
  fp = {}
  for j in 0...5
    fp["#{j}"] = Sprite.new(@viewport)
    fp["#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb458_2")
    fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
    fp["#{j}"].oy = fp["#{j}"].bitmap.height + 16
    fp["#{j}"].zoom_x = factor*0.75
    fp["#{j}"].zoom_y = factor*0.75
    fp["#{j}"].opacity = 0
    fp["#{j}"].x = cx
    fp["#{j}"].y = cy
    fp["#{j}"].z = @userIsPlayer ? 29 : 19
    fp["#{j}"].angle = 60*j + 30
  end
  fp["ring"] = Sprite.new(@viewport)
  fp["ring"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb458")
  fp["ring"].ox = fp["ring"].bitmap.width/2
  fp["ring"].oy = fp["ring"].bitmap.height/2
  fp["ring"].x = cx
  fp["ring"].y = cy
  fp["ring"].zoom_x = 0
  fp["ring"].zoom_y = 0
  fp["ring"].z = @userIsPlayer ? 29 : 19
  fp["blade"] = Sprite.new(@viewport)
  fp["blade"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb458_3")
  fp["blade"].ox = fp["blade"].bitmap.width/2
  fp["blade"].oy = fp["blade"].bitmap.height/2
  fp["blade"].x = cx
  fp["blade"].y = cy
  fp["blade"].zoom_x = factor
  fp["blade"].zoom_y = factor
  fp["blade"].z = @userIsPlayer ? 29 : 19
  fp["blade"].opacity = 0
  fp["blade"].color = Color.new(255,255,255,128)
  fp["blade2"] = Sprite.new(@viewport)
  fp["blade2"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb458_3")
  fp["blade2"].ox = fp["blade2"].bitmap.width/2
  fp["blade2"].oy = fp["blade2"].bitmap.height/2
  fp["blade2"].x = cx
  fp["blade2"].y = cy
  fp["blade2"].zoom_x = factor
  fp["blade2"].zoom_y = factor
  fp["blade2"].z = @targetIsPlayer ? 29 : 19
  fp["blade2"].opacity = 0
  fp["blade2"].color = Color.new(255,255,255,128)
  for i in 0...96
    cx, cy = @userSprite.getCenter(true)
    @vector.reset if !@multiHit && i == 64
    pbSEPlay("EBDX/Anim/normal3",80) if i == 88
    pbSEPlay("EBDX/Anim/normal3",60) if i == 92
    pbSEPlay("EBDX/Anim/ground1",80) if i == 16
    pbSEPlay("Anim/fog2",90) if i == 16
    pbSEPlay("EBDX/Anim/psychic3",80) if i == 64
    if i < 16
      fp["ring"].zoom_x += factor/16.0
      fp["ring"].zoom_y += factor/16.0
    elsif i < 64
      for j in 0...5
        fp["#{j}"].zoom_x += 0.05*factor*((i < 24) ? 0.5 : 0.25)
        fp["#{j}"].zoom_y += 0.05*factor*((i < 24) ? 0.5 : 0.25)
        fp["#{j}"].opacity += 32*((i < 24) ? 1 : -1)
      end
      fp["ring"].opacity -= 8
      fp["blade"].opacity += 16
      fp["blade"].angle += 8
      fp["blade"].color.alpha -= 8 if fp["blade"].color.alpha > 0
    else
      fp["blade"].angle += 8
      fp["blade"].opacity -= 16
      fp["blade"].x = cx
      fp["blade"].y = cy
      fp["blade2"].opacity += 32
      fp["blade2"].x = cx + (i-64)*distance_x/24.0
      fp["blade2"].y = cy - (i-64)*distance_y/24.0
      x2, y2 = @targetSprite.getCenter(true)
      x0 = fp["blade2"].x
      y0 = fp["blade2"].y
      fp["blade2"].angle = -Math.atan(1.0*(y2-y0)/(x2-x0))*180/Math::PI + 180*(@targetIsPlayer ? 1 : 0) if i < 88
      fp["blade2"].zoom_x -= (@userSprite.zoom_x - @targetSprite.zoom_x)/32.0
      fp["blade2"].zoom_y -= (@userSprite.zoom_y - @targetSprite.zoom_y)/32.0
      if !@targetIsPlayer
        fp["blade2"].z = @targetSprite.z - 1 if x0 > x2 && y0 < y2
      else
        fp["blade2"].z = @targetSprite.z + 1 if x0 < x2 && y0 > y2
      end
    end
    @scene.wait(1,true)
  end
  pbDisposeSpriteHash(fp)
end
