#===============================================================================
#  Common Animation: AURAFLARE
#===============================================================================
EliteBattle.defineCommonAnimation(:AURAFLARE) do
  #-----------------------------------------------------------------------------
  #  hides UI elements
  @scene.pbHideAllDataboxes
  fp = {}
  #-----------------------------------------------------------------------------
  #  vector config
  back = !@battle.opposes?(@targetIndex)
  @vector.set(@scene.getRealVector(@targetIndex, back))
  @scene.wait(16, true)
  factor = @targetSprite.zoom_x
  #-----------------------------------------------------------------------------
  # particle initialization
  for i in 0...16
    fp["c#{i}"] = Sprite.new(@viewport)
    fp["c#{i}"].z = @targetSprite.z + 10
    fp["c#{i}"].bitmap = pbBitmap(sprintf("Graphics/EBDX/Animations/Moves/ebMega%03d",rand(4)+1))
    fp["c#{i}"].center!
    fp["c#{i}"].opacity = 0
  end
  #-----------------------------------------------------------------------------
  # ray initialization
  rangle = []
  cx, cy = @targetSprite.getCenter(true)
  for i in 0...8; rangle.push((360/8)*i +  15); end
  for j in 0...8
    fp["r#{j}"] = Sprite.new(@viewport)
    fp["r#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebMega005")
    fp["r#{j}"].ox = 0
    fp["r#{j}"].color = Color.new(186, 86, 102)
    fp["r#{j}"].oy = fp["r#{j}"].bitmap.height/2
    fp["r#{j}"].opacity = 0
    fp["r#{j}"].zoom_x = 0
    fp["r#{j}"].zoom_y = 0
    fp["r#{j}"].x = cx
    fp["r#{j}"].y = cy
    a = rand(rangle.length)
    fp["r#{j}"].angle = rangle[a]
    fp["r#{j}"].z = @targetSprite.z + 2
    rangle.delete_at(a)
  end
  #-----------------------------------------------------------------------------
  # ripple initialization
  for j in 0...3
    fp["v#{j}"] = Sprite.new(@viewport)
    fp["v#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebMega006")
    fp["v#{j}"].center!
    fp["v#{j}"].x = cx
    fp["v#{j}"].y = cy
    fp["v#{j}"].opacity = 0
    fp["v#{j}"].zoom_x = 2*factor
    fp["v#{j}"].zoom_y = 2*factor
    fp["v#{j}"].z = @targetSprite.z + 1
    fp["v#{j}"].toggle = 1
    fp["v#{j}"].color = Color.new(186,86,102)
  end
  #-----------------------------------------------------------------------------
  @sprites["battlebg"].defocus
  pbSEPlay("Anim/Harden",120)
  @targetSprite.color = Color.new(221,68,92,0)
  for i in 0...104
    @targetSprite.color.alpha += 8
    @targetSprite.anim = true
    # particle animation
    for j in 0...16
      next if j > (i/8)
      if fp["c#{j}"].opacity == 0 && i < 72
        fp["c#{j}"].opacity = 255
        x, y = randCircleCord(96*factor)
        fp["c#{j}"].x = cx - 96*factor + x
        fp["c#{j}"].y = cy - 96*factor + y
      end
      x2 = cx; y2 = cy
      x0 = fp["c#{j}"].x; y0 = fp["c#{j}"].y
      fp["c#{j}"].x += (x2 - x0)*0.1
      fp["c#{j}"].y += (y2 - y0)*0.1
      fp["c#{j}"].opacity -= 16
    end
    #-----------------------------------------------------------------------------
    # ray animation
    for j in 0...8
      if fp["r#{j}"].opacity == 0 && j <= (i%128)/16 && i < 96
        fp["r#{j}"].opacity = 255
        fp["r#{j}"].zoom_x = 0
        fp["r#{j}"].zoom_y = 0
      end
      fp["r#{j}"].opacity -= 4
      fp["r#{j}"].zoom_x += 0.05
      fp["r#{j}"].zoom_y += 0.05
    end
    #-----------------------------------------------------------------------------
    pbSEPlay("Anim/Twine", 80) if i == 40
    pbSEPlay("Anim/Refresh") if i == 56
    #-----------------------------------------------------------------------------
    if i >= 24
      # ripple animation
      for j in 0...3
        next if j > (i-32)/12
        next if fp["v#{j}"].zoom_x <= 0
        fp["v#{j}"].opacity += 16*fp["v#{j}"].toggle
        fp["v#{j}"].zoom_x -= 0.05
        fp["v#{j}"].zoom_y -= 0.05
        fp["v#{j}"].toggle = -0.2 if fp["v#{j}"].zoom_x < 1.6*factor
      end
    end
    @scene.wait(1,true)
  end
  @viewport.color = Color.white
  @targetSprite.color.alpha = 0
  pbDisposeSpriteHash(fp)
  @sprites["battlebg"].focus
  #-----------------------------------------------------------------------------
  # animate impact
  fp["impact"] = Sprite.new(@viewport)
  fp["impact"].bitmap = pbBitmap("Graphics/EBDX/Pictures/impact")
  fp["impact"].center!(true)
  fp["impact"].z = 999
  fp["impact"].opacity = 0
  @targetSprite.charged = true# unless !@hitNum.nil?
  playBattlerCry(@battlers[@targetIndex])
  k = -2
  for i in 0...24
    fp["impact"].opacity += 64
    fp["impact"].angle += 180 if i%4 == 0
    fp["impact"].mirror = !fp["impact"].mirror if i%4 == 2
    k *= -1 if i%4 == 0
    @viewport.color.alpha -= 16 if i > 1
    @scene.moveEntireScene(0,k,true,true)
    @scene.wait(1,false)
  end
  for i in 0...16
    fp["impact"].opacity -= 64
    fp["impact"].angle += 180 if i%4 == 0
    fp["impact"].mirror = !fp["impact"].mirror if i%4 == 2
    @scene.wait
  end
  #-----------------------------------------------------------------------------
  #  return to original and dispose particles
  @scene.pbShowAllDataboxes
  fp["impact"].dispose
  #-----------------------------------------------------------------------------
end
