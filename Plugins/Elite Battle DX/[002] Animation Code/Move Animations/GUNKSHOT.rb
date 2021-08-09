#-------------------------------------------------------------------------------
#  Gunk Shot
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:GUNKSHOT) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  fp = {}
  rndx = []; prndx = []
  rndy = []; prndy = []
  rangl = []; dx = []; dy = []
  @targetSprite.color = Color.new(181,42,165,0)
  fp["bg"] = ScrollingSprite.new(@viewport)
  fp["bg"].speed = 64
  fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/eb427_bg")
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  for i in 0...128
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb427_1")
    z = 1 - rand(61)/100.0
    fp["#{i}"].zoom_x = z
    fp["#{i}"].zoom_y = z
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].visible = false
    fp["#{i}"].toggle = rand(2)==0 ? 1 : -1
    fp["#{i}"].param = 1 + rand(4)
    fp["#{i}"].z = @targetSprite.z + 1
    rndx.push(rand(192)); prndx.push(rand(64))
    rndy.push(rand(192)); prndy.push(rand(64))
    rangl.push(rand(9))
    dx.push(0)
    dy.push(0)
  end
  px = []
  py = []
  for i in 0...12
    fp["p#{i}"] = Sprite.new(@viewport)
    fp["p#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb427_2")
    fp["p#{i}"].ox = fp["p#{i}"].bitmap.width/2
    fp["p#{i}"].oy = fp["p#{i}"].bitmap.height/2
    fp["p#{i}"].opacity = 0
    fp["p#{i}"].z = @targetSprite.z
    px.push(0)
    py.push(0)
  end
  @vector.set(vector2)
  @sprites["battlebg"].defocus
  16.times { @targetSprite.anim = true; @scene.wait(1,true) }
  for i in 0...20
    if i < 10
      fp["bg"].opacity += 25.5
    else
      fp["bg"].color.alpha -= 25.5
    end
    fp["bg"].update
    @targetSprite.anim = true
    @scene.wait(1,true)
  end
  # shoot first
  for i in 0...96
    @vector.set(vector) if i == 16 # change vector
    ax, ay = @userSprite.getAnchor
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...128
      next if j>(i*2)
      if !fp["#{j}"].visible
        dx[j] = ax - 32*@userSprite.zoom_x*0.5 + prndx[j]*@userSprite.zoom_x*0.5
        dy[j] = ay - 32*@userSprite.zoom_y*0.5 + prndy[j]*@userSprite.zoom_y*0.5
        fp["#{j}"].x = dx[j]
        fp["#{j}"].y = dy[j]
        fp["#{j}"].visible = true
      end
      x0 = ax - 32*@userSprite.zoom_x*0.5 + prndx[j]*@userSprite.zoom_x*0.5
      y0 = ay - 32*@userSprite.zoom_y*0.5 + prndy[j]*@userSprite.zoom_y*0.5
      x2 = cx - 96*@targetSprite.zoom_x*0.5 + rndx[j]*@targetSprite.zoom_x*0.5
      y2 = cy - 96*@targetSprite.zoom_y*0.5 + rndy[j]*@targetSprite.zoom_y*0.5
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].angle += fp["#{j}"].toggle*(2 + fp["#{j}"].param)
      fp["#{j}"].tone.gray += 8
      fp["#{j}"].opacity -= 16
    end
    for l in 0...12
      next if i < 16
      next if l>((i-16)/4)
      if fp["p#{l}"].opacity <= 0 && i < 64
        fp["p#{l}"].opacity = 255 - rand(101)
        fp["p#{l}"].x = cx
        fp["p#{l}"].y = cy
        c = [Color.new(0,0,0,0),Color.new(165,91,239),Color.new(119,58,189)]
        fp["p#{l}"].color = c[rand(3)]
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
    if i > 7
      @targetSprite.color.alpha += 8 if @targetSprite.color.alpha < 128
      @targetSprite.still
    end
    fp["bg"].update
    @targetSprite.anim = true
    @scene.wait(1,true)
  end
  for i in 0...32
    if i < 12
    elsif i < 22
      fp["bg"].color.alpha += 25.5
    elsif i < 32
      fp["bg"].opacity -= 25.5
    end
    fp["bg"].update
    @targetSprite.still
    @targetSprite.color.alpha -= 8
    @targetSprite.anim = true
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  pbDisposeSpriteHash(fp)
  @vector.reset
end
