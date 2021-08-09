#===============================================================================
#  Common Animation: STATUP
#===============================================================================
EliteBattle.defineCommonAnimation(:STATUP) do
  #-----------------------------------------------------------------------------
  #  configure variables
  @scene.wait(16, true) if @scene.afterAnim
  pt = {}; rndx = []; rndy = []; tone = []; timer = []; speed = []
  endy = @targetSprite.y - @targetSprite.height*(@targetIsPlayer ? 1.5 : 1)
  #-----------------------------------------------------------------------------
  #  set up sprites
  for i in 0...64
    s = rand(2)
    y = rand(64) + 1
    c = [Color.new(238,83,17),Color.new(236,112,19),Color.new(242,134,36)][rand(3)]
    pt["#{i}"] = Sprite.new(@viewport)
    pt["#{i}"].bitmap = Bitmap.new(14,14)
    pt["#{i}"].bitmap.bmp_circle(c)
    pt["#{i}"].center!
    width = (96/@targetSprite.width*0.5).to_i
    pt["#{i}"].x = @targetSprite.x + rand((64 + width)*@targetSprite.zoom_x - 16)*(s==0 ? 1 : -1)
    pt["#{i}"].y = @targetSprite.y
    pt["#{i}"].z = @targetSprite.z + (rand(2)==0 ? 1 : -1)
    r = rand(4)
    pt["#{i}"].zoom_x = @targetSprite.zoom_x*[1,0.9,0.95,0.85][r]*0.84
    pt["#{i}"].zoom_y = @targetSprite.zoom_y*[1,0.9,0.95,0.85][r]*0.84
    pt["#{i}"].opacity = 0
    pt["#{i}"].tone = Tone.new(128,128,128)
    tone.push(128)
    rndx.push(pt["#{i}"].x + rand(32)*(s==0 ? 1 : -1))
    rndy.push(endy - y*@targetSprite.zoom_y)
    timer.push(0)
    speed.push((rand(50)+1)*0.002)
  end
  #-----------------------------------------------------------------------------
  #  play animation
  pbSEPlay("Anim/increase")
  for i in 0...64
    for j in 0...64
      next if j > (i*2)
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
    @scene.wait(1, true)
  end
  #-----------------------------------------------------------------------------
  #  dispose sprites
  pbDisposeSpriteHash(pt)
  #-----------------------------------------------------------------------------
end
