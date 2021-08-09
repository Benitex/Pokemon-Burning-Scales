#-------------------------------------------------------------------------------
#  Water Gun
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:WATERGUN) do
  # set up animation
  fp = {}; rndx = []; rndy = []; dx = []; dy = []; px = []; py = []; rangl = []
  for i in 0...12
    fp["p#{i}"] = Sprite.new(@viewport)
    fp["p#{i}"].bitmap = Bitmap.new(16,16)
    fp["p#{i}"].bitmap.bmp_circle
    fp["p#{i}"].ox = 8
    fp["p#{i}"].oy = 8
    fp["p#{i}"].opacity = 0
    fp["p#{i}"].z = @targetSprite.z
    px.push(0)
    py.push(0)
  end
  for k in 0...64
    i = 63-k
    fp["#{i}"] = Sprite.new(@viewport)
    bmp = pbBitmap("Graphics/EBDX/Animations/Moves/eb551")
    fp["#{i}"].bitmap = Bitmap.new(bmp.width,bmp.height)
    fp["#{i}"].bitmap.blt(0,0,bmp,Rect.new(0,0,bmp.width,bmp.height))
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 19
    fp["#{i}"].color = Color.new(248,248,248,200)
    rndx.push(rand(16)); rndy.push(rand(16)); rangl.push(rand(2))
    dx.push(0); dy.push(0)
  end
  for i in 0...64
    pbSEPlay("EBDX/Anim/water1",60) if i%4==0 && i < 48
    ax, ay = @userSprite.getAnchor
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...64
      if fp["#{j}"].opacity == 0
        dx[j] = ax - 8*@userSprite.zoom_x*0.5 + rndx[j]*@userSprite.zoom_x*0.5
        dy[j] = ay - 8*@userSprite.zoom_y*0.5 + rndy[j]*@userSprite.zoom_y*0.5
        fp["#{j}"].x = dx[j]
        fp["#{j}"].y = dy[j]
        fp["#{j}"].zoom_x = 0.8#(!@targetIsPlayer ? 1.2 : 0.8)#@userSprite.zoom_x
        fp["#{j}"].zoom_y = 0.8#(!@targetIsPlayer ? 1.2 : 0.8)#@userSprite.zoom_y
        fp["#{j}"].opacity = 128 if !(j>i*2)
      end
      next if j>(i*2)
      x2 = cx - 8*@targetSprite.zoom_x*0.5 + rndx[j]*@targetSprite.zoom_x*0.5
      y2 = cy - 8*@targetSprite.zoom_y*0.5 + rndy[j]*@targetSprite.zoom_y*0.5
      x0 = dx[j]
      y0 = dy[j]
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].zoom_x += 0.04#(factor - fp["#{j}"].zoom_x)*0.2
      fp["#{j}"].zoom_y += 0.04#(factor - fp["#{j}"].zoom_y)*0.2
      fp["#{j}"].opacity += 32
      fp["#{j}"].angle += 8*(rangl[j]==0 ? -1 : 1)
      fp["#{j}"].angle = -Math.atan(1.0*(y2-y0)/(x2-x0))*180/Math::PI + (rand(4)==0 ? 180 : 0)
      fp["#{j}"].color.alpha -= 5 if fp["#{j}"].color.alpha > 0
      nextx = fp["#{j}"].x# + (x2 - x0)*0.1
      nexty = fp["#{j}"].y# + (y2 - y0)*0.1
      if !@targetIsPlayer
        fp["#{j}"].visible = false if nextx > cx && nexty < cy
      else
        fp["#{j}"].visible = false if nextx < cx && nexty > cy
      end
    end
    for l in 0...12
      next if i < 2
      next if l>((i-6)/4)
      if fp["p#{l}"].opacity <= 0 && i < 48
        fp["p#{l}"].opacity = 255 - rand(101)
        fp["p#{l}"].x = cx
        fp["p#{l}"].y = cy
        r = rand(2)
        fp["p#{l}"].zoom_x = r==0 ? 1 : 0.5
        fp["p#{l}"].zoom_y = r==0 ? 1 : 0.5
        x, y = randCircleCord(96)
        px[l] = cx - 48*@targetSprite.zoom_x + x*@targetSprite.zoom_x
        py[l] = cy - 48*@targetSprite.zoom_y + y*@targetSprite.zoom_y
      end
      x2 = px[l]
      y2 = py[l]
      x0 = fp["p#{l}"].x
      y0 = fp["p#{l}"].y
      fp["p#{l}"].x += (x2 - x0)*0.05
      fp["p#{l}"].y += (y2 - y0)*0.05
      fp["p#{l}"].opacity -= 8
    end
    @targetSprite.still if i >= 64
    @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer)) if i == 16
    @vector.inc = 0.1 if i == 64
    @scene.wait(1,true)
  end
  for j in 0...48; fp["#{j}"].visible = false; end
  for l in 0...12; fp["p#{l}"].visible = false; end
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
