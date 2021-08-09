#-------------------------------------------------------------------------------
#  Iron Head
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:IRONHEAD) do
  factor = @targetSprite.zoom_x
  # set up animation
  fp = {}; rndx = []; rndy = []
  pbSEPlay("EBDX/Anim/iron2",80,80)
  pbSEPlay("EBDX/Anim/ground1",80)
  for i in 0...2
    4.times do
      @userSprite.x += 8*(@targetIsPlayer ? -1 : 1)*(i==0 ? 1 : -1)
      @userSprite.x -= 2*(@targetIsPlayer ? -1 : 1)*(i==0 ? 1 : -1)
      @scene.wait
    end
  end
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @scene.wait(16,true)
  for i in 0...16
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb024")
    fp["#{i}"].ox = 6
    fp["#{i}"].oy = 6
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 50
    r = rand(3)
    fp["#{i}"].zoom_x = (@targetSprite.zoom_x)*(r==0 ? 1 : 0.5)
    fp["#{i}"].zoom_y = (@targetSprite.zoom_y)*(r==0 ? 1 : 0.5)
    fp["#{i}"].tone = Tone.new(60,60,60)
    rndx.push(rand(128))
    rndy.push(rand(128))
  end
  factor = 1
  frame = Sprite.new(@viewport)
  frame.z = 50
  frame.bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb520")
  frame.src_rect.set(0,0,114,114)
  frame.ox = 57
  frame.oy = 57
  frame.zoom_x = 0.5*factor
  frame.zoom_y = 0.5*factor
  frame.x, frame.y = @targetSprite.getCenter(true)
  frame.opacity = 0
  frame.tone = Tone.new(255,255,255)
  # start animation
  for i in 1..30
    if i == 6
      pbSEPlay("EBDX/Anim/iron3",90)
      pbSEPlay("EBDX/Anim/iron1",80)
    end
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
    frame.src_rect.x = 114 if i == 10
    if i >= 10
      frame.opacity -= 25.5
      frame.zoom_x += 0.1*factor
      frame.zoom_y += 0.1*factor
      frame.angle += 2
    end
    for j in 0...16
      next if i < 6
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
      fp["#{j}"].angle += 2
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
