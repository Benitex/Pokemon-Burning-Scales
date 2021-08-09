#-------------------------------------------------------------------------------
#  Hydro Pump
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:HYDROPUMP) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  # set up animation
  fp = {}
  rndx = [[],[]]; rndy = [[],[]]
  dx = [[],[]]; dy = [[],[]]
  fp["bg"] = ScrollingSprite.new(@viewport)
  fp["bg"].speed = 64
  fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/eb536_bg")
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  string = ["eb536_2","eb536"]
  rop = [255,80,40,135]
  px = []
  py = []
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
  for m in 0...2
    for i in 0...20
      fp["#{i}#{m}"] = Sprite.new(@viewport)
      bmp = pbBitmap("Graphics/EBDX/Animations/Moves/"+string[m])
      fp["#{i}#{m}"].bitmap = Bitmap.new(bmp.width,bmp.height)
      fp["#{i}#{m}"].bitmap.blt(0,0,bmp,Rect.new(0,0,bmp.width,bmp.height),(m==0 ? rop[rand(4)] : 255))
      fp["#{i}#{m}"].ox = fp["#{i}#{m}"].bitmap.width/2
      fp["#{i}#{m}"].oy = fp["#{i}#{m}"].bitmap.height/2
      fp["#{i}#{m}"].opacity = 0
      fp["#{i}#{m}"].z = @targetIsPlayer ? 29 : 19
      fp["#{i}#{m}"].zoom_x = [0.5,1][m]
      fp["#{i}#{m}"].zoom_y = [0.5,1][m]
      rndx[m].push(rand(16))
      rndy[m].push(rand(16))
      dx[m].push(0)
      dy[m].push(0)
    end
  end
  k = 1
  @sprites["battlebg"].defocus
  # start animation
  for i in 0...20
    if i < 10
      fp["bg"].opacity += 25.5
    else
      fp["bg"].color.alpha -= 25.5
    end
    fp["bg"].update
    @scene.wait(1,true)
  end
  pbSEPlay("Anim/Water3",80)
  @scene.wait(4,true)
  for i in 0...96
    pbSEPlay("Anim/Water5") if i == 12
    ax, ay = @userSprite.getAnchor
    cx, cy = @targetSprite.getCenter(true)
    for m in 0...2
      for j in 0...20
        if fp["#{j}#{m}"].opacity == 0
          dx[m][j] = ax - 8*@userSprite.zoom_x*0.5 + rndx[m][j]*@userSprite.zoom_x*0.5
          dy[m][j] = ay - 8*@userSprite.zoom_y*0.5 + rndy[m][j]*@userSprite.zoom_y*0.5
          fp["#{j}#{m}"].x = dx[m][j]
          fp["#{j}#{m}"].y = dy[m][j]
        end
        next if j>(i/4)
        x2 = cx - 8*@targetSprite.zoom_x*0.5 + rndx[m][j]*@targetSprite.zoom_x*0.5
        y2 = cy - 8*@targetSprite.zoom_y*0.5 + rndy[m][j]*@targetSprite.zoom_y*0.5
        x0 = dx[m][j]
        y0 = dy[m][j]
        fp["#{j}#{m}"].x += (x2 - x0)*0.04*(m+1)
        fp["#{j}#{m}"].y += (y2 - y0)*0.04*(m+1)
        fp["#{j}#{m}"].zoom_x += (1 - fp["#{j}#{m}"].zoom_x)*0.1
        fp["#{j}#{m}"].zoom_y += (1 - fp["#{j}#{m}"].zoom_y)*0.1
        fp["#{j}#{m}"].opacity += 51
        fp["#{j}#{m}"].angle += 8*(m+1)*j
        nextx = fp["#{j}#{m}"].x# + (x2 - x0)*0.1
        nexty = fp["#{j}#{m}"].y# + (y2 - y0)*0.1
        if !@targetIsPlayer
          fp["#{j}#{m}"].visible = false if nextx > cx && nexty < cy
        else
          fp["#{j}#{m}"].visible = false if nextx < cx && nexty > cy
        end
      end
    end
    for l in 0...12
      next if i < 12
      next if l>((i-12)/4)
      if fp["p#{l}"].opacity <= 0
        fp["p#{l}"].opacity = 255 - rand(101)
        fp["p#{l}"].x = cx
        fp["p#{l}"].y = cy
        r = rand(2)
        fp["p#{l}"].zoom_x = r==0 ? 1 : 0.5
        fp["p#{l}"].zoom_y = r==0 ? 1 : 0.5
        x, y = randCircleCord(128)
        px[l] = cx - 128*@targetSprite.zoom_x + x*@targetSprite.zoom_x
        py[l] = cy - 128*@targetSprite.zoom_y + y*@targetSprite.zoom_y
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
    @vector.set(vector) if i == 64
    @vector.inc = 0.1 if i == 64
    fp["bg"].update
    if i < 64
      k*=-1 if i%4==0
      @scene.moveEntireScene(0,k*4,true,true)
    end
    pbSEPlay("Anim/Water1") if i == 84
    if i.between?(85,90)
      @targetSprite.zoom_x += 0.01
      @targetSprite.zoom_y -= 0.04
    elsif i.between?(91,96)
      @targetSprite.zoom_x -= 0.01
      @targetSprite.zoom_y += 0.04
    end
    @scene.wait(1,(i>=64 && i<85))
  end
  for j in 0...20; for m in 0...2; fp["#{j}#{m}"].visible = false; end; end
  for l in 0...12; fp["p#{l}"].visible = false; end
  for i in 0...20
    @targetSprite.still
    if i < 10
      fp["bg"].color.alpha += 25.5
    else
      fp["bg"].opacity -= 25.5
    end
    fp["bg"].update
    @scene.wait
  end
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
