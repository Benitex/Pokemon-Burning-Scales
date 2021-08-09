#===============================================================================
#  Common Animation: SLEEP
#===============================================================================
EliteBattle.defineCommonAnimation(:SLEEP) do
  #-----------------------------------------------------------------------------
  #  configure variables
  @scene.wait(16, true) if @scene.afterAnim
  fp = {}; r = []
  factor = @targetSprite.zoom_x
  #-----------------------------------------------------------------------------
  #  set up sprites
  for i in 0...3
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebSleep")
    fp["#{i}"].center!
    fp["#{i}"].angle = @targetIsPlayer ? 55 : 125
    fp["#{i}"].zoom_x = 0
    fp["#{i}"].zoom_y = 0
    fp["#{i}"].z = @targetIsPlayer ? 29 : 19
    fp["#{i}"].tone = Tone.new(192,192,192)
    r.push(0)
  end
  #-----------------------------------------------------------------------------
  #  play animation
  pbSEPlay("EBDX/Anim/snore",80)
  for j in 0...48
    cx, cy = @targetSprite.getCenter(true)
    for i in 0...3
      next if i > (j/12)
      fp["#{i}"].zoom_x += ((1*factor) - fp["#{i}"].zoom_x)*0.1
      fp["#{i}"].zoom_y += ((1*factor) - fp["#{i}"].zoom_y)*0.1
      a = @targetIsPlayer ? 55 : 125
      r[i] += 4*factor
      x = cx + r[i]*Math.cos(a*(Math::PI/180)) + 16*factor*(@targetIsPlayer ? 1 : -1)
      y = cy - r[i]*Math.sin(a*(Math::PI/180)) - 32*factor
      fp["#{i}"].x = x; fp["#{i}"].y = y
      fp["#{i}"].opacity -= 16 if r[i] >= 64
      fp["#{i}"].tone.all -= 16 if fp["#{i}"].tone.all > 0
      fp["#{i}"].angle += @targetIsPlayer ? - 1 : 1
    end
    @scene.wait(1,true)
  end
  #-----------------------------------------------------------------------------
  #  dispose sprites
  pbDisposeSpriteHash(fp)
  #-----------------------------------------------------------------------------
end
