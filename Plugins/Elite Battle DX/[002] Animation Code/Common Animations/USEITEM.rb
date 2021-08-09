#===============================================================================
#  Common Animation: HEALTHUP
#===============================================================================
EliteBattle.defineCommonAnimation(:USEITEM) do
  #-----------------------------------------------------------------------------
  #  configure variables
  @scene.wait(16, true) if @scene.afterAnim
  pt = {}; rndx = []; rndy = []; tone = []; timer = []; speed = []
  endy = @targetSprite.y - @targetSprite.bitmap.height*(@targetIsPlayer ? 1.5 : 1)
  #-----------------------------------------------------------------------------
  #  set up sprites
  for j in 0...3
    pt["c#{j}"] = Sprite.new(@viewport)
    pt["c#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebItem1")
    pt["c#{j}"].center!
    pt["c#{j}"].x, pt["c#{j}"].y = @targetSprite.getCenter(true)
    pt["c#{j}"].zx = @targetSprite.zoom_x * 2; pt["c#{j}"].zoom_x = pt["c#{j}"].zx
    pt["c#{j}"].zy = @targetSprite.zoom_y * 2; pt["c#{j}"].zoom_y = pt["c#{j}"].zy
    pt["c#{j}"].z = @targetSprite.z + 1
    pt["c#{j}"].opacity = 0
  end
  #-----------------------------------------------------------------------------
  #  play circle animation
  pbSEPlay("EBDX/Anim/shine1",80)
  for i in 0...48
    for j in 0...3
      next if (i/6) < j
      pt["c#{j}"].zoom_x -= pt["c#{j}"].zx/32
      pt["c#{j}"].zoom_y -= pt["c#{j}"].zy/32
      pt["c#{j}"].opacity += 16*(pt["c#{j}"].zoom_x > pt["c#{j}"].zx/2 ? 1 : -1)
    end
    @scene.wait(1, true)
  end
  #-----------------------------------------------------------------------------
  #  initialize shiny particles
  for j in 0...12
    pt["s#{j}"] = Sprite.new(@viewport)
    pt["s#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebShiny3")
    pt["s#{j}"].ox = pt["s#{j}"].bitmap.width/2
    pt["s#{j}"].oy = pt["s#{j}"].bitmap.height/2
    pt["s#{j}"].opacity = 0
    z = [1,0.75,1.25,0.5][rand(4)]*@targetSprite.zoom_x
    pt["s#{j}"].zoom_x = z
    pt["s#{j}"].zoom_y = z
    cx, cy = @targetSprite.getCenter(true)
    pt["s#{j}"].x = cx - 32*@targetSprite.zoom_x + rand(64)*@targetSprite.zoom_x
    pt["s#{j}"].y = cy - 32*@targetSprite.zoom_x + rand(64)*@targetSprite.zoom_x
    pt["s#{j}"].opacity = 0
    pt["s#{j}"].z = @targetIsPlayer ? 29 : 19
  end
  #-----------------------------------------------------------------------------
  #  play shiny particle animation
  pbSEPlay("Anim/Recovery",80)
  for i in 0...32
    for k in 0...12
      next if k > i
      pt["s#{k}"].opacity += 51
      pt["s#{k}"].zoom_x -= pt["s#{k}"].zoom_x*0.25 if pt["s#{k}"].opacity >= 255 && pt["s#{k}"].zoom_x > 0
      pt["s#{k}"].zoom_y -= pt["s#{k}"].zoom_y*0.25 if pt["s#{k}"].opacity >= 255 && pt["s#{k}"].zoom_y > 0
    end
    @scene.wait(1, true)
  end
  #-----------------------------------------------------------------------------
  #  dispose sprites
  pbDisposeSpriteHash(pt)
  #-----------------------------------------------------------------------------
end
