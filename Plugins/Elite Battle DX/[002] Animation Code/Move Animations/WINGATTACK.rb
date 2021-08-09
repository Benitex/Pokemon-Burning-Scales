#-------------------------------------------------------------------------------
#  Wing Attack
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:WINGATTACK) do
  pbSEPlay("EBDX/Anim/flying1",80)
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @scene.wait(16,true)
  factor = @targetSprite.zoom_x
  # set up animation
  fp = {}; rndx = []; rndy = []
  cx, cy = @targetSprite.getCenter(true)
  for i in 0...12
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb303_2")
    fp["#{i}"].ox = 10
    fp["#{i}"].oy = 10
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 51
    r = rand(3)
    fp["#{i}"].zoom_x = (factor-0.5)*(r==0 ? 1 : 0.5)
    fp["#{i}"].zoom_y = (factor-0.5)*(r==0 ? 1 : 0.5)
    fp["#{i}"].tone = Tone.new(60,60,60)
    rndx.push(rand(128))
    rndy.push(rand(64))
  end
  wait = []
  for m in 0...8
    fp["w#{m}"] = Sprite.new(@viewport)
    fp["w#{m}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb164")
    fp["w#{m}"].ox = 20
    fp["w#{m}"].oy = 16
    fp["w#{m}"].opacity = 0
    fp["w#{m}"].z = 50
    fp["w#{m}"].angle = rand(360)
    fp["w#{m}"].zoom_x = factor - 0.5
    fp["w#{m}"].zoom_y = factor - 0.5
    fp["w#{m}"].x = cx - 32*factor + rand(64*factor)
    fp["w#{m}"].y = cy - 112*factor + rand(112*factor)
    wait.push(0)
  end
  pbSEPlay("EBDX/Anim/normal1",80)
  frame = Sprite.new(@viewport)
  frame.z = 51
  frame.bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb303")
  frame.src_rect.set(0,0,64,64)
  frame.ox = 32
  frame.oy = 32
  frame.zoom_x = 0.5*factor
  frame.zoom_y = 0.5*factor
  frame.x, frame.y = @targetSprite.getCenter(true)
  frame.opacity = 0
  frame.tone = Tone.new(255,255,255)
  frame.y -= 32*@targetSprite.zoom_y
  # start animation
  for i in 1..30
    if i.between?(1,5)
      @targetSprite.still
      @targetSprite.zoom_y-=0.05*factor
      @targetSprite.tone.all-=12.8
      frame.zoom_x += 0.1*factor
      frame.zoom_y += 0.1*factor
      frame.opacity += 51
    end
    frame.tone = Tone.new(0,0,0) if i == 6
    if i.between?(6,10)
      @targetSprite.still
      @targetSprite.zoom_y+=0.05*factor
      @targetSprite.tone.all+=12.8
      frame.angle += 2
    end
    frame.src_rect.x = 64 if i == 10
    if i >= 10
      frame.opacity -= 25.5
      frame.zoom_x += 0.1*factor
      frame.zoom_y += 0.1*factor
      frame.angle += 2
    end
    for m in 0...8
      next if m>(i/2)
      fp["w#{m}"].angle += 2
      fp["w#{m}"].opacity += 32*(wait[m] < 8 ? 1 : -0.25)
      wait[m] +=  1
    end
    for j in 0...12
      cx = frame.x; cy = frame.y
      if fp["#{j}"].opacity == 0 && fp["#{j}"].visible
        fp["#{j}"].x = cx
        fp["#{j}"].y = cy
      end
      x2 = cx - 64*@targetSprite.zoom_x + rndx[j]*@targetSprite.zoom_x
      y2 = cy - 64*@targetSprite.zoom_y + rndy[j]*@targetSprite.zoom_y
      x0 = fp["#{j}"].x
      y0 = fp["#{j}"].y
      fp["#{j}"].x += (x2 - x0)*0.2
      fp["#{j}"].y += (y2 - y0)*0.2
      fp["#{j}"].zoom_x += 0.01
      fp["#{j}"].zoom_y += 0.01
      if i < 20
        fp["#{j}"].tone.red -= 6; fp["#{j}"].tone.blue -= 6; fp["#{j}"].tone.green -= 6
      end
      if (x2 - x0)*0.2 < 1 && (y2 - y0)*0.2 < 1
        fp["#{j}"].opacity -= 51
      else
        fp["#{j}"].opacity += 51
      end
      fp["#{j}"].visible = false if fp["#{j}"].opacity <= 0
    end
    @scene.wait
  end
  frame.dispose
  pbDisposeSpriteHash(fp)
  @vector.reset if !@multiHit
end
