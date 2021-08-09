#===============================================================================
#  Common Animation: SHINY
#===============================================================================
EliteBattle.defineCommonAnimation(:SHINY) do
  #-----------------------------------------------------------------------------
  #  configure variables
  @scene.wait(16, true) if @scene.afterAnim
  fp = {}; k = -1
  factor = @targetSprite.zoom_x
  #-----------------------------------------------------------------------------
  #  set up sprites
  for i in 0...16
    cx, cy = @targetSprite.getCenter(true)
    fp["#{i}"] = Sprite.new(@viewport)
    str = "Graphics/EBDX/Animations/Moves/ebShiny1"
    str = "Graphics/EBDX/Animations/Moves/ebShiny2" if i >= 8
    fp["#{i}"].bitmap = pbBitmap(str).clone
    fp["#{i}"].bitmap.hue_change(180) if i < 8 && @battlers[@targetIndex].pokemon.superShiny?
    fp["#{i}"].center!
    fp["#{i}"].x = cx
    fp["#{i}"].y = cy
    fp["#{i}"].zoom_x = factor
    fp["#{i}"].zoom_y = factor
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = @targetIsPlayer ? 29 : 19
  end
  for j in 0...8
    fp["s#{j}"] = Sprite.new(@viewport)
    fp["s#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebShiny3").clone
    fp["s#{j}"].bitmap.hue_change(180) if @battlers[@targetIndex].pokemon.superShiny?
    fp["s#{j}"].center!
    fp["s#{j}"].opacity = 0
    z = [1,0.75,1.25,0.5][rand(4)]*factor
    fp["s#{j}"].zoom_x = z
    fp["s#{j}"].zoom_y = z
    cx, cy = @targetSprite.getCenter(true)
    fp["s#{j}"].x = cx - 32*factor + rand(64)*factor
    fp["s#{j}"].y = cy - 32*factor + rand(64)*factor
    fp["s#{j}"].opacity = 0
    fp["s#{j}"].z = @targetIsPlayer ? 29 : 19
  end
  #-----------------------------------------------------------------------------
  #  play animation part 1
  pbSEPlay("EBDX/Shiny")
  for i in 0...48
    k *= -1 if i%24 == 0
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...16
      next if (j >= 8 && i < 16)
      a = (j < 8 ? -30 : -15) + 45*(j%8) + i*2
      r = @targetSprite.width*factor/2.5
      x = cx + r*Math.cos(a*(Math::PI/180))
      y = cy - r*Math.sin(a*(Math::PI/180))
      x = (x - fp["#{j}"].x)*0.1
      y = (y - fp["#{j}"].y)*0.1
      fp["#{j}"].x += x
      fp["#{j}"].y += y
      fp["#{j}"].angle += 8
      if j < 8
        fp["#{j}"].opacity += 51 if i < 16
        if i >= 16
          fp["#{j}"].opacity -= 16
          fp["#{j}"].zoom_x -= 0.04*factor
          fp["#{j}"].zoom_y -= 0.04*factor
        end
      else
        fp["#{j}"].opacity += 51 if i < 32
        if i >= 32
          fp["#{j}"].opacity -= 16
          fp["#{j}"].zoom_x -= 0.02*factor
          fp["#{j}"].zoom_y -= 0.02*factor
        end
      end
    end
    @targetSprite.tone.all += 3.2*k/2
    @scene.wait(1,true)
  end
  #-----------------------------------------------------------------------------
  #  play animation part 2
  pbSEPlay("EBDX/Anim/shine1",80)
  for i in 0...16
    for j in 0...8
      next if j>i
      fp["s#{j}"].opacity += 51
      fp["s#{j}"].zoom_x -= fp["s#{j}"].zoom_x*0.25 if fp["s#{j}"].opacity >= 255
      fp["s#{j}"].zoom_y -= fp["s#{j}"].zoom_y*0.25 if fp["s#{j}"].opacity >= 255
    end
    @scene.wait(1,true)
  end
  #-----------------------------------------------------------------------------
  #  dispose sprites
  pbDisposeSpriteHash(fp)
  #-----------------------------------------------------------------------------
end
