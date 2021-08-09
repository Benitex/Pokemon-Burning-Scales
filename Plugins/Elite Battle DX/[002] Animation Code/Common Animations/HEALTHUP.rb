#===============================================================================
#  Common Animation: HEALTHUP
#===============================================================================
EliteBattle.defineCommonAnimation(:HEALTHUP) do
  #-----------------------------------------------------------------------------
  #  configure variables
  @scene.wait(16, true) if @scene.afterAnim
  pt = {}; rndx = []; rndy = []; tone = []; timer = []; speed = []
  endy = @targetSprite.y - @targetSprite.bitmap.height*(@targetIsPlayer ? 1.5 : 1)
  #-----------------------------------------------------------------------------
  #  set up sprites
  for i in 0...32
    s = rand(2)
    y = rand(64) + 1
    c = [Color.new(92,202,81),Color.new(68,215,105),Color.new(192,235,180)][rand(3)]
    pt["#{i}"] = Sprite.new(@viewport)
    pt["#{i}"].bitmap = Bitmap.new(14,14)
    pt["#{i}"].bitmap.bmp_circle(c)
    pt["#{i}"].ox = pt["#{i}"].bitmap.width/2
    pt["#{i}"].oy = pt["#{i}"].bitmap.height/2
    width = (96/@targetSprite.bitmap.width*0.5).to_i
    pt["#{i}"].x = @targetSprite.x + rand((64 + width)*@targetSprite.zoom_x - 32)*(s==0 ? 1 : -1)
    pt["#{i}"].y = @targetSprite.y
    pt["#{i}"].z = @targetSprite.z + (rand(2)==0 ? 1 : -1)
    r = rand(4)
    pt["#{i}"].zoom_x = @targetSprite.zoom_x*[1,0.9,0.75,0.5][r]*0.84
    pt["#{i}"].zoom_y = @targetSprite.zoom_y*[1,0.9,0.75,0.5][r]*0.84
    pt["#{i}"].opacity = 0
    pt["#{i}"].tone = Tone.new(128,128,128)
    tone.push(128)
    rndx.push(pt["#{i}"].x + rand(32)*(s==0 ? 1 : -1))
    rndy.push(endy - y*@targetSprite.zoom_y)
    timer.push(0)
    speed.push((rand(50)+1)*0.002)
  end
  for j in 0...12
    pt["s#{j}"] = Sprite.new(@viewport)
    pt["s#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebHealing")
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
  #  play animation
  pbSEPlay("Anim/Recovery",80)
  for i in 0...64
    for j in 0...32
      next if j > (i)
      timer[j] += 1
      pt["#{j}"].x += (rndx[j] - pt["#{j}"].x)*speed[j]
      pt["#{j}"].y -= (pt["#{j}"].y - rndy[j])*speed[j]
      tone[j] -= 8 if tone[j] > 0
      pt["#{j}"].tone.all = tone[j]
      pt["#{j}"].angle += 4
      if timer[j] > 8
        pt["#{j}"].opacity -= 8
        pt["#{j}"].zoom_x -= 0.02*@targetSprite.zoom_x if pt["#{j}"].zoom_x > 0
        pt["#{j}"].zoom_y -= 0.02*@targetSprite.zoom_y if pt["#{j}"].zoom_y > 0
      else
        pt["#{j}"].opacity += 25 if pt["#{j}"].opacity < 200
        pt["#{j}"].zoom_x += 0.025*@targetSprite.zoom_x
        pt["#{j}"].zoom_y += 0.025*@targetSprite.zoom_y
      end
    end
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
